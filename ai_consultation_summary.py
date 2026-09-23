#!/usr/bin/env python3
"""
ai_consultation_summary.py
---------------------------------
Перетворює транскрипт консультації (Zoom / Google Meet / Ringostat)
на структуроване резюме, готове для запису в кастомні поля картки
клієнта в NetHunt CRM.

Архітектурні рішення:
- Виклик LLM ізольований у одну функцію (call_llm), щоб легко замінити
  провайдера (Anthropic / інший) без зміни бізнес-логіки.
- Суворий JSON Schema у промпті + walidacja на виході (validate_summary),
  бо результат іде напряму в CRM-поля і "галюцинація" формату там дорожча,
  ніж галюцинація тексту.
- --demo режим не бʼє в мережу: дозволяє тестувати pipeline і CI без
  API-ключа та без вартості токенів.
- Вивід одразу у форматі, сумісному з NetHunt CRM API (PATCH /records),
  щоб інтеграція через n8n/Make зводилась до одного HTTP-виклику.

Використання:
    export ANTHROPIC_API_KEY=sk-...
    python3 ai_consultation_summary.py --file transcript.txt
    python3 ai_consultation_summary.py --demo          # без API-ключа
"""

import argparse
import json
import os
import sys
from dataclasses import dataclass, asdict
from typing import Optional

MODEL = "claude-sonnet-4-6"

SYSTEM_PROMPT = """Ти — асистент відділу продажів консалтингової компанії.
Отримуєш транскрипт консультації менеджера другого рівня з клієнтом.
Поверни ЛИШЕ JSON (без пояснень, без markdown) такої форми:

{
  "potreba_klienta": "1-2 речення",
  "zaperechennya": ["коротке заперечення 1", "..."],
  "domovlenosti": "що саме узгодили наприкінці",
  "status_ugody": "one of: gotovy_kupyty | potribna_pauza | vidmova | potribna_druga_zustrich",
  "nastupny_krok": "конкретна дія і дедлайн, якщо є",
  "confidence": 0.0-1.0
}

Якщо якогось поля немає в транскрипті — став null, не вигадуй факти."""


@dataclass
class ConsultationSummary:
    potreba_klienta: Optional[str]
    zaperechennya: list
    domovlenosti: Optional[str]
    status_ugody: str
    nastupny_krok: Optional[str]
    confidence: float


ALLOWED_STATUSES = {
    "gotovy_kupyty",
    "potribna_pauza",
    "vidmova",
    "potribna_druga_zustrich",
}


def call_llm(transcript: str) -> str:
    """Реальний виклик Claude API. Винесено окремо, щоб замінити провайдера
    без зміни решти пайплайну."""
    try:
        import anthropic
    except ImportError:
        sys.exit(
            "Пакет 'anthropic' не встановлено. Виконайте:\n"
            "  pip install anthropic --break-system-packages"
        )

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        sys.exit(
            "Змінна ANTHROPIC_API_KEY не задана. Або задайте ключ, "
            "або запустіть скрипт з прапорцем --demo."
        )

    client = anthropic.Anthropic(api_key=api_key)
    response = client.messages.create(
        model=MODEL,
        max_tokens=600,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": transcript}],
    )
    return response.content[0].text


def call_llm_demo(transcript: str) -> str:
    """Офлайн-заглушка для тестування без мережі/ключа. Імітує відповідь
    моделі на основі найпростіших ключових слів — цього достатньо, щоб
    перевірити валідацію та формат виводу в CRM."""
    lowered = transcript.lower()
    status = "potribna_druga_zustrich"
    if "оплат" in lowered or "готовий купити" in lowered or "реквізити" in lowered:
        status = "gotovy_kupyty"
    elif "подума" in lowered or "не зараз" in lowered:
        status = "potribna_pauza"
    elif "не цікав" in lowered or "відмовля" in lowered:
        status = "vidmova"

    fake = {
        "potreba_klienta": "Потребує систематизації відділу продажів і скорочення циклу угоди.",
        "zaperechennya": ["висока ціна програми", "немає часу на 7-тижневе навчання"],
        "domovlenosti": "Клієнт погодився отримати комерційну пропозицію на пошту.",
        "status_ugody": status,
        "nastupny_krok": "Надіслати реквізити і зателефонувати через 2 дні.",
        "confidence": 0.72,
    }
    return json.dumps(fake, ensure_ascii=False)


def validate_summary(raw_json: str) -> ConsultationSummary:
    try:
        data = json.loads(raw_json)
    except json.JSONDecodeError as e:
        raise ValueError(f"Модель повернула не-JSON відповідь: {e}\nRAW: {raw_json[:300]}")

    status = data.get("status_ugody")
    if status not in ALLOWED_STATUSES:
        raise ValueError(f"Невідомий status_ugody='{status}', очікував один з {ALLOWED_STATUSES}")

    confidence = float(data.get("confidence", 0))
    if not (0.0 <= confidence <= 1.0):
        raise ValueError(f"confidence поза межами [0,1]: {confidence}")

    return ConsultationSummary(
        potreba_klienta=data.get("potreba_klienta"),
        zaperechennya=data.get("zaperechennya") or [],
        domovlenosti=data.get("domovlenosti"),
        status_ugody=status,
        nastupny_krok=data.get("nastupny_krok"),
        confidence=confidence,
    )


def to_nethunt_payload(summary: ConsultationSummary, record_id: str) -> dict:
    """Формат, готовий для PATCH-запиту в NetHunt CRM API (кастомні поля
    картки клієнта). Низька confidence позначається прапорцем "review",
    щоб такі картки потрапляли на ручну перевірку менеджером, а не
    змінювали CRM без контролю."""
    return {
        "recordId": record_id,
        "fields": {
            "AI_Potreba": summary.potreba_klienta,
            "AI_Zaperechennya": "; ".join(summary.zaperechennya),
            "AI_Domovlenosti": summary.domovlenosti,
            "AI_Status_Ugody": summary.status_ugody,
            "AI_Nastupny_Krok": summary.nastupny_krok,
            "AI_Confidence": summary.confidence,
            "AI_Needs_Review": summary.confidence < 0.6,
        },
    }


def main():
    parser = argparse.ArgumentParser(description="Транскрипт → резюме консультації для CRM")
    parser.add_argument("--file", help="Шлях до txt-файлу з транскриптом")
    parser.add_argument("--demo", action="store_true", help="Офлайн-режим без API-ключа")
    parser.add_argument("--record-id", default="DEMO-0001", help="ID картки клієнта в NetHunt")
    args = parser.parse_args()

    if args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            transcript = f.read()
    else:
        transcript = (
            "Клієнт: у нас хаос у продажах, менеджери забувають передзвонювати.\n"
            "Консультант: пропоную програму систематизації відділу продажів.\n"
            "Клієнт: ціна висока, і часу на 7 тижнів немає, треба подумати.\n"
            "Консультант: надішлю комерційну пропозицію, зідзвонимось через 2 дні.\n"
        )

    raw = call_llm_demo(transcript) if args.demo else call_llm(transcript)
    summary = validate_summary(raw)
    payload = to_nethunt_payload(summary, args.record_id)

    print(json.dumps(asdict(summary), ensure_ascii=False, indent=2))
    print("\n--- Payload для NetHunt CRM (PATCH /v1/zapier/records) ---")
    print(json.dumps(payload, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

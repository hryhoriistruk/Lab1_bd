DROP TABLE IF EXISTS SwoovoOrders;
DROP TABLE IF EXISTS SwoovoServices;
DROP TABLE IF EXISTS SwoovoProviders;
DROP TABLE IF EXISTS SwoovoClients;
DROP TABLE IF EXISTS SwoovoCategories;



CREATE TABLE SwoovoCategories
(
    CategoryID SERIAL PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL,
    Description VARCHAR(255)
);



CREATE TABLE SwoovoProviders
(
    ProviderID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Specialty VARCHAR(100),
    Rating NUMERIC(3,2),
    Phone VARCHAR(20),
    City VARCHAR(50),
    CHECK (Rating >= 0 AND Rating <= 5)
);



CREATE TABLE SwoovoClients
(
    ClientID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    City VARCHAR(50)
);



CREATE TABLE SwoovoServices
(
    ServiceID SERIAL PRIMARY KEY,
    CategoryID INT NOT NULL,
    ProviderID INT NOT NULL,
    ServiceName VARCHAR(150) NOT NULL,
    Description VARCHAR(255),
    Price NUMERIC(10,2) NOT NULL,
    DurationMinutes INT,
    IsActive BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (CategoryID)
        REFERENCES SwoovoCategories(CategoryID),
    FOREIGN KEY (ProviderID)
        REFERENCES SwoovoProviders(ProviderID),
    CHECK (Price >= 0),
    CHECK (DurationMinutes > 0)
);



CREATE TABLE SwoovoOrders
(
    OrderID SERIAL PRIMARY KEY,
    ClientID INT NOT NULL,
    ServiceID INT NOT NULL,
    OrderDate DATE NOT NULL DEFAULT CURRENT_DATE,
    Status VARCHAR(30) NOT NULL DEFAULT 'Нове',
    TotalPrice NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (ClientID)
        REFERENCES SwoovoClients(ClientID),
    FOREIGN KEY (ServiceID)
        REFERENCES SwoovoServices(ServiceID),
    CHECK (TotalPrice >= 0),
    CHECK
    (
        Status IN
        (
            'Нове',
            'В процесі',
            'Виконано',
            'Скасовано'
        )
    )
);




INSERT INTO SwoovoCategories
(CategoryName, Description)
VALUES

('Клінінг',
 'Прибирання квартир та офісів'),

('Репетиторство',
 'Навчання та підготовка до іспитів'),

('Ремонт техніки',
 'Ремонт комп''ютерів та побутової техніки'),

('Дизайн',
 'Графічний та веб-дизайн'),

('IT-послуги',
 'Розробка сайтів та програм'),

('Фотографія',
 'Фотосесії та зйомка заходів'),

('Юридичні послуги',
 'Консультації юриста'),

('Краса',
 'Макіяж та інші бьюті-послуги'),

('Перевезення',
 'Переїзди та доставка'),

('Психологія',
 'Консультації психолога');




INSERT INTO SwoovoProviders
(FullName, Specialty, Rating, Phone, City)
VALUES

('Олена Ковальчук',
 'Клінінг',
 4.80,
 '0671112233',
 'Львів'),

('Ігор Мельник',
 'Репетитор математики',
 4.90,
 '0672223344',
 'Київ'),

('Андрій Бойко',
 'Ремонт техніки',
 4.60,
 '0673334455',
 'Львів'),

('Марія Шевченко',
 'UI/UX дизайнер',
 5.00,
 '0674445566',
 'Київ'),

('Тарас Гриценко',
 'Веброзробник',
 4.70,
 '0675556677',
 'Львів'),

('Софія Ткаченко',
 'Фотограф',
 4.90,
 '0676667788',
 'Одеса'),

('Віктор Лисенко',
 'Юрист',
 4.50,
 '0677778899',
 'Київ'),

('Наталія Кравець',
 'Візажист',
 4.80,
 '0678889900',
 'Львів'),

('Дмитро Захарчук',
 'Водій-вантажник',
 4.40,
 '0679990011',
 'Львів'),

('Юлія Романенко',
 'Психолог',
 4.90,
 '0670001122',
 'Київ');




INSERT INTO SwoovoClients
(FullName, Phone, Email, City)
VALUES

('Артем Соколов',
 '0501112233',
 'artem@mail.com',
 'Львів'),

('Катерина Дудник',
 '0502223344',
 'kateryna@mail.com',
 'Київ'),

('Максим Іваненко',
 '0503334455',
 'maksym@mail.com',
 'Одеса'),

('Вікторія Петренко',
 '0504445566',
 'viktoria@mail.com',
 'Харків'),

('Богдан Савчук',
 '0505556677',
 'bogdan@mail.com',
 'Львів'),

('Ірина Гончар',
 '0506667788',
 'iryna@mail.com',
 'Дніпро'),

('Роман Кузьменко',
 '0507778899',
 'roman@mail.com',
 'Львів'),

('Олеся Мороз',
 '0508889900',
 'olesia@mail.com',
 'Івано-Франківськ'),

('Владислав Пилипенко',
 '0509990011',
 'vlad@mail.com',
 'Київ'),

('Анна Ковтун',
 '0500001122',
 'anna@mail.com',
 'Луцьк');




INSERT INTO SwoovoServices
(
    CategoryID,
    ProviderID,
    ServiceName,
    Description,
    Price,
    DurationMinutes
)
VALUES



(1,1,
 'Генеральне прибирання квартири',
 'Повне прибирання квартири',
 900,180),

(1,1,
 'Прибирання офісу',
 'Підтримуюче прибирання офісу',
 500,90),

(1,1,
 'Миття вікон',
 'Миття вікон та скляних поверхонь',
 600,120),


/* РЕПЕТИТОРСТВО */

(2,2,
 'Підготовка до НМТ',
 'Підготовка до іспиту з математики',
 400,60),

(2,2,
 'Математика 5-9 клас',
 'Індивідуальні заняття',
 350,60),

(2,2,
 'Алгебра',
 'Допомога зі шкільною програмою',
 300,45),




(3,3,
 'Ремонт пральної машини',
 'Діагностика та ремонт',
 750,120),

(3,3,
 'Ремонт ноутбука',
 'Чистка та заміна деталей',
 850,90),

(3,3,
 'Ремонт холодильника',
 'Діагностика та ремонт',
 900,120),




(4,4,
 'Дизайн логотипу',
 'Створення логотипу',
 1500,240),

(4,4,
 'UI/UX дизайн',
 'Дизайн мобільного застосунку',
 2500,480),

(4,4,
 'Дизайн банера',
 'Створення рекламного банера',
 700,120),




(5,5,
 'Розробка сайту',
 'Створення сайту під ключ',
 5000,1200),

(5,5,
 'Лендінг',
 'Односторінковий сайт',
 3000,600),

(5,5,
 'Підтримка сайту',
 'Технічна підтримка',
 2000,300),




(6,6,
 'Фотосесія в студії',
 'Портретна фотосесія',
 1200,90),

(6,6,
 'Весільна фотозйомка',
 'Зйомка повного дня',
 8000,600),

(6,6,
 'Фотозйомка заходу',
 'Зйомка корпоративу або події',
 3000,240),




(7,7,
 'Консультація юриста',
 'Онлайн юридична консультація',
 600,45),

(7,7,
 'Перевірка договору',
 'Юридична перевірка договору',
 1000,90),




(8,8,
 'Макіяж',
 'Професійний макіяж',
 800,90),

(8,8,
 'Вечірній макіяж',
 'Макіяж для заходу',
 1000,120),

(8,8,
 'Весільний макіяж',
 'Макіяж нареченої',
 1500,150),




(9,9,
 'Переїзд по місту',
 'Водій та вантажник',
 1200,180),

(9,9,
 'Перевезення меблів',
 'Перевезення меблів по місту',
 900,120),




(10,10,
 'Консультація психолога',
 'Індивідуальна онлайн сесія',
 650,60),

(10,10,
 'Сімейна консультація',
 'Консультація для пари',
 900,90);




INSERT INTO SwoovoOrders
(
    ClientID,
    ServiceID,
    OrderDate,
    Status,
    TotalPrice
)
VALUES

(1,1,'2025-06-01','Виконано',900),

(2,4,'2025-06-03','Виконано',400),

(3,7,'2025-06-05','В процесі',750),

(4,10,'2025-06-07','Виконано',1500),

(5,13,'2025-06-10','Скасовано',5000),

(6,16,'2025-06-12','Виконано',1200),

(7,19,'2025-06-15','Виконано',600),

(8,22,'2025-06-18','В процесі',800),

(9,25,'2025-06-20','Виконано',1200),

(10,27,'2025-06-22','Виконано',650);




SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'Swoovo%';




SELECT *
FROM SwoovoCategories;

SELECT *
FROM SwoovoProviders;

SELECT *
FROM SwoovoClients;

SELECT *
FROM SwoovoServices;

SELECT *
FROM SwoovoOrders;



IF OBJECT_ID('dbo.SwoovoOrders', 'U') IS NOT NULL
    DROP TABLE dbo.SwoovoOrders;

IF OBJECT_ID('dbo.SwoovoServices', 'U') IS NOT NULL
    DROP TABLE dbo.SwoovoServices;

IF OBJECT_ID('dbo.SwoovoProviders', 'U') IS NOT NULL
    DROP TABLE dbo.SwoovoProviders;

IF OBJECT_ID('dbo.SwoovoClients', 'U') IS NOT NULL
    DROP TABLE dbo.SwoovoClients;

IF OBJECT_ID('dbo.SwoovoCategories', 'U') IS NOT NULL
    DROP TABLE dbo.SwoovoCategories;

GO




CREATE TABLE dbo.SwoovoCategories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,

    CategoryName NVARCHAR(100) NOT NULL,

    Description NVARCHAR(255)
);

GO



CREATE TABLE dbo.SwoovoProviders
(
    ProviderID INT IDENTITY(1,1) PRIMARY KEY,

    FullName NVARCHAR(100) NOT NULL,

    Specialty NVARCHAR(100),

    Rating DECIMAL(3,2),

    Phone NVARCHAR(20),

    City NVARCHAR(50),

    CHECK (Rating >= 0 AND Rating <= 5)
);

GO




CREATE TABLE dbo.SwoovoClients
(
    ClientID INT IDENTITY(1,1) PRIMARY KEY,

    FullName NVARCHAR(100) NOT NULL,

    Phone NVARCHAR(20),

    Email NVARCHAR(100),

    City NVARCHAR(50)
);

GO




CREATE TABLE dbo.SwoovoServices
(
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,

    CategoryID INT NOT NULL,

    ProviderID INT NOT NULL,

    ServiceName NVARCHAR(150) NOT NULL,

    Description NVARCHAR(255),

    Price DECIMAL(10,2) NOT NULL,

    DurationMinutes INT,

    IsActive BIT NOT NULL DEFAULT 1,

    FOREIGN KEY (CategoryID)
        REFERENCES dbo.SwoovoCategories(CategoryID),

    FOREIGN KEY (ProviderID)
        REFERENCES dbo.SwoovoProviders(ProviderID),

    CHECK (Price >= 0),

    CHECK (DurationMinutes > 0)
);

GO




CREATE TABLE dbo.SwoovoOrders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,

    ClientID INT NOT NULL,

    ServiceID INT NOT NULL,

    OrderDate DATE NOT NULL DEFAULT GETDATE(),

    Status NVARCHAR(30) NOT NULL DEFAULT N'Нове',

    TotalPrice DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (ClientID)
        REFERENCES dbo.SwoovoClients(ClientID),

    FOREIGN KEY (ServiceID)
        REFERENCES dbo.SwoovoServices(ServiceID),

    CHECK (TotalPrice >= 0),

    CHECK
    (
        Status IN
        (
            N'Нове',
            N'В процесі',
            N'Виконано',
            N'Скасовано'
        )
    )
);

GO




INSERT INTO dbo.SwoovoCategories
(CategoryName, Description)
VALUES

(N'Клінінг',
 N'Прибирання квартир та офісів'),

(N'Репетиторство',
 N'Навчання та підготовка до іспитів'),

(N'Ремонт техніки',
 N'Ремонт комп''ютерів та побутової техніки'),

(N'Дизайн',
 N'Графічний та веб-дизайн'),

(N'IT-послуги',
 N'Розробка сайтів та програм'),

(N'Фотографія',
 N'Фотосесії та зйомка заходів'),

(N'Юридичні послуги',
 N'Консультації юриста'),

(N'Краса',
 N'Макіяж та інші бьюті-послуги'),

(N'Перевезення',
 N'Переїзди та доставка'),

(N'Психологія',
 N'Консультації психолога');

GO




INSERT INTO dbo.SwoovoProviders
(FullName, Specialty, Rating, Phone, City)
VALUES

(N'Олена Ковальчук',
 N'Клінінг',
 4.80,
 N'0671112233',
 N'Львів'),

(N'Ігор Мельник',
 N'Репетитор математики',
 4.90,
 N'0672223344',
 N'Київ'),

(N'Андрій Бойко',
 N'Ремонт техніки',
 4.60,
 N'0673334455',
 N'Львів'),

(N'Марія Шевченко',
 N'UI/UX дизайнер',
 5.00,
 N'0674445566',
 N'Київ'),

(N'Тарас Гриценко',
 N'Веброзробник',
 4.70,
 N'0675556677',
 N'Львів'),

(N'Софія Ткаченко',
 N'Фотограф',
 4.90,
 N'0676667788',
 N'Одеса'),

(N'Віктор Лисенко',
 N'Юрист',
 4.50,
 N'0677778899',
 N'Київ'),

(N'Наталія Кравець',
 N'Візажист',
 4.80,
 N'0678889900',
 N'Львів'),

(N'Дмитро Захарчук',
 N'Водій-вантажник',
 4.40,
 N'0679990011',
 N'Львів'),

(N'Юлія Романенко',
 N'Психолог',
 4.90,
 N'0670001122',
 N'Київ');

GO




INSERT INTO dbo.SwoovoClients
(FullName, Phone, Email, City)
VALUES

(N'Артем Соколов',
 N'0501112233',
 N'artem@mail.com',
 N'Львів'),

(N'Катерина Дудник',
 N'0502223344',
 N'kateryna@mail.com',
 N'Київ'),

(N'Максим Іваненко',
 N'0503334455',
 N'maksym@mail.com',
 N'Одеса'),

(N'Вікторія Петренко',
 N'0504445566',
 N'viktoria@mail.com',
 N'Харків'),

(N'Богдан Савчук',
 N'0505556677',
 N'bogdan@mail.com',
 N'Львів'),

(N'Ірина Гончар',
 N'0506667788',
 N'iryna@mail.com',
 N'Дніпро'),

(N'Роман Кузьменко',
 N'0507778899',
 N'roman@mail.com',
 N'Львів'),

(N'Олеся Мороз',
 N'0508889900',
 N'olesia@mail.com',
 N'Івано-Франківськ'),

(N'Владислав Пилипенко',
 N'0509990011',
 N'vlad@mail.com',
 N'Київ'),

(N'Анна Ковтун',
 N'0500001122',
 N'anna@mail.com',
 N'Луцьк');

GO




INSERT INTO dbo.SwoovoServices
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
 N'Генеральне прибирання квартири',
 N'Повне прибирання квартири',
 900,180),

(1,1,
 N'Прибирання офісу',
 N'Підтримуюче прибирання офісу',
 500,90),

(1,1,
 N'Миття вікон',
 N'Миття вікон та скляних поверхонь',
 600,120),


/* РЕПЕТИТОРСТВО */

(2,2,
 N'Підготовка до НМТ',
 N'Підготовка до іспиту з математики',
 400,60),

(2,2,
 N'Математика 5-9 клас',
 N'Індивідуальні заняття',
 350,60),

(2,2,
 N'Алгебра',
 N'Допомога зі шкільною програмою',
 300,45),




(3,3,
 N'Ремонт пральної машини',
 N'Діагностика та ремонт',
 750,120),

(3,3,
 N'Ремонт ноутбука',
 N'Чистка та заміна деталей',
 850,90),

(3,3,
 N'Ремонт холодильника',
 N'Діагностика та ремонт',
 900,120),




(4,4,
 N'Дизайн логотипу',
 N'Створення логотипу',
 1500,240),

(4,4,
 N'UI/UX дизайн',
 N'Дизайн мобільного застосунку',
 2500,480),

(4,4,
 N'Дизайн банера',
 N'Створення рекламного банера',
 700,120),




(5,5,
 N'Розробка сайту',
 N'Створення сайту під ключ',
 5000,1200),

(5,5,
 N'Лендінг',
 N'Односторінковий сайт',
 3000,600),

(5,5,
 N'Підтримка сайту',
 N'Технічна підтримка',
 2000,300),




(6,6,
 N'Фотосесія в студії',
 N'Портретна фотосесія',
 1200,90),

(6,6,
 N'Весільна фотозйомка',
 N'Зйомка повного дня',
 8000,600),

(6,6,
 N'Фотозйомка заходу',
 N'Зйомка корпоративу або події',
 3000,240),




(7,7,
 N'Консультація юриста',
 N'Онлайн юридична консультація',
 600,45),

(7,7,
 N'Перевірка договору',
 N'Юридична перевірка договору',
 1000,90),




(8,8,
 N'Макіяж',
 N'Професійний макіяж',
 800,90),

(8,8,
 N'Вечірній макіяж',
 N'Макіяж для заходу',
 1000,120),

(8,8,
 N'Весільний макіяж',
 N'Макіяж нареченої',
 1500,150),




(9,9,
 N'Переїзд по місту',
 N'Водій та вантажник',
 1200,180),

(9,9,
 N'Перевезення меблів',
 N'Перевезення меблів по місту',
 900,120),




(10,10,
 N'Консультація психолога',
 N'Індивідуальна онлайн сесія',
 650,60),

(10,10,
 N'Сімейна консультація',
 N'Консультація для пари',
 900,90);

GO




INSERT INTO dbo.SwoovoOrders
(
    ClientID,
    ServiceID,
    OrderDate,
    Status,
    TotalPrice
)
VALUES

(1,1,'2025-06-01',N'Виконано',900),

(2,4,'2025-06-03',N'Виконано',400),

(3,7,'2025-06-05',N'В процесі',750),

(4,10,'2025-06-07',N'Виконано',1500),

(5,13,'2025-06-10',N'Скасовано',5000),

(6,16,'2025-06-12',N'Виконано',1200),

(7,19,'2025-06-15',N'Виконано',600),

(8,22,'2025-06-18',N'В процесі',800),

(9,25,'2025-06-20',N'Виконано',1200),

(10,27,'2025-06-22',N'Виконано',650);

GO




SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME LIKE 'Swoovo%';

GO




SELECT *
FROM dbo.SwoovoCategories;

GO




SELECT *
FROM dbo.SwoovoProviders;

GO




SELECT *
FROM dbo.SwoovoClients;

GO




SELECT *
FROM dbo.SwoovoServices;

GO




SELECT *
FROM dbo.SwoovoOrders;

GO

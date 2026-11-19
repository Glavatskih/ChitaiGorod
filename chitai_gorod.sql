--
-- PostgreSQL database dump
--

\restrict zZGG6nCWLGCHhihIsotODohla8TViX1yHameKeLa8oLSXTG5pG0xR3glxNUFrgi

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_user (
    id integer NOT NULL,
    last_name character varying(100) NOT NULL,
    first_name character varying(100) NOT NULL,
    patronymic character varying(100),
    login character varying(100) NOT NULL,
    password character varying(100) NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE public.app_user OWNER TO postgres;

--
-- Name: app_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_user_id_seq OWNER TO postgres;

--
-- Name: app_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_user_id_seq OWNED BY public.app_user.id;


--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.category_id_seq OWNER TO postgres;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.category_id_seq OWNED BY public.category.id;


--
-- Name: customer_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_order (
    id integer NOT NULL,
    order_date date NOT NULL,
    delivery_date date NOT NULL,
    pickup_point_id integer NOT NULL,
    user_id integer NOT NULL,
    receive_code integer NOT NULL,
    status_id integer NOT NULL,
    CONSTRAINT ck_order_dates CHECK ((delivery_date >= order_date)),
    CONSTRAINT customer_order_receive_code_check CHECK ((receive_code > 0))
);


ALTER TABLE public.customer_order OWNER TO postgres;

--
-- Name: customer_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_order_id_seq OWNER TO postgres;

--
-- Name: customer_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_order_id_seq OWNED BY public.customer_order.id;


--
-- Name: manufacturer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manufacturer (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.manufacturer OWNER TO postgres;

--
-- Name: manufacturer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.manufacturer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.manufacturer_id_seq OWNER TO postgres;

--
-- Name: manufacturer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.manufacturer_id_seq OWNED BY public.manufacturer.id;


--
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT order_item_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- Name: order_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_status (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.order_status OWNER TO postgres;

--
-- Name: order_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_status_id_seq OWNER TO postgres;

--
-- Name: order_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_status_id_seq OWNED BY public.order_status.id;


--
-- Name: pickup_point; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pickup_point (
    id integer NOT NULL,
    address character varying(255) NOT NULL
);


ALTER TABLE public.pickup_point OWNER TO postgres;

--
-- Name: pickup_point_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pickup_point_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pickup_point_id_seq OWNER TO postgres;

--
-- Name: pickup_point_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pickup_point_id_seq OWNED BY public.pickup_point.id;


--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id integer NOT NULL,
    article character varying(20) NOT NULL,
    name character varying(300) NOT NULL,
    unit_id integer NOT NULL,
    price numeric(10,2) NOT NULL,
    supplier_id integer NOT NULL,
    manufacturer_id integer NOT NULL,
    category_id integer NOT NULL,
    discount numeric(5,2) DEFAULT 0 NOT NULL,
    stock_quantity integer DEFAULT 0 NOT NULL,
    description text,
    photo_path character varying(255),
    CONSTRAINT product_discount_check CHECK (((discount >= (0)::numeric) AND (discount <= (100)::numeric))),
    CONSTRAINT product_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT product_stock_quantity_check CHECK ((stock_quantity >= 0))
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_id_seq OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;


--
-- Name: supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.supplier OWNER TO postgres;

--
-- Name: supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplier_id_seq OWNER TO postgres;

--
-- Name: supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_id_seq OWNED BY public.supplier.id;


--
-- Name: unit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unit (
    id integer NOT NULL,
    name character varying(20) NOT NULL
);


ALTER TABLE public.unit OWNER TO postgres;

--
-- Name: unit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.unit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.unit_id_seq OWNER TO postgres;

--
-- Name: unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.unit_id_seq OWNED BY public.unit.id;


--
-- Name: user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_role (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.user_role OWNER TO postgres;

--
-- Name: user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_role_id_seq OWNER TO postgres;

--
-- Name: user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_role_id_seq OWNED BY public.user_role.id;


--
-- Name: app_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user ALTER COLUMN id SET DEFAULT nextval('public.app_user_id_seq'::regclass);


--
-- Name: category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.category_id_seq'::regclass);


--
-- Name: customer_order id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_order ALTER COLUMN id SET DEFAULT nextval('public.customer_order_id_seq'::regclass);


--
-- Name: manufacturer id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturer ALTER COLUMN id SET DEFAULT nextval('public.manufacturer_id_seq'::regclass);


--
-- Name: order_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_status ALTER COLUMN id SET DEFAULT nextval('public.order_status_id_seq'::regclass);


--
-- Name: pickup_point id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pickup_point ALTER COLUMN id SET DEFAULT nextval('public.pickup_point_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- Name: supplier id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier ALTER COLUMN id SET DEFAULT nextval('public.supplier_id_seq'::regclass);


--
-- Name: unit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit ALTER COLUMN id SET DEFAULT nextval('public.unit_id_seq'::regclass);


--
-- Name: user_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role ALTER COLUMN id SET DEFAULT nextval('public.user_role_id_seq'::regclass);


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_user (id, last_name, first_name, patronymic, login, password, role_id) FROM stdin;
1	Никифорова	Анна	Семеновна	94d5ous@gmail.com	uzWC67	1
2	Стелина	Евгения	Петровна	uth4iz@mail.com	2L6KZG	1
3	Михайлюк	Анна	Вячеславовна	5d4zbu@tutanota.com	rwVDh9	1
4	Ситдикова	Елена	Анатольевна	ptec8ym@yahoo.com	LdNyos	2
5	Ворсин	Петр	Евгеньевич	1qz4kw@mail.com	gynQMT	2
6	Старикова	Елена	Павловна	4np6se@mail.com	AtnDjr	2
7	Никифорова	Весения	Николаевна	yzls62@outlook.com	JlFRCZ	3
8	Сазонов	Руслан	Германович	1diph5e@tutanota.com	8ntwUp	3
9	Одинцов	Серафим	Артёмович	tjde7c@yahoo.com	YOyhfR	3
10	Степанов	Михаил	Артёмович	wpmrc3do@tutanota.com	RSbvHv	3
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category (id, name) FROM stdin;
1	Учебник для вузов
2	Учебное пособие
3	Хрестоматия
4	Художественная литература
\.


--
-- Data for Name: customer_order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_order (id, order_date, delivery_date, pickup_point_id, user_id, receive_code, status_id) FROM stdin;
1	2024-02-27	2024-04-20	1	10	901	1
2	2023-09-28	2024-04-21	11	7	902	1
3	2024-03-21	2024-04-22	2	8	903	1
4	2024-02-20	2024-04-23	11	9	904	1
5	2024-03-17	2024-04-24	2	10	905	1
6	2024-03-01	2024-04-25	15	7	906	1
7	2024-02-29	2024-04-26	3	8	907	1
8	2024-03-31	2024-04-27	19	9	908	2
9	2024-04-02	2024-04-28	5	10	909	2
10	2024-04-03	2024-04-29	19	10	910	2
\.


--
-- Data for Name: manufacturer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.manufacturer (id, name) FROM stdin;
1	Амрита-Русь
2	Аспект Пресс
3	ВКН
4	Время
5	Златоуст
6	Лениздат
7	Неолит
8	Прогресс книга
9	Т8 Издательские технологии
10	Яуза
\.


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_item (order_id, product_id, quantity) FROM stdin;
1	1	2
1	2	2
2	2	1
2	1	1
3	3	10
3	4	10
4	5	5
4	3	4
5	6	20
5	7	20
6	1	2
6	2	2
7	8	3
7	9	3
8	5	1
8	6	1
9	10	5
9	9	1
10	9	5
10	10	5
\.


--
-- Data for Name: order_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_status (id, name) FROM stdin;
1	Завершен
2	Новый
\.


--
-- Data for Name: pickup_point; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pickup_point (id, address) FROM stdin;
1	420151, г. Лесной, ул. Вишневая, 32
2	125061, г. Лесной, ул. Подгорная, 8
3	630370, г. Лесной, ул. Шоссейная, 24
4	400562, г. Лесной, ул. Зеленая, 32
5	614510, г. Лесной, ул. Маяковского, 47
6	410542, г. Лесной, ул. Светлая, 46
7	620839, г. Лесной, ул. Цветочная, 8
8	443890, г. Лесной, ул. Коммунистическая, 1
9	603379, г. Лесной, ул. Спортивная, 46
10	603721, г. Лесной, ул. Гоголя, 41
11	410172, г. Лесной, ул. Северная, 13
12	614611, г. Лесной, ул. Молодежная, 50
13	454311, г. Лесной, ул. Новая, 19
14	660007, г. Лесной, ул. Октябрьская, 19
15	603036, г. Лесной, ул. Садовая, 4
16	394060, г. Лесной, ул. Фрунзе, 43
17	410661, г. Лесной, ул. Школьная, 50
18	625590, г. Лесной, ул. Коммунистическая, 20
19	625683, г. Лесной, ул. 8 Марта
20	450983, г. Лесной, ул. Комсомольская, 26
21	394782, г. Лесной, ул. Чехова, 3
22	603002, г. Лесной, ул. Дзержинского, 28
23	450558, г. Лесной, ул. Набережная, 30
24	344288, г. Лесной, ул. Чехова, 1
25	614164, г. Лесной, ул. Степная, 30
26	394242, г. Лесной, ул. Коммунистическая, 43
27	660540, г. Лесной, ул. Солнечная, 25
28	125837, г. Лесной, ул. Шоссейная, 40
29	125703, г. Лесной, ул. Партизанская, 49
30	625283, г. Лесной, ул. Победы, 46
31	614753, г. Лесной, ул. Полевая, 35
32	426030, г. Лесной, ул. Маяковского, 44
33	450375, г. Лесной, ул. Клубная, 44
34	625560, г. Лесной, ул. Некрасова, 12
35	630201, г. Лесной, ул. Комсомольская, 17
36	190949, г. Лесной, ул. Мичурина, 26
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (id, article, name, unit_id, price, supplier_id, manufacturer_id, category_id, discount, stock_quantity, description, photo_path) FROM stdin;
1	A112T4	Прокляты и убиты	1	585.00	2	10	4	25.00	6	Роман-эпопею "Прокляты и убиты" Виктора Астафьева по праву считают одним из самых сильных и пронзительных произведений отечественной военной прозы.	Images/1.jpg
2	G843H5	Тайны и загадки отца Брауна	1	193.00	3	10	4	30.00	9	Гилберт Кит Честертон — признанный классик английской литературы, один из самых ярких писателей первой половины XX века. Классикой стали его романы и многочисленные эссе, однако любовь массового читателя принесли ему рассказы об отце Брауне, тихом, застенчивом священнике, мастерски раскрывающем наиболее запутанные загадки и преступления.	Images/2.jpg
3	D325D4	Девайс	1	1599.00	9	9	4	5.00	12	Молодой фрилансер Захар Скаро устраивается на очередную подработку. Задача, казалось бы, тривиальная: тестирование нового устройства. Вот только вопрос в том, тестированием какой реальности занимается этот новый Девайс?	Images/3.jpg
4	S432T5	Необыкновенное обыкновенное чудо. Школьные истории	1	549.00	11	9	4	15.00	15	\N	Images/4.jpg
5	F325D4	Чук и Гек	1	209.00	1	9	4	18.00	3	В книгу вошли повести и рассказы Аркадия Петровича Гайдара: "Чук и Гек", "Горячий камень" и "Сказка о военной тайне, о Мальчише-Кибальчише и его твердом слове"	Images/5.jpg
6	G432G6	Информационная безопасность. Национальные стандарты Российской Федерации. 3-е издание. Учебное пособие	1	3899.00	16	8	1	22.00	3	В учебном пособии рассмотрено более 300 действующих открытых документов национальной системы стандартизации Российской Федерации, включая международные и межгосударственные стандарты в области информационной безопасности по состоянию на начало 2023 года.	Images/6.jpg
7	H542F5	Linux. Командная строка. Лучшие практики	1	1799.00	6	8	1	4.00	5	Перейдите на новый уровень работы в Linux! Если вы системный администратор, разработчик программного обеспечения, SRE-инженер или пользователь Linux, книга поможет вам работать быстрее, элегантнее и эффективнее.	Images/7.jpg
8	C346F5	Квантовые миры и возникновение пространства-времени	1	1349.00	15	8	1	5.00	4	Шон Кэрролл — физик-теоретик и один из самых известных в мире популяризаторов науки — заставляет нас по-новому взглянуть на физику. Столкновение с главной загадкой квантовой механики полностью поменяет наши представления о пространстве и времени.	Images/8.jpg
9	F256G6	Вселенная. Происхождение жизни, смысл нашего существования и огромный космос	1	1799.00	15	8	1	6.00	2	Знаменитый физик Шон Кэрролл в свойственной ему увлекательной манере объясняет принципы, которые лежат в основах научных революций от Дарвина до Эйнштейна, и показывает как невероятные научные открытия последнего столетия изменили наш мир.	\N
10	J532V5	Пушкин. Бродский. Империя и судьба. В 2-х томах (комплект из 2-х книг)	1	529.00	17	4	3	8.00	6	Первая книга двухтомника «Пушкин. Бродский. Империя и судьба» пронизана пушкинской темой. Пушкин — «певец империи и свободы» — присутствует даже там, где он впрямую не упоминается, ибо его судьба, как и судьба других героев книги, органично связана с трагедией великой империи.	Images/10.jpg
11	G643F4	Иосиф Бродский. Избранные эссе (комплект из 6-ти книг)	1	4925.00	8	6	3	2.00	24	Шесть сборников избранных эссе Иосифа Бродского (1940-1996), великого поэта, драматурга, мыслителя, лауреата Нобелевской премии по литературе (1987): «Будущее или далекое прошлое», «Верь своей боли», «Как читать книгу», «О русской литературе», «О тирании», «Путеводитель по переименованному городу». Все тексты представлены на английском языке и в переводе на русский и открывают автора не только как поэта, но как историка, критика, и глубокого и ироничного мыслителя.	Images/11.jpg
12	J326V5	Тысячелетие императорской керамики	1	2599.00	18	6	3	5.00	4	Фарфор стал величайшим символом китайской культуры. Это одно из выдающихся изобретений, внесших неоценимый вклад в мировую цивилизацию.	Images/12.jpg
13	J632F6	Вечные спутники: Портреты из всемирной литературы	1	1599.00	4	6	3	0.00	6	Книга "Вечные спутники" - это цикл критических очерков о культуре и великих литераторах, сопровождавших жизнь и творчество русского писателя, поэта, литературного критика и общественного деятеля Дмитрия Мережковского (1865–1941).	Images/13.jpg
14	G632H6	Формирование литературной репутации Н.Г.Чернышевского в ХIX-XXI веках	1	1349.00	5	7	3	2.00	8	Монография Д. А. Щербакова - новаторская. Поэтапно рассмотрены не только многочисленные суждения известных отечественных и зарубежных критиков, литературоведов, философов и политиков, различным образом характеризовавших Н. Г. Чернышевского в связи и вне связи со знаменитым романом "Что делать?	Images/14.jpg
15	M642E5	Теория искусства. Краткий путеводитель	1	879.00	12	7	3	3.00	2	\N	Images/15.jpg
16	G543F5	Религиозные верования с древнейших времен до наших дней	1	879.00	5	1	3	4.00	6	Настоящее издание представляет собой сборник переводов лекций по истории дохристианских и нехристианских религий, прочитанных в Лондоне в период с 1888 по 1891 гг. авторитетными исследователями данного раздела религиоведения.	Images/16.jpg
17	B653G6	Русский язык: Первые шаги. Часть 3. Учебное пособие	1	2699.00	10	5	2	8.00	9	Пособие является завершающей частью учебного комплекса. Третья часть содержит 10 уроков (21-30, последний-повторительный). Усвоение лексико-грамматического материала рассчитано примерно на 200-240 часов аудиторных занятий.	Images/17.jpg
18	J735J7	Синтетический образ индивидуального психического мира	1	1099.00	13	5	3	9.00	4	Психика подобна определенным объектам, это фиксируют сами люди в языке и искусстве. В данном исследовании рассматриваются в этом плане образы сосуда, воронки, дерева и крепости.	Images/18.jpg
19	H436H7	Английский язык в спорте: Учебное пособие	1	1999.00	7	2	2	2.00	0	Учебное пособие подготовлено для слушателей, изу чающих английский язык как язык специальности	Images/19.jpg
20	H475R5	Лексика и грамматика современного китайского языка (к тому II учебника «Новый практический курс китайского языка» под редакцией Лю Сюня): учебное пособие	1	608.00	14	3	2	25.00	12	Пособие выступает дополнением ко второму тому учебника «Новый практический курс китайского языка» (под редакцией Лю Сюня).	Images/20.jpg
21	test1	Тестовая книга	1	992.00	1	1	1	10.00	0	тест легкий такой	Images/187d9b1e2401409b8e23bf2ca1745d7e.jpg
\.


--
-- Data for Name: supplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier (id, name) FROM stdin;
1	Аркадий Гайдар
2	Виктор Астафьев
3	Гилберт Кит Честертон
4	Дмитрий Мережковский
5	Дмитрий Щербаков
6	Дэниел Джей Барретт
7	Екатерина Габарта, Ирина Игнатьева
8	Иосиф Бродский
9	Кирилл Каланджи
10	Любовь Беликова, Инна Ерофеева, Татьяна Шутова
11	Людмила Улицкая
12	Роджер Осборн, Дэн Стерджис
13	Сергей Моргачев
14	Татьяна Лопаткина, Софья Маннапова
15	Шон Кэрролл
16	Юрий Родичев
17	Яков Гордин
18	Янь Чуннянь
\.


--
-- Data for Name: unit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unit (id, name) FROM stdin;
1	шт.
\.


--
-- Data for Name: user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role (id, name) FROM stdin;
1	Администратор
2	Менеджер
3	Авторизированный клиент
\.


--
-- Name: app_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_user_id_seq', 10, true);


--
-- Name: category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.category_id_seq', 4, true);


--
-- Name: customer_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_order_id_seq', 11, true);


--
-- Name: manufacturer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.manufacturer_id_seq', 10, true);


--
-- Name: order_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_status_id_seq', 2, true);


--
-- Name: pickup_point_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pickup_point_id_seq', 36, true);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_id_seq', 21, true);


--
-- Name: supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_id_seq', 18, true);


--
-- Name: unit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unit_id_seq', 1, true);


--
-- Name: user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_role_id_seq', 3, true);


--
-- Name: app_user app_user_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_login_key UNIQUE (login);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: category category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_name_key UNIQUE (name);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: customer_order customer_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_pkey PRIMARY KEY (id);


--
-- Name: manufacturer manufacturer_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturer
    ADD CONSTRAINT manufacturer_name_key UNIQUE (name);


--
-- Name: manufacturer manufacturer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturer
    ADD CONSTRAINT manufacturer_pkey PRIMARY KEY (id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (order_id, product_id);


--
-- Name: order_status order_status_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_status
    ADD CONSTRAINT order_status_name_key UNIQUE (name);


--
-- Name: order_status order_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_status
    ADD CONSTRAINT order_status_pkey PRIMARY KEY (id);


--
-- Name: pickup_point pickup_point_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pickup_point
    ADD CONSTRAINT pickup_point_address_key UNIQUE (address);


--
-- Name: pickup_point pickup_point_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pickup_point
    ADD CONSTRAINT pickup_point_pkey PRIMARY KEY (id);


--
-- Name: product product_article_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_article_key UNIQUE (article);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: supplier supplier_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_name_key UNIQUE (name);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);


--
-- Name: unit unit_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit
    ADD CONSTRAINT unit_name_key UNIQUE (name);


--
-- Name: unit unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit
    ADD CONSTRAINT unit_pkey PRIMARY KEY (id);


--
-- Name: user_role user_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_name_key UNIQUE (name);


--
-- Name: user_role user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (id);


--
-- Name: ix_app_user_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_user_role ON public.app_user USING btree (role_id);


--
-- Name: ix_customer_order_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_customer_order_user ON public.customer_order USING btree (user_id);


--
-- Name: ix_order_item_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_order_item_product ON public.order_item USING btree (product_id);


--
-- Name: ix_product_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_product_category ON public.product USING btree (category_id);


--
-- Name: ix_product_manufacturer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_product_manufacturer ON public.product USING btree (manufacturer_id);


--
-- Name: ix_product_supplier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_product_supplier ON public.product USING btree (supplier_id);


--
-- Name: app_user app_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.user_role(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: customer_order customer_order_pickup_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_pickup_point_id_fkey FOREIGN KEY (pickup_point_id) REFERENCES public.pickup_point(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: customer_order customer_order_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.order_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: customer_order customer_order_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_item order_item_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.customer_order(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product product_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product product_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturer(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product product_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.supplier(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product product_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.unit(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict zZGG6nCWLGCHhihIsotODohla8TViX1yHameKeLa8oLSXTG5pG0xR3glxNUFrgi


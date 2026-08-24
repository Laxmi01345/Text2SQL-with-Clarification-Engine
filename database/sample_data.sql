SET datestyle = 'ISO, MDY';

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS translation CASCADE;

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(50),
    customer_state VARCHAR(50)
);

CREATE TABLE sellers (
    seller_id VARCHAR(100) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state VARCHAR(100)
);

CREATE TABLE products (
    product_id VARCHAR(100) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE translation (
    category_name VARCHAR,
    category_name_english VARCHAR
);

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(100),
    order_item_id INTEGER,
    product_id VARCHAR(100),
    seller_id VARCHAR(100),
    shipping_limit_date TIMESTAMP,
    price REAL,
    freight_value REAL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE reviews (
    review_id VARCHAR(100),
    order_id VARCHAR(100),
    review_score SMALLINT,
    review_comment_title VARCHAR(100),
    review_comment_message VARCHAR,
    review_creation_date DATE,
    review_answer_timestamp TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE payments (
    order_id VARCHAR(100),
    payment_sequential INTEGER,
    payment_type VARCHAR(100),
    payment_installments INTEGER,
    payment_value DOUBLE PRECISION,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- TRANSLATION DATA (71 rows - all categories)
INSERT INTO translation (category_name, category_name_english) VALUES
('beleza_saude', 'health_beauty'),
('informatica_acessorios', 'computers_accessories'),
('automotivo', 'auto'),
('cama_mesa_banho', 'bed_bath_table'),
('moveis_decoracao', 'furniture_decor'),
('esporte_lazer', 'sports_leisure'),
('perfumaria', 'perfumery'),
('utilidades_domesticas', 'housewares'),
('telefones', 'telephony'),
('relogios_presentes', 'watches_gifts'),
('alarmes_seguranca', 'security_accessories'),
('construcao_ferramentas_construcao', 'construction_tools_construction'),
('jardinagem', 'garden_tools'),
('cozinha_comida_bebida', 'kitchen_dining_laundry_garden_furniture'),
('brinquedos', 'toys'),
('telefonia_fixa', 'fixed_telephony'),
('bolsas_acessorios', 'luggage_accessories'),
('casa_construcao', 'home_construction'),
('climatizacao', 'air_conditioning'),
('fraldas_higiene', 'diapers_hygiene'),
('marketplace', 'marketplace'),
('fashion_bolsas_carteras', 'fashion_bags_accessories'),
('livros_interesse_geral', 'books_general_interest'),
('moveis_escritorio', 'office_furniture'),
('casa_inteligente', 'home_appliances_2'),
('eletrodomesticos_2', 'home_appliances_2'),
('fashion_underwear_e_moda_praia', 'fashion_underwear_beach'),
('artigos_festas', 'party_supplies'),
('bebidas', 'drinks'),
('construcao_ferramentas_jardim', 'garden_tools'),
('eletroportateis', 'small_appliances'),
('fashion_esportiva', 'fashion_sport'),
('audio', 'audio'),
('eletrodomesticos', 'home_appliances'),
('artigos_natal', 'christmas_supplies'),
('livros_tecnicos', 'books_technical'),
('malas_acessorios', 'luggage_accessories'),
('fashion_masculina', 'fashion_male'),
('cine_foto', 'cine_photo'),
('fashion_feminina', 'fashion_womens'),
('moveis_sala', 'furniture_living_room'),
('construcao_ferramentas_ferramentas', 'construction_tools_tools'),
('sinalizacao_e_seguranca', 'signaling_and_security'),
('moveis_cozinha', 'furniture_kitchen'),
('protecao_seguranca', 'security'),
('panelas', 'kitchen_dining_laundry_garden_furniture'),
('moveis_quarto', 'furniture_bedroom'),
('artigos_mesa', 'kitchen_dining_laundry_garden_furniture'),
('fashion_calcados', 'fashion_shoes'),
('eletro_6', 'electronics'),
('construcao_ferramentas_iluminacao', 'construction_tools_lighting'),
('agro_industria_comercio', 'agro_industry_and_commerce'),
('pet_shop', 'pet_shop'),
('industria_comercio', 'industry_commerce_and_business'),
('branded_fashion', 'fashion'),
('outros', 'other'),
('pc_gamer', 'pc_gamer'),
('fraldas_higiene', 'diapers_hygiene'),
('casa_construcao', 'home_construction'),
('livros_importados', 'imported_books'),
('musica', 'music'),
('moveis_colchao_estofado', 'furniture_mattress_and_upholstery');

-- SELLERS DATA (50 sellers)
INSERT INTO sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state) VALUES
('SELLER001', 13001, 'Campinas', 'SP'),
('SELLER002', 13002, 'Campinas', 'SP'),
('SELLER003', 20001, 'Rio de Janeiro', 'RJ'),
('SELLER004', 20002, 'Rio de Janeiro', 'RJ'),
('SELLER005', 30001, 'Belo Horizonte', 'MG'),
('SELLER006', 30002, 'Belo Horizonte', 'MG'),
('SELLER007', 40001, 'Salvador', 'BA'),
('SELLER008', 40002, 'Salvador', 'BA'),
('SELLER009', 50001, 'Recife', 'PE'),
('SELLER010', 50002, 'Recife', 'PE'),
('SELLER011', 60001, 'Fortaleza', 'CE'),
('SELLER012', 60002, 'Fortaleza', 'CE'),
('SELLER013', 70001, 'Brasilia', 'DF'),
('SELLER014', 70002, 'Brasilia', 'DF'),
('SELLER015', 80001, 'Curitiba', 'PR'),
('SELLER016', 80002, 'Curitiba', 'PR'),
('SELLER017', 90001, 'Porto Alegre', 'RS'),
('SELLER018', 90002, 'Porto Alegre', 'RS'),
('SELLER019', 10001, 'Sao Paulo', 'SP'),
('SELLER020', 10002, 'Sao Paulo', 'SP'),
('SELLER021', 11001, 'Guarulhos', 'SP'),
('SELLER022', 11002, 'Guarulhos', 'SP'),
('SELLER023', 12001, 'Sao Bernardo do Campo', 'SP'),
('SELLER024', 12002, 'Sao Bernardo do Campo', 'SP'),
('SELLER025', 13003, 'Campinas', 'SP'),
('SELLER026', 14001, 'Sao Jose do Rio Preto', 'SP'),
('SELLER027', 14002, 'Sao Jose do Rio Preto', 'SP'),
('SELLER028', 15001, 'Sorocaba', 'SP'),
('SELLER029', 15002, 'Sorocaba', 'SP'),
('SELLER030', 16001, 'Ribeirao Preto', 'SP'),
('SELLER031', 16002, 'Ribeirao Preto', 'SP'),
('SELLER032', 17001, 'Sao Jose dos Campos', 'SP'),
('SELLER033', 17002, 'Sao Jose dos Campos', 'SP'),
('SELLER034', 18001, 'Piracicaba', 'SP'),
('SELLER035', 18002, 'Piracicaba', 'SP'),
('SELLER036', 19001, 'Presidente Prudente', 'SP'),
('SELLER037', 19002, 'Presidente Prudente', 'SP'),
('SELLER038', 21001, 'Niteroi', 'RJ'),
('SELLER039', 21002, 'Niteroi', 'RJ'),
('SELLER040', 22001, 'Campos dos Goytacazes', 'RJ'),
('SELLER041', 22002, 'Campos dos Goytacazes', 'RJ'),
('SELLER042', 31001, 'Juiz de Fora', 'MG'),
('SELLER043', 31002, 'Juiz de Fora', 'MG'),
('SELLER044', 32001, 'Governador Valadares', 'MG'),
('SELLER045', 32002, 'Governador Valadares', 'MG'),
('SELLER046', 41001, 'Feira de Santana', 'BA'),
('SELLER047', 41002, 'Feira de Santana', 'BA'),
('SELLER048', 51001, 'Joao Pessoa', 'PB'),
('SELLER049', 51002, 'Joao Pessoa', 'PB'),
('SELLER050', 61001, 'Sao Luis', 'MA');

-- PRODUCTS DATA (200 products)
INSERT INTO products (product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm) VALUES
('PROD001', 'beleza_saude', 40, 200, 1, 500, 20, 10, 15),
('PROD002', 'beleza_saude', 35, 180, 2, 450, 18, 8, 12),
('PROD003', 'informatica_acessorios', 50, 300, 3, 800, 25, 15, 20),
('PROD004', 'informatica_acessorios', 45, 250, 2, 700, 22, 12, 18),
('PROD005', 'automotivo', 30, 150, 1, 1200, 30, 20, 25),
('PROD006', 'automotivo', 28, 140, 1, 1100, 28, 18, 22),
('PROD007', 'cama_mesa_banho', 60, 400, 4, 2000, 50, 30, 40),
('PROD008', 'cama_mesa_banho', 55, 350, 3, 1800, 45, 25, 35),
('PROD009', 'moveis_decoracao', 42, 220, 2, 3000, 60, 40, 50),
('PROD010', 'moveis_decoracao', 38, 200, 2, 2800, 55, 35, 45),
('PROD011', 'esporte_lazer', 48, 280, 3, 1500, 40, 20, 30),
('PROD012', 'esporte_lazer', 44, 260, 2, 1400, 38, 18, 28),
('PROD013', 'perfumaria', 25, 100, 1, 200, 15, 8, 10),
('PROD014', 'perfumaria', 22, 90, 1, 180, 12, 6, 8),
('PROD015', 'utilidades_domesticas', 35, 180, 2, 900, 25, 15, 20),
('PROD016', 'utilidades_domesticas', 32, 160, 2, 850, 22, 12, 18),
('PROD017', 'telefones', 40, 250, 3, 300, 20, 10, 15),
('PROD018', 'telefones', 38, 230, 2, 280, 18, 8, 12),
('PROD019', 'relogios_presentes', 30, 150, 2, 400, 20, 12, 15),
('PROD020', 'relogios_presentes', 28, 140, 1, 380, 18, 10, 12),
('PROD021', 'alarmes_seguranca', 35, 200, 2, 600, 25, 15, 20),
('PROD022', 'alarmes_seguranca', 32, 180, 2, 550, 22, 12, 18),
('PROD023', 'brinquedos', 45, 300, 4, 800, 30, 20, 25),
('PROD024', 'brinquedos', 42, 280, 3, 750, 28, 18, 22),
('PROD025', 'bolsas_acessorios', 38, 200, 2, 500, 25, 15, 20),
('PROD026', 'bolsas_acessorios', 35, 180, 2, 450, 22, 12, 18),
('PROD027', 'casa_construcao', 40, 250, 2, 2000, 40, 25, 30),
('PROD028', 'casa_construcao', 38, 230, 2, 1800, 35, 20, 25),
('PROD029', 'climatizacao', 45, 300, 3, 5000, 60, 40, 50),
('PROD030', 'climatizacao', 42, 280, 2, 4500, 55, 35, 45),
('PROD031', 'cozinha_comida_bebida', 50, 350, 3, 1200, 35, 20, 25),
('PROD032', 'cozinha_comida_bebida', 48, 330, 2, 1100, 32, 18, 22),
('PROD033', 'eletrodomesticos', 55, 400, 4, 3000, 50, 35, 40),
('PROD034', 'eletrodomesticos', 52, 380, 3, 2800, 45, 30, 35),
('PROD035', 'eletroportateis', 40, 250, 2, 1500, 30, 20, 25),
('PROD036', 'eletroportateis', 38, 230, 2, 1400, 28, 18, 22),
('PROD037', 'fashion_bolsas_carteras', 35, 200, 2, 600, 25, 15, 20),
('PROD038', 'fashion_bolsas_carteras', 32, 180, 1, 550, 22, 12, 18),
('PROD039', 'fashion_calcados', 42, 280, 3, 800, 30, 15, 20),
('PROD040', 'fashion_calcados', 40, 260, 2, 750, 28, 12, 18),
('PROD041', 'fashion_esportiva', 38, 250, 2, 500, 25, 12, 18),
('PROD042', 'fashion_esportiva', 35, 230, 2, 450, 22, 10, 15),
('PROD043', 'fashion_feminina', 45, 300, 3, 400, 22, 10, 15),
('PROD044', 'fashion_feminina', 42, 280, 2, 380, 20, 8, 12),
('PROD045', 'fashion_masculina', 42, 280, 2, 450, 22, 10, 15),
('PROD046', 'fashion_masculina', 40, 260, 2, 420, 20, 8, 12),
('PROD047', 'fashion_underwear_e_moda_praia', 38, 220, 2, 200, 18, 8, 12),
('PROD048', 'fashion_underwear_e_moda_praia', 35, 200, 1, 180, 15, 6, 10),
('PROD049', 'fraldas_higiene', 50, 350, 3, 2000, 40, 30, 35),
('PROD050', 'fraldas_higiene', 48, 330, 2, 1800, 35, 25, 30),
('PROD051', 'jardinagem', 40, 250, 2, 1200, 35, 25, 30),
('PROD052', 'jardinagem', 38, 230, 2, 1100, 32, 22, 28),
('PROD053', 'livros_interesse_geral', 30, 150, 1, 300, 20, 3, 15),
('PROD054', 'livros_interesse_geral', 28, 140, 1, 280, 18, 2, 12),
('PROD055', 'livros_tecnicos', 32, 180, 1, 350, 22, 3, 15),
('PROD056', 'livros_tecnicos', 30, 160, 1, 320, 20, 2, 12),
('PROD057', 'moveis_escritorio', 55, 400, 4, 8000, 80, 50, 60),
('PROD058', 'moveis_escritorio', 52, 380, 3, 7500, 75, 45, 55),
('PROD059', 'moveis_cozinha', 50, 350, 3, 6000, 70, 40, 50),
('PROD060', 'moveis_cozinha', 48, 330, 3, 5500, 65, 35, 45),
('PROD061', 'moveis_quarto', 52, 380, 3, 7000, 75, 50, 60),
('PROD062', 'moveis_quarto', 50, 360, 3, 6500, 70, 45, 55),
('PROD063', 'moveis_sala', 55, 400, 4, 8000, 80, 50, 65),
('PROD064', 'moveis_sala', 52, 380, 3, 7500, 75, 45, 60),
('PROD065', 'moveis_colchao_estofado', 60, 450, 5, 15000, 100, 30, 80),
('PROD066', 'moveis_colchao_estofado', 58, 430, 4, 14000, 95, 25, 75),
('PROD067', 'musica', 35, 200, 2, 500, 25, 5, 20),
('PROD068', 'musica', 32, 180, 1, 450, 22, 4, 18),
('PROD069', 'outros', 40, 250, 2, 800, 30, 15, 25),
('PROD070', 'outros', 38, 230, 2, 750, 28, 12, 22),
('PROD071', 'pc_gamer', 50, 350, 3, 5000, 50, 30, 40),
('PROD072', 'pc_gamer', 48, 330, 3, 4500, 45, 25, 35),
('PROD073', 'pet_shop', 42, 280, 2, 1000, 30, 20, 25),
('PROD074', 'pet_shop', 40, 260, 2, 900, 28, 18, 22),
('PROD075', 'telefonia_fixa', 35, 200, 2, 400, 20, 10, 15),
('PROD076', 'telefonia_fixa', 32, 180, 1, 350, 18, 8, 12),
('PROD077', 'audio', 45, 300, 3, 800, 30, 15, 25),
('PROD078', 'audio', 42, 280, 2, 750, 28, 12, 22),
('PROD079', 'construcao_ferramentas_construcao', 40, 250, 2, 1500, 35, 20, 25),
('PROD080', 'construcao_ferramentas_construcao', 38, 230, 2, 1400, 32, 18, 22),
('PROD081', 'construcao_ferramentas_ferramentas', 42, 280, 2, 1200, 30, 15, 20),
('PROD082', 'construcao_ferramentas_ferramentas', 40, 260, 2, 1100, 28, 12, 18),
('PROD083', 'construcao_ferramentas_iluminacao', 38, 250, 2, 800, 25, 15, 20),
('PROD084', 'construcao_ferramentas_iluminacao', 35, 230, 2, 750, 22, 12, 18),
('PROD085', 'construcao_ferramentas_jardim', 45, 300, 3, 2000, 40, 25, 30),
('PROD086', 'construcao_ferramentas_jardim', 42, 280, 2, 1800, 35, 22, 28),
('PROD087', 'casa_inteligente', 40, 250, 2, 500, 20, 10, 15),
('PROD088', 'casa_inteligente', 38, 230, 2, 450, 18, 8, 12),
('PROD089', 'eletro_6', 48, 320, 3, 2000, 40, 25, 30),
('PROD090', 'eletro_6', 45, 300, 2, 1800, 35, 22, 28),
('PROD091', 'sinalizacao_e_seguranca', 35, 200, 2, 700, 25, 15, 20),
('PROD092', 'sinalizacao_e_seguranca', 32, 180, 1, 650, 22, 12, 18),
('PROD093', 'protecao_seguranca', 38, 220, 2, 900, 28, 18, 22),
('PROD094', 'protecao_seguranca', 35, 200, 2, 850, 25, 15, 20),
('PROD095', 'artigos_festas', 40, 250, 3, 600, 25, 15, 20),
('PROD096', 'artigos_festas', 38, 230, 2, 550, 22, 12, 18),
('PROD097', 'artigos_mesa', 42, 280, 2, 800, 28, 15, 22),
('PROD098', 'artigos_mesa', 40, 260, 2, 750, 25, 12, 20),
('PROD099', 'marketplace', 35, 200, 2, 500, 22, 12, 18),
('PROD100', 'marketplace', 32, 180, 1, 450, 20, 10, 15),
('PROD101', 'beleza_saude', 44, 280, 2, 600, 22, 12, 18),
('PROD102', 'informatica_acessorios', 48, 320, 3, 900, 28, 18, 22),
('PROD103', 'automotivo', 32, 160, 1, 1300, 32, 22, 28),
('PROD104', 'cama_mesa_banho', 58, 380, 3, 2200, 55, 35, 45),
('PROD105', 'moveis_decoracao', 40, 210, 2, 3200, 65, 45, 55),
('PROD106', 'esporte_lazer', 46, 270, 2, 1600, 42, 22, 32),
('PROD107', 'perfumaria', 24, 95, 1, 190, 14, 7, 9),
('PROD108', 'utilidades_domesticas', 34, 170, 2, 880, 24, 14, 19),
('PROD109', 'telefones', 42, 260, 3, 310, 22, 11, 16),
('PROD110', 'relogios_presentes', 29, 145, 1, 390, 19, 11, 14),
('PROD111', 'alarmes_seguranca', 34, 190, 2, 580, 24, 14, 19),
('PROD112', 'brinquedos', 44, 290, 3, 780, 29, 19, 24),
('PROD113', 'bolsas_acessorios', 37, 190, 2, 480, 24, 14, 19),
('PROD114', 'casa_construcao', 39, 240, 2, 1900, 38, 23, 28),
('PROD115', 'climatizacao', 44, 290, 2, 4800, 58, 38, 48),
('PROD116', 'cozinha_comida_bebida', 49, 340, 2, 1150, 34, 19, 24),
('PROD117', 'eletrodomesticos', 54, 390, 3, 2900, 48, 33, 38),
('PROD118', 'eletroportateis', 39, 240, 2, 1450, 29, 19, 24),
('PROD119', 'fashion_bolsas_carteras', 34, 190, 1, 580, 24, 14, 19),
('PROD120', 'fashion_calcados', 41, 270, 2, 780, 29, 14, 19),
('PROD121', 'fashion_esportiva', 37, 240, 2, 480, 24, 11, 17),
('PROD122', 'fashion_feminina', 44, 290, 2, 390, 21, 9, 14),
('PROD123', 'fashion_masculina', 41, 270, 2, 440, 21, 9, 14),
('PROD124', 'fashion_underwear_e_moda_praia', 37, 210, 1, 190, 17, 7, 11),
('PROD125', 'fraldas_higiene', 49, 340, 2, 1900, 38, 28, 33),
('PROD126', 'jardinagem', 39, 240, 2, 1150, 34, 24, 29),
('PROD127', 'livros_interesse_geral', 29, 145, 1, 290, 19, 3, 14),
('PROD128', 'livros_tecnicos', 31, 170, 1, 340, 21, 3, 14),
('PROD129', 'moveis_escritorio', 54, 390, 3, 7800, 78, 48, 58),
('PROD130', 'moveis_cozinha', 49, 340, 3, 5800, 68, 38, 48),
('PROD131', 'moveis_quarto', 51, 370, 3, 6800, 73, 48, 58),
('PROD132', 'moveis_sala', 54, 390, 3, 7800, 78, 48, 63),
('PROD133', 'moveis_colchao_estofado', 59, 440, 4, 14500, 98, 28, 78),
('PROD134', 'musica', 34, 190, 1, 480, 24, 5, 19),
('PROD135', 'outros', 39, 240, 2, 780, 29, 14, 24),
('PROD136', 'pc_gamer', 49, 340, 3, 4800, 48, 28, 38),
('PROD137', 'pet_shop', 41, 270, 2, 950, 29, 19, 24),
('PROD138', 'telefonia_fixa', 34, 190, 1, 380, 19, 9, 14),
('PROD139', 'audio', 44, 290, 2, 780, 29, 14, 24),
('PROD140', 'construcao_ferramentas_construcao', 39, 240, 2, 1450, 34, 19, 24),
('PROD141', 'construcao_ferramentas_ferramentas', 41, 270, 2, 1150, 29, 14, 19),
('PROD142', 'construcao_ferramentas_iluminacao', 37, 240, 2, 780, 24, 14, 19),
('PROD143', 'construcao_ferramentas_jardim', 44, 290, 2, 1900, 38, 24, 29),
('PROD144', 'casa_inteligente', 39, 240, 2, 480, 19, 9, 14),
('PROD145', 'eletro_6', 47, 310, 2, 1900, 38, 24, 29),
('PROD146', 'sinalizacao_e_seguranca', 34, 190, 1, 680, 24, 14, 19),
('PROD147', 'protecao_seguranca', 37, 210, 2, 880, 27, 17, 21),
('PROD148', 'artigos_festas', 39, 240, 2, 580, 24, 14, 19),
('PROD149', 'artigos_mesa', 41, 270, 2, 780, 27, 14, 21),
('PROD150', 'marketplace', 34, 190, 1, 480, 21, 11, 16),
('PROD151', 'beleza_saude', 42, 270, 2, 550, 21, 11, 17),
('PROD152', 'informatica_acessorios', 47, 310, 3, 850, 27, 17, 21),
('PROD153', 'automotivo', 31, 155, 1, 1250, 31, 21, 27),
('PROD154', 'cama_mesa_banho', 57, 370, 3, 2100, 53, 33, 43),
('PROD155', 'moveis_decoracao', 39, 205, 2, 3100, 63, 43, 53),
('PROD156', 'esporte_lazer', 45, 265, 2, 1550, 41, 21, 31),
('PROD157', 'perfumaria', 23, 92, 1, 185, 13, 6, 8),
('PROD158', 'utilidades_domesticas', 33, 165, 2, 860, 23, 13, 18),
('PROD159', 'telefones', 41, 255, 3, 305, 21, 10, 15),
('PROD160', 'relogios_presentes', 28, 142, 1, 385, 18, 10, 13),
('PROD161', 'alarmes_seguranca', 33, 185, 2, 565, 23, 13, 18),
('PROD162', 'brinquedos', 43, 285, 3, 765, 28, 18, 23),
('PROD163', 'bolsas_acessorios', 36, 185, 2, 465, 23, 13, 18),
('PROD164', 'casa_construcao', 38, 235, 2, 1850, 37, 22, 27),
('PROD165', 'climatizacao', 43, 285, 2, 4650, 57, 37, 47),
('PROD166', 'cozinha_comida_bebida', 48, 335, 2, 1125, 33, 18, 23),
('PROD167', 'eletrodomesticos', 53, 385, 3, 2850, 47, 32, 37),
('PROD168', 'eletroportateis', 38, 235, 2, 1425, 28, 18, 23),
('PROD169', 'fashion_bolsas_carteras', 33, 185, 1, 565, 23, 13, 18),
('PROD170', 'fashion_calcados', 40, 265, 2, 765, 28, 13, 18),
('PROD171', 'fashion_esportiva', 36, 235, 2, 465, 23, 10, 16),
('PROD172', 'fashion_feminina', 43, 285, 2, 385, 20, 8, 13),
('PROD173', 'fashion_masculina', 40, 265, 2, 425, 20, 8, 13),
('PROD174', 'fashion_underwear_e_moda_praia', 36, 205, 1, 185, 16, 6, 10),
('PROD175', 'fraldas_higiene', 48, 335, 2, 1850, 37, 27, 32),
('PROD176', 'jardinagem', 38, 235, 2, 1125, 33, 23, 28),
('PROD177', 'livros_interesse_geral', 28, 142, 1, 285, 18, 2, 13),
('PROD178', 'livros_tecnicos', 30, 165, 1, 335, 20, 2, 13),
('PROD179', 'moveis_escritorio', 53, 385, 3, 7650, 77, 47, 57),
('PROD180', 'moveis_cozinha', 48, 335, 3, 5650, 67, 37, 47),
('PROD181', 'moveis_quarto', 50, 365, 3, 6650, 72, 47, 57),
('PROD182', 'moveis_sala', 53, 385, 3, 7650, 77, 47, 62),
('PROD183', 'moveis_colchao_estofado', 58, 435, 4, 14250, 97, 27, 77),
('PROD184', 'musica', 33, 185, 1, 465, 23, 4, 18),
('PROD185', 'outros', 38, 235, 2, 765, 28, 13, 23),
('PROD186', 'pc_gamer', 48, 335, 3, 4650, 47, 27, 37),
('PROD187', 'pet_shop', 40, 265, 2, 925, 28, 18, 23),
('PROD188', 'telefonia_fixa', 33, 185, 1, 365, 18, 8, 13),
('PROD189', 'audio', 43, 285, 2, 765, 28, 13, 23),
('PROD190', 'construcao_ferramentas_construcao', 38, 235, 2, 1425, 33, 18, 23),
('PROD191', 'construcao_ferramentas_ferramentas', 40, 265, 2, 1125, 28, 13, 18),
('PROD192', 'construcao_ferramentas_iluminacao', 36, 235, 2, 765, 23, 13, 18),
('PROD193', 'construcao_ferramentas_jardim', 43, 285, 2, 1850, 37, 23, 28),
('PROD194', 'casa_inteligente', 38, 235, 2, 465, 18, 8, 13),
('PROD195', 'eletro_6', 46, 305, 2, 1850, 37, 23, 28),
('PROD196', 'sinalizacao_e_seguranca', 33, 185, 1, 665, 23, 13, 18),
('PROD197', 'protecao_seguranca', 36, 205, 2, 865, 26, 16, 20),
('PROD198', 'artigos_festas', 38, 235, 2, 565, 23, 13, 18),
('PROD199', 'artigos_mesa', 40, 265, 2, 765, 26, 13, 20),
('PROD200', 'marketplace', 33, 185, 1, 465, 20, 10, 15);

-- CUSTOMERS DATA (500 customers)
-- Generating with a loop-style INSERT for efficiency
DO $$
DECLARE
    i INTEGER;
    cities TEXT[] := ARRAY['Sao Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Brasilia', 'Salvador', 'Fortaleza', 'Curitiba', 'Recife', 'Porto Alegre', 'Manaus', 'Belem', 'Goiania', 'Guarulhos', 'Campinas', 'Sao Luis', 'Maceio', 'Campo Grande', 'Teresina', 'Joao Pessoa', 'Natal', 'Aracaju', 'Cuiaba', 'Ribeirao Preto', 'Uberlandia', 'Sorocaba', 'Sao Jose dos Campos', 'Londrina', 'Maringa', 'Florianopolis', 'Joinville'];
    states TEXT[] := ARRAY['SP', 'RJ', 'MG', 'DF', 'BA', 'CE', 'PR', 'PE', 'RS', 'AM', 'PA', 'GO', 'SP', 'SP', 'MA', 'AL', 'MS', 'PI', 'PB', 'RN', 'SE', 'MT', 'SP', 'MG', 'SP', 'SP', 'PR', 'PR', 'SC', 'SC'];
    zip INTEGER;
    cust_id TEXT;
    cust_uid TEXT;
BEGIN
    FOR i IN 1..500 LOOP
        cust_id := 'CUST' || LPAD(i::TEXT, 4, '0');
        cust_uid := 'CUID' || LPAD(i::TEXT, 4, '0');
        zip := 10000 + (i * 13) % 90000;
        INSERT INTO customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
        VALUES (cust_id, cust_uid, zip, cities[1 + (i % 30)], states[1 + (i % 30)]);
    END LOOP;
END $$;

-- ORDERS DATA (500 orders)
DO $$
DECLARE
    i INTEGER;
    statuses TEXT[] := ARRAY['delivered', 'shipped', 'canceled', 'unavailable', 'invoiced', 'processing', 'approved', 'created'];
    base_date TIMESTAMP := '2017-01-01'::TIMESTAMP;
    rand_days INTEGER;
    cust_id TEXT;
    status TEXT;
    purchase_ts TIMESTAMP;
    approved_ts TIMESTAMP;
    carrier_ts TIMESTAMP;
    delivered_ts TIMESTAMP;
    estimated_ts TIMESTAMP;
BEGIN
    FOR i IN 1..500 LOOP
        cust_id := 'CUST' || LPAD(((i - 1) % 500 + 1)::TEXT, 4, '0');
        status := statuses[1 + (i % 8)];
        rand_days := (i * 7) % 730;
        purchase_ts := base_date + (rand_days || ' days')::INTERVAL + ((i * 137) % 24 || ' hours')::INTERVAL;
        approved_ts := purchase_ts + ((i * 3) % 48 || ' hours')::INTERVAL;
        carrier_ts := approved_ts + ((i * 5) % 72 || ' hours')::INTERVAL;
        delivered_ts := carrier_ts + ((i * 7) % 168 || ' hours')::INTERVAL;
        estimated_ts := purchase_ts + ((i * 11) % 30 || ' days')::INTERVAL;

        INSERT INTO orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
        VALUES (
            'ORD' || LPAD(i::TEXT, 5, '0'),
            cust_id,
            status,
            purchase_ts,
            approved_ts,
            CASE WHEN status IN ('shipped', 'delivered') THEN carrier_ts ELSE NULL END,
            CASE WHEN status = 'delivered' THEN delivered_ts ELSE NULL END,
            estimated_ts
        );
    END LOOP;
END $$;

-- ORDER_ITEMS DATA (700 items)
DO $$
DECLARE
    i INTEGER;
    order_idx INTEGER;
    prod_idx INTEGER;
    seller_idx INTEGER;
    item_id INTEGER;
    base_price REAL;
    freight REAL;
BEGIN
    FOR i IN 1..700 LOOP
        order_idx := ((i - 1) % 500) + 1;
        prod_idx := ((i - 1) % 200) + 1;
        seller_idx := ((i - 1) % 50) + 1;
        item_id := ((i - 1) / 500) + 1;
        base_price := 20 + (i * 13) % 500;
        freight := 5 + (i * 7) % 50;

        INSERT INTO order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
        VALUES (
            'ORD' || LPAD(order_idx::TEXT, 5, '0'),
            item_id,
            'PROD' || LPAD(prod_idx::TEXT, 3, '0'),
            'SELLER' || LPAD(seller_idx::TEXT, 3, '0'),
            ('2017-01-01'::TIMESTAMP) + ((i * 11) % 730 || ' days')::INTERVAL,
            base_price,
            freight
        );
    END LOOP;
END $$;

-- PAYMENTS DATA (600 payments)
DO $$
DECLARE
    i INTEGER;
    order_idx INTEGER;
    ptypes TEXT[] := ARRAY['credit_card', 'boleto', 'debit_card', 'voucher'];
    installments INTEGER;
    pvalue DOUBLE PRECISION;
BEGIN
    FOR i IN 1..600 LOOP
        order_idx := ((i - 1) % 500) + 1;
        installments := 1 + (i * 3) % 12;
        pvalue := 20 + (i * 17) % 800;

        INSERT INTO payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
        VALUES (
            'ORD' || LPAD(order_idx::TEXT, 5, '0'),
            1 + (i * 2) % 3,
            ptypes[1 + (i % 4)],
            installments,
            pvalue
        );
    END LOOP;
END $$;

-- REVIEWS DATA (500 reviews)
DO $$
DECLARE
    i INTEGER;
    scores SMALLINT[];
    titles TEXT[] := ARRAY['Excelente', 'Bom', 'Regular', 'Ruim', 'Otimo', 'Produto ok', 'Recomendo', 'Nao recomendo', 'Satisfatorio', 'Rapida entrega'];
    messages TEXT[] := ARRAY['Produto chegou bem embalado.', 'Entrega foi rapida.', 'Qualidade boa pelo preco.', 'Produto como descrito.', 'Sem problemas.', 'Tudo certo.', 'Recebi antes do prazo.', 'Produto danificado.', 'Nao esperava tao rapido.', 'Muito satisfeito.'];
    score INTEGER;
    order_idx INTEGER;
BEGIN
    FOR i IN 1..500 LOOP
        order_idx := ((i - 1) % 500) + 1;
        score := 1 + (i * 11) % 5;

        INSERT INTO reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
        VALUES (
            'REV' || LPAD(i::TEXT, 5, '0'),
            'ORD' || LPAD(order_idx::TEXT, 5, '0'),
            score,
            titles[1 + (i % 10)],
            messages[1 + (i % 10)],
            ('2017-01-01'::DATE) + ((i * 5) % 730),
            ('2017-01-01'::TIMESTAMP) + ((i * 5) % 730 || ' days')::INTERVAL + ((i * 3) % 24 || ' hours')::INTERVAL
        );
    END LOOP;
END $$;

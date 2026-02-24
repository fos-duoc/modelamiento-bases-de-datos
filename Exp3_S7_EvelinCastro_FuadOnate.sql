-- ============================================================
-- PRY2204 - Modelamiento de Bases de Datos
-- Experiencia 3 - Semana 7
-- Actividad: Realizando el poblamiento y consultas en la
--            base de datos con sentencias SQL
-- Caso: Holding Carpenter SPA
-- Estudiantes: Evelin Castro - Fuad Oñate
-- ============================================================


-- ============================================================
-- LIMPIEZA PREVIA (ejecutar si se desea reiniciar)
-- ============================================================
BEGIN
    FOR obj IN (
        SELECT object_name, object_type FROM user_objects
        WHERE object_type IN ('TABLE','SEQUENCE')
        ORDER BY object_type DESC
    ) LOOP
        BEGIN
            IF obj.object_type = 'TABLE' THEN
                EXECUTE IMMEDIATE 'DROP TABLE ' || obj.object_name || ' CASCADE CONSTRAINTS';
            ELSIF obj.object_type = 'SEQUENCE' THEN
                EXECUTE IMMEDIATE 'DROP SEQUENCE ' || obj.object_name;
            END IF;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/


-- ============================================================
-- CASO 1: IMPLEMENTACIÓN DEL MODELO RELACIONAL (DDL)
-- Orden: tablas fuertes → débiles
-- ============================================================

-- Tabla REGION (IDENTITY: inicio 7, incremento 2)
CREATE TABLE REGION (
    id_region     NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 7 INCREMENT BY 2),
    nombre_region VARCHAR2(60) NOT NULL,
    CONSTRAINT region_pk PRIMARY KEY (id_region),
    CONSTRAINT region_nombre_un UNIQUE (nombre_region)
);

-- Tabla ESTADO_CIVIL
CREATE TABLE ESTADO_CIVIL (
    id_estado_civil NUMBER,
    descripcion     VARCHAR2(30) NOT NULL,
    CONSTRAINT estado_civil_pk PRIMARY KEY (id_estado_civil),
    CONSTRAINT estado_civil_desc_un UNIQUE (descripcion)
);

-- Tabla GENERO
CREATE TABLE GENERO (
    id_genero   NUMBER,
    descripcion VARCHAR2(20) NOT NULL,
    CONSTRAINT genero_pk PRIMARY KEY (id_genero),
    CONSTRAINT genero_desc_un UNIQUE (descripcion)
);

-- Tabla TITULACION
CREATE TABLE TITULACION (
    id_titulacion NUMBER,
    descripcion   VARCHAR2(50) NOT NULL,
    CONSTRAINT titulacion_pk PRIMARY KEY (id_titulacion),
    CONSTRAINT titulacion_desc_un UNIQUE (descripcion)
);

-- Tabla DOMINIO
CREATE TABLE DOMINIO (
    id_dominio  NUMBER,
    descripcion VARCHAR2(40) NOT NULL,
    CONSTRAINT dominio_pk PRIMARY KEY (id_dominio),
    CONSTRAINT dominio_desc_un UNIQUE (descripcion)
);

-- Tabla IDIOMA (IDENTITY: inicio 25, incremento 3)
CREATE TABLE IDIOMA (
    id_idioma     NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 25 INCREMENT BY 3),
    nombre_idioma VARCHAR2(40) NOT NULL,
    CONSTRAINT idioma_pk PRIMARY KEY (id_idioma),
    CONSTRAINT idioma_nombre_un UNIQUE (nombre_idioma)
);

-- Tabla TITULO (depende de TITULACION)
CREATE TABLE TITULO (
    id_titulo     NUMBER,
    nombre_titulo VARCHAR2(80) NOT NULL,
    id_titulacion NUMBER NOT NULL,
    CONSTRAINT titulo_pk      PRIMARY KEY (id_titulo),
    CONSTRAINT titulo_tit_fk  FOREIGN KEY (id_titulacion) REFERENCES TITULACION(id_titulacion)
);

-- Tabla COMUNA (depende de REGION)
CREATE TABLE COMUNA (
    id_comuna  NUMBER,
    nombre     VARCHAR2(50) NOT NULL,
    id_region  NUMBER NOT NULL,
    CONSTRAINT comuna_pk       PRIMARY KEY (id_comuna),
    CONSTRAINT comuna_reg_fk   FOREIGN KEY (id_region) REFERENCES REGION(id_region)
);

-- Tabla COMPANIA (depende de COMUNA)
CREATE TABLE COMPANIA (
    id_compania      NUMBER,
    nombre_empresa   VARCHAR2(80)   NOT NULL,
    direccion        VARCHAR2(100)  NOT NULL,
    id_comuna        NUMBER         NOT NULL,
    renta_promedio   NUMBER(10,2)   NOT NULL,
    porcentaje_aumento NUMBER(5,2)  NOT NULL,
    CONSTRAINT compania_pk       PRIMARY KEY (id_compania),
    CONSTRAINT compania_com_fk   FOREIGN KEY (id_comuna) REFERENCES COMUNA(id_comuna),
    CONSTRAINT compania_renta_ck CHECK (renta_promedio > 0),
    CONSTRAINT compania_porc_ck  CHECK (porcentaje_aumento >= 0)
);

-- Tabla PERSONAL (tabla más débil, depende de varias)
CREATE TABLE PERSONAL (
    id_personal      NUMBER,
    run              NUMBER(8)      NOT NULL,
    dv               VARCHAR2(1)    NOT NULL,
    nombre           VARCHAR2(50)   NOT NULL,
    apellido_pat     VARCHAR2(50)   NOT NULL,
    apellido_mat     VARCHAR2(50),
    email            VARCHAR2(100),
    sueldo           NUMBER(10,2)   NOT NULL,
    id_compania      NUMBER         NOT NULL,
    id_comuna        NUMBER         NOT NULL,
    id_estado_civil  NUMBER         NOT NULL,
    id_genero        NUMBER         NOT NULL,
    id_titulacion    NUMBER         NOT NULL,
    id_idioma        NUMBER         NOT NULL,
    id_dominio       NUMBER         NOT NULL,
    CONSTRAINT personal_pk          PRIMARY KEY (id_personal),
    CONSTRAINT personal_comp_fk     FOREIGN KEY (id_compania)     REFERENCES COMPANIA(id_compania),
    CONSTRAINT personal_comu_fk     FOREIGN KEY (id_comuna)       REFERENCES COMUNA(id_comuna),
    CONSTRAINT personal_eciv_fk     FOREIGN KEY (id_estado_civil) REFERENCES ESTADO_CIVIL(id_estado_civil),
    CONSTRAINT personal_gen_fk      FOREIGN KEY (id_genero)       REFERENCES GENERO(id_genero),
    CONSTRAINT personal_tit_fk      FOREIGN KEY (id_titulacion)   REFERENCES TITULACION(id_titulacion),
    CONSTRAINT personal_idi_fk      FOREIGN KEY (id_idioma)       REFERENCES IDIOMA(id_idioma),
    CONSTRAINT personal_dom_fk      FOREIGN KEY (id_dominio)      REFERENCES DOMINIO(id_dominio)
);


-- ============================================================
-- CASO 2: MODIFICACIÓN DEL MODELO (ALTER TABLE)
-- ============================================================

-- 2.1 Email opcional, pero único si se ingresa
ALTER TABLE PERSONAL
    ADD CONSTRAINT personal_email_un UNIQUE (email);

-- 2.2 Dígito verificador solo acepta: 0,1,2,3,4,5,6,7,8,9,'K'
ALTER TABLE PERSONAL
    ADD CONSTRAINT personal_dv_ck CHECK (dv IN ('0','1','2','3','4','5','6','7','8','9','K'));

-- 2.3 Sueldo mínimo del personal: 450.000 pesos
ALTER TABLE PERSONAL
    ADD CONSTRAINT personal_sueldo_ck CHECK (sueldo >= 450000);


-- ============================================================
-- CASO 3: POBLAMIENTO DEL MODELO
-- Orden: IDIOMA → REGION → COMUNA → COMPANIA
-- ============================================================

-- ---- SEQUENCE para COMUNA (inicio 1101, incremento 6) ----
CREATE SEQUENCE seq_comuna
    START WITH 1101
    INCREMENT BY 6
    NOCACHE;

-- ---- SEQUENCE para COMPANIA (inicio 10, incremento 5) ----
CREATE SEQUENCE seq_compania
    START WITH 10
    INCREMENT BY 5
    NOCACHE;


-- TABLA IDIOMA (usa IDENTITY 25, +3)
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Español');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Inglés');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Francés');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Portugués');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Alemán');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Italiano');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Chino Mandarín');
COMMIT;


-- TABLA REGION (usa IDENTITY 7, +2)
INSERT INTO REGION (nombre_region) VALUES ('Región de Arica y Parinacota');
INSERT INTO REGION (nombre_region) VALUES ('Región de Tarapacá');
INSERT INTO REGION (nombre_region) VALUES ('Región de Antofagasta');
INSERT INTO REGION (nombre_region) VALUES ('Región de Atacama');
INSERT INTO REGION (nombre_region) VALUES ('Región de Coquimbo');
INSERT INTO REGION (nombre_region) VALUES ('Región de Valparaíso');
INSERT INTO REGION (nombre_region) VALUES ('Región Metropolitana');
INSERT INTO REGION (nombre_region) VALUES ('Región del Libertador B. OHiggins');
INSERT INTO REGION (nombre_region) VALUES ('Región del Maule');
INSERT INTO REGION (nombre_region) VALUES ('Región del Ñuble');
INSERT INTO REGION (nombre_region) VALUES ('Región del Biobío');
INSERT INTO REGION (nombre_region) VALUES ('Región de La Araucanía');
INSERT INTO REGION (nombre_region) VALUES ('Región de Los Ríos');
INSERT INTO REGION (nombre_region) VALUES ('Región de Los Lagos');
INSERT INTO REGION (nombre_region) VALUES ('Región de Aysén');
INSERT INTO REGION (nombre_region) VALUES ('Región de Magallanes');
COMMIT;


-- TABLA COMUNA (usa SEQUENCE seq_comuna: 1101, 1107, 1113...)
-- Muestra: comunas representativas de la Región Metropolitana (id_region = 7+2*6 = 19)
-- Nota: id_region 7 = Arica, 9 = Tarapacá ... 19 = RM
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Arica',           7);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Iquique',          9);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Antofagasta',      11);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Copiapó',          13);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'La Serena',        15);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Viña del Mar',     17);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Santiago',         19);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Providencia',      19);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Las Condes',       19);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Rancagua',         21);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Talca',            23);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Concepción',       27);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Temuco',           29);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Valdivia',         31);
INSERT INTO COMUNA (id_comuna, nombre, id_region) VALUES (seq_comuna.NEXTVAL, 'Puerto Montt',     33);
COMMIT;


-- TABLA COMPANIA (usa SEQUENCE seq_compania: 10, 15, 20, 25, 30, 35, 40)
INSERT INTO COMPANIA (id_compania, nombre_empresa, direccion, id_comuna, renta_promedio, porcentaje_aumento)
    VALUES (seq_compania.NEXTVAL, 'Carpenter Retail Norte',   'Av. General Velásquez 1250',  1119, 850000.00,  8.50);
INSERT INTO COMPANIA (id_compania, nombre_empresa, direccion, id_comuna, renta_promedio, porcentaje_aumento)
    VALUES (seq_compania.NEXTVAL, 'Carpenter Centro',         'Av. Libertador 890',          1125, 920000.00,  7.00);
INSERT INTO COMPANIA (id_compania, nombre_empresa, direccion, id_comuna, renta_promedio, porcentaje_aumento)
    VALUES (seq_compania.NEXTVAL, 'Carpenter Sur',            'Calle Independencia 340',     1137, 780000.00,  9.00);
INSERT INTO COMPANIA (id_compania, nombre_empresa, direccion, id_comuna, renta_promedio, porcentaje_aumento)
    VALUES (seq_compania.NEXTVAL, 'Carpenter Metropolitana',  'Av. Apoquindo 4600',          1143, 1050000.00, 6.50);
INSERT INTO COMPANIA (id_compania, nombre_empresa, direccion, id_comuna, renta_promedio, porcentaje_aumento)
    VALUES (seq_compania.NEXTVAL, 'Carpenter Express',        'Av. Grecia 820',              1149, 720000.00, 10.00);
INSERT INTO COMPANIA (id_compania, nombre_empresa, direccion, id_comuna, renta_promedio, porcentaje_aumento)
    VALUES (seq_compania.NEXTVAL, 'Carpenter Digital',        'Calle Merced 230',            1143, 980000.00,  7.50);
INSERT INTO COMPANIA (id_compania, nombre_empresa, direccion, id_comuna, renta_promedio, porcentaje_aumento)
    VALUES (seq_compania.NEXTVAL, 'Carpenter Mayorista',      'Ruta 5 Norte Km 1320',        1101, 860000.00,  8.00);
COMMIT;


-- ============================================================
-- CASO 4: RECUPERACIÓN DE DATOS
-- ============================================================

-- INFORME 1: Simulación Renta Promedio por empresa
-- Alias: "Nombre Empresa", "Dirección", "Renta Promedio", "Renta Simulada"
-- Orden: Renta Promedio DESC, luego Nombre Empresa ASC (en caso de empate)
SELECT
    c.nombre_empresa                                        AS "Nombre Empresa",
    c.direccion                                             AS "Dirección",
    c.renta_promedio                                        AS "Renta Promedio",
    ROUND(c.renta_promedio * (1 + c.porcentaje_aumento/100), 2) AS "Renta Simulada"
FROM
    COMPANIA c
ORDER BY
    c.renta_promedio DESC,
    c.nombre_empresa ASC;


-- INFORME 2: Nueva simulación renta promedio (+15% adicional al porcentaje registrado)
-- Alias: "ID Empresa", "Nombre Empresa", "Renta Promedio Actual",
--        "% Aumento Ajustado", "Renta Promedio Incrementada"
-- Orden: Renta Promedio Actual ASC, luego Nombre Empresa DESC
SELECT
    c.id_compania                                                     AS "ID Empresa",
    c.nombre_empresa                                                  AS "Nombre Empresa",
    c.renta_promedio                                                  AS "Renta Promedio Actual",
    (c.porcentaje_aumento + 15)                                       AS "% Aumento Ajustado",
    ROUND(c.renta_promedio * (1 + (c.porcentaje_aumento + 15)/100), 2) AS "Renta Promedio Incrementada"
FROM
    COMPANIA c
ORDER BY
    c.renta_promedio ASC,
    c.nombre_empresa DESC;


-- ============================================================
-- FIN DEL SCRIPT
-- PRY2204 | Exp3 S7 | Castro - Oñate
-- ============================================================

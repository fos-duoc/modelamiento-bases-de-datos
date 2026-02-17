-- ============================================================
-- PRY2204 - Modelamiento de Bases de Datos
-- Experiencia 3 - Semana 6
-- Actividad Formativa: Implementando un Modelo Relacional 
-- con sentencias SQL
-- Estudiantes: Evelin Castro - Fuad Oñate
-- Fecha: Febrero 2026
-- Caso: Consultorio Médico Municipalidad Santa Gema
-- ============================================================

-- ============================================================
-- SECCION 0: BORRADO DE OBJETOS (orden inverso por dependencias)
-- ============================================================

DROP TABLE detalle_receta CASCADE CONSTRAINTS;
DROP TABLE pago CASCADE CONSTRAINTS;
DROP TABLE receta CASCADE CONSTRAINTS;
DROP TABLE medicamento CASCADE CONSTRAINTS;
DROP TABLE tipo_medicamento CASCADE CONSTRAINTS;
DROP TABLE tipo_receta CASCADE CONSTRAINTS;
DROP TABLE digitador CASCADE CONSTRAINTS;
DROP TABLE medico CASCADE CONSTRAINTS;
DROP TABLE especialidad CASCADE CONSTRAINTS;
DROP TABLE paciente CASCADE CONSTRAINTS;
DROP TABLE comuna CASCADE CONSTRAINTS;
DROP TABLE ciudad CASCADE CONSTRAINTS;
DROP TABLE region CASCADE CONSTRAINTS;

-- ============================================================
-- CASO 1: CREACION DE TABLAS Y RESTRICCIONES
-- ============================================================

-- ------------------------------------------------------------
-- Tabla REGION
-- Almacena las regiones del pais
-- ------------------------------------------------------------
CREATE TABLE region (
    id_region       NUMBER          NOT NULL,
    nombre          VARCHAR2(80)    NOT NULL,
    CONSTRAINT region_pk PRIMARY KEY (id_region)
);

-- ------------------------------------------------------------
-- Tabla CIUDAD
-- Almacena las ciudades asociadas a una region
-- ------------------------------------------------------------
CREATE TABLE ciudad (
    id_ciudad       NUMBER          NOT NULL,
    nombre          VARCHAR2(80)    NOT NULL,
    id_region       NUMBER          NOT NULL,
    CONSTRAINT ciudad_pk PRIMARY KEY (id_ciudad),
    CONSTRAINT ciudad_region_fk FOREIGN KEY (id_region) 
        REFERENCES region (id_region)
);

-- ------------------------------------------------------------
-- Tabla COMUNA
-- Almacena las comunas asociadas a una ciudad
-- El identificador comienza en 1101 y se incrementa en 1
-- ------------------------------------------------------------
CREATE TABLE comuna (
    id_comuna       NUMBER GENERATED ALWAYS AS IDENTITY 
                    (START WITH 1101 INCREMENT BY 1) NOT NULL,
    nombre          VARCHAR2(80)    NOT NULL,
    id_ciudad       NUMBER          NOT NULL,
    CONSTRAINT comuna_pk PRIMARY KEY (id_comuna),
    CONSTRAINT comuna_ciudad_fk FOREIGN KEY (id_ciudad) 
        REFERENCES ciudad (id_ciudad)
);

-- ------------------------------------------------------------
-- Tabla ESPECIALIDAD
-- Almacena las especialidades medicas
-- El identificador se incrementa automaticamente con identity
-- ------------------------------------------------------------
CREATE TABLE especialidad (
    id_especialidad NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL,
    nombre          VARCHAR2(80)    NOT NULL,
    CONSTRAINT especialidad_pk PRIMARY KEY (id_especialidad)
);

-- ------------------------------------------------------------
-- Tabla MEDICO
-- Almacena los datos de los medicos del consultorio
-- El telefono debe ser unico (no se repite entre medicos)
-- El digito verificador solo permite valores 0-9 y K
-- ------------------------------------------------------------
CREATE TABLE medico (
    run_medico      NUMBER          NOT NULL,
    dv_medico       CHAR(1)         NOT NULL,
    nombre          VARCHAR2(50)    NOT NULL,
    apellido        VARCHAR2(50)    NOT NULL,
    telefono        VARCHAR2(15)    NOT NULL,
    id_especialidad NUMBER          NOT NULL,
    CONSTRAINT medico_pk PRIMARY KEY (run_medico),
    CONSTRAINT medico_especialidad_fk FOREIGN KEY (id_especialidad) 
        REFERENCES especialidad (id_especialidad),
    CONSTRAINT medico_telefono_un UNIQUE (telefono),
    CONSTRAINT medico_dv_ck CHECK (dv_medico IN ('0','1','2','3','4','5','6','7','8','9','K'))
);

-- ------------------------------------------------------------
-- Tabla PACIENTE
-- Almacena los datos de los pacientes del consultorio
-- Incluye direccion completa (ciudad, comuna, region via FK)
-- El digito verificador solo permite valores 0-9 y K
-- ------------------------------------------------------------
CREATE TABLE paciente (
    run_paciente    NUMBER          NOT NULL,
    dv_paciente     CHAR(1)         NOT NULL,
    nombre          VARCHAR2(50)    NOT NULL,
    apellido        VARCHAR2(50)    NOT NULL,
    direccion       VARCHAR2(100)   NOT NULL,
    edad            NUMBER,
    id_comuna       NUMBER          NOT NULL,
    CONSTRAINT paciente_pk PRIMARY KEY (run_paciente),
    CONSTRAINT paciente_comuna_fk FOREIGN KEY (id_comuna) 
        REFERENCES comuna (id_comuna),
    CONSTRAINT paciente_dv_ck CHECK (dv_paciente IN ('0','1','2','3','4','5','6','7','8','9','K'))
);

-- ------------------------------------------------------------
-- Tabla DIGITADOR
-- Almacena los datos de los digitadores que ingresan recetas
-- El digito verificador solo permite valores 0-9 y K
-- ------------------------------------------------------------
CREATE TABLE digitador (
    run_digitador   NUMBER          NOT NULL,
    dv_digitador    CHAR(1)         NOT NULL,
    nombre          VARCHAR2(50)    NOT NULL,
    apellido        VARCHAR2(50)    NOT NULL,
    CONSTRAINT digitador_pk PRIMARY KEY (run_digitador),
    CONSTRAINT digitador_dv_ck CHECK (dv_digitador IN ('0','1','2','3','4','5','6','7','8','9','K'))
);

-- ------------------------------------------------------------
-- Tabla TIPO_RECETA
-- Almacena los tipos de receta: digital, magistral, retenida,
-- general, veterinaria
-- ------------------------------------------------------------
CREATE TABLE tipo_receta (
    id_tipo_receta  NUMBER          NOT NULL,
    descripcion     VARCHAR2(50)    NOT NULL,
    CONSTRAINT tipo_receta_pk PRIMARY KEY (id_tipo_receta)
);

-- ------------------------------------------------------------
-- Tabla TIPO_MEDICAMENTO
-- Almacena los tipos de medicamento (generico, marca)
-- ------------------------------------------------------------
CREATE TABLE tipo_medicamento (
    id_tipo_medicamento NUMBER      NOT NULL,
    descripcion     VARCHAR2(50)    NOT NULL,
    CONSTRAINT tipo_medicamento_pk PRIMARY KEY (id_tipo_medicamento)
);

-- ------------------------------------------------------------
-- Tabla MEDICAMENTO
-- Almacena los medicamentos con nombre, dosis y stock
-- ------------------------------------------------------------
CREATE TABLE medicamento (
    id_medicamento  NUMBER          NOT NULL,
    nombre          VARCHAR2(100)   NOT NULL,
    dosis_recomendada VARCHAR2(100) NOT NULL,
    stock           NUMBER          NOT NULL,
    id_tipo_medicamento NUMBER      NOT NULL,
    CONSTRAINT medicamento_pk PRIMARY KEY (id_medicamento),
    CONSTRAINT medicamento_tipo_fk FOREIGN KEY (id_tipo_medicamento) 
        REFERENCES tipo_medicamento (id_tipo_medicamento)
);

-- ------------------------------------------------------------
-- Tabla RECETA
-- Almacena las recetas medicas emitidas por los medicos
-- Cada receta tiene un identificador unico
-- Incluye fecha emision, observaciones y fecha expiracion
-- ------------------------------------------------------------
CREATE TABLE receta (
    id_receta       NUMBER          NOT NULL,
    fecha_emision   DATE            NOT NULL,
    observaciones   VARCHAR2(500),
    fecha_expiracion DATE,
    diagnostico     VARCHAR2(200)   NOT NULL,
    run_paciente    NUMBER          NOT NULL,
    run_medico      NUMBER          NOT NULL,
    run_digitador   NUMBER          NOT NULL,
    id_tipo_receta  NUMBER          NOT NULL,
    CONSTRAINT receta_pk PRIMARY KEY (id_receta),
    CONSTRAINT receta_paciente_fk FOREIGN KEY (run_paciente) 
        REFERENCES paciente (run_paciente),
    CONSTRAINT receta_medico_fk FOREIGN KEY (run_medico) 
        REFERENCES medico (run_medico),
    CONSTRAINT receta_digitador_fk FOREIGN KEY (run_digitador) 
        REFERENCES digitador (run_digitador),
    CONSTRAINT receta_tipo_fk FOREIGN KEY (id_tipo_receta) 
        REFERENCES tipo_receta (id_tipo_receta)
);

-- ------------------------------------------------------------
-- Tabla DETALLE_RECETA
-- Tabla intermedia entre RECETA y MEDICAMENTO
-- Cada receta puede contener uno o mas medicamentos
-- ------------------------------------------------------------
CREATE TABLE detalle_receta (
    id_receta       NUMBER          NOT NULL,
    id_medicamento  NUMBER          NOT NULL,
    cantidad        NUMBER          NOT NULL,
    CONSTRAINT detalle_receta_pk PRIMARY KEY (id_receta, id_medicamento),
    CONSTRAINT detalle_receta_receta_fk FOREIGN KEY (id_receta) 
        REFERENCES receta (id_receta),
    CONSTRAINT detalle_receta_med_fk FOREIGN KEY (id_medicamento) 
        REFERENCES medicamento (id_medicamento)
);

-- ------------------------------------------------------------
-- Tabla PAGO
-- Almacena los pagos asociados a las recetas
-- Una receta puede tener uno o mas pagos
-- Cada pago registra monto y fecha
-- ------------------------------------------------------------
CREATE TABLE pago (
    id_pago         NUMBER          NOT NULL,
    monto           NUMBER          NOT NULL,
    fecha_pago      DATE            NOT NULL,
    metodo_pago     VARCHAR2(20),
    id_receta       NUMBER          NOT NULL,
    CONSTRAINT pago_pk PRIMARY KEY (id_pago),
    CONSTRAINT pago_receta_fk FOREIGN KEY (id_receta) 
        REFERENCES receta (id_receta)
);

-- ============================================================
-- CASO 2: MODIFICACIONES CON ALTER TABLE
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Agregar precio unitario al medicamento
-- El precio oscila entre $1.000 y $2.000.000
-- ------------------------------------------------------------
ALTER TABLE medicamento ADD (
    precio_unitario NUMBER
);

ALTER TABLE medicamento ADD CONSTRAINT medicamento_precio_ck 
    CHECK (precio_unitario BETWEEN 1000 AND 2000000);

-- ------------------------------------------------------------
-- 2.2 Agregar restriccion de metodo de pago
-- Solo se permiten: EFECTIVO, TARJETA, TRANSFERENCIA
-- ------------------------------------------------------------
ALTER TABLE pago ADD CONSTRAINT pago_metodo_ck 
    CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA'));

-- ------------------------------------------------------------
-- 2.3 Eliminar columna edad y agregar fecha de nacimiento
-- Se optimiza el acceso a datos del paciente
-- ------------------------------------------------------------
ALTER TABLE paciente DROP COLUMN edad;

ALTER TABLE paciente ADD (
    fecha_nacimiento DATE
);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================

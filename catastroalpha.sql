DROP DATABASE IF EXISTS catastro;
CREATE DATABASE IF NOT EXISTS catastro;
use catastro;

-- personas que pagan recibos e impuestos variados
create table contribuyente(
id_contribuyente int not null AUTO_INCREMENT,
correo varchar(50) not null,
direccion VARCHAR(50),
nit VARCHAR(15) NOT NULL,
PRIMARY KEY (id_contribuyente),
estado VARCHAR(25),
UNIQUE (id_contribuyente , nit)
);

CREATE TABLE empresa (
    id_empresa INT NOT NULL AUTO_INCREMENT,
    id_contribuyente INT NOT NULL,
    nombre_juridico VARCHAR(50),
    nombre_comercial VARCHAR(50),
    estado VARCHAR(25),
    CONSTRAINT FOREIGN KEY (id_contribuyente)
        REFERENCES contribuyente (id_contribuyente),
    PRIMARY KEY (id_empresa)
);

CREATE TABLE persona (
    id_persona INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    id_contribuyente INT NOT NULL,
    estado VARCHAR(25),
    CONSTRAINT FOREIGN KEY (id_contribuyente)
        REFERENCES contribuyente (id_contribuyente),
    PRIMARY KEY (id_persona)
);

create table rol(
id_rol int not null AUTO_INCREMENT,
rol varchar(50) not null,
estado VARCHAR(25),
PRIMARY KEY (id_rol)
);

-- personas que operan el sistema
create table usuario(
id_usuario int not null AUTO_INCREMENT,
usuario varchar(50) not null,
clave varchar(50) not null,
correo varchar(50) not null,
id_rol int not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_rol)
        REFERENCES rol (id_rol),
PRIMARY KEY (id_usuario)
);

-- se pueden crear cualquier evento clasificado para hacer busquedas como: colonia_create, colonia_update
create table tipo_evento(
id_tipo_evento int not null AUTO_INCREMENT,
nombre varchar(50) not null,
estado VARCHAR(25),
PRIMARY KEY (id_tipo_evento)
);
create table bitacora(
id_bitacora int not null AUTO_INCREMENT,
id_usuario int not null,
detalle text not null,
fecha_hora date not null,
id_tipo_evento int not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
        CONSTRAINT FOREIGN KEY (id_tipo_evento)
        REFERENCES tipo_evento (id_tipo_evento),
PRIMARY KEY (id_bitacora)
);

create table colonia(
id_colonia int not null AUTO_INCREMENT,
nombre varchar(50) not null,
estado VARCHAR(25),
PRIMARY KEY (id_colonia)
);

CREATE TABLE zona (
    id_zona INT NOT NULL,
    nombre VARCHAR(25),
    id_colonia INT NOT NULL,
    PRIMARY KEY (id_zona),
    estado VARCHAR(25),
    CONSTRAINT FOREIGN KEY (id_colonia)
        REFERENCES colonia (id_colonia)
);

-- los inmuebles tienen mismos datos, dispenso seran los que no tangan asigandos impuestos
-- impuestos inmuebles es M:M
create table inmueble(
id_inmueble int not null AUTO_INCREMENT,
id_zona INT NOT NULL,
ubicacion VARCHAR(100),
dimensiones VARCHAR(50),
id_contribuyente INT NOT NULL,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_contribuyente)
REFERENCES contribuyente (id_contribuyente),
PRIMARY KEY (id_inmueble),
CONSTRAINT FOREIGN KEY (id_zona)
REFERENCES zona (id_zona)
);

CREATE TABLE cuenta (
    id_cuenta INT NOT NULL AUTO_INCREMENT,
    numero_cuenta BIGINT NOT NULL,
    nombre text not null,
    estado VARCHAR(25),
    PRIMARY KEY (id_cuenta),
    UNIQUE KEY (numero_cuenta)
);

-- el calculo es responsabilidad del programa, buscando movimientos por fecha se sabe si se pagaron
create table impuesto(
id_impuesto int not null AUTO_INCREMENT,
id_cuenta INT NOT NULL,
nombre varchar(50) not null,
descripcion text not null,
interes_mensual double not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_cuenta)
REFERENCES cuenta (id_cuenta),
PRIMARY KEY (id_impuesto)
);

-- se crean como consecuencia secundaria, permite pagar impuestos en recibos o directamente
-- sirve para guardar ingresos de impuestos y evitar calcularlos leyendo todos los recibos que tengan
-- junto con cualquier otro tramite que pague impuestos
create table pago_impuesto(
id_pago_impuesto int not null AUTO_INCREMENT,
id_impuesto int not null,
id_contribuyente INT NOT NULL,
monto double not null,
interes double not null,
fecha date not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_impuesto)
        REFERENCES impuesto (id_impuesto),
        CONSTRAINT FOREIGN KEY (id_contribuyente)
        REFERENCES contribuyente (id_contribuyente),
PRIMARY KEY (id_pago_impuesto)
);
 
-- inmuebles con 0 son dispenso
create table grabacion_impuesto_inmueble(
id_grabacion_impuesto_inmueble int not null AUTO_INCREMENT,
id_impuesto int not null,
id_inmueble int not null,
monto_mensual double not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_impuesto)
        REFERENCES impuesto (id_impuesto),
        CONSTRAINT FOREIGN KEY (id_inmueble)
        REFERENCES inmueble (id_inmueble),
PRIMARY KEY (id_grabacion_impuesto_inmueble)
);

-- pago de impuesto por inmueble
-- deben ser periodicos
create table movimiento_cuenta_inmueble(
id_movimiento_cuenta int not null AUTO_INCREMENT,
id_contribuyente int not null,
id_grabacion_impuesto_inmueble int not null,
interes double,
fecha date not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_contribuyente)
        REFERENCES contribuyente (id_contribuyente),
        CONSTRAINT FOREIGN KEY (id_grabacion_impuesto_inmueble)
        REFERENCES grabacion_impuesto_inmueble (id_grabacion_impuesto_inmueble),
PRIMARY KEY (id_movimiento_cuenta)
);

create table recibo_agua(
id_recibo_agua int not null AUTO_INCREMENT,
id_contribuyente int not null,
subtotal DOUBLE NOT NULL,
total DOUBLE NOT NULL,
interes_mensual double not null,
fechaEmitido DATE NOT NULL,
fechaCancelado DATE,
fechaVencimiento DATE NOT NULL,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_contribuyente)
        REFERENCES contribuyente (id_contribuyente),
PRIMARY KEY (id_recibo_agua)
);

-- permite impuestos, interes...
create table detalle_recibo_agua(
id_detalle_recibo_agua int not null AUTO_INCREMENT,
id_recibo_agua int not null,
monto double not null,
nombre varchar(50) not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_recibo_agua)
        REFERENCES recibo_agua (id_recibo_agua),
PRIMARY KEY (id_detalle_recibo_agua)
);

create table pago_agua(
id_pago_agua int not null AUTO_INCREMENT,
id_recibo_agua int not null,
id_cuenta INT NOT NULL,
fecha date not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_recibo_agua)
        REFERENCES recibo_agua (id_recibo_agua),
        CONSTRAINT FOREIGN KEY (id_cuenta)
        REFERENCES cuenta (id_cuenta),
PRIMARY KEY (id_pago_agua)
);

create table tarjeta(
id_tarjeta int not null AUTO_INCREMENT,
detalle text not null,
id_contribuyente int not null,
fecha_creacion date not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_contribuyente)
        REFERENCES contribuyente (id_contribuyente),
PRIMARY KEY (id_tarjeta)
);

CREATE TABLE grupo (
    id_grupo INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(25) NOT NULL,
    estado VARCHAR(25),
    PRIMARY KEY (id_grupo)
);

CREATE TABLE detalleGrupo (
    id_detalle_grupo INT NOT NULL AUTO_INCREMENT,
    id_grupo INT NOT NULL,
    id_inmueble INT NOT NULL,
    estado VARCHAR(25),
    CONSTRAINT FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo),
    CONSTRAINT FOREIGN KEY (id_inmueble)
        REFERENCES inmueble (id_inmueble),
        PRIMARY KEY (id_detalle_grupo)
);

create table contador(
id_contador INT NOT NULL AUTO_INCREMENT,
puesto_en_servicio date not null,
id_contribuyente int not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_contribuyente)
        REFERENCES contribuyente (id_contribuyente),
PRIMARY KEY (id_contador)
);

create table medida(
id_medida INT NOT NULL AUTO_INCREMENT,
medida double not null,
realizada date not null,
id_contador int not null,
estado VARCHAR(25),
CONSTRAINT FOREIGN KEY (id_contador)
        REFERENCES contador (id_contador),
PRIMARY KEY (id_medida)
);

CREATE TABLE aviso_contribuyente (
    id_aviso_contribuyente INT NOT NULL,
    fecha_emision DATETIME,
	id_contribuyente int not null,
    mensaje text,
    estado VARCHAR(25),
    esUrgente TINYINT NOT NULL, -- 0 no es urgente / 1 es urgente !
    CONSTRAINT FOREIGN KEY (id_contribuyente)
        REFERENCES contribuyente (id_contribuyente),
        PRIMARY KEY (id_aviso_contribuyente)
);

CREATE TABLE aviso_grupo (
    id_aviso_grupo INT NOT NULL,
    fecha_emision DATETIME,
    id_grupo INT NOT NULL,
    mensaje text,
    estado VARCHAR(25),
    esUrgente TINYINT NOT NULL, -- 0 no es urgente / 1 es urgente !
    CONSTRAINT FOREIGN KEY (id_grupo)
	REFERENCES grupo (id_grupo),
	PRIMARY KEY (id_aviso_grupo)
);

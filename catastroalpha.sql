DROP DATABASE IF EXISTS catastro;
CREATE DATABASE IF NOT EXISTS catastro;
use catastro;

CREATE TABLE empresa (
    idEmpresa INT NOT NULL AUTO_INCREMENT,
    nombreJuridico VARCHAR(50),
    nombreComercial VARCHAR(50),
    nit VARCHAR(15) NOT NULL,
    direccion VARCHAR(50),
    PRIMARY KEY (idEmpresa),
    UNIQUE (idEmpresa , nit)
);

CREATE TABLE colonia (
    idColonia INT NOT NULL,
    nombre VARCHAR(25),
    PRIMARY KEY (idColonia)
);

CREATE TABLE zona (
    idZona INT NOT NULL,
    nombre VARCHAR(25),
    idColonia INT NOT NULL,
    PRIMARY KEY (idZona),
    CONSTRAINT FOREIGN KEY (idColonia)
        REFERENCES colonia (idColonia)
);

CREATE TABLE inmueble (
    ubicacion VARCHAR(100),
    dimensiones VARCHAR(50),
    idInmueble INT NOT NULL PRIMARY KEY,
    esDispenso INT NOT NULL DEFAULT 0,
    idPropietario INT NOT NULL,
    CONSTRAINT FOREIGN KEY (idPropietario)
        REFERENCES empresa (idEmpresa),
    idColonia INT NOT NULL,
    CONSTRAINT FOREIGN KEY (idColonia)
        REFERENCES colonia (idColonia)
);

CREATE TABLE tributo (
    idTributo INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    valorDescuento DOUBLE NOT NULL
);

CREATE TABLE cuenta (
    idCuenta INT NOT NULL AUTO_INCREMENT,
    numeroCuenta BIGINT NOT NULL,
    idEmpresa INT NOT NULL,
    PRIMARY KEY (idCuenta),
    UNIQUE KEY (numeroCuenta),
    CONSTRAINT FOREIGN KEY (idEmpresa)
        REFERENCES empresa (idEmpresa)
);

CREATE TABLE recibo ( -- Estaaa
    idRecibo INT NOT NULL,
    subtotal DOUBLE NOT NULL,
    total DOUBLE NOT NULL,
    fechaEmitido DATE,
    fechaCancelado DATE,
    fechaVencimiento DATE,
    idEmpresa INT NOT NULL,
    idEmpleado INT NOT NULL,
    PRIMARY KEY (idRecibo),
    CONSTRAINT FOREIGN KEY (idEmpresa)
        REFERENCES empresa (idEmpresa)
);

CREATE TABLE detallerecibo (
    idDetalleRecibo INT NOT NULL,
    idRecibo INT NOT NULL,
    idTributo INT NOT NULL,
    PRIMARY KEY (idRecibo),
    CONSTRAINT FOREIGN KEY (idTributo)
        REFERENCES tributo (idTributo),
    CONSTRAINT FOREIGN KEY (idRecibo)
        REFERENCES recibo (idRecibo)
);

CREATE TABLE tipoTransaccion ( -- DEbito o credito
    idTipoTransaccion INT NOT NULL,
    nombre VARCHAR(25),
    PRIMARY KEY (idTipoTransaccion)
);

CREATE TABLE transaccion (
    idTransaccion INT NOT NULL,
    montoPagado DOUBLE NOT NULL,
    fechaRealizado DATETIME NOT NULL,
    sobrecargo DOUBLE,
    descuento DOUBLE,
    idCuenta INT NOT NULL,
    PRIMARY KEY (idTransaccion),
    CONSTRAINT FOREIGN KEY (idCuenta)
        REFERENCES cuenta (idCuenta),
    idTipoTransaccion INT NOT NULL,
    CONSTRAINT FOREIGN KEY (idTipoTransaccion)
        REFERENCES tipoTransaccion (idTipoTransaccion)
);

CREATE TABLE estadoCuenta (
    idEstadoCuenta INT NOT NULL,
    fechaEmision DATETIME NOT NULL,
    PRIMARY KEY (idEstadoCuenta)
);

-- Tengo algo de dudas con las siguientes tablas:

CREATE TABLE detalle_estadocuenta (
    idDetalleEstadoCuenta INT NOT NULL,
    idEstadoCuenta INT NOT NULL,
    idTransaccion INT NOT NULL,
    PRIMARY KEY (idDetalleEstadoCuenta),
    CONSTRAINT FOREIGN KEY (idEstadoCuenta)
        REFERENCES estadoCuenta (idEstadoCuenta),
    CONSTRAINT FOREIGN KEY (idTransaccion)
        REFERENCES transaccion (idTransaccion)
);

CREATE TABLE grupo (
    idGrupo INT NOT NULL,
    nombre VARCHAR(25) NOT NULL,
    PRIMARY KEY (idGrupo)
);

CREATE TABLE detalleGrupo (
    idDetalleGrupo INT NOT NULL,
    idGrupo INT NOT NULL,
    idInmueble INT NOT NULL,
    CONSTRAINT FOREIGN KEY (idGrupo)
        REFERENCES grupo (idGrupo),
    CONSTRAINT FOREIGN KEY (idInmueble)
        REFERENCES inmueble (idInmueble)
);

CREATE TABLE aviso (
    idAviso INT NOT NULL,
    fechaEmision DATETIME,
    idDestinatario INT NOT NULL,
    mensaje VARCHAR(250),
    esUrgente TINYINT NOT NULL -- 0 no es urgente / 1 es urgente !
);

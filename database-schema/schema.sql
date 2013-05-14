-- Assumindo MySQL para a base de dados
-- DROP DATABASE IF EXISTS perlpro;
CREATE DATABASE IF NOT EXISTS perlpro
    DEFAULT CHARACTER SET 'UTF8'
    DEFAULT COLLATE 'UTF8_SWEDISH_CI';

USE perlpro;

-- DROP TABLE IF EXISTS usuario
CREATE TABLE usuario (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
      , nome VARCHAR (100) NOT NULL 
      , password VARCHAR (128) NOT NULL
      , ativo TINYINT UNSIGNED NOT NULL DEFAULT 0
      , data_criado TIMESTAMP NOT NULL
      , data_modificado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- DROP TABLE IF EXISTS usuario_email
CREATE TABLE usuario_email (
	id BIGINT UNSINGED NOT NULL AUTO_INCREMENT PRIMARY KEY 
      , id_usuario BIGINT UNSIGNED NOT NULL
      , FOREIGN KEY ( id_usuario ) REFERENCES usuario ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
      , email VARCHAR ( 512 ) NOT NULL
      , primario TINYINT UNSIGNED NOT NULL DEFAULT 1
) ENGINE = InnoDB;

-- DROP TABLE IF EXISTS usuario_extra_info
CREATE TABLE usuario_extra_info ( 
        id_usuario BIGINT UNSIGNED NOT NULL
      , sobre VARCHAR(500) NOT NULL
      , data_criado TIMESTAMP NOT NULL
      , data_modificado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      , FOREIGN KEY ( id_usuario ) REFERENCES usuario ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- DROP TABLE IF EXISTS mapa_usuario_empresa
CREATE TABLE mapa_usuario_empresa (
       id_usuario BIGINT UNSIGNED NOT NULL
     , id_empresa BIGINT UNSIGNED NOT NULL
     , FOREIGN KEY ( id_usuario ) REFERENCES usuario ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
     , FOREIGN KEY ( id_empresa ) REFERENCES empresa ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
     , data_entrada TIMESTAMP NOT NULL
     , data_saida TIMESTAMP NULL
) ENGINE=InnoDB;

-- DROP TABLE IF EXISTS empresa
CREATE TABLE empresa (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
      , nome VARCHAR ( 100 ) NOT NULL 
      -- TODO: talvez seja melhor ter um mapa de cidades para empresas (exemplo: a IBM tem escritorios em muitas cidades).
      , id_cidade BIGINT UNSIGNED NULL
      , FOREING KEY ( id_cidade ) REFERENCES cidade ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
      -- TODO: puxar a orelha do Daniel Vinciguerra - o pessoal deveria ir ao website da empresa saber destas coisas.
      -- , descricao VARCHAR( 10 ) NULL
      , data_criado TIMESTAMP NOT NULL
      , data_modificado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- DROP TABLE IF EXISTS empresa_website
CREATE TABLE empresa_website (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
      , id_empresa BIGINT UNSIGNED NOT NULL 
      , FOREIGN KEY ( id_empresa ) REFERENCES empresa ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
      , url VARCHAR ( 2048 ) NOT NULL
) ENGINE = InnoDB;

-- DROP TABLE IF EXISTS cidade
CREATE TABLE cidade (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
      , nome VARCHAR ( 150 ) NOT NULL 
      , id_estado BIGINT UNSIGNED 
      , FOREIGN KEY ( id_estado ) REFERENCES estado ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
      , id_pais BIGINT UNSIGNED
      , FOREIGN KEY ( id_pais ) REFERENCES pais ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
      , UNIQUE ( id_pais, id_estado, nome )
) ENGINE = InnoDB;

CREATE TABLE estado (
        id BIGINT UNSINGED NOT NULL AUTO_INCREMENT PRIMARY KEY
      , nome VARCHAR (70)
      , id_pais BIGINT UNSIGNED NOT NULL
      , UNIQUE ( id_pais, nome )
      , FOREIGN KEY ( id_pais ) REFERENCES pais ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- DROP TABLE IF EXISTS pais
CREATE TABLE pais (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
      , nome VARCHAR ( 100 ) NOT NULL
      , UNIQUE ( nome )
) ENGINE = InnoDB;

-- DROP TABLE IF EXISTS oportunidade
CREATE TABLE oportunidade (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
      , id_empresa BIGINT NOT NULL
      , FOREIGN KEY ( id_empresa ) REFERENCES empresa ( id ) ON DELETE RESTRICT ON UPDATE CASCADE 
      , titulo_anuncio VARCHAR( 150 ) NOT NULL
      , corpo_anuncio TINYTEXT NOT NULL
      , data_adicionado TIMESTAMP NOT NULL
      , data_modificado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- DROP TABLE IF EXISTS subscricao_noticias
CREATE TABLE subscricao_noticias (
        id_usuario_email BIGINT UNSIGNED NOT NULL
      , UNIQUE( id_usuario_email )
      , FOREIGN KEY ( id_usuario_email ) REFERENCES usuario_email ( id ) ON DELETE RESTRICT ON UPDATE CASCADE
      , data_adicionado TIMESTAMP NOT NULL
      , data_modificado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      , data_ultimo_envio TIMESTAMP NOT NULL
) ENGINE = InnoDB;



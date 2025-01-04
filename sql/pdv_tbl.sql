 DROP TABLE IF EXISTS tb_usuario;
CREATE TABLE tb_usuario (
    id int(11) NOT NULL AUTO_INCREMENT,
    email varchar(70) NOT NULL,
    hash varchar(64) NOT NULL,
    nome varchar(30) NOT NULL DEFAULT "",
    token varchar(64) DEFAULT NULL,
    access int(11) DEFAULT -1,
    asaas_id varchar(16) DEFAULT NULL,
    cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expira TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	UNIQUE KEY (hash),
	UNIQUE KEY (email),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- ALTER TABLE tb_usuario ADD expira TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
	INSERT INTO tb_usuario (email,hash,access,nome)VALUES("tales@planet3.com.br","b494f6a8b457c58f8feaac439d771a15045337826d72be5b14bb2f224dc7eb39",0,"Developer");
-- UPDATE tb_usuario SET nome="Tales C. Dantas" WHERE id=1;

 DROP TABLE IF EXISTS tb_usr_perm_perfil;
CREATE TABLE tb_usr_perm_perfil (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    perm varchar(50) NOT NULL DEFAULT "0",
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE IF EXISTS tb_mail;
CREATE TABLE tb_mail (
	data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    id_from int(11) NOT NULL,
    id_to int(11) NOT NULL,
    message varchar(1000),
    looked boolean DEFAULT 0,
    FOREIGN KEY (id_from) REFERENCES tb_usuario(id),
    FOREIGN KEY (id_to) REFERENCES tb_usuario(id),
    PRIMARY KEY (data,id_from)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE IF EXISTS tb_calendario;
CREATE TABLE tb_calendario (
    id_user int(11) NOT NULL,
    data_agd date NOT NULL,
    obs varchar(255),
    PRIMARY KEY (id_user,data_agd)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* FIM PADRÃO */

/* EMPRESAS */

DROP TABLE tb_empresa;
CREATE TABLE tb_empresa(
    id int(11) NOT NULL AUTO_INCREMENT,
    razao_social varchar(80) NOT NULL,
    fantasia varchar(40) DEFAULT null,
    cnpj varchar(14) DEFAULT NULL,
    ie varchar(14) DEFAULT NULL,
    im varchar(14) DEFAULT NULL,
    end varchar(60) DEFAULT NULL,
	num varchar(6) DEFAULT NULL,
    comp varchar(50) DEFAULT NULL,
    bairro varchar(60) DEFAULT NULL,
    cidade varchar(30) DEFAULT NULL,
    uf varchar(2) DEFAULT NULL,
    cep varchar(10) DEFAULT NULL,
    cliente BOOLEAN DEFAULT 1,
    ramo varchar(80) DEFAULT NULL,
    tel varchar(15) DEFAULT NULL,
    email varchar(80) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* PRODUTOS */

DROP TABLE tb_produto;
CREATE TABLE tb_produto(
    id int(11) NOT NULL AUTO_INCREMENT,
    id_emp int(11) DEFAULT NULL,
    descricao varchar(80) NOT NULL,
    estoque double DEFAULT 0,
    estq_min double DEFAULT 0,
    und varchar(10) DEFAULT "UND",
    ncm varchar(8) DEFAULT NULL,
	cod_int int(11) DEFAULT NULL,
    cod_bar varchar(15) DEFAULT NULL,
    cod_forn varchar(20) DEFAULT NULL,
    consumo BOOLEAN DEFAULT 0,
    custo double DEFAULT 0,
    markup double DEFAULT 0,
    local varchar(20),
    disponivel boolean DEFAULT 1,
    UNIQUE KEY (descricao),
    FOREIGN KEY (id_emp) REFERENCES tb_empresa(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* CLIENTES */

DROP TABLE IF EXISTS tb_cliente;
CREATE TABLE tb_cliente (
  id int(11) NOT NULL AUTO_INCREMENT,
  nome varchar(50) NOT NULL,
  cpf varchar(12) DEFAULT NULL,
  cel varchar(15) DEFAULT NULL,
  saldo double NOT NULL DEFAULT 0,
  obs varchar(255) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
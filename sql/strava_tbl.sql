 DROP TABLE IF EXISTS tb_usuario;
CREATE TABLE tb_usuario (
    id int(11) NOT NULL AUTO_INCREMENT,
    email varchar(70) NOT NULL,
    hash varchar(64) NOT NULL,
    nome varchar(30) NOT NULL DEFAULT "",
    token varchar(64) DEFAULT NULL,
    access int(11) DEFAULT -1,
    cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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

 DROP TABLE IF EXISTS tb_post;
CREATE TABLE tb_post (
    id int(11) NOT NULL AUTO_INCREMENT,
    id_user int(11) NOT NULL,
    id_parent int(11) DEFAULT NULL,
    nome varchar(30) DEFAULT "",
    texto varchar(512) NOT NULL DEFAULT "",
    dist double DEFAULT 0,
    mov_time int DEFAULT 0,
    time int DEFAULT 0,
    elev int DEFAULT 0,
    date_trk datetime DEFAULT NULL,
    file varchar(256) DEFAULT "",
    cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo varchar(3) DEFAULT "TXT",
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE IF EXISTS tb_post_like;
CREATE TABLE tb_post_like (
    id_post int(11) NOT NULL,
    id_user int(11) NOT NULL,
    FOREIGN KEY (id_post) REFERENCES tb_post(id),
    FOREIGN KEY (id_user) REFERENCES tb_usuario(id),    
    PRIMARY KEY (id_post,id_user)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE IF EXISTS tb_post_view;
CREATE TABLE tb_post_view (
    id_post int(11) NOT NULL,
    id_user int(11) NOT NULL,
    FOREIGN KEY (id_post) REFERENCES tb_post(id),
    FOREIGN KEY (id_user) REFERENCES tb_usuario(id),
    PRIMARY KEY (id_post,id_user)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE IF EXISTS tb_follow;
CREATE TABLE tb_follow (
    id_user int(11) NOT NULL,
    id_follow int(11) NOT NULL,
    FOREIGN KEY (id_user) REFERENCES tb_usuario(id),
    FOREIGN KEY (id_follow) REFERENCES tb_usuario(id),
    PRIMARY KEY (id_user,id_follow)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_segmento;
CREATE TABLE tb_segmento (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_owner int(11) NOT NULL,
  nome varchar(60) NOT NULL,
  data date DEFAULT NULL,
  lat_ini double DEFAULT '0',
  lon_ini double DEFAULT '0',
  lat_fin double DEFAULT '0',
  lon_fin double DEFAULT '0',
  dist double DEFAULT '0',
  FOREIGN KEY (id_owner) REFERENCES tb_usuario(id),
  PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
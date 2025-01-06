/* FUNCTIONS */

 DROP PROCEDURE IF EXISTS sp_getHash;
DELIMITER $$
	CREATE PROCEDURE sp_getHash(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SELECT SHA2(CONCAT(Iemail, Isenha), 256) AS HASH;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_allow;
DELIMITER $$
	CREATE PROCEDURE sp_allow(
		IN Iallow varchar(80),
		IN Ihash varchar(64)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @quer =CONCAT('SET @allow = (SELECT ',@access,' IN ',Iallow,');');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
	END $$
DELIMITER ;

/* LOGIN */

 DROP PROCEDURE IF EXISTS sp_login;
DELIMITER $$
	CREATE PROCEDURE sp_login(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @hash = (SELECT SHA2(CONCAT(Iemail, Isenha), 256));
		SELECT *, IF(nome="",SUBSTRING_INDEX(email,"@",1),nome) AS nome FROM tb_usuario WHERE hash=@hash;
	END $$
DELIMITER ;

/* USER */

 DROP PROCEDURE IF EXISTS sp_newUser;
DELIMITER $$
	CREATE PROCEDURE sp_newUser(
        IN Inome varchar(30),
		IN Iemail varchar(80),
		IN Isenha varchar(30),
        IN Iasaas_id varchar(16)
    )
	BEGIN
		SET @has_user = (SELECT COUNT(*) FROM tb_usuario WHERE email COLLATE utf8_general_ci = Iemail COLLATE utf8_general_ci);
		IF (@has_user = 0)THEN
			SET @hash = SHA2(CONCAT(Iemail, Isenha), 256);
			INSERT INTO tb_usuario (nome,email,hash,asaas_id)VALUES(Inome,Iemail,@hash,Iasaas_id);
			CALL sp_add_credit(Iasaas_id,3,0);
			SELECT hash FROM tb_usuario WHERE id= (SELECT MAX(id) FROM tb_usuario);
        ELSE
			SELECT 0 AS hash;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_reseta_pass;
DELIMITER $$
	CREATE PROCEDURE sp_reseta_pass(
        IN Iemail varchar(80)
    )
	BEGIN    
		UPDATE tb_usuario SET access=1 WHERE asaas_id COLLATE utf8_general_ci = Iasaas_id COLLATE utf8_general_ci;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_confirma_email;
DELIMITER $$
	CREATE PROCEDURE sp_confirma_email(
        IN Iasaas_id varchar(16)
    )
	BEGIN    
		UPDATE tb_usuario SET access=1 WHERE asaas_id COLLATE utf8_general_ci = Iasaas_id COLLATE utf8_general_ci;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_setUser;
DELIMITER $$
	CREATE PROCEDURE sp_setUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Inome varchar(30),
		IN Iemail varchar(80),
		IN Isenha varchar(30),
        IN Iaccess int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iemail="")THEN
				SET SQL_SAFE_UPDATES = 0;            
				DELETE FROM tb_mail WHERE id_from=Iid OR id_to=Iid;
 				DELETE FROM tb_creditos WHERE id_usuario=Iid;
 				DELETE FROM tb_clube WHERE id_usuario=Iid;
 				DELETE FROM tb_aluno WHERE id_usuario=Iid;
 				DELETE FROM tb_aula WHERE id_usuario=Iid;
 				DELETE FROM tb_agenda WHERE id_usuario=Iid;
 				DELETE FROM tb_aula_dada WHERE id_usuario=Iid;
				DELETE FROM tb_usuario WHERE id=Iid;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_usuario (email,hash,access,nome)VALUES(Iemail,SHA2(CONCAT(Iemail, Isenha), 256),Iaccess,Inome);            
                ELSE
					IF(Isenha="")THEN
						UPDATE tb_usuario SET email=Iemail, access=Iaccess, nome=Inome WHERE id=Iid;
                    ELSE
						UPDATE tb_usuario SET email=Iemail, hash=SHA2(CONCAT(Iemail, Isenha), 256), access=Iaccess, nome=Inome WHERE id=Iid;
                    END IF;
                END IF;
            END IF;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_viewUser;
DELIMITER $$
	CREATE PROCEDURE sp_viewUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_usuario WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS email, 0 AS access;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_updatePass;
DELIMITER $$
	CREATE PROCEDURE sp_updatePass(	
		IN Ihash varchar(64),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @call_id = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@call_id > 0)THEN
			UPDATE tb_user SET hash = SHA2(CONCAT(email, Isenha), 256) WHERE id=@call_id;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

/* PERMISSÂO */

 DROP PROCEDURE IF EXISTS sp_set_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_set_usr_perm_perf(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid int(11),
		IN Inome varchar(30)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			IF(Iid = 0 AND Inome != "")THEN
				INSERT INTO tb_usr_perm_perfil (nome) VALUES (Inome);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_usr_perm_perfil WHERE id=Iid;
				ELSE
					UPDATE tb_usr_perm_perfil SET nome = Inome WHERE id=Iid;
                END IF;
            END IF;			
			SELECT * FROM tb_usr_perm_perfil;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_view_usr_perm_perf(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SET @quer = CONCAT('SELECT * FROM tb_usr_perm_perfil WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

/* CALENDAR */

 DROP PROCEDURE IF EXISTS sp_view_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_view_calendar(	
		IN Ihash varchar(64),
		IN IdataIni date,
		IN IdataFin date
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT * FROM tb_calendario WHERE id_user=@id_call AND data_agd>=IdataIni AND data_agd<=IdataFin;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_set_calendar(	
		IN Ihash varchar(64),
		IN Idata date,
		IN Iobs varchar(255)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			SET @exist = (SELECT COUNT(*) FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata);
			IF(@exist AND Iobs = "")THEN
				DELETE FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata; 
			ELSE
				INSERT INTO tb_calendario (id_user, data_agd, obs) VALUES(@id_call, Idata, Iobs)
                ON DUPLICATE KEY UPDATE obs=Iobs;
			END IF;
        END IF;
	END $$
DELIMITER ;

/* MAIL */

 DROP PROCEDURE IF EXISTS sp_check_usr_mail;
DELIMITER $$
	CREATE PROCEDURE sp_check_usr_mail(
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call>0)THEN        
			SELECT COUNT(*) AS new_mail FROM tb_mail WHERE id_to = @id_call AND looked=0;
		ELSE
			SELECT 0 AS new_mail ;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_mail;
DELIMITER $$
	CREATE PROCEDURE sp_set_mail(	
		IN Ihash varchar(64),
        IN Iid_to int(11),
		IN Imessage varchar(512)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			INSERT INTO tb_mail (id_from,id_to,message) VALUES (@id_call,Iid_to,Imessage);
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_mail;
DELIMITER $$
	CREATE PROCEDURE sp_view_mail(	
		IN Ihash varchar(64),
        IN Isend boolean
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call > 0)THEN
			IF(Isend)THEN
				SELECT MAIL.*, USR.email AS mail_from
					FROM tb_mail AS MAIL 
					INNER JOIN tb_usuario AS USR
					ON MAIL.id_from = USR.id AND MAIL.id_to = @id_call;            
            ELSE
				SELECT MAIL.*, USR.email AS mail_to
					FROM tb_mail AS MAIL 
					INNER JOIN tb_usuario AS USR
					ON MAIL.id_to = USR.id AND MAIL.id_from = @id_call;            
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_del_mail;
DELIMITER $$
	CREATE PROCEDURE sp_del_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			DELETE FROM tb_mail WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_mark_mail;
DELIMITER $$
	CREATE PROCEDURE sp_mark_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			UPDATE tb_mail SET looked=1 WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_all_mail_adress;
DELIMITER $$
	CREATE PROCEDURE sp_all_mail_adress(	
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT id,email FROM tb_usuario WHERE id != @id_call ORDER BY email ASC;
	END $$
DELIMITER ;

/* FIM PADRÂO */

/* TB EMPRESA */

 DROP PROCEDURE IF EXISTS sp_view_emp;
DELIMITER $$
	CREATE PROCEDURE sp_view_emp(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_empresa WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_empresa;
DELIMITER $$
	CREATE PROCEDURE sp_set_empresa(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Irazao_social varchar(80),
		IN Ifantasia varchar(40),
		IN Icnpj varchar(14),
		IN Iie varchar(14),
		IN Iim varchar(14),
		IN Iend varchar(60),
		IN Inum varchar(6),
		IN Icomp varchar(50),
		IN Ibairro varchar(60),
		IN Icidade varchar(30),
		IN Iuf varchar(2),
		IN Icep varchar(10),
		IN Icliente BOOLEAN,
		IN Iramo varchar(80),
		IN Itel varchar(15),
		IN Iemail varchar(80)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid=0)THEN
				INSERT INTO tb_empresa (razao_social,fantasia,cnpj,ie,im,end,num,comp,bairro,cidade,uf,cep,cliente,ramo,tel,email) 
				VALUES (Irazao_social,Ifantasia,Icnpj,Iie,Iim,Iend,Inum,Icomp,Ibairro,Icidade,Iuf,Icep,Icliente,Iramo,Itel,Iemail);
			ELSE
				IF(Irazao_social = "")THEN
					DELETE FROM tb_empresa WHERE id=Iid;
				ELSE
					UPDATE tb_empresa SET razao_social=Irazao_social,fantasia=Ifantasia,cnpj=Icnpj,ie=Iie,im=Iim,end=Iend,num=Inum,
                    comp=Icomp,bairro=Ibairro,cidade=Icidade,uf=Iuf,cep=Icep,cliente=Icliente,ramo=Iramo,tel=Itel,email=Iemail
					WHERE id=Iid; 
				END IF;
			END IF;
		END IF;
	END $$
DELIMITER ;

/* TB PRODUTO */

 DROP PROCEDURE IF EXISTS sp_view_prod;
DELIMITER $$
	CREATE PROCEDURE sp_view_prod(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_prod WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
DELIMITER ; 

 DROP PROCEDURE IF EXISTS sp_set_prod;
DELIMITER $$
	CREATE PROCEDURE sp_set_prod(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_emp int(11),
		IN Idescricao varchar(80),
		IN Iestoque double,
		IN Iestq_min double,
		IN Iund varchar(10),
		IN Incm varchar(8),
		IN Icod_int int(11),
		IN Icod_bar varchar(15),
		IN Icod_forn varchar(20),
		IN Iconsumo BOOLEAN,
        IN Icusto double,
		IN Imarkup double,
        IN Ilocal varchar(20),
        IN Idisp BOOLEAN
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid = 0)THEN
				INSERT INTO tb_produto (id_emp,descricao,estoque,estq_min,und,ncm,cod_int,cod_bar,cod_forn,consumo,custo,markup,local,disponivel)
				VALUES (Iid_emp,Idescricao,Iestoque,Iestq_min,Iund,Incm,Icod_int,Icod_bar,Icod_forn,Iconsumo,Icusto,Imarkup,Ilocal,Idisp);
            ELSE
				IF(Idescricao = "")THEN
					DELETE FROM tb_produto WHERE id=Iid;
                ELSE
					UPDATE tb_produto 
                    SET id_emp=Iid_emp,descricao=Idescricao,estoque=Iestoque,estq_min=Iestq_min,und=Iund,ncm=Incm,cod_int=Icod_int,
					cod_bar=Icod_bar,cod_forn=Icod_forn,consumo=Iconsumo,custo=Icusto,markup=Imarkup,local=Ilocal,disponivel=Idisp
                    WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

/* CLIENTE */

 DROP PROCEDURE IF EXISTS sp_view_cliente;
DELIMITER $$
	CREATE PROCEDURE sp_view_cliente(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_cliente WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY nome;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;        
    
	DROP PROCEDURE IF EXISTS sp_set_cliente;
	DELIMITER $$
	CREATE PROCEDURE sp_set_cliente(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(50),
		IN Icpf varchar(12),
		IN Icel varchar(15),
		IN Isaldo double,
		IN Iobs varchar(255)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @cpf = (SELECT COUNT(*) FROM tb_cliente WHERE cpf COLLATE utf8_general_ci = Icpf COLLATE utf8_general_ci);
            IF(@cpf = 0)THEN
				IF(Iid=0)THEN
					INSERT INTO tb_cliente (nome,cpf,cel,saldo,obs)
					VALUES (Inome,Icpf,Icel,Isaldo,Iobs);
					SELECT "Cliente cadastrado com sucesso!" AS MESSAGE, Iid AS id_cliente;
                ELSE
					IF(Inome="")THEN
						DELETE FROM tb_cliente WHERE id=Iid;
						SELECT "Cliente deletado com sucesso!" AS MESSAGE, Iid AS id_cliente;
                    ELSE
						UPDATE tb_cliente 
                        SET nom=Inome,cpf=Icpf,cel=Icel,saldo=Isaldo,obs=Iobs
                        WHERE id=Iid;
						SELECT "Cliente editado com sucesso!" AS MESSAGE, @id AS id_cliente;
                    END IF;
                END IF;
			ELSE
				SELECT "Cliente já cadastrado!, verificar o CPF" AS MESSAGE,0 AS id_cliente;
            END IF;
        END IF;
	END $$
	DELIMITER ;     
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
		IN Isenha varchar(30)
    )
	BEGIN
		SET @has_user = (SELECT COUNT(*) FROM tb_usuario WHERE email COLLATE utf8_general_ci = Iemail COLLATE utf8_general_ci);
		IF (@has_user = 0)THEN
			SET @hash = SHA2(CONCAT(Iemail, Isenha), 256);
			INSERT INTO tb_usuario (nome,email,hash)VALUES(Inome,Iemail,@hash);
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
        IN Ihash varchar(64)
    )
	BEGIN    
		UPDATE tb_usuario SET access=1 WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1;
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
 				DELETE FROM tb_calendario WHERE id_user=Iid;
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

 DROP PROCEDURE IF EXISTS sp_get_usr_name;
DELIMITER $$
	CREATE PROCEDURE sp_get_usr_name(
		IN Iid_user int(11)
    )
	BEGIN    
		SELECT nome FROM tb_usuario WHERE id=Iid_user;
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

 DROP PROCEDURE IF EXISTS sp_view_post;
DELIMITER $$
	CREATE PROCEDURE sp_view_post(
		IN Ihash varchar(64),
		IN Idate datetime,
		IN Istart int(11),        
        IN Istop int(11)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);		
		SELECT *, (@id_call=id_user) AS owner FROM vw_post WHERE cadastro >= SUBDATE(Idate, 7) AND id_parent=0 LIMIT Istart,Istop;
        
        IF(@id_call != 0)THEN
			REPLACE INTO tb_post_view (SELECT id, @id_call AS A FROM vw_post WHERE cadastro >= SUBDATE(Idate, 3) AND id_parent=0 LIMIT Istart,Istop);
		END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_comm;
DELIMITER $$
	CREATE PROCEDURE sp_view_comm(
		IN Ihash varchar(64),
		IN Iid_post int(11)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);		
		SELECT *, (@id_call=id_user) AS owner FROM vw_post WHERE id_parent=Iid_post;
        
        IF(@id_call != 0)THEN
			REPLACE INTO tb_post_view (SELECT id, @id_call AS A FROM vw_post WHERE id_parent=Iid_post);
		END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_post;
DELIMITER $$
	CREATE PROCEDURE sp_set_post(
		IN Ihash varchar(64),
		IN Iid int(11),
        IN Iid_parent int(11),
        IN Inome varchar(30),
		IN Itexto varchar(512)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call > 0)THEN
			IF(Inome="")THEN
                DELETE FROM tb_post_like WHERE id_post=Iid;
                DELETE FROM tb_post_view WHERE id_post=Iid;
				DELETE FROM tb_post WHERE id=Iid OR Iid_parent=Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_post (id_user,id_parent,nome,texto,tipo)
                    VALUES(@id_call,Iid_parent,Inome,Itexto,"TXT");
                ELSE
					UPDATE tb_post SET nome=inome,texto=itexto WHERE id=Iid;
                END IF;
            END IF;
            CALL sp_view_comm(Ihash,Iid_parent);
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_track;
DELIMITER $$
	CREATE PROCEDURE sp_set_track(
		IN Ihash varchar(64),
		IN Iid int(11),
        IN Inome varchar(30),
        IN Idist double,
        IN Imov_time INT,
        IN Itime INT,
        IN Ielev INT,
        IN Idate_trk datetime,
        IN Ifile varchar(256),
        IN Ilat_min double,
        IN Ilat_max double,
        IN Ilon_min double,
        IN Ilon_max double
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call > 0)THEN
			IF(Inome!="")THEN
				IF(Iid=0)THEN
					INSERT INTO tb_post (id_user,id_parent,nome,dist,mov_time,time,elev,date_trk,tipo,file,lat_min,lat_max,lon_min,lon_max)
					VALUES(@id_call,0,Inome,Idist,Imov_time,Itime,Ielev,Idate_trk,"GPX",Ifile,Ilat_min,Ilat_max,Ilon_min,Ilon_max);
				ELSE
					UPDATE tb_post SET dist=Idist,mov_time=Imov_time,time=Itime,elev=Ielev,date_trk=Idate_trk WHERE id=Iid;
				END IF;
			END IF;
        END IF;
 		CALL sp_view_comm(Ihash,0);
	END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_like_post;
DELIMITER $$
	CREATE PROCEDURE sp_like_post(
		IN Ihash varchar(64),
		IN Iid_post int(11)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @has = (SELECT COUNT(*) FROM tb_post_like WHERE id_post = Iid_post AND id_user = @id_call);
        IF(@has>0)THEN
			DELETE FROM tb_post_like WHERE id_post = Iid_post AND id_user = @id_call; 
		ELSE 
			INSERT INTO tb_post_like (id_post,id_user) VALUES (Iid_post, @id_call);
        END IF;
        SELECT COUNT(*) AS LK FROM tb_post_like WHERE id_post = Iid_post; 
	END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_follow;
DELIMITER $$
	CREATE PROCEDURE sp_follow(
		IN Ihash varchar(64),
		IN Iid_follow int(11)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @has = (SELECT COUNT(*) FROM tb_follow WHERE id_follow = Iid_follow AND id_user = @id_call);
        IF(@has>0)THEN
			DELETE FROM tb_follow WHERE id_follow = Iid_follow AND id_user = @id_call; 
		ELSE 
			IF(@id_call != Iid_follow)THEN
				INSERT INTO tb_follow (id_follow,id_user) VALUES (Iid_follow, @id_call);
            END IF;
        END IF;
        SELECT COUNT(*) AS FLW FROM tb_follow WHERE id_user = @id_call; 
	END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_set_seg;
DELIMITER $$
	CREATE PROCEDURE sp_set_seg(
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(60),
		IN Ilat_ini double,
		IN Ilon_ini double,
		IN Ilat_fin double,
		IN Ilon_fin double,
		IN Idist double,
		IN Ialt double,
        IN IsegPoints varchar(9999)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(Inome="")THEN
			DELETE FROM tb_segmento WHERE id = Iid; 
			DELETE FROM tb_seg_points WHERE id_seg = Iid; 
		ELSE
 			INSERT INTO tb_segmento (id_owner,nome,lat_ini,lon_ini,lat_fin,lon_fin,dist,alt) 
             VALUES (@id_call,Inome,Ilat_ini,Ilon_ini,Ilat_fin,Ilon_fin,Idist,Ialt);

			SET @id = (SELECT MAX(id) FROM tb_segmento);
			SET @points = (SELECT REPLACE(IsegPoints,"id_seg",@id));

			SET @quer = CONCAT('INSERT INTO tb_seg_points (id_seg,id_count,lat,lon) VALUES ',@points);
 			PREPARE stmt1 FROM @quer;
 			EXECUTE stmt1;

        END IF;
	END $$
DELIMITER ;
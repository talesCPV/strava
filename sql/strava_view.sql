DROP VIEW IF EXISTS vw_hora_dia;
CREATE VIEW vw_hora_dia AS
	SELECT 0 AS hora UNION ALL SELECT 1
		UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
		UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
		UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13
		UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17
		UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 11
		UNION ALL SELECT 22 UNION ALL SELECT 23;

	SELECT * FROM vw_hora_dia;

DROP VIEW IF EXISTS vw_usuario;
 CREATE VIEW vw_usuario AS
	SELECT id,email,access,nome,cadastro,
	IF(access=0,"ROOT",IFNULL((SELECT nome FROM tb_usr_perm_perfil WHERE USR.access = id),"DESCONHECIDO")) AS perfil 
	FROM tb_usuario AS USR;

SELECT * FROM vw_usuario;

DROP VIEW IF EXISTS vw_post;
 CREATE VIEW vw_post AS
	SELECT PST.*,USR.nome AS nome_usuario,
	(SELECT COUNT(*) FROM tb_post WHERE id_parent=PST.id) AS COMM,
	(SELECT COUNT(*) FROM tb_post_like WHERE id_post=PST.id) AS LIK
	FROM tb_post AS PST
    INNER JOIN tb_usuario AS USR
    ON PST.id_user = USR.id;

SELECT * FROM vw_post;
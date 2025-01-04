<?php

    $query_db = array(
        /* LOGIN */
        "LOG-0"  => 'CALL sp_login("x00", "x01");', // USER, PASS

        /* USERS */
        "USR-0"  => 'CALL sp_viewUser(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "USR-1"  => 'CALL sp_setUser(@access,@hash,x00,"x01","x02","x03",x04);', // ID, NOME, EMAIL, PASS, ACCESS
        "USR-2"  => 'CALL sp_updatePass(@hash,"x00","x01");', // NOME, PASS
        "USR-3"  => 'CALL sp_check_usr_mail(@hash);', //
        "USR-4"  => 'CALL sp_newUser("x00","x01","x02","x03");', // NOME,EMAIL, PASS, ASAAS_ID

        /* CALENDAR */
        "CAL-0"  => 'CALL sp_view_calendar(@hash,"x00","x01");', // DT_INI, DT_FIN
        "CAL-1"  => 'CALL sp_set_calendar(@hash,"x00","x01");', // DT_AGD, OBS

        /* MAIL */
        "MAIL-0"  => 'CALL sp_set_mail(@hash,"x00","x01");', // ID_TO, MESSAGE
        "MAIL-1"  => 'CALL sp_view_mail(@hash,x00);', // I_SEND
        "MAIL-2"  => 'CALL sp_all_mail_adress(@hash);', //      
        "MAIL-3"  => 'CALL sp_del_mail(@hash,"x00",x01,x02);', // DATA, ID_FROM, ID_TO
        "MAIL-4"  => 'CALL sp_mark_mail(@hash,"x00",x01,x02);', // DATA, ID_FROM, ID_TO

        /* SYSTEMA */
        "SYS-0"  => 'CALL sp_set_usr_perm_perf(@access,@hash,x00,"x01");', // ID, NOME
        "SYS-1"  => 'CALL sp_view_usr_perm_perf(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE

        /* CREDITOS */
        "CRED-0" => 'SELECT * FROM tb_planos;', 
        "CRED-1" => 'CALL sp_set_plano(@access,@hash,x00,"x01","x02","x03",x04)', // id,nome,sobre,valor,credito
        "CRED-2" => 'CALL sp_add_credit("x00",x01);', // ASAAS_ID, MESES
        "CRED-3" => 'CALL sp_view_credit(@hash);',

        /* CADASTROS */

        /* EMPRESAS */
        "EMP-0"   => 'CALL sp_view_emp(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "EMP-1"   => 'CALL sp_set_empresa(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08","x09","x10","x11","x12","x13","x14","x15","x16");', // id,razao_social,fant,cnpj,ie,im,end,num,comp,bairro,cidade,uf,cep,cliente,ramo,tel,email
 
       /* PRODUTOS */
       "PROD-0"  => 'CALL sp_view_prod(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
       "PROD-1"  => 'CALL sp_set_prod(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08","x09",x10,"x11","x12","x13","x14");', //ID,ID_EMP,DESCRIÇÃO,ESTOQUE,ESTQ_MIN,UND,NCM,COD_INT,COD_BAR,COD_FORN,CONSUMO,CUSTO,MARKUP,LOCAL,DISPONIVEL

        /* CLIENTES */
        "CLI-0" => 'CALL sp_view_cliente(@access,@hash,"x00","x01","x02");', // FIELD, SIGNAL, VALUE
        "CLI-1" => 'CALL sp_set_cliente(@access,@hash,"x00","x01","x02","x03","x04","x05");', //  ID,NOME,CPF,CEL.SALDO,OBS


    );

?>
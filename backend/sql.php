<?php

    $query_db = array(
        /* LOGIN */
        "LOG-0"  => 'CALL sp_login("x00", "x01");', // USER, PASS

        /* USERS */
        "USR-0"  => 'CALL sp_viewUser(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "USR-1"  => 'CALL sp_setUser(@access,@hash,x00,"x01","x02","x03",x04);', // ID, NOME, EMAIL, PASS, ACCESS
        "USR-2"  => 'CALL sp_updatePass(@hash,"x00","x01");', // NOME, PASS
        "USR-3"  => 'CALL sp_check_usr_mail(@hash);', //
        "USR-4"  => 'CALL sp_newUser("x00","x01","x02");', // NOME,EMAIL, PASS
        "USR-5"  => 'CALL sp_get_usr_name(x00);', // USR-ID

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


        /* CADASTROS */

        /* POST */
        "POST-0"   => 'CALL sp_view_post("x00","x01",x02,x03);', // hash,datetime, Start, Stop
        "POST-1"   => 'CALL sp_set_post(@hash,x00,x01,"x02","x03");', // id ,id_parent,nome ,texto
        "POST-2"   => 'CALL sp_like_post(@hash,x01)', // id_post
        "POST-3"   => 'CALL sp_view_comm(@hash,x01)', // id_post

        /* FOLLOW */
        "FLW-0"   => 'CALL sp_follow(@hash,x01)', // id_user to follow

    );

?>
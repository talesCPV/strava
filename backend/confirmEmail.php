<?php

    if(isset($_GET['user'])){
        include_once "connect.php";

        $query = 'CALL sp_confirma_email("'.$_GET['user'].'");';

        $result = mysqli_query($conexao, $query);
        $conexao->close();

        header("Location: https://planet3.com.br/strava/");
    }

?>
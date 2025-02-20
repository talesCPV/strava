<?php

  $out = "";

  if (IsSet($_FILES["up_file"]) && IsSet($_POST["hash"])){

    $file = $_FILES["up_file"]["tmp_name"];
    $filename = $_FILES["up_file"]["name"];


    $user_hash = $_POST["hash"];
    $user_id = "";
    $user_name = "";
    $user_email = "";

    include "connect.php";
    $query = 'SELECT id,nome,email FROM tb_usuario WHERE hash  = "'.$user_hash.'" LIMIT 1;';

    $result = mysqli_query($conexao, $query);

    if(is_object($result)){      
        if($result->num_rows > 0){			
            $r = mysqli_fetch_assoc($result);
            $user_id = $r["id"];
            $user_name = $r["nome"];
            $user_email = $r["email"];
        }        
    }

    $conexao->close(); 

    $path = getcwd().'/../gpx/'.$user_email.'/';

    if (file_exists($file)){

      if (!is_dir($path."gpx/")){
        mkdir($path."gpx/", 0777, true);
      }

      if(move_uploaded_file($file, $path."gpx/".$filename)){
        $xml = simplexml_load_file($path."gpx/".$filename);

        $object = new stdClass();

        $object->name =  "".$xml->trk->name;
        $object->type =  "".$xml->trk->type;
        try{
          $object->date =  "".$xml->metadata->time;
        }catch(Exception $e){
          $object->date =  "0000-01-01T00:00:00Z";
        }
        $object->points = array();

        include_once "gps.php";

        $dist = 0;
        $acum = 0;
        $time = 0;
        $mov_time = 0;
        $lat_min = 9999;
        $lat_max = -9999;
        $lon_min = 9999;
        $lon_max = -9999;

        foreach($xml->trk->trkseg->trkpt as $trkpoint){
          $point = new stdClass();
          $point->lat = $trkpoint->attributes()->lat."";
          $point->lon = $trkpoint->attributes()->lon."";
          $point->ele = "".$trkpoint->ele;
          $hour = 0;
          $lat_min = min($point->lat, $lat_min);
          $lat_max = max($point->lat, $lat_max);
          $lon_min = min($point->lon, $lon_min);
          $lon_max = max($point->lon, $lon_max);
          try{
            $point->time = "".$trkpoint->time;
            $hour = strtotime($trkpoint->time);
          }catch(Exception $e){
            $point->time = "0000-01-01T00:00:00Z";
          }          
          $point->speed = 0;

          if($last){

            $move_dist = distance($last,$point);
            $time += $hour - $last->hour;
            if($hour){
              $point->speed = number_format((float)((3600 / ($hour - $last->hour)) * $move_dist), 2, '.', '');
            }else{
              $point->speed = 0;
            }
            if($move_dist > 0.001 ){
              $dist += $move_dist;
              $mov_time += $hour - $last->hour;

              if($point->ele > $last->ele ){
                $acum += $point->ele - $last->ele;
              }
            }
          }

          $point->dist = number_format((float)$dist, 2, '.', '');
          $point->acum = number_format((float)$acum, 2, '.', '');
          $point->time_sec = $time;
          $point->mov_time = $mov_time;

          $object->points[] = $point;
          $last = $point;
          $last->hour = $hour;
        }

        function timeFormat($time){
          $h = intdiv($time/3600,1);
          $m = $time/3600 - $h;
          return str_pad($h,2,"0",STR_PAD_LEFT).":".str_pad((round(($m- intdiv($m,1))*60)),2,"0",STR_PAD_LEFT);
        }

        $object->distance =  number_format((float)$dist, 2, '.', '');
        $object->acumulado =  number_format((float)$acum, 2, '.', '');
        $object->time =  timeFormat($time);
        $object->mov_time =  timeFormat($mov_time);
        $object->lat_min =  $lat_min;
        $object->lat_max =  $lat_max;
        $object->lon_min =  $lon_min;
        $object->lon_max =  $lon_max;

        $out = json_encode($object);

        if (!is_dir($path."json/")){
          mkdir($path."json/", 0755, true);
        }

        $file = explode(".",$filename)[0].".json";
        $json =  $path."json/".$file;

        if(!file_exists($json)){          
          setPostTrack($user_hash,$object->name,$object->distance,$mov_time,$time,$object->acumulado,$object->date,$json,$lat_min,$lat_max,$lon_min,$lon_max);
        }

        $fp = fopen($json, "w");
        fwrite($fp,$out);
        fclose($fp);

      }
    }
  }

  function setPostTrack($hash,$name,$dist,$mov_time,$time,$acum,$date,$file,$lat_min,$lat_max,$lon_min,$lon_max){

    $query = 'CALL sp_set_track("'. $hash .'",0,"'. $name .'","'. $dist .'",'. $mov_time .','. $time .','. $acum.',"'.$date.'","'.substr($file,strlen(getcwd()),null).'","'.$lat_min.'","'.$lat_max.'","'.$lon_min.'","'.$lon_max.'");';

    include "connect.php";
    $result = mysqli_query($conexao, $query);
    $conexao->close(); 

  }


  print $out;

?>
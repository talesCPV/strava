<?php

  $out = "";

  if (IsSet($_FILES["up_file"]) && IsSet($_POST["user_id"])){

    $file = $_FILES["up_file"]["tmp_name"];
    $filename = $_FILES["up_file"]["name"];
    $path = getcwd().'/../gpx/'.$_POST["user_id"].'/';

    if (file_exists($file)){

      if (!is_dir($path."gpx/")){
        mkdir($path."gpx/", 0777, true);
      }

      if(move_uploaded_file($file, $path."gpx/".$filename)){
        $xml = simplexml_load_file($path."gpx/".$filename);

        $object = new stdClass();
        $object->name =  "".$xml->trk->name;
        $object->date =  "".$xml->metadata->time;
        $object->type =  "".$xml->trk->type;
        $object->track = array();

        include_once "gps.php";

        $dist = 0;
        $acum = 0;
        $time = 0;
        $mov_time = 0;
        foreach($xml->trk->trkseg->trkpt as $trkpoint){
          $point = new stdClass();
          $point->lat = $trkpoint->attributes()->lat."";
          $point->lon = $trkpoint->attributes()->lon."";
          $point->ele = "".$trkpoint->ele;
          $point->time = "".$trkpoint->time;
          
          $hour = strtotime($trkpoint->time);

          if($last){

            $move_dist = distance($last,$point);
            $time += $hour - $last->hour;

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

          $object->track[] = $point;
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

        $out = json_encode($object);

        if (!is_dir($path."json/")){
          mkdir($path."json/", 0755, true);
        }

        $json =  $path."json/".explode(".",$filename)[0].".json";

        $fp = fopen($json, "w");
        fwrite($fp,$out);
        fclose($fp);
      }
    }
  }
  
  print $out;

?>
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
        $object->time =  "".$xml->metadata->time;
        $object->type =  "".$xml->trk->type;
        $object->track = array();

        include_once "gps.php";

        $dist = 0;
        $acum = 0;
        $lat = 0;
        foreach($xml->trk->trkseg->trkpt as $trkpoint){
          $point = new stdClass();
          $point->lat = $trkpoint->attributes()->lat."";
          $point->lon = $trkpoint->attributes()->lon."";
          $point->ele = "".$trkpoint->ele;
          $point->time = "".$trkpoint->time;

          if($last){
            $dist += distance($last,$point);

            if($point->ele - $last->ele > 0.01){
              $acum += $point->ele - $last->ele;
            }
          }

          $point->dist = $dist;
          $point->acum = $acum;

          $object->track[] = $point;
          $last = $point;
        }

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
<?php

  $out = 0;

  if (IsSet($_FILES["up_file"]) && IsSet($_POST["user_id"])){ 

    $file = $_FILES["up_file"]["tmp_name"];
//    $ext = pathinfo($_FILES["up_file"]["name"], PATHINFO_EXTENSION);    
    $filename = $_FILES["up_file"]["name"];
    $path = getcwd().'/../gpx/'.$_POST["user_id"].'/';    

    if (!is_dir($path)){
      mkdir($path, 0777, true);
    }

//    $url = $path.$filename;   
    if (file_exists($file)){    

      if (!is_dir($path."gpx/")){
        mkdir($path."gpx/", 0777, true);
      }

      if(move_uploaded_file($file, $path."gpx/".$filename)){      
//        $out = $filename;
      }

     
      $xml = simplexml_load_file($path."gpx/".$filename);
    
      $object = new stdClass();
      $object->name =  "".$xml->trk->name;
      $object->time =  "".$xml->metadata->time;
      $object->type =  "".$xml->trk->type;
      $object->track = array();
      foreach($xml->trk->trkseg->trkpt as $trkpoint)
      {
        $object->track[] =  $trkpoint  ;
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
  print $out;

?>
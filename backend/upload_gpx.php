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

    $url = $path.$filename;   
    if (file_exists($file)){    
               
      if(move_uploaded_file($file, $url)){      
        $out = $filename;
      }

     
      $xml = simplexml_load_file($url);
      $resp = array();
      $resp[] = $xml->trk->name;
      foreach($xml->trk->trkseg->trkpt as $trkpoint)
      {
        $resp[] =  $trkpoint  ;
      }

//      var_dump($resp);
      $out = json_encode($resp);


    }




  }
  print $out;

?>
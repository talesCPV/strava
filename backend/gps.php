<?php

    function distance($A,$B){
        $delta_lat = $B->lat - $A->lat;
        $delta_lon = $B->lon - $A->lon;

        $earth_radius = 6372.795477598;

        $alpha    = $delta_lat/2;
        $beta     = $delta_lon/2;
        $a        = sin(deg2rad($alpha)) * sin(deg2rad($alpha)) + cos(deg2rad($A->lat)) * cos(deg2rad($B->lat)) * sin(deg2rad($beta)) * sin(deg2rad($beta)) ;
        $c        = asin(min(1, sqrt($a)));
        $distance = 2*$earth_radius * $c;
        $distance = round($distance, 4);

        return $distance;

    }


?>
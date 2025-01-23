    google.charts.load('current', {'packages':['corechart']})

    function drawAlt(obj,id='chart_div') {

        google.charts.setOnLoadCallback(()=>{
            var data = google.visualization.arrayToDataTable(map.alt)

            var options = {
              title: 'Altimetria',
              width: '100%',
              height: 200,
              hAxis: {title: 'Km',  titleTextStyle: {color: '#333'}},
              vAxis: {minValue: 0,baseline: map.alt[1][1]}
            }
    
            var chart = new google.visualization.LineChart(document.getElementById(id))
            chart.draw(data, options)
    
            google.visualization.events.addListener(chart, 'onmouseover', function(e) {
                try{
                    setMark([obj.gps.points[e.row].lat,obj.gps.points[e.row].lon])
                }catch{null}
            })
        })

    }
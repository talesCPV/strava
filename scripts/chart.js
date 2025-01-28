    google.charts.load('current', {'packages':['corechart']})

    function drawAlt(obj,data,id='chart_div') {

console.log(data)

        google.charts.setOnLoadCallback(()=>{
            var dt = google.visualization.arrayToDataTable(data)

            var options = {
              title: 'Altimetria',
              width: '100%',
              height: 200,
              hAxis: {title: 'Km',  titleTextStyle: {color: '#333'}},
              vAxis: {minValue: 0,baseline: data[1][1]}
            }
    
            var chart = new google.visualization.LineChart(document.getElementById(id))
            chart.draw(dt, options)
    
            google.visualization.events.addListener(chart, 'onmouseover', function(e) {
                try{
                    setMark([obj.gps.points[e.row].lat,obj.gps.points[e.row].lon])
                }catch{null}
            })

            google.visualization.events.addListener(chart, 'click', function(e) {
                console.log(e)
            })

        })

    }
    google.charts.load('current', {'packages':['corechart']})

    function drawAlt(obj,id='chart_div',range) {

        obj.alt.unshift(['Km:','Alt(m)'])

        google.charts.setOnLoadCallback(()=>{
            obj.chart = new Object
            obj.chart.data = google.visualization.arrayToDataTable(obj.alt)

            obj.chart.options = {
              title: 'Altimetria',
              width: '100%',
              height: 200,
              hAxis: {title: 'Km',  titleTextStyle: {color: '#333'}},
              vAxis: {minValue: 0,baseline: 0}
            }
    
            obj.chart.view = new google.visualization.AreaChart(document.getElementById(id))
            obj.chart.view.draw(obj.chart.data, obj.chart.options)
    
            google.visualization.events.addListener(obj.chart.view, 'onmouseover', function(e) {
                try{
                    setMark([obj.gps.points[e.row].lat,obj.gps.points[e.row].lon])
                }catch{null}
            })

            google.visualization.events.addListener(obj.chart.view, 'click', function(e) {
                console.log(e)
            })


        })

    }
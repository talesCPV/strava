    google.charts.load('current', {'packages':['corechart']})

    function drawAlt(obj,id='chart_div') {


        google.charts.setOnLoadCallback(()=>{
            obj.chart = new Object
               
            obj.chart.view = new google.visualization.AreaChart(document.getElementById(id))
            obj.chart.draw = ()=>{
                const data = google.visualization.arrayToDataTable([['Km:','Alt(m)','Seg.']].concat(obj.segAlt))
                obj.chart.view.draw(data)
            }

            obj.chart.draw()
    
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
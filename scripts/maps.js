var map

function loadMap(pos){
    map = L.map('map').setView(pos, 13);

    setLayer()

}

function setLayer(lay='map'){
    const mapUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
    const satUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
    try{
        map.removeLayer(map.layer);
    }catch{ null }

    map.layer = L.tileLayer( lay=='map' ? mapUrl : satUrl , {
        maxZoom: 18,
        attribution: `Strava Clone 1.0`
    }).addTo(map);
    map.layer.name = lay
    map.setZoom(11);
}

function setMark(pos){
/*
    const icon = L.icon({
        iconUrl: 'assets/icons/bike.png',
        iconSize:    [20, 20]
    })
*/
    try{
        map.removeLayer(map.mark);
    }catch{null}

    map.mark = L.marker(pos).addTo(map)
}

function drawTrack(pts){
    map.points = []
    map.alt = [['Km: ','Alt(m) ']]
    for(let i=0; i<pts.length; i++){
        map.points.push([pts[i].lat,pts[i].lon])
        map.alt.push([parseFloat(pts[i].dist),parseFloat(pts[i].ele)])
    }
    var polygon = L.polygon(map.points).addTo(map);
}
var map

function loadMap(pos){
    map = L.map('map').setView(pos, 13);
    setLayer()
}

function setLayer(lay='map', mp=map){
    const mapUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
    const satUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
    try{
        mp.removeLayer(mp.layer);
    }catch{ null }

    mp.layer = L.tileLayer( lay=='map' ? mapUrl : satUrl , {
        maxZoom: 18,
        attribution: `Strava Clone 1.0`
    }).addTo(mp);
    mp.layer.name = lay
    mp.setZoom(11);
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

function drawTrack(pts, mp=map){
    mp.points = []
    mp.alt = [['Km: ','Alt(m) ']]
    for(let i=0; i<pts.length; i++){
        mp.points.push([pts[i].lat,pts[i].lon])
        mp.alt.push([parseFloat(pts[i].dist),parseFloat(pts[i].ele)])
    }
    mp.polygon = L.polygon(mp.points).addTo(mp);
}
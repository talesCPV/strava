
function makeIcon(color){

    return new L.Icon({
        iconUrl: `https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-${color}.png`,
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34]
    })
}

function newMap(pos,id='map'){
    const map = L.map(id).setView(pos, 13)
    map.polyline = new Object
    map.marker = new Object
    setLayer(map)
    return map
}

function setLayer(mp,lay='map'){
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

function setMark(mp,pos,name,color='blue',center=false){

    try{
        mp.removeLayer(mp.marker[name])
    }catch{null}

    mp.marker[name] = L.marker(pos,{icon: makeIcon(color)}).addTo(mp)
    if(center){
        mp.setView(new L.LatLng(pos[0],pos[1]))
    }
}

function drawTrack(pts, mp=map, name='default', color='blue',center=1){
    const points = []
    const alt = []

    try{
        mp.removeLayer(mp.polyline[name])
    }catch{null}

    for(let i=0; i<pts.length; i++){
        points.push([pts[i].lat,pts[i].lon])
        alt.push([parseFloat(pts[i].dist),parseFloat(pts[i].ele)])
    }
    mp.polyline[name] = new L.Polyline(points, {
        color: color,
        weight: 3,
        opacity: 0.5,
        smoothFactor: 1
    })
    mp.polyline[name].addTo(mp)
    mp.center = mp.polyline[name].getBounds().getCenter()
    if(center){
        mp.setView(new L.LatLng(mp.center.lat,mp.center.lng), 11)
    }

    return alt
}

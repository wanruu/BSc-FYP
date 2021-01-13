// distance function: calculate distance between p1p2 and p3p4

const laScale = 111000;
const lgScale = 85390;

// weighted distance
exports.weightedDistance = function(locations) {
    let dist = computeDistance(locations)
    // TODO: change the weight
    return 0.8 * dist.perpendicular + dist.parallel + dist.angle
}

// locations: [{latitude: ?, longitude: ?, altitude: ?}]
// return: {perpendicular: ?, parallel: ?, angle: ?}
exports.computeDistance = function(locations) {
    // ensure input parameters are valid
    if(locations.length != 4) {
        console.log("Parameter error in function distance.");
        return
    }
    
    // ensure p1p2 > p3p4
    let dist1 = (locations[0].altitude - locations[1].altitude) * (locations[0].altitude - locations[1].altitude) +
        (locations[0].latitude - locations[1].latitude) * laScale * (locations[0].latitude - locations[1].latitude) * laScale +
        (locations[0].longitude - locations[1].longitude) * lgScale * (locations[0].longitude - locations[1].longitude) * lgScale;
    let dist2 = (locations[2].altitude - locations[3].altitude) * (locations[2].altitude - locations[3].altitude) +
        (locations[2].latitude - locations[3].latitude) * laScale * (locations[2].latitude - locations[3].latitude) * laScale +
        (locations[2].longitude - locations[3].longitude) * lgScale * (locations[2].longitude - locations[3].longitude) * lgScale;
    
    // change locations to points: 
    // [{latitude: ?, longitude: ?, altitude: ?}] to [{x: ?, y: ?, z: ?}]
    var points = [];
    points.push({x: 0, y: 0, z: 0}); // regard points[0] as origin
    
    if(dist1 < dist2) {
        for(index in [2, 1, 0]) {
            let point = {
                x: (locations[index].latitude - locations[3].latitude) * laScale,
                y: (locations[index].longitude - locations[3].longitude) * lgScale,
                z: locations[index].altitude - locations[3].altitude
            };
            points.push(point);
        }
    } else {
        for(index in [1, 2, 3]) {
            let point = {
                x: (locations[index].latitude - locations[0].latitude) * laScale,
                y: (locations[index].longitude - locations[0].longitude) * lgScale,
                z: locations[index].altitude - locations[0].altitude
            };
            points.push(point);
        }
    }
    
    // calculate something for later computing
    let length1 = dist(points[0], points[1]); // length of p1p2
    let length2 = dist(points[2], points[3]); // length of p3p4
    let proj_p3 = multi(points[1], dotProduct(points[2], points[1])/length1/length1); // projection point of p3 onto p1p2
    let proj_p4 = multi(points[1], dotProduct(points[3], points[1])/length1/length1); // projection point of p4 onto p1p2
    let theta = Math.acos(dotProduct(points[1], minus(points[3], points[2])) / length1 / length2);
    
    // perpendicular distance
    let l_perp1 = dist(proj_p3, points[2]);
    let l_perp2 = dist(proj_p4, points[3]);
    let perp = (l_perp1 * l_perp1 + l_perp2 * l_perp2) / (l_perp1 + l_perp2);

    // parallel distance
    let l_para1 = Math.min(dist(proj_p3, points[0]), dist(proj_p3, points[1]));
    let l_para2 = Math.min(dist(proj_p4, points[0]), dist(proj_p4, points[1]));
    let parallel = Math.min(l_para1, l_para2);

    // angle distance: no direction
    let angle = length2 * Math.sin(theta);

    return {perpendicular: perp, parallel: parallel, angle: angle};
}

// start, end: {x: ?, y: ?, z: ?}
function dist(start, end) {
    return Math.pow((start.x - end.x) * (start.x - end.x) +
        (start.y - end.y) * (start.y - end.y) +
        (start.z - end.z) * (start.z - end.z), 0.5);
}

// p1, p2: {x: ?, y: ?, z: ?}
// return Number
function dotProduct(p1, p2) {
    return p1.x * p2.x + p1.y * p2.y + p1.z * p2.z;
}

// point: {x: ?, y: ?, z: ?}
// return: {x: ?, y: ?, z: ?}
function divide(point, num) {
    return {x: point.x / num, y: point.y / num, z: point.z / num};
}

function minus(p1, p2) {
    return {x: p1.x - p2.x, y: p1.y - p2.y, z: p1.z - p2.z}
}

function plus(p1, p2) {
    return {x: p1.x + p2.x, y: p1.y + p2.y, z: p1.z + p2.z}
}

function multi(point, num) {
    return {x: point.x * num, y: point.y * num, z: point.z * num}
}





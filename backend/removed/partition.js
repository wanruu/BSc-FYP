var distFunc = require("./distance");

const laScale = 111000;
const lgScale = 85390;

function MDLPar(traj, startIndex, endIndex) {
    // only two cp in this trajectory
    // distance between two charateristic points
    var angleSum = 0;
    var perpSum = 0;

    let diffX = (traj[startIndex].latitude - traj[endIndex].latitude) * laScale;
    let diffY = (traj[startIndex].longitude - traj[endIndex].longitude) * lgScale;
    let diffZ = traj[startIndex].altitude - traj[endIndex].altitude;

    for(var index = startIndex; index < endIndex; index++) {
        let dist = distFunc.computeDistance([traj[startIndex], traj[endIndex], traj[index], traj[index+1]]);
        // perpendicular distance
        perpSum += dist.perpendicular;
        // angle distance
        angleSum += dist.angle;
    }
    let LH = Math.log2(Math.pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5));
    let LH_D = Math.log2(angleSum) + Math.log2(perpSum);
    return LH + 0.08*LH_D;
}

function MDLNotPar(traj, startIndex, endIndex) {
    var LH = 0.0;
    // LH_D = 0 under this situation
    for(var index = startIndex; index < endIndex; index++) {
        let diffX = (traj[index].latitude - traj[index+1].latitude) * laScale;
        let diffY = (traj[index].longitude - traj[index+1].longitude) * lgScale;
        let diffZ = traj[index].altitude - traj[index+1].altitude;
        LH += Math.pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5);
    }
    return Math.log2(LH);
}

exports.partition = function(traj) {
    // characteristic points
    var cp = [];

    // add starting point to cp
    cp.push(traj[0]);

    var startIndex = 0;
    var length = 1;

    while (startIndex + length <= traj.length - 1) {
        let currIndex = startIndex + length;
        // cost if regard current point as charateristic point
        let costPar = MDLPar(traj, startIndex, currIndex);
        // cost if not regard current point as charateristic point
        let costNotPar = MDLNotPar(traj, startIndex, currIndex);
        // print(startIndex, currIndex, costPar, costNotPar)
        if(costPar > costNotPar) {
            // add previous point to cp 
            cp.push(traj[currIndex - 1])
            startIndex = currIndex - 1
            length = 1
        } else {
            length += 1
        }
    }
    // add ending point to cp
    cp.push(traj[traj.length - 1])
    return cp
}


/* require modules */
var mongoose = require('mongoose');
var express = require('express');
var bodyParser = require('body-parser');
var session = require('express-session');
var http = require('http');
var cors = require('cors');

/* define app to use express */
var app = express();
app.use(bodyParser.urlencoded({extended: false}), bodyParser.json());

/* session */
app.use(session({
    secret: 'CUMap',
    cookie: { maxAge: 1000*60*60 }
}));

/* cors */
app.use(cors());

/* connect to mongodb */
var mongodb = 'mongodb://localhost:27017/CUMap';
mongoose.set('useCreateIndex', true);
mongoose.connect(mongodb, { useNewUrlParser: true });
var db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', () => {
    console.log('Connection is open...');
});

/* define schema */
var Schema = mongoose.Schema;

var LocationSchema = Schema({
    name_en: { type: String, require: true },
    latitude: { type: Number, require: true },
    longitude: { type: Number, require: true },
    altitude: { type: Number, require: true },
    type: { type: Number, require: true }
});
var TrajectorySchema = Schema({
    points: [{ latitude: Number, longitude: Number, altitude: Number }],
    timestamp: { type: Date }
});
var PathSchema = Schema({
    start: { type: Schema.Types.ObjectId, ref: 'Location' },
    end: { type: Schema.Types.ObjectId, ref: 'Location' },
    path: [{ latitude: Number, longitude: Number, altitude: Number }],
    dist: { type: Number, require: true },
    type: { type: Number, require: true } // 0: on foot, 1: by bus
});
var VersionSchema = Schema({
    database: { type: String, require: true, unique: true},
    version: { type: String, require: true }
})

/* define model */
const LocationModel = mongoose.model('Location', LocationSchema);
const TrajectoryModel = mongoose.model('Trajectory', TrajectorySchema);
const PathModel = mongoose.model('Path', PathSchema);
const VersionModel = mongoose.model('Version', VersionSchema);

/* set header */
/* app.all('/', (req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, PUT, DELETE, POST');
    res.setHeader('Access-Control-Allow-Headers', '*');
    res.setHeader('Content-Type', 'application/json');
    next();
}); */

/* MARK: - get map img */
/* app.get('/map', (req, res) => {
    console.log("get");
    res.setHeader('Content-Type', 'image/jpeg');
    res.sendFile("cuhk-campus-map.jpg", {root: __dirname});
}); */

/* admin login */
// TODO

app.get('/versions', (req, res) => {
    console.log("GET /versions - " + Date());
    VersionModel.find({}, (err, result) => {
        if(err) {
            res.send({operation: "get", target: "version", success: false, data: []});
        } else {
            res.send({operation: "get", target: "version", success: true, data: result})
        }
    });
});

app.put('/version', (req, res) => {
    console.log("PUT /version - " + Date());
    var database = req.body.database
    var version = req.body.version
    VersionModel.findOne({database: database}, (err, result) => {
        if(err) {
            res.send({operation: "unknown", target: "version", success: false, data: []});
        } else if(result) {
            VersionModel.updateOne({database: database}, {$set: {version: version}}, (err, result) => {
                if(err) {
                    res.send({operation: "update", target: "version", success: false, data: []});
                } else {
                    res.send({operation: "update", target: "version", success: true, data: []});
                }
            });
        } else {
            VersionModel.create({database: database, version: version}, (err, result) => {
                if(err) {
                    res.send({operation: "add", target: "version", success: false, data: []});
                } else {
                    res.send({operation: "add", target: "version", success: true, data: []});
                }
            });
        }
    });
});

/* MARK: - Location Model */
app.post('/location', (req, res) => {
    console.log("POST /location - " + Date());
    var name_en = req.body.name_en;
    var latitude = req.body.latitude;
    var longitude = req.body.longitude;
    var altitude = req.body.altitude;
    var type = req.body.type;

    var newLocation = {name_en: name_en, latitude: latitude, longitude: longitude, altitude: altitude, type: type};
    LocationModel.create(newLocation, (err, result) => {
        if(err) {
            console.log(err);
            res.status(404).send();
        } else {
            res.send({id: result._id, name_en: result.name_en, latitude: result.latitude, longitude: result.longitude, altitude: result.altitude, type: result.type});
        }
    });
});

app.put('/location', (req, res) => {
    console.log("PUT /location - " + Date());
    var conditions = {_id: mongoose.Types.ObjectId(req.body.id)};
    var update = { 
        $set: {
            name_en: req.body.name_en,
            latitude: req.body.latitude,
            longitude: req.body.longitude,
            altitude: req.body.altitude,
            type: req.body.type
        }
    }
    LocationModel.updateOne(conditions, update, (err, result) => {
        if(err) {
            console.log(err);
            res.status(404).send(err);
        } else {
            res.send(result);
        }
    });
});

app.get('/locations', (req, res) => {
    console.log("GET /locations - " + Date());
    let aggr = [
        { $match: {} },
        { $project: { _id: 0, id: "$_id", name_en: "$name_en", latitude: "$latitude", longitude: "$longitude", altitude: "$altitude", type: "$type" } }
    ];
    LocationModel.aggregate(aggr, (err, result) => {
        if(err) {
            console.log(err);
            res.status(404).send();
        } else {
            res.send(result);
        }
    });
});

app.delete('/location', (req, res) => {
    console.log("DELETE /location - " + Date());
    LocationModel.deleteOne({ _id: mongoose.Types.ObjectId(req.body.id)}, (err, result) => {
        if(err) {
            console.log(err);
            res.status(404).send();
        } else {
            // { n: 0, ok: 1, deletedCount: 0 }
            res.send(result);
        }
    });
});

/* MARK: - Trajectory Model */
app.post('/trajectory', (req, res) => {
    console.log("POST /trajectory - " + Date())
    var points = req.body.points;
    var time = Date();
    TrajectoryModel.create({points: points, timestamp: time}, (err, result) => {
        if(err) {
            res.send({operation: "add", target: "trajectory", success: false, data: []});
        } else {
            res.send({operation: "add", target: "trajectory", success: true, data: []});
        }
    });
});
app.post('/trajectories', (req, res) => {
    console.log("POST /trajectories - " + Date())
    var trajectories = req.body.trajectories;
    var time = Date();
    var promises = []
    
    for(let i in trajectories) {
        var promise = TrajectoryModel.create({points: trajectories[i], timestamp: time}, (err, result) => {
            if(err) {
                res.send({operation: "add", target: "trajectories", success: false, data: []});
            }
        });
        promises.push(promise);
    }
    Promise.all(promises).then(value => {
        res.send({operation: "add", target: "trajectories", success: true, data: []});
    });
});
app.get('/trajectories', (req, res) => {
    console.log("GET /trajectories - " + Date());
    TrajectoryModel.find({}, (err, result) => {
        if(err) {
            res.send({operation: "get", target: "trajectories", success: false, data: []});
        } else {            
            var trajs = []
            for(var i in result) {
                trajs.push(result[i].points)
            }
            res.send({operation: "get", target: "trajectories", success: true, data: trajs});
        }
    })
});
app.delete('/trajectory', (req, res) => {
    console.log("DELETE /trajectory - " + Date());
    var ObjectId = require('mongodb').ObjectID
    TrajectoryModel.deleteOne({_id: ObjectId(req.body.id)}, (err, result) => {
        if(err) {
            res.send({operation: "delete", target: "trajectory", success: false, data: []});
        } else {
            res.send({operation: "delete", target: "trajectory", success: true, data: []});
        }
    });
});

app.post('/path', (req, res) => {
    console.log("POST /path - " + Date());
    var data = req.body.data;
    LocationModel.findOne({name_en: data.start.name_en, type: data.start.type}, (err, result1) => {
        if(result1) {
            LocationModel.findOne({name_en: data.end.name_en, type: data.end.type}, (err, result2) => {
                if(result2) {
                    var conditions = {start: result1._id, end: result2._id, path: data.path, dist: data.dist, type: data.type}
                    PathModel.create(conditions, (err, result) => {
                        if(err) {
                            res.send({operation: "add", target: "path", success: false, data: []});
                        } else {
                            res.send({operation: "add", target: "path", success: true, data: []});
                        }
                    });
                } else {
                    res.send({operation: "add", target: "path", success: false, data: []});
                }
            });
        } else {
            res.send({operation: "add", target: "path", success: false, data: []});
        }
    });
});

app.get('/paths', (req, res) => {
    console.log("GET /paths - " + Date());
    PathModel.find({}).populate([{path: 'start', select: 'name_en type -_id'}, {path: 'end', select: 'name_en type -_id'}]).exec((err, result) => {
        if(err) {
            res.send({operation: "get", target: "paths", success: false, data: []})
        } else {
            res.send({operation: "get", target: "paths", success: true, data: result})
        }
    });
});

http.createServer(app).listen(8000);


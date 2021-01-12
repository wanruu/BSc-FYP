# API List

Response: json

## Location Model

```js
var LocationSchema = Schema({
  _id: ObjectId,
  name_en: String, // required
  latitude: Number, // required
  longitude: Number, // required
  altitude: Number, // required
  type: Number // required
});
```

| Method | Parameter  |     Content-Type      |                       Data                       |             Response             |
| :----: | :--------: | :-------------------: | :----------------------------------------------: | :------------------------------: |
|  POST  | /location  | x-www-form-urlencoded |   name_en, latitude, longitude, altitude, type   |            `Location`            |
|  PUT   | /location  | x-www-form-urlencoded | id, name_en, latitude, longitude, altitude, type |            `Location`            |
|  GET   | /locations |           /           |                        /                         |           `[Location]`           |
| DELETE | /location  | x-www-form-urlencoded |                        id                        | `{n: ?, ok: ?, deletedCount: ?}` |

## Trajectory Model

```js
var TrajectorySchema = Schema({
    points: [{ latitude: Number, longitude: Number, altitude: Number }]
});
```

| Method |   Parameter   |     Content-Type      |     Data     |             Response             |
| :----: | :-----------: | :-------------------: | :----------: | :------------------------------: |
|  POST  |  /trajectory  |         json          |    points    |       `{id: ?, points: ?}`       |
|  POST  | /trajectories |         json          | trajectories |      `[{id: ?, points: ?}]`      |
|  GET   | /trajectories |           /           |      /       |      `[{id: ?, points: ?}]`      |
| DELETE |  /trajectory  | x-www-form-urlencoded |      id      | `{n: ?, ok: ?, deletedCount: ?}` |

## Route Model

```js
var RouteSchema = Schema({
    startLoc: { type: Schema.Types.ObjectId, ref: 'Location' },
    endLoc: { type: Schema.Types.ObjectId, ref: 'Location' },
    points: [{ latitude: Number, longitude: Number, altitude: Number }],
    dist: Number, // required
    type: [ Number ]
});
```

| Method | Parameter | Content-Type |                Data                |                           Response                           |
| :----: | :-------: | :----------: | :--------------------------------: | :----------------------------------------------------------: |
|  POST  |  /route   |     json     | startId, endId, points, dist, type | `{_id: ?, startLoc: ?, endLoc: ?, points: ?, dist: ?, type: ?}` |
|  GET   |  /routes  |      /       |                 /                  |                          `[Route]`                           |

## Bus Model

```js
var BusSchema = Schema({
    id: String // required, unique. 1a, 1b, 2, 3, 4, 5, 6a, 6b, 7, 8, light
    name_en: String,
    name_ch: String,
    serviceHour: String, // required. eg. 07:40-18:40
    serviceDay: Number, // required. 0: Mon-Sat, 1: Sun&PH, 2: teach
    stops: [{ type: Schema.Types.ObjectId, ref: 'Location' }], // locations the bus pass by
    departTime: [Number], // required. depart hourly at (mins)
    special: [{ departTime: Number, busStop: { type: Schema.Types.ObjectId, ref: 'Location' }, stop: Boolean }]
});
```

| Method | Parameter | Content-Type |                           Data                            | Response |
| :----: | :-------: | :----------: | :-------------------------------------------------------: | :------: |
|  POST  |   /bus    |     json     | id, name_en, name_ch, serviceHour, serviceDay, departTime |  `Bus`   |
|  GET   |  /buses   |      /       |                             /                             | `[Bus]`  |

## Version Model

```js
var VersionSchema = Schema({
    database: String // required, unique
    version: String // required
});
```

| Method | Parameter |     Content-Type      |       Data        |              Response               |
| :----: | :-------: | :-------------------: | :---------------: | :---------------------------------: |
|  GET   | /versions |           /           |         /         |    `[{database: ?, version: ?}]`    |
|  PUT   | /version  | x-www-form-urlencoded | database, version | `{_id: ?, database: ?, version: ?}` |


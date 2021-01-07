# View Model

## 1 UserPoint.swift

Indicate the location of current location.

```swift
@ObservedObject var locationGetter: LocationGetterModel
@Binding var offset: Offset
@Binding var scale: CGFloat
```

# Page

## 1 MainPage.swift

Entry page, containing navigation links to other pages.

## 2 CollectPage.swift

For collecting trajectory and location data.

### 2.1 Data

Updating and recording location:

```swift
@StateObject var locationGetter = LocationGetterModel()
@State var isRecording = true
```

Control add location window:

```swift
@State var showAddLocation = false
```

Gesture:

```swift
@State var lastOffset = Offset(x: 0, y: 0)
@State var offset = Offset(x: 0, y: 0)
@State var lastScale = minZoomOut
@State var scale = minZoomOut
```

### 2.2 Component

Background map image:

```swift
Image("cuhk-campus-map")
```

Recorded trajectories (not uploaded yet):

```swift
UserPathsView(locationGetter: locationGetter, offset: $offset, scale: $scale)
```

Current location:

```swift
UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale)
```

Tool bar:

```swift
HStack {
    RecordButton(locationGetter: locationGetter, isRecording: $isRecording)
    DeleteButton(locationGetter: locationGetter)
}
```

New location window:

```swift
if showAddLocation {
    NewLocationWindow(locationGetter: locationGetter, showing: $showAddLocation)
}
```

## 3 LocationPage.swift

Locations data:

```swift
@State var locations: [Location] = []
@State var clickedLoc: Location? = nil
@StateObject var curLocModel = CurLocModel() // for getting current location
```

Control windows:

```swift
@State var showList = false // sheet: location list
@State var showEditWindow = false // window: edit a location
@State var showAddWindow = false // window: add a location
```

Gesture:

```swift
@State var offset: Offset = Offset(x: 0, y: 0)
@State var lastOffset = Offset(x: 0, y: 0)
@State var scale: CGFloat = minZoomOut
@State var lastScale = minZoomOut
```

## 4 
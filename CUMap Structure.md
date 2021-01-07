# View Model

## 1 UserPoint.swift

Indicate the location of current location.

```swift
@ObservedObject var locationGetter: LocationGetterModel
@Binding var offset: Offset
@Binding var scale: CGFloat
```

## 2 MapView.swift

Show a background map:

```swift
Image("cuhk-campus-map")
```

Show plans in map:

```swift
@Binding var plans: [Plan]
@Binding var planIndex: Int
```

Show current location: <i>(UserPoint.swift)</i>

```swift
@ObservedObject var locationGetter: LocationGetterModel
```

Hold gesture:

```swift
@State var lastOffset = Offset(x: 0, y: 0)
@State var offset = Offset(x: 0, y: 0)
@State var lastScale = initialZoom
@State var scale = initialZoom
```

The offset of MapView.swift is controlled by height of <i>PlansView.swift</i> as follow:

```swift
.offset(y: lastHeight >= UIScreen.main.bounds.height * 0.4 ? -lastHeight : 0)
```

## 3 PlansView.swift

Show plans in sheets:

```swift
@Binding var plans: [Plan]
@Binding var planIndex: Int
```

If plans.isEmpty, `NoPlanView(lastHeight: $lastHeight, height: $height)` ; else, `PlanView(plan: plans[planIndex], lastHeight: $lastHeight, height: $height)`.

The height of itself:

```swift
@Binding var lastHeight: CGFloat
@Binding var height: CGFloat
```

## 4 SearchView.swift

Switched between SearchArea and SearchList.

### 4.1 SearchArea

Positioned at top of screen, ignoring safe area. 

For doing RP (route planning), once it appears or 􀄬 is clicked.

<img src="./CUMap/screenshots/SearchArea.png" alt="SearchList" style="zoom:50%;" />

Display data:

```swift
@State var startName: String
@State var endName: String
@State var mode: TransMode // .bus ot .foot
@State var angle = 0.0 // animation for 􀄬
```

Show SearchList:

```swift
@Binding var showStartList: Bool
@Binding var showEndList: Bool
```

Input:

```swift
@State var locations: [Location]
@State var routes: [Route]
@ObservedObject var locationGetter: LocationGetterModel // user's location
@State var startId: String
@State var endId: String
```

Output:

```swift
@Binding var plans: [Plan]
@Binding var planIndex: Int
```

<b>Note</b>: if user chooses "Your location", `startId` or `endId` will be set as `"current"`, `startName` or `endName` will be set as `"Your Location"`.

### 4.2 SearchList

A page occupying whole screen. 

For searching and choosing a location as starting point or ending point.

<img src="./CUMap/screenshots/SearchList.png" alt="SearchList" style="zoom:25%;" />

Search box:

```swift
@State var placeholder: String // "From" or "To"
@State var keyword: String // type to search for location
```

Location List:

```swift
@ObservedObject var locationGetter: LocationGetterModel // for current location
@State var locations: [Location]
```

Chosen Location:

```swift
@Binding var location: Location
```

Show itself or not:

```swift
@Binding var showList: Bool
```








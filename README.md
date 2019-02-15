# Virtual Toruest info
This app is created as a final project of the [iOS Nanodegree - Udacity](https://www.udacity.com/course/ios-developer-nanodegree--nd003).

## Build
### Requirements
* Xcode 10.1
* iOS 12.1
* Swift 4.2

### Steps to build
1. Clone repo 
```
git clone https://github.com/smokyabdulrahman/Virtual-Tourist.git
```
2. Install dependences (**CocoaPods needed**)
```
pod install
```
3. Insert flicker API key & secret inside -> (Virtual\ Tourist/API/FlickrAPI.swift) *left my key & secret for ease of building*
```swift
class FlickrAPI {
    struct Constants {
        static let API_KEY = // Here
        static let API_SECRET = // Here
        static let BASE_URL = "https://api.flickr.com/services/rest"
        static let FLICKR_SEARCH_METHOD = "flickr.photos.search"
        static let ACCURACY = 11
        static let NUM_OF_PHOTOS = 20
    }
    ....
```
4. Open `Virtual Tourist.xcworkspace`
5. Build app for your device or simulator

## How to use the app
- Launch the app using your phone or iOS Simulator
- A map is shown where you can long press the location you want, which will make the app add a pin at that location.
- tapping the pin will push a view where random photos will appear that are assouciated with that location.
- you can get new random photos by pressing "get new photos" button below.
- you can delete unwanted photos by tapping on them.
- all loaded photos and pins will be stored using coredata.

## Resources
This app uses the following frameworks and APIs:

### Third-party frameworks

| Framework | Description |
| --- | --- 
| [CocoaPods](https://github.com/CocoaPods/CocoaPods) | The Cocoa Dependency Manager. |
| [Alamofire](https://github.com/Alamofire/Alamofire) | Easy HTTP networking in Swift. |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | The better way to deal with JSON data in Swift.|
| [Kingfisher](https://github.com/onevcat/Kingfisher) | A lightweight, pure-Swift library for downloading and caching images from the web.|

### APIs
| Framework | Description |
| --- | --- |
| [Flickr API](https://www.flickr.com/services/api/) | It is used to retrieve photos related to the locations. |
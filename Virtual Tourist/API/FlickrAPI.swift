//
//  FlickerAPI.swift
//  Virtual Tourist
//
//  Created by ABDULRAHMAN ALRAHMA on 1/26/19.
//  Copyright © 2019 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FlickrAPI {
    struct Constants {
        static let API_KEY = "08c7316d179eb223b8de21eed30c0cd8"
        static let API_SECRET = "5d2e8b55cbd9637c"
        static let BASE_URL = "https://api.flickr.com/services/rest"
        static let FLICKR_SEARCH_METHOD = "flickr.photos.search"
        static let ACCURACY = 11
        static let NUM_OF_PHOTOS = 20
    }
    
    static func getListOfPhotosIn(lat: Double, lon: Double, completionHandler: @escaping (Connectivity.Status, [String]?) -> Void) {
        let url = "\(Constants.BASE_URL)?api_key=\(Constants.API_KEY)&method=\(Constants.FLICKR_SEARCH_METHOD)&per_page=\(Constants.NUM_OF_PHOTOS)&format=json&nojsoncallback=?&lat=\(lat)&lon=\(lon)&page=\((1...10).randomElement() ?? 1)"
        
        if !Connectivity.isConnectedToInternet {
            completionHandler(.notConnected, nil)
        }
        
        Alamofire.request(url).responseJSON { (response) in
            if((response.result.value) != nil) {
                let swiftyJsonVar = JSON(response.result.value!)
                var photosURL: [String] = []
                
                if let photos = swiftyJsonVar["photos"]["photo"].array {
                    for photo in photos {
                        let photoURL = "https://farm\(photo["farm"].stringValue).staticflickr.com/\(photo["server"].stringValue)/\(photo["id"])_\(photo["secret"]).jpg"
                        photosURL.append(photoURL)
                    }
                }
                completionHandler(.connected, photosURL)
            } else {
                completionHandler(.other, nil)
            }
        }
        
    }
}

class Connectivity {
    static var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    enum Status {
        case notConnected, connected, other
    }
}

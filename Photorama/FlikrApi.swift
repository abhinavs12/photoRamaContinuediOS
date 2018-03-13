//
//  FlikrApi.swift
//  Photorama
//
//  Created by Mansi Gupta on 2018-03-12.
//  Copyright © 2018 Mansi Gupta. All rights reserved.
//

import Foundation

enum Method: String{
    case interestingPhotos = "flickr.interestingness.getList"
}

enum FlickrError: Error{
    case invalidJSONData
}

struct FlikrApi{
    
    private static let baseUrlString = "https://api.flickr.com/services/rest"
    private static let apiKey = "7464d3a94ac124feac0ac5a1a308fb78"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static func flickrURL(method: Method, parameters:[String:String]?) -> URL{
        var components = URLComponents(string: baseUrlString)
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method" : method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams{
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters{
            for (key, value) in additionalParams{
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        components?.queryItems = queryItems
        
        return (components?.url!)!
        
        
    }
    
    static func photos(fromJSON data: Data) -> PhotosResult{
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
            let jsonDictionary = jsonObject as? [AnyHashable:Any],
            let photos = jsonDictionary["photos"] as? [String:Any],
                let photosArray = photos["photo"] as? [[String:Any]] else{
                     return .failure(FlickrError.invalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            
            for photoJSON in photosArray{
                if let photo = photo(fromJSON: photoJSON){
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.isEmpty && !photosArray.isEmpty{
                return.failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
        
    }
    
    static var interestingPhotosURL: URL{
        return flickrURL(method: .interestingPhotos, parameters: ["extras" : "url_h,date_taken"])
    }
    
    private static func photo(fromJSON json: [String: Any]) -> Photo? {
    
    guard
    let photoID = json["id"] as? String,
    let title = json["title"] as? String,
    let dateString = json["datetaken"] as? String,
    let photoURLString = json["url_h"] as? String,
    let url = URL(string: photoURLString),
    let dateTaken = dateFormatter.date(from: dateString) else {
    
    return nil
    }
        return Photo(title: title, remoteURL: url, photoID: photoID, dateTaken: dateTaken)
    
    
    }
}



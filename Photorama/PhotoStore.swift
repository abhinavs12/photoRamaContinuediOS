//
//  PhotoStore.swift
//  Photorama
//
//  Created by Mansi Gupta on 2018-03-12.
//  Copyright © 2018 Mansi Gupta. All rights reserved.
//

import Foundation
import UIKit


enum PhotosResult{
    case success([Photo])
    case failure(Error)
}
enum ImageResult {
    case success(UIImage)
    case failure(Error)
}
enum PhotoError: Error{
    case imageCreationError
}

class PhotoStore {
    
    private let session: URLSession = {
        
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
        
    }()
    
    
    
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult)->Void){
        
        let url = FlikrApi.interestingPhotosURL
        let request = URLRequest(url:url)
        
        let task = session.dataTask(with: request){
            
            (data, response, error) -> Void in
            
            if let jsonData = data{
                
                do{
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    print(jsonObject)
                } catch let error {
                    print("Error creating json object: \(error)")
                }
                    
                
                    
                }else if let requestError = error {
                print("Error fetching interesting photos: \(requestError)")
                
                
            } else {
                print("Unexpected error with the request")
            }
           let result = self.processPhotosRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                  completion(result)
            }
          
        }
        
        task.resume()
    }
    
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult)->Void){
        
       let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult{
        guard
        let imageData = data,
            let image = UIImage(data: imageData) else{
                if data == nil{
                    return .failure(error!)
                } else{
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult{
        guard let jsonData = data else {
            return .failure(error!)
        }
        return FlikrApi.photos(fromJSON: jsonData)
    }
    
    
}

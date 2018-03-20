//
//  Photo.swift
//  Photorama
//
//  Created by Mansi Gupta on 2018-03-12.
//  Copyright © 2018 Mansi Gupta. All rights reserved.
//

import Foundation

class Photo{
    
    let title: String
    let remoteURL : URL
    let photoID: String
    let dateTaken: Date
    
    init(title:String, remoteURL: URL, photoID: String, dateTaken:Date) {
        self.title = title
        self.photoID = photoID
        self.remoteURL = remoteURL
        self.dateTaken = dateTaken
    }
}


extension Photo: Equatable{
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.photoID == rhs.photoID
    }
}

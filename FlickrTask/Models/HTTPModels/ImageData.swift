//
//  ImageData.swift
//  FlickrTask
//
//  Created by Ivaylo Zhelev on 1.12.19.
//  Copyright © 2019 Ivaylo Zhelev. All rights reserved.
//

import Foundation

class ImageData: NSObject {
    
    // MARK: Properties
    
    private(set) var farm     : Int
    private(set) var isPublic : Int
    private(set) var isFriend : Int
    private(set) var isFamily : Int
    
    private(set) var id     : String
    private(set) var owner  : String
    private(set) var secret : String
    private(set) var server : String
    private(set) var title  : String
    
    
    // MARK: Initializers
    
    init(response: NSDictionary) {
        self.farm     = response.safeInt(forKey: "farm")
        self.isPublic = response.safeInt(forKey: "ispublic")
        self.isFriend = response.safeInt(forKey: "isfriend")
        self.isFamily = response.safeInt(forKey: "isfamily")
        
        self.id     = response.safeString(forKey: "id")
        self.owner  = response.safeString(forKey: "owner")
        self.secret = response.safeString(forKey: "secret")
        self.server = response.safeString(forKey: "server")
        self.title  = response.safeString(forKey: "title")
        
        super.init()
    }
    
    
    // MARK: Public Methods
    
    static func imagesFromResponse(_ response: NSDictionary) -> [ImageData] {
        guard let list = response.unsafeDictionary(forKey: "photos") else {
            return []
        }
        
        guard let dataList = list.unsafeDictArray(forKey: "photo") else {
            return []
        }
        
        var data: [ImageData] = []
        
        for slice in dataList {
            data.append(ImageData(response: slice))
        }
    
        return data
    }
    
}

//
//  NSDictionary+Helpers.swift
//  FlickrTask
//
//  Created by Ivaylo Zhelev on 3.12.19.
//  Copyright © 2019 Ivaylo Zhelev. All rights reserved.
//

import Foundation

extension NSDictionary {

    // MARK: Public Methods

    func safeInt(forKey key: String) -> Int {
        return self.object(forKey: key) as? Int ?? -1
    }

    func safeString(forKey key: String) -> String {
        return self.object(forKey: key) as? String ?? ""
    }

    func unsafeDictionary(forKey key: String) -> NSDictionary? {
        return self.object(forKey: key) as? NSDictionary
    }
    
    func unsafeDictArray(forKey key: String) -> [NSDictionary]? {
        return self.object(forKey: key) as? [NSDictionary]
    }
}


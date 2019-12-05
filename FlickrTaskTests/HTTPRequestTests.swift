//
//  HTTPRequestTests.swift
//  FlickrTaskTests
//
//  Created by Ivaylo Zhelev on 3.12.19.
//  Copyright © 2019 Ivaylo Zhelev. All rights reserved.
//

import XCTest
@testable import FlickrTask

class HTTPRequestTests: XCTestCase {
    
    func testInvalidHTTPRequestURL() {
        XCTAssertEqual(HTTPRequestManager.shared.getImagesListForTag("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=man&page=1") {_ in }, 0)
    }
    
    func testValidHTTPRequestURL() {
       XCTAssertEqual(HTTPRequestManager.shared.getImagesListForTag("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=¬&page=1") {_ in }, 1)
    }
}


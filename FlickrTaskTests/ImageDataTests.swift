//
//  ImageDataTests.swift
//  FlickrTaskTests
//
//  Created by Ivaylo Zhelev on 3.12.19.
//  Copyright © 2019 Ivaylo Zhelev. All rights reserved.
//

import XCTest
@testable import FlickrTask

class ImageDataTests: XCTestCase {
    
    var imageData: ImageData!
    
    override func setUp() {
        super.setUp()
        
        self.imageData = ImageData(response: [:])
    }

    override func tearDown() {
        super.tearDown()
        
        self.imageData = nil
    }

    func testImageDataEmptyDictionary() {
        XCTAssertNotNil(imageData)
    }
}

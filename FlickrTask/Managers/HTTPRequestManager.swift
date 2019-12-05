//
//  HTTPRequestManager.swift
//  FlickrTask
//
//  Created by Ivaylo Zhelev on 2.12.19.
//  Copyright © 2019 Ivaylo Zhelev. All rights reserved.
//

import UIKit
import Foundation

final class HTTPRequestManager: NSObject {

    // MARK: Constants
    
    let cachedImage = NSCache<NSString, UIImage>()
    
    
    // MARK: Singleton
    
    public static let shared = HTTPRequestManager()
    
    
    // MARK: Public Methods
    
    func getImagesListForTag(_ tag: String, page: Int = 1, completion: @escaping ([ImageData]) -> Void) -> Int {
        let tag = tag.replacingOccurrences(of: " ", with: "%20")
        
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=\(tag.isEmpty ? "null" : tag)&page=\(page)"), UIApplication.shared.canOpenURL(url) else {
            
            print("Invalid URL")
            return 1 // Due to Unit Test purposes
        }
        
        let downloadImagesListTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let imageDataList = ImageData.imagesFromResponse(json as! NSDictionary)
                
                DispatchQueue.main.async {
                    completion(imageDataList)
                }
                
            } catch {
                print("Could not format data '\(data)' to json")
            }
        }
        
        downloadImagesListTask.resume()
        
        return 0 // Due to Unit Test purposes
    }
    
    func downloadImage(from imageData: ImageData, completion: @escaping (UIImage?) -> Void) -> Int {
        guard let url = self.downloadLink(imageData: imageData), UIApplication.shared.canOpenURL(url) else {
            completion(nil)
            
            print("Invalid URL")
            return 1 // Due to Unit Test purposes
        }
        
        if let cachedImage = cachedImage.object(forKey: url.absoluteString as NSString) {
            DispatchQueue.main.async() {
                completion(cachedImage)
            }
        }
        else {
            let downloadImageTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let _ = error {
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    completion(nil)
                    return
                }
                
                DispatchQueue.main.async() {
                    if let image = UIImage(data: data) {
                        self.cachedImage.setObject(image, forKey: url.absoluteString as NSString)
                        completion(image)
                    }
                }
            }
            
            downloadImageTask.resume()
        }
        
        return 0 // Due to Unit Test purposes
    }
    
    
    // MARK: Private Methods
    
    private func downloadLink(imageData: ImageData) -> URL? {
        let link = "https://farm\(imageData.farm).static.flickr.com/\(imageData.server)/\(imageData.id)_\(imageData.secret).jpg"
        return URL(string: link)
    }
}

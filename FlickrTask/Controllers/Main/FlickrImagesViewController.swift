//
//  FlickrImagesViewController.swift
//  FlickrTask
//
//  Created by Ivaylo Zhelev on 1.12.19.
//  Copyright © 2019 Ivaylo Zhelev. All rights reserved.
//

import UIKit

class FlickrImagesViewController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: Constants
    
    private let kCellsPerRow: CGFloat = 3.0
    private let kSidePadding: CGFloat = 8.0
    
    private let kCellIdentifier = "imageCell"
    
    
    // MARK: Variables
    
    private var imageList           : [UIImage] = []
    private var operatingImageList  : [UIImage] = []
    
    private var imageDataList: [ImageData] = []
    
    private var loadImageAttempts     = 0
    private var downloadImageAttempts = 0
    
    
    // MARK: Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate    = self
        self.collectionView.dataSource  = self
        
        self.searchBar.delegate = self
        
        self.collectionView.backgroundColor = .white
        
        self.getImagesListFor("")
    }
    
    
    // MARK: Private Methods
    
    private func image(for indexPath: IndexPath) -> UIImage {
        return self.operatingImageList[indexPath.item]
    }
    
    private func getImagesListFor(_ tag: String, newSearch: Bool = true) {
        _ = HTTPRequestManager.shared.getImagesListForTag(tag) { imageDataList in
            
            if newSearch {
                self.imageDataList = imageDataList
            }
            else {
                self.imageDataList.append(contentsOf: imageDataList)
            }
            
            if imageDataList.isEmpty {
                DispatchQueue.main.async {
                    self.operatingImageList = []
                    self.collectionView.reloadData()
                }
            }

            for data in self.imageDataList {
                self.downloadImageAttempts += 1
                self.downloadImage(with: data, newSearch: newSearch)
            }
        }
    }
    
    private func downloadImage(with data: ImageData, newSearch: Bool = true) {
        _ = HTTPRequestManager.shared.downloadImage(from: data) { image in
            self.loadImageAttempts += 1
            
            if let image = image {
                self.imageList.append(image)
            }
            
            if self.loadImageAttempts == self.downloadImageAttempts {
                DispatchQueue.main.async {
                    if newSearch {
                        self.operatingImageList = self.imageList
                    }
                    else {
                        self.operatingImageList.append(contentsOf: self.imageList)
                    }
                    
                    self.imageList = []
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension FlickrImagesViewController: UICollectionViewDataSource {
    
    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.operatingImageList.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath)
        
        if let imageCell = cell as? FlickrImageCollectionViewCell {
            imageCell.imageView.image = self.operatingImageList[indexPath.item]
        }
        
        if self.operatingImageList.count - 1 == indexPath.item {
            self.getImagesListFor(self.searchBar.text ?? "", newSearch: false)
        }
        
        return cell
    }
}

extension FlickrImagesViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: Collection View Flow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat  = (self.collectionView.frame.size.width - (kCellsPerRow * kSidePadding)) / kCellsPerRow
        let ratio: CGFloat  = self.image(for: indexPath).size.width / self.image(for: indexPath).size.height
        let height: CGFloat = width / ratio
        
        return CGSize(width: width, height: height)
    }
}

extension FlickrImagesViewController: UISearchBarDelegate {
    
    // MARK: Search Bar Delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
        if let _ = self.operatingImageList.first {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
        
        self.getImagesListFor(searchBar.text ?? "")
    }
}


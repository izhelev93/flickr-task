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
    
    private var loadingContainer    : UIView = UIView()
    private var loadingView         : UIView = UIView()
    private var activityIndicator   : UIActivityIndicatorView = UIActivityIndicatorView()
    
    private var imageList           : [UIImage] = []
    private var operatingImageList  : [UIImage] = []
    
    private var imageDataList: [ImageData] = []
    
    private var loadImageAttempts     = 0
    private var downloadImageAttempts = 0
    private var page = 1
    
    
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
        if !newSearch {
            self.page += 1
        }
        else {
            self.page = 1
        }
        
        self.showActivityIndicatory(uiView: self.view)
        
        _ = HTTPRequestManager.shared.getImagesListForTag(tag, page: self.page) { newImageDataList in
            
            if newSearch {
                self.imageDataList = newImageDataList
            }
            else {
                self.imageDataList.append(contentsOf: newImageDataList)
            }
            
            if newImageDataList.isEmpty {
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
                
                self.hideActivityIndicator(uiView: self.view)
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

extension FlickrImagesViewController {
    
    // MARK: Activity Indicator
    
    // USED CODE FROM https://github.com/erangaeb/dev-notes/blob/master/swift/ViewControllerUtils.swift
    
    private func showActivityIndicatory(uiView: UIView) {
        self.loadingContainer.frame = uiView.frame
        self.loadingContainer.center = uiView.center
        self.loadingContainer.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)

        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        actInd.style = UIActivityIndicatorView.Style.large
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                y: loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        self.loadingContainer.addSubview(loadingView)
        uiView.addSubview(self.loadingContainer)
        actInd.startAnimating()
    }
    
    private func hideActivityIndicator(uiView: UIView) {
        self.activityIndicator.stopAnimating()
        self.loadingContainer.removeFromSuperview()
    }
    
    private func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}


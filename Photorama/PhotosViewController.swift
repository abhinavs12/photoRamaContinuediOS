//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Mansi Gupta on 2018-03-12.
//  Copyright © 2018 Mansi Gupta. All rights reserved.
//

import UIKit


class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    var store:PhotoStore!
    let photoDataSource = PhotoDataSource()

  
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        store.fetchInterestingPhotos{
            
            (photosResult) -> Void in
            
            switch photosResult{
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                
                self.photoDataSource.photos = photos
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
            
        }
  
        
 
    }
    
    func tappedView(gesture: UIGestureRecognizer) {
        let secondViewController = MyImageViewController(nibName: nil, bundle: nil)
        self.present(secondViewController, animated: true, completion: nil)
        
        
    }
    
    
    
  
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        
        store.fetchImage(for: photo) {
            (result) -> Void in
            
            guard let photoIndex = self.photoDataSource.photos.index(of : photo),
                case let .success(image) = result else {
                    return
            }
            
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
            
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageViewPage: MyImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyImageViewController") as! MyImageViewController
        
        imageViewPage.selectedImage = String(describing: photoDataSource.photos[indexPath.row].remoteURL)
        
        
        self.navigationController?.pushViewController(imageViewPage, animated: true)
    }
    
  
    
 

}




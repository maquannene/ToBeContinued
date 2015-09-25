//
//  MVBImageTextTrackViewController.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MVBImageTextTrackViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: MVBImageTextTrackLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.delegate = self
        layout.numberOfColumns = 3
    }
    
}

extension MVBImageTextTrackViewController: MVBImageTextTrackLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        return 100.0
    }
}

extension MVBImageTextTrackViewController: UICollectionViewDelegate {
    
}

extension MVBImageTextTrackViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MVBImageTextTrackCell.ClassName, forIndexPath: indexPath) as! MVBImageTextTrackCell
//        cell.photo = photos[indexPath.item]
        return cell
    }
    
}

//
//  MVBImageTextTrackViewController.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import AVFoundation

class MVBImageTextTrackViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: MVBImageTextTrackLayout!
    var dataSource: MVBImageTextTrackDataSource!
    
    //  模拟数据源数组
    lazy var imageTextTracks: [MVBImageTextTrackModel] = MVBImageTextTrackModel.allImageTextTrack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.delegate = self
        layout.numberOfColumns = 1
        dataSource = MVBImageTextTrackDataSource()
        
        configurePullToRefresh()
        
    }
    
}

//  MARK: Private
extension MVBImageTextTrackViewController {
    
    //  配置下拉刷新
    func configurePullToRefresh() {
        collectionView!.header = MJRefreshNormalHeader() {
            //  首先试图获取存有每条imageTextTrack 的 id 列表
            self.dataSource.queryImageTextTrackIdList {
                guard $0 == true else {
                    //  如果获取失败，就创建新的
                    self.dataSource.queryCreateImageTextTrackIdList { [unowned self] succeed in
                        self.collectionView!.header.endRefreshing()
                    }
                    return
                }
                
                //  获取成功，就逐条请求存储的imageTextTrack存在缓存中
                self.dataSource.queryImageTextTrackList { [unowned self] succeed in
                    guard succeed == true else { self.collectionView!.header.endRefreshing(); return }
                    self.collectionView.reloadData()
                    self.collectionView!.header.endRefreshing()
                }
            }
        }
    }
    
    
}

//  MARK: MVBImageTextTrackLayoutDelegate
extension MVBImageTextTrackViewController: MVBImageTextTrackLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        print(indexPath.item)
        let imageTextTrack = imageTextTracks[indexPath.item]
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRectWithAspectRatioInsideRect(imageTextTrack.image.size, boundingRect)
        return rect.height
    }
}

//  MARK: UICollectionViewDelegate
extension MVBImageTextTrackViewController: UICollectionViewDelegate {
    
}

//  MARK: UICollectionViewDataSource
extension MVBImageTextTrackViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageTextTracks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MVBImageTextTrackCell.ClassName, forIndexPath: indexPath) as! MVBImageTextTrackCell
        cell.imageTextTrack = imageTextTracks[indexPath.item]
        return cell
    }
    
}

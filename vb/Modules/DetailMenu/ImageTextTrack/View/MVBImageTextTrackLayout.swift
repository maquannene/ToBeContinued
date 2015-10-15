//
//  MVBImageTextTrackLayout.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

protocol MVBImageTextTrackLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class MVBImageTextTrackLayoutAttributes: UICollectionViewLayoutAttributes {
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! UICollectionViewLayoutAttributes
        return copy
    }
    
//    override func isEqual(object: AnyObject?) -> Bool {
//        if let attributes = object as? UICollectionViewLayoutAttributes {
//            if attributes.photoHeight == photoHeight {
//                return super.isEqual(object)
//            }
//        }
//        return false
//    }
    
}

class MVBImageTextTrackLayout: UICollectionViewLayout {
    
    var delegate: MVBImageTextTrackLayoutDelegate!
    var numberOfColumns = 1
    var cellPadding: CGFloat = 0
    
    private var layoutAttributesCache = [MVBImageTextTrackLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    
    private var width: CGFloat {
        return self.collectionView!.w
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return MVBImageTextTrackLayoutAttributes.self
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepareLayout() {
        
        layoutAttributesCache.removeAll()
        
        //  每个cell的宽度
        let cellWidth = width / CGFloat(numberOfColumns)
        
        var xOffsets = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffsets.append(CGFloat(column) * cellWidth)
        }
        
        var yOffsets = [CGFloat](count: numberOfColumns, repeatedValue: 0)
        
        var column = 0
        
        for item in 0..<collectionView!.numberOfItemsInSection(0) {
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            let imageWidth = cellWidth - (cellPadding * 2)
            let imageHeight = delegate.collectionView(collectionView!, heightForImageAtIndexPath: indexPath, withWidth: imageWidth)
            let cellHeight = cellPadding + imageHeight + cellPadding
            
            let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: cellWidth, height: cellHeight)
            let attributes = MVBImageTextTrackLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            layoutAttributesCache.append(attributes)
            contentHeight = max(contentHeight, CGRectGetMaxY(frame))
            yOffsets[column] = yOffsets[column] + cellHeight
            let x = yOffsets.reduce(yOffsets[0]){
                min($0, $1)
            }
            column = yOffsets.indexOf(x)!
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in layoutAttributesCache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
}

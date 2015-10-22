//
//  MVBImageTextTrackLayout.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

typealias CellHeightInfo = (cellHeight: CGFloat, longCell: Bool)

protocol MVBImageTextTrackLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: NSIndexPath, withWidth cellWidth: CGFloat) -> CellHeightInfo
}

class MVBImageTextTrackLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var longImage: Bool = false
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! MVBImageTextTrackLayoutAttributes
        copy.longImage = longImage
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? MVBImageTextTrackLayoutAttributes {
            if attributes.longImage == longImage {
                return super.isEqual(object)
            }
        }
        return false
    }
    
}

class MVBImageTextTrackLayout: UICollectionViewLayout {
    
    var delegate: MVBImageTextTrackLayoutDelegate!
    var numberOfColumns: Int = 1
    var cellWidth: CGFloat = 0
    var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    private var layoutAttributesCache = [MVBImageTextTrackLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat = 0
    
    override class func layoutAttributesClass() -> AnyClass {
        return MVBImageTextTrackLayoutAttributes.self
    }
    
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    //  prepareLayout中计算每个cell的布局放在缓存cache中
    override func prepareLayout() {
        
        super.prepareLayout()
        
        layoutAttributesCache.removeAll()
        contentHeight = 0
        contentWidth = 0
        
        var xOffsets = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffsets.append(CGFloat(column) * cellWidth + sectionInset.left)
        }
        
        var yOffsets = [CGFloat](count: numberOfColumns, repeatedValue: sectionInset.top)
        
        var column = 0
        
        for item in 0..<collectionView!.numberOfItemsInSection(0) {
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            let cellHeightInfo = delegate.collectionView(collectionView!, heightForImageAtIndexPath: indexPath, withWidth: cellWidth)
            let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: cellWidth, height: cellHeightInfo.cellHeight)
            let attributes = MVBImageTextTrackLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            attributes.longImage = cellHeightInfo.longCell
            layoutAttributesCache.append(attributes)
            contentHeight = max(contentHeight, CGRectGetMaxY(frame))
            contentWidth = max(contentWidth, CGRectGetMaxX(frame))
            yOffsets[column] = yOffsets[column] + cellHeightInfo.cellHeight
            let x = yOffsets.reduce(yOffsets[0]){
                min($0, $1)
            }
            column = yOffsets.indexOf(x)!
        }

        contentHeight += sectionInset.bottom
        contentWidth += sectionInset.right
    }
    
    //  从缓存中获取当前rect 要展示的[attributes]
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in layoutAttributesCache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    //  从缓存中获取indexPath的attributes
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesCache[indexPath.item]
    }
    
}

//
//  ImageTrackLayout.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

typealias CellHeightInfo = (cellHeight: CGFloat, longCell: Bool)

protocol ImageTrackLayoutDelegate: NSObjectProtocol {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth cellWidth: CGFloat) -> CellHeightInfo
}

class ImageTrackLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var longImage: Bool = false
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! ImageTrackLayoutAttributes
        copy.longImage = longImage
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? ImageTrackLayoutAttributes {
            if attributes.longImage == longImage {
                return super.isEqual(object)
            }
        }
        return false
    }
    
}

class ImageTrackLayout: UICollectionViewLayout {
    
    weak var delegate: ImageTrackLayoutDelegate!
    var numberOfColumns: Int = 1
    var cellWidth: CGFloat = 0
    var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    fileprivate var layoutAttributesCache = [ImageTrackLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat = 0
    
    override class var layoutAttributesClass : AnyClass {
        return ImageTrackLayoutAttributes.self
    }
    
    
    override var collectionViewContentSize : CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    //  prepareLayout中计算每个cell的布局放在缓存cache中
    override func prepare() {
        
        super.prepare()
        
        layoutAttributesCache.removeAll()
        contentHeight = 0
        contentWidth = 0
        
        var xOffsets = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffsets.append(CGFloat(column) * cellWidth + sectionInset.left)
        }
        
        var yOffsets = [CGFloat](repeating: sectionInset.top, count: numberOfColumns)
        
        var column = 0
        
        for item in 0..<collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let cellHeightInfo = delegate!.collectionView(collectionView!, heightForImageAtIndexPath: indexPath, withWidth: cellWidth)
            let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: cellWidth, height: cellHeightInfo.cellHeight)
            let attributes = ImageTrackLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            attributes.longImage = cellHeightInfo.longCell
            layoutAttributesCache.append(attributes)
            contentHeight = max(contentHeight, frame.maxY)
            contentWidth = max(contentWidth, frame.maxX)
            yOffsets[column] = yOffsets[column] + cellHeightInfo.cellHeight
            let x = yOffsets.reduce(yOffsets[0]){
                min($0, $1)
            }
            column = yOffsets.index(of: x)!
        }
        
        contentHeight += sectionInset.bottom
        contentWidth += sectionInset.right
    }
    
    //  从缓存中获取当前rect 要展示的[attributes]
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in layoutAttributesCache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    //  从缓存中获取indexPath的attributes
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesCache[indexPath.item]
    }
    
}

//
//  MVBImageTextTrackCell.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import UIKit

class MVBImageTextTrackCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var imageTextTrack: MVBImageTextTrackModel? {
        didSet {
            imageView.image = UIImage(named: "08.jpg")
            textLabel.text = "hahaha"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1
    }
    
}

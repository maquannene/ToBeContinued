//
//  ImageTrackAddMenuView.swift
//  vb
//
//  Created by 马权 on 10/10/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import UIKit

class ImageTrackAddMenuView: UIView {

    @IBOutlet weak var fromPictureAlbumButton: UIButton! {
        didSet {
            fromPictureAlbumButton.layer.borderColor = UIColor.blackColor().CGColor
            fromPictureAlbumButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var fromCameraButton: UIButton! {
        didSet {
            fromCameraButton.layer.borderColor = UIColor.blackColor().CGColor
            fromCameraButton.layer.borderWidth = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

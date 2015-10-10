//
//  MVBImageTextTrackAddMenuView.swift
//  vb
//
//  Created by 马权 on 10/10/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import UIKit

class MVBImageTextTrackAddMenuView: UIView {

    @IBOutlet weak var fromPictureAlbumButton: UIButton!
    
    @IBOutlet weak var fromCameraButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fromPictureAlbumButton.layer.borderColor = UIColor.blackColor().CGColor
        fromPictureAlbumButton.layer.borderWidth = 1
        fromCameraButton.layer.borderColor = UIColor.blackColor().CGColor
        fromCameraButton.layer.borderWidth = 1
    }

}

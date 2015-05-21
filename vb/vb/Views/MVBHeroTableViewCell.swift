//
//  MVBHeroTableViewCell.swift
//  vb
//
//  Created by 马权 on 5/20/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBHeroTableViewCell: UITableViewCell {

    @IBOutlet var heroImageButton: UIButton!
    @IBOutlet var heroNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(heroModel: MVBHeroModel!) {
        if let heroImage = heroModel.heroImage as UIImage? {
            self.heroImageButton.setBackgroundImage(heroImage, forState: UIControlState.Normal)
        }
        else {
            self.heroImageButton.setBackgroundImage(nil, forState: UIControlState.Normal)
            heroModel.getHeroImage(self)
        }
        self.heroNameLabel.text = heroModel.localized_name! as? String
    }
}

extension MVBHeroTableViewCell: MVBHeroModelDelegate {
    func heroModelHeroImageDidLoad(heroModel: MVBHeroModel) {
        if heroNameLabel.text == heroModel.localized_name {
            self.heroImageButton.setBackgroundImage(heroModel.heroImage!, forState: UIControlState.Normal)
        }

    }
}

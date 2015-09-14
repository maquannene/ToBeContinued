//
//  MVBHeroTableViewCell.swift
//  vb
//
//  Created by 马权 on 5/20/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBHeroTableViewCell: UITableViewCell {

    @IBOutlet var heroImageButton: UIButton!
    @IBOutlet var heroNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.heroImageButton.setTitle("", forState: UIControlState.Normal)
        self.heroNameLabel.text = ""
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(heroModel: MVBHeroModel!) {
        self.heroImageButton.sd_setBackgroundImageWithURL(NSURL(string: heroModel.getHeroImageUrl() as String), forState: UIControlState.Normal, placeholderImage: UIImage(named: "loading.png"), options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) -> Void in
        }
        self.heroNameLabel.text = heroModel.localized_name! as String
    }
    deinit {
        print("\(self.dynamicType) deinit \(heroNameLabel.text)", terminator: "")
    }
}


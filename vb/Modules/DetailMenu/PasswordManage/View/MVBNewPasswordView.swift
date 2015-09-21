
//
//  MVBNewPasswordView.swift
//  vb
//
//  Created by 马权 on 6/29/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBNewPasswordView: UIView {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var detailContentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createButton.layer.borderColor = UIColor.blackColor().CGColor
        createButton.layer.cornerRadius = 5
        createButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.blackColor().CGColor
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
    }
    
    func configureData(title: String, detailContent: String) {
        titleTextView.text = title
        detailContentTextView.text = detailContent
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, withEvent: event)
        return view
    }
    
    deinit {
        print("\(self.dynamicType) deinit")
    }
}

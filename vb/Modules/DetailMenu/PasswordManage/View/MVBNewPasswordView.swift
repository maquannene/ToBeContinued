
//
//  MVBNewPasswordView.swift
//  vb
//
//  Created by 马权 on 6/29/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBNewPasswordView: UIView {
   
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var detailContentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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

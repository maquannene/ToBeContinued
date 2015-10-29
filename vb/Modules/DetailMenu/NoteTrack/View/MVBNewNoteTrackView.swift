
//
//  MVBNewNoteTrackView.swift
//  vb
//
//  Created by 马权 on 6/29/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBNewNoteTrackView: UIView {

    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var detailContentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = RGBA(red: 255, green: 255, blue: 255, alpha: 1)
        layer.cornerRadius = 10
        layer.borderColor = RGBA(red: 237, green: 238, blue: 239, alpha: 1).CGColor
        layer.borderWidth = 1
        layer.shadowColor = UIColor.grayColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.8
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
        print("\(self.dynamicType) deinit\n")
    }
}

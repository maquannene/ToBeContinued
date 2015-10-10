//
//  MVBNoteTrackDetailCell.swift
//  vb
//
//  Created by 马权 on 7/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBNoteTrackDetailCell: UITableViewCell {

//    lazy var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var detailButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var detailButtonRightGap: NSLayoutConstraint!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var hasDetailButton: Bool {
        set {
            if newValue {
                detailButtonWidth.constant = 30
                detailButtonRightGap.constant = 10
            }
            else {
                detailButtonWidth.constant = 0
                detailButtonRightGap.constant = 0
            }
        }
        get {
            return !(detailButtonRightGap.constant == 0)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.cyanColor()
    }
    
    deinit {
        print("\(self.dynamicType) deinit")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hasDetailButton = contentLabel.isTruncated()
    }

}

// MARK: Public
extension MVBNoteTrackDetailCell {
    func configureWithNoteTrackModel(noteTrackModel: MVBNoteTrackModel) -> Void {
        selectionStyle = UITableViewCellSelectionStyle.None
        detailButtonWidth.constant = 0
        detailButtonRightGap.constant = 0
        //  重新设置了约束，要更新约束布局。
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        contentLabel!.text = noteTrackModel.detailContent
        //  这两句非常重要。让contentLabel内加入文本后重新排列文字，并且刷新字号。
        //  这样在layoutSubview中调用isTruncated才正确。
        contentLabel!.setNeedsLayout()
        contentLabel!.layoutIfNeeded()
    }
}
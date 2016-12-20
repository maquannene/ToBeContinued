//
//  NoteTrackDetailCell.swift
//  vb
//
//  Created by 马权 on 7/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

protocol NoteTrackDetailCellDataSource: class {
    var detailContentStr: String? { get }
}

class NoteTrackDetailCell: UITableViewCell {

    weak var noteTrackModel: NoteTrackDetailCellDataSource?
    
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
        backgroundColor = UIColor.cyan
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hasDetailButton = contentLabel.isTruncated()
    }
    
    deinit {
        print("\(type(of: self)) deinit\n")
    }

}

// MARK: Public
extension NoteTrackDetailCell {
    
    func configureWithNoteTrackModel(_ noteTrackModel: NoteTrackDetailCellDataSource!) -> Void {
        self.noteTrackModel = noteTrackModel
        selectionStyle = UITableViewCellSelectionStyle.none
        detailButtonWidth.constant = 0
        detailButtonRightGap.constant = 0
        //  重新设置了约束，要更新约束布局。
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        contentLabel!.text = noteTrackModel.detailContentStr
        //  这两句非常重要。让contentLabel内加入文本后重新排列文字，并且刷新字号。
        //  这样在layoutSubview中调用isTruncated才正确。
        contentLabel!.setNeedsLayout()
        contentLabel!.layoutIfNeeded()
    }
}

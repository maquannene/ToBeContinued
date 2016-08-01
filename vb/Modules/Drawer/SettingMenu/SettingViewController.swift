//
//  SettingViewController.swift
//  vb
//
//  Created by 马权 on 11/8/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import MMDrawerController
import SVProgressHUD
import Kingfisher

class SettingViewController: DetailBaseViewController {
    
    private struct Static {
        static let disclosureCell = "disclosureCell"
        static let switchCell = "switchCell"
        static let commonCell = "commonCell"
        static let gapCell = "gapCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var specialEffectSwitchClosuer: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        let leftButton = UIBarButtonItem(image: UIImage(named: "leftArrow"), style: .Plain, target: self, action: #selector(SettingViewController.backMainAction(_:)))
        leftButton.tintColor = UIColor.blackColor()
        self.navigationItem.setLeftBarButtonItem(leftButton, animated: false)
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.clearColor())
    }

    @objc private func backMainAction(sender: AnyObject) {
        mm_drawerController!.openDrawerSide(.Left, animated: true, completion: nil)
    }

}

extension SettingViewController {
    
    @objc private func specialEffectSwitchAction(sender: UISwitch!) {
        specialEffectSwitchClosuer?(sender.on)
    }
    
}

//  1. 用户信息 disclosureCell
//  2. 开关特效 switchCell
//  3. 清理缓存 commonCell

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.item == 0 || indexPath.item == 2 || indexPath.item == 4 {
            return 20
        }
        else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell!
        if indexPath.item == 0 || indexPath.item == 2 || indexPath.item == 4 {
            cell = tableView.dequeueReusableCellWithIdentifier(Static.gapCell)
        }
        if indexPath.item == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier(Static.disclosureCell)
            cell.textLabel?.text = "个人信息"
        }
        if indexPath.item == 3 {
            cell = tableView.dequeueReusableCellWithIdentifier(Static.switchCell)
            cell.textLabel?.text = "神器特效"
            if let sw = cell.accessoryView as? UISwitch {
                if let specialEffect = NSUserDefaults.standardUserDefaults().valueForKey("specialEffect") as? NSNumber {
                    sw.setOn(specialEffect.boolValue == true, animated: false)
                }
                sw.addTarget(self, action: #selector(SettingViewController.specialEffectSwitchAction(_:)), forControlEvents: .ValueChanged)
            }
        }
        if indexPath.item == 5 {
            cell = tableView.dequeueReusableCellWithIdentifier(Static.commonCell)
            cell.textLabel?.text = "清除缓存"
            
            ImageCache.defaultCache.calculateDiskCacheSizeWithCompletionHandler {
                if let label = cell.accessoryView as? UILabel {
                    label.text = String(format: "%.1f MB", CGFloat($0) / 1204.0 / 1024.0)
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.item == 5 {
            Kingfisher.ImageCache.defaultCache.clearDiskCache()
            Kingfisher.ImageCache.defaultCache.clearMemoryCache()
            SVProgressHUD.showSuccessWithStatus("清除成功")
            tableView.reloadData()
        }
    }
    
}

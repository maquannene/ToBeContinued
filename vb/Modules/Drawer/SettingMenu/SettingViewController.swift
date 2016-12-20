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
    
    fileprivate struct Static {
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
        let leftButton = UIBarButtonItem(image: UIImage(named: "leftArrow"), style: .plain, target: self, action: #selector(SettingViewController.backMainAction(_:)))
        leftButton.tintColor = UIColor.black
        self.navigationItem.setLeftBarButton(leftButton, animated: false)
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.clear)
    }

    @objc fileprivate func backMainAction(_ sender: AnyObject) {
        mm_drawerController!.open(.left, animated: true, completion: nil)
    }

}

extension SettingViewController {
    
    @objc fileprivate func specialEffectSwitchAction(_ sender: UISwitch!) {
        specialEffectSwitchClosuer?(sender.isOn)
    }
    
}

//  1. 用户信息 disclosureCell
//  2. 开关特效 switchCell
//  3. 清理缓存 commonCell

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.item == 0 || indexPath.item == 2 || indexPath.item == 4 {
            return 20
        }
        else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell!
        if indexPath.item == 0 || indexPath.item == 2 || indexPath.item == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: Static.gapCell)
        }
        if indexPath.item == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: Static.disclosureCell)
            cell.textLabel?.text = "个人信息"
        }
        if indexPath.item == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: Static.switchCell)
            cell.textLabel?.text = "神器特效"
            if let sw = cell.accessoryView as? UISwitch {
                if let specialEffect = UserDefaults.standard.value(forKey: "specialEffect") as? NSNumber {
                    sw.setOn(specialEffect.boolValue == true, animated: false)
                }
                sw.addTarget(self, action: #selector(SettingViewController.specialEffectSwitchAction(_:)), for: .valueChanged)
            }
        }
        if indexPath.item == 5 {
            cell = tableView.dequeueReusableCell(withIdentifier: Static.commonCell)
            cell.textLabel?.text = "清除缓存"
            ImageCache.default.calculateDiskCacheSize {
                if let label = cell.accessoryView as? UILabel {
                    label.text = String(format: "%.1f MB", CGFloat($0) / 1204.0 / 1024.0)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.item == 5 {
            ImageCache.default.clearDiskCache()
            ImageCache.default.clearMemoryCache()
            SVProgressHUD.showSuccess(withStatus: "清除成功")
            tableView.reloadData()
        }
    }
    
}

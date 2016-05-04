//
//  MainMenuViewController.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import MMDrawerController
import SVProgressHUD
import SDWebImage

enum MainMenuViewControllerOperate: Int {
    case Home
    case NoteTrack
    case ImageTextTrack
    case Setting
    case LogOut
}

protocol MainMenuViewControllerDelegate: NSObjectProtocol {
    func mainMenuViewController(mainMenuViewController: MainMenuViewController, operate: MainMenuViewControllerOperate) -> Void
}

class MainMenuViewController: UIViewController {
    
    weak var delegate: MainMenuViewControllerDelegate?
    
    override func loadView()
    {
        NSBundle.mainBundle().loadNibNamed("MainMenuView", owner: self, options: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mainMenuView!.menuTableView.registerNib(UINib(nibName: MainMenuViewCell.ClassName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: MainMenuViewCell.ClassName)
        self.configurUserInfo()
        
        let x = specialEffect
        specialEffect = x
    }
    
    func configurUserInfo()
    {
        if let userModel = MVBAppDelegate.MVBApp().dataSource.userModel as MVBUserModel? {
            if let coverImagePhoto = userModel.cover_image_phone as? String {
                mainMenuView!.headBackgroundImageView.sd_setImageWithURL(NSURL(string: coverImagePhoto as String!))
                mainMenuView!.nameLabel.textColor = UIColor.whiteColor()
            }
            else {
                mainMenuView!.nameLabel.textColor = UIColor.blackColor()
            }

            mainMenuView!.headImageView.sd_setImageWithURL(NSURL(string: userModel.avatar_large as String!))
            mainMenuView!.nameLabel.text = userModel.name as? String
            mainMenuView!.describeLbel.text = userModel._description as? String
        }
        else {
            let appDataSource = MVBAppDelegate.MVBApp().dataSource
            appDataSource.getUserInfo(self, tag: "getUserInfo")  //
        }
    }
    
    deinit
    {
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
 
//    struct ListItem {
//        var icon: UIImage?
//        var title: String
//        var url: NSURL
//        
//        static func listItemsFromJSONData(jsonData: NSData?) -> [ListItem] {
//            guard let jsonData = jsonData,
//                let json = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: []),
//                let jsonItems = json as? Array<NSDictionary> else { return [] }
//            
//            return jsonItems.flatMap { (itemDesc: NSDictionary) -> ListItem? in
//                guard let title = itemDesc["title"] as? String,
//                    let urlString = itemDesc["url"] as? String,
//                    let url = NSURL(string: urlString)
//                    else { return nil }
//                let iconName = itemDesc["icon"] as? String
//                let icon = iconName.flatMap { UIImage(named: $0) }
//                return ListItem(icon: icon, title: title, url: url)
//            }
//        }
//    }
    
}

//  MARK: Private
extension MainMenuViewController {
    
    weak var mainMenuView: MainMenuView! {
        return self.view as! MainMenuView
    }
    
    private var specialEffect: Bool {
        set {
            if newValue {
                self.mm_drawerController.setDrawerVisualStateBlock { (drawerVc, drawerSide, percentVisible) -> Void in
                    let block: MMDrawerControllerDrawerVisualStateBlock = MMDrawerVisualState.MVBCustomDrawerVisualState()
                    block(drawerVc, drawerSide, percentVisible)
                }
                self.mainMenuView!.clipsToBounds = true
            }
            else {
                self.mm_drawerController.setDrawerVisualStateBlock(MMDrawerVisualState.slideVisualStateBlock())
                self.mainMenuView!.clipsToBounds = false
            }
            NSUserDefaults.standardUserDefaults().setValue(NSNumber(bool: newValue), forKeyPath: "specialEffect")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            guard let specialEffect = NSUserDefaults.standardUserDefaults().valueForKey("specialEffect") as? NSNumber else { return false }
            return specialEffect.boolValue == true
        }
    }
    
}

// MARK: buttonAction
extension MainMenuViewController {

    @IBAction func backMainAction(sender: AnyObject)
    {
        delegate!.mainMenuViewController(self, operate: .Home)
    }
    
    @IBAction func settingAction(sender: AnyObject)
    {
        if let _ = (mm_drawerController!.centerViewController as? UINavigationController)?.topViewController as? MVBSettingViewController {
            mm_drawerController!.closeDrawerAnimated(true, completion: nil)
        }
        else {
            let settingNavi = UIStoryboard(name: "MVBSetting", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UINavigationController
            let settingViewController = settingNavi.topViewController as! MVBSettingViewController
            settingViewController.specialEffectSwitchClosuer = { [unowned self] in
                self.specialEffect = $0
            }
            mm_drawerController!.setCenterViewController(settingNavi, withFullCloseAnimation: true, completion: { [unowned self] (finish) -> Void in
                self.mm_drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
                self.mm_drawerController!.bouncePreviewForDrawerSide(MMDrawerSide.Left, distance: 5, completion: { (finish) -> Void in
                    self.mm_drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
                })
            })
        }
        
        delegate!.mainMenuViewController(self, operate: .Setting)
    }

    @IBAction func logOutAction(sender: AnyObject)
    {
        let appDataSource = MVBAppDelegate.MVBApp().dataSource
        WeiboSDK.logOutWithToken(appDataSource.accessToken!, delegate: self, withTag: "logOut")
        SVProgressHUD.showWithStatus("正在退出...")
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
    }
    
    @IBAction func clearDiskMemory(sender: AnyObject)
    {
        //  清理硬盘缓存
        SDImageCache.sharedImageCache().clearDisk()
        SDImageCache.sharedImageCache().clearMemory()
        SDImageCache.sharedImageCache().cleanDisk()
    }
    
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension MainMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y < 0 {
            if scrollView.contentOffset.y < -80 {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -80)
            }
            mainMenuView!.headBackgroundImageView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y / 2)
        }
        else {
            mainMenuView!.headBackgroundImageView.transform = CGAffineTransformMakeTranslation(0, 0)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.row {
        case 0:
            delegate?.mainMenuViewController(self, operate: .NoteTrack)
        case 1:
            delegate?.mainMenuViewController(self, operate: .ImageTextTrack)
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(MainMenuViewCell.ClassName) as! MainMenuViewCell
        if indexPath.row == 0 {
            cell.textLabel?.text = "Note Track"
        }
        if indexPath.row == 1 {
            cell.textLabel?.text = "Image Text Track"
        }
        return cell
    }
    
}

// MARK: WBHttpRequestDelegate
extension MainMenuViewController: WBHttpRequestDelegate {
    
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!)
    {
        if request.tag == "logOut" {
            MVBAppDelegate.MVBApp().dataSource.clearUserInfo()
            SVProgressHUD.dismiss()
            //  清理硬盘缓存
            SDImageCache.sharedImageCache().clearDisk()
            SDImageCache.sharedImageCache().clearMemory()
            
            self.mm_drawerController!.dismissViewControllerAnimated(false) {
                self.delegate!.mainMenuViewController(self, operate: MainMenuViewControllerOperate.LogOut)
            }
        }
        if request.tag == "getUserInfo" {
            MVBAppDelegate.MVBApp().dataSource.setUserInfoWithJsonString(result!)
            configurUserInfo()
        }
    }
    
    func request(request: WBHttpRequest!, didFailWithError error: NSError!)
    {
        SVProgressHUD.showErrorWithStatus("网络错误")
    }
    
}

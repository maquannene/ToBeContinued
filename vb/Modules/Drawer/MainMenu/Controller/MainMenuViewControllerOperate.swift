//
//  MainMenuViewController.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import MMDrawerController
import SVProgressHUD
import Kingfisher

enum MainMenuViewControllerOperate: Int {
    case home
    case noteTrack
    case imageTrack
    case setting
    case logOut
}

protocol MainMenuViewControllerDelegate: NSObjectProtocol {
    func mainMenuViewController(_ mainMenuViewController: MainMenuViewController, operate: MainMenuViewControllerOperate) -> Void
}

class MainMenuViewController: UIViewController {
    
    weak var delegate: MainMenuViewControllerDelegate?
    
    override func loadView()
    {
        Bundle.main.loadNibNamed("MainMenuView", owner: self, options: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mainMenuView.menuTableView.register(UINib(nibName: MainMenuViewCell.RealClassName, bundle: Bundle.main), forCellReuseIdentifier: MainMenuViewCell.RealClassName)
        UserInfoManange.shareInstance.getUserInfo(from: true) { [unowned self] (success, userModel) in
            if success && userModel != nil {
                self.configure(userModel!)
            }
        }
        
        self.mm_drawerController.setDrawerVisualStateBlock(MMDrawerVisualState.slideVisualStateBlock())
        self.mainMenuView.clipsToBounds = false
    }
    
    func configure(_ userModel: UserModel)
    {
        if let coverImagePhoto = userModel.cover_image_phone as String?,
            let url = URL(string: coverImagePhoto) {
            mainMenuView.headBackgroundImageView.kf.setImage(with: ImageResource(downloadURL: url))
            mainMenuView.nameLabel.textColor = UIColor.white
        }
        else {
            mainMenuView.nameLabel.textColor = UIColor.black
        }
        
        if let avatar_large = userModel.avatar_large as String?,
            let url = URL(string: avatar_large) {
            mainMenuView.headImageView.mkf_setImage(with: url)
        }

        mainMenuView.nameLabel.text = userModel.name as? String
        mainMenuView.describeLbel.text = userModel._description as? String
    }
    
    deinit
    {
        print("\(type(of: self)) deinit\n", terminator: "")
    }
    
}

//  MARK: Private
extension MainMenuViewController {
    
    weak var mainMenuView: MainMenuView! {
        return self.view as! MainMenuView
    }
}

// MARK: buttonAction
extension MainMenuViewController {

    @IBAction func backMainAction(_ sender: AnyObject)
    {
        delegate!.mainMenuViewController(self, operate: .home)
    }
    
    @IBAction func settingAction(_ sender: AnyObject)
    {
        if let _ = (mm_drawerController!.centerViewController as? UINavigationController)?.topViewController as? SettingViewController {
            mm_drawerController!.closeDrawer(animated: true, completion: nil)
        }
        else {
            let settingNavi = UIStoryboard(name: "Setting", bundle: Bundle.main).instantiateInitialViewController() as! UINavigationController
            _ = settingNavi.topViewController as! SettingViewController
            mm_drawerController!.setCenterView(settingNavi, withFullCloseAnimation: true, completion: { [unowned self] (finish) -> Void in
                self.mm_drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode()
                self.mm_drawerController!.bouncePreview(for: MMDrawerSide.left, distance: 5, completion: { (finish) -> Void in
                    self.mm_drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.all
                })
            })
        }
        
        delegate!.mainMenuViewController(self, operate: .setting)
    }

    @IBAction func logOutAction(_ sender: AnyObject)
    {
        let userInfoManage = UserInfoManange.shareInstance
        WeiboSDK.logOut(withToken: userInfoManage.accessToken!, delegate: self, withTag: "logOut")
        SVProgressHUD.show(withStatus: "正在退出...")
    }
    
    @IBAction func clearDiskMemory(_ sender: AnyObject)
    {
        //  清理硬盘缓存
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
        ImageCache.default.cleanExpiredDiskCache()
    }
    
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension MainMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y < 0 {
            if scrollView.contentOffset.y < -80 {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -80)
            }
            mainMenuView.headBackgroundImageView.transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y / 2)
        }
        else {
            mainMenuView.headBackgroundImageView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.row {
        case 0:
            delegate?.mainMenuViewController(self, operate: .noteTrack)
        case 1:
            delegate?.mainMenuViewController(self, operate: .imageTrack)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainMenuViewCell.RealClassName) as! MainMenuViewCell
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
    
    func request(_ request: WBHttpRequest!, didFinishLoadingWithResult result: String!)
    {
        if request.tag == "logOut" {
            UserInfoManange.shareInstance.clear()
            SVProgressHUD.dismiss()
            //  清理硬盘缓存
            //  清理硬盘缓存
            ImageCache.default.clearDiskCache()
            ImageCache.default.clearMemoryCache()
            ImageCache.default.cleanExpiredDiskCache()
            
            self.mm_drawerController!.dismiss(animated: false) {
                self.delegate!.mainMenuViewController(self, operate: MainMenuViewControllerOperate.logOut)
            }
        }
    }
    
    func request(_ request: WBHttpRequest!, didFailWithError error: Error!)
    {
        SVProgressHUD.showError(withStatus: "网络错误")
    }
    
}

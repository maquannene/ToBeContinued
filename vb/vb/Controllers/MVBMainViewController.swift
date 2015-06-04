
//
//  MVBMainViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBMainViewController: UIViewController {
    
    var userVC: MVBUserViewController?
    var heroesVC: MVBHeroesViewController?
    
    override func viewDidLoad() {
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "heroesVC" {
            if heroesVC != nil {
                self.presentViewController(heroesVC!, animated: true, completion: { () -> Void in
                    
                })
                return false
            }
            else {
                return true
            }
        }
        if identifier == "userVC" {
            if userVC != nil {
                self.presentViewController(userVC!, animated: true, completion: { () -> Void in
                    
                })
                return false
            }
            else {
                return true
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier as String? {
            self.setValue(segue.destinationViewController, forKey: identifier)
        }
    }
    @IBAction func logOutAction(sender: AnyObject) {
        var appDelegate = MVBAppDelegate.MVBApp()
        WeiboSDK.logOutWithToken(appDelegate.accessToken!, delegate: self, withTag: nil)
    }
    
    deinit {
    
    }
    
}

extension MVBMainViewController: WBHttpRequestDelegate {
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        
    }
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

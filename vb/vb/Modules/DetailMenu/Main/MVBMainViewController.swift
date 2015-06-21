
//
//  MVBMainViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import BlocksKit

class MVBMainViewController: MVBDetailBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellowColor()
        
        var button: UIButton = UIButton(frame: CGRectMake(100, 200, 80, 44))
//        button.backgroundColor = UIColor.redColor()
        button.bk_addEventHandler({ (button) -> Void in
            var vc = UIViewController()
            
            vc.view.backgroundColor = UIColor.redColor()
            self.navigationController!.pushViewController(vc, animated: true)
        }, forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var destVc: UIViewController? = self.valueForKey(identifier!) as? UIViewController
        if destVc != nil {
            self.navigationController!.pushViewController(destVc!, animated: true)
            return false
        }
        else {
            return true
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier as String? {
            self.setValue(segue.destinationViewController, forKey: identifier)
        }
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}
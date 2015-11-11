
//
//  MVBHomeViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import BlocksKit

class MVBHomeViewController: MVBDetailBaseViewController {
    
    //  将自己放在一个navigationController上初始化，可采用类方法
    //  但是这种方法不好，如果有一百个类继承MVBDetailBaseViewController都想用这种初始化方法就要写100遍
    //  所以在父类中 写一个便利构造函数
    //  且因为swift 不允许 initCustom() 这种写法，必须要用参数区别，所以用枚举代替init后缀也是不错的选择。
//    class func initOnNavigationController() -> MVBHomeViewController {
//        var vc: MVBHomeViewController = MVBHomeViewController()
//        var navi: UINavigationController = UINavigationController(rootViewController: vc)
//        vc.mainNavi = navi
//        return vc
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        self.view.backgroundColor = UIColor.yellowColor()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        let destVc: UIViewController? = self.valueForKey(identifier!) as? UIViewController
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
        print("\(self.dynamicType) deinit\n")
    }
}
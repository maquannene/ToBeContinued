
//
//  HomeViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class HomeViewController: DetailBaseViewController {
    
    //  将自己放在一个navigationController上初始化，可采用类方法
    //  但是这种方法不好，如果有一百个类继承DetailBaseViewController都想用这种初始化方法就要写100遍
    //  所以在父类中 写一个便利构造函数
    //  且因为swift 不允许 initCustom() 这种写法，必须要用参数区别，所以用枚举代替init后缀也是不错的选择。
//    class func initOnNavigationController() -> HomeViewController {
//        var vc: HomeViewController = HomeViewController()
//        var navi: UINavigationController = UINavigationController(rootViewController: vc)
//        vc.mainNavi = navi
//        return vc
//    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.yellow
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool
    {
        let destVc: UIViewController? = self.value(forKey: identifier!) as? UIViewController
        if destVc != nil {
            self.navigationController!.pushViewController(destVc!, animated: true)
            return false
        }
        else {
            return true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let identifier = segue.identifier as String? {
            self.setValue(segue.destination, forKey: identifier)
        }
    }
    
    deinit {
        print("\(type(of: self)) deinit\n")
    }
    
}

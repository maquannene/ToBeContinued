//
//  MVBNewPasswordConfigViewController.swift
//  vb
//
//  Created by 马权 on 6/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBNewPasswordConfigViewController: UIViewController {
    
    var confirmBtn: UIButton?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        confirmBtn = UIButton(frame: CGRectMake(0, 0, 44, 44))
//        confirmBtn!.backgroundColor = UIColor.redColor()
        confirmBtn!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        confirmBtn!.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        confirmBtn!.setTitle("添加", forState: UIControlState.Normal)
        confirmBtn!.addTarget(self, action: "confirmBtnAddNewPasswrodAction:", forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmBtn!)
    }
    
    override func viewDidLoad() {
    }
    
    func confirmBtnAddNewPasswrodAction(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

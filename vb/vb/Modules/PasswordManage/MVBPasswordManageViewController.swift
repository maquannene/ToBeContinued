//
//  MVBPasswordManageViewController.swift
//  vb
//
//  Created by 马权 on 6/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordManageViewController: UIViewController {
    
    weak var newPasswordBtn: UIButton?
    weak var newPasswordConfigVc: MVBNewPasswordConfigViewController?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        newPasswordBtn = (UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton)
        newPasswordBtn!.addTarget(self, action: "addNewPasswrodAction:", forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newPasswordBtn!)
    }
    
    override func viewDidLoad() {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier as String? {
            self.setValue(segue.destinationViewController, forKey: identifier)
        }
    }
    
    func addNewPasswrodAction(sender: AnyObject!) {
        self .performSegueWithIdentifier("newPasswordConfigVc", sender: sender)
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

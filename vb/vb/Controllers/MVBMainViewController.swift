
//
//  MVBMainViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBMainViewController: UIViewController, WBHttpRequestDelegate {
    
    weak var personViewController: MVBPersonViewController?
    var heroesViewController: MVBHeroesViewController?
    
    override func viewDidLoad() {
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "heroesViewController" {
            if heroesViewController != nil {
                self.presentViewController(heroesViewController!, animated: true, completion: { () -> Void in
                    
                })
                return false
            }
            else {
                return true
            }
        }
        if identifier == "personViewController" {
            if personViewController != nil {
                self.presentViewController(personViewController!, animated: true, completion: { () -> Void in
                    
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
}

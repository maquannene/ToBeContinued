//
//  MVBAccountManageViewController.swift
//  vb
//
//  Created by 马权 on 6/25/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

let kAccountCell = "kAccountCell"

class MVBAccountManageViewController: MVBDetailBaseViewController {
    
    var accountListView: UITableView?
    var dataSource: MVBAccountManageDataSource!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        
        dataSource = MVBAccountManageDataSource()
        
        accountListView = UITableView(frame: CGRectMake(0, 64, self.view.frame.width, self.view.frame.height - 64 - 44), style: UITableViewStyle.Plain)
        accountListView!.delegate = dataSource as UITableViewDelegate
        accountListView!.dataSource = dataSource as UITableViewDataSource
        accountListView!.rowHeight = 60
        accountListView!.registerClass(MVBAcconutTableViewCell.self, forCellReuseIdentifier: kAccountCell)
        accountListView!.tableFooterView = UIView()
        self.view.addSubview(accountListView!)
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }

}
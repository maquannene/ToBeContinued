//
//  MVBHeroesViewController.swift
//  vb
//
//  Created by 马权 on 5/20/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

let kDota2DevApiKey = "key"
let kDota2DevApiValue = "5E09D57E6D09BE20A1DF727134A89871"
let kDota2HeroesLanguageKey = "language"
let kDota2HeroesLanguageValue = "zh"
let kDota2HeroesUrl = "https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/"

class MVBHeroesViewController: UIViewController {

    @IBOutlet weak var heroesTableView: UITableView!
    var heroesInfo: MVBHeroesInfoModel = MVBHeroesInfoModel()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heroesTableView.registerNib(UINib(nibName: "MVBHeroTableViewCell", bundle: nil), forCellReuseIdentifier: "hero")
        self.getHeroesModel()
    }
}

extension MVBHeroesViewController {
    func getHeroesModel() {
        var requestOperate: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        requestOperate.responseSerializer = AFJSONResponseSerializer()
        var param: [String: String] = [kDota2DevApiKey: kDota2DevApiValue,
                                       kDota2HeroesLanguageKey: kDota2HeroesLanguageValue]
        weak var aSelf = self
        requestOperate.GET(kDota2HeroesUrl, parameters: param, success: { (operation, result: AnyObject!) in
            let resultDic = result as! NSDictionary
            self.heroesInfo = MVBHeroesInfoModel(keyValues: resultDic["result"])
            self.heroesInfo.heroseModelArray = NSMutableArray(array:MVBHeroModel.objectArrayWithKeyValuesArray(self.heroesInfo.heroesDicArray))
            aSelf!.heroesTableView.reloadData()
        }) {
            println($1)
        }
        
//        var image: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: NSURL(string: "http://cdn.dota2.com/apps/dota2/images/heroes/terrorblade_lg.png"))
//        image.requestSerializer = AFHTTPRequestSerializer() as AFHTTPRequestSerializer
//        image.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
//        image.responseSerializer.acceptableContentTypes = ["application/json", "text/json", "text/javascript","text/html", "text/plain", "image/png"]
//        image.GET("http://cdn.dota2.com/apps/dota2/images/heroes/terrorblade_lg.png", parameters: nil, success: { (operation, result) -> Void in
//            println(result)
//            var image = result as! UIImage
//            }) { (operation, error) -> Void in
//                println(error)
//        }
    }
}

extension MVBHeroesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.heroesInfo.count.integerValue
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView .dequeueReusableCellWithIdentifier("hero") as! MVBHeroTableViewCell
        var heroesModel = self.heroesInfo.heroseModelArray
        if let cellModel = heroesModel[indexPath.row] as? MVBHeroModel {
            cell.configure(cellModel)
        }
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
}

//
//  MVBHeroesViewController.swift
//  vb
//
//  Created by 马权 on 5/20/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

let kDota2DevApiKey = "key"
let kDota2DevApiValue = "5E09D57E6D09BE20A1DF727134A89871"
let kDota2HeroesLanguageKey = "language"
let kDota2HeroesLanguageValue = "zh"
let kDota2HeroesUrl = "https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/"

class MVBHeroesViewController: MVBDetailBaseViewController {
    
    @IBOutlet weak var heroesTableView: UITableView!
    var heroesInfo: MVBHeroesInfoModel = MVBHeroesInfoModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blueColor()
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        SDImageCache.sharedImageCache().clearMemory()
        super.dismissViewControllerAnimated(flag, completion: completion)
    }
    
    @IBAction func clearDiskAction(sender: AnyObject) {
        SDImageCache.sharedImageCache().clearDisk()
    }
    
    @IBAction func clearMemory(sender: AnyObject) {
        SDImageCache.sharedImageCache().clearMemory()
    }
    
    deinit {
        print("\(self.dynamicType) deinit")
    }
}

extension MVBHeroesViewController {
    func getHeroesModel() {
        let requestOperate: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        requestOperate.responseSerializer = AFJSONResponseSerializer()
        let param: [String: String] = [kDota2DevApiKey: kDota2DevApiValue,
                                       kDota2HeroesLanguageKey: kDota2HeroesLanguageValue]
        requestOperate.GET(kDota2HeroesUrl, parameters: param, success: {
            [unowned self] (operation, result: AnyObject!) in
            let resultDic = result as! NSDictionary
            self.heroesInfo = MVBHeroesInfoModel(keyValues: resultDic["result"])
            self.heroesInfo.heroseModelArray = NSMutableArray(array:MVBHeroModel.objectArrayWithKeyValuesArray(self.heroesInfo.heroesDicArray))
            self.heroesTableView.reloadData()
        }) {
            print($1)
        }
    } 
}

extension MVBHeroesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.heroesInfo.count.integerValue
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("hero") as! MVBHeroTableViewCell
        let heroesModel = self.heroesInfo.heroseModelArray
        if let cellModel = heroesModel?[indexPath.row] as? MVBHeroModel {
            cell.configure(cellModel)
        }
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

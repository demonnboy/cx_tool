//
//  ViewController.swift
//  cx_tool
//
//  Created by Demon on 2020/8/18.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let array = ["UI测试", "unrecognized selector crash", "NSTimer crash", "Container crash（数组越界，插nil等）", "NSString crash （字符串操作的crash)", "字典崩溃", "测试输出"]
    var name =  ""
    override func viewDidLoad() {
        super.viewDidLoad()
        printLog("进入到页面了")
        self.view.addSubview(self.tableView)
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 50
        table.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        return table
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        let str = self.array[indexPath.row]
        cell.textLabel?.text = str
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let test = TestCrash()
        switch indexPath.row {
            case 0:
                let vc = TestViewController()
                vc.view.backgroundColor = UIColor.black
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                test.unrecognizedSelector()
            case 3:
                test.arrayCrash()
            case 4:
                test.stringCrash()
            case 5:
                test.dictionaryCrash()
            case 6:
                let dics: [[String: Any]] = [["component": "banner", "result": [["img": "http://www.shihuo.com", "title": "测试数据"]]], ["component": "banner", "result": [["img": "http://www.baidu.com", "title": "首页广告"]]]]
                
                let list = (NSArray.yy_modelArray(with: BaseModel.self, json: dics) as? [BaseModel]) ?? []
                for item in list {
                    if let l = item.getRealModels() {
                        print(l.count)
                    }
                }
            default:
                break
        }
    }
}


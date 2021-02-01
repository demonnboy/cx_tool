//
//  ViewController.swift
//  cx_tool
//
//  Created by Demon on 2020/8/18.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var testView: UIView!
    var timer: Timer!
    let net = NetworkMonitor()
    
    let array = ["UI测试", "unrecognized selector crash", "NSTimer crash", "Container crash（数组越界，插nil等）", "NSString crash （字符串操作的crash)", "字典崩溃", "测试输出", "uipageviewconreoller"]
    var name =  ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(bytecalte), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        timer.fire()
    }
    
    @objc func bytecalte() {
        print("1111")
        print(net.getInterFaceBytes())
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print(testView!)
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
            case 7:
                self.navigationController?.pushViewController(PageViewController(), animated: true)
            default:
                break
        }
    }
}


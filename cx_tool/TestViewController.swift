//
//  TestViewController.swift
//  cx_tool
//
//  Created by Demon on 2020/8/19.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit

class TestViewController: SHCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "update", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.updateItem))
    }
    
    @objc func updateItem() {
        var res: [SHCellModelProtocol] = []
        for _ in 0..<1 {
            let model = TestViewControllrtModel()
            model.color = UIColor.black
            res.append(model)
        }
        
        self.fetchs.fetch.updates(start: 7, newObject: res)
    }
    
    func testData() -> [SHCellModelProtocol] {
        var res: [SHCellModelProtocol] = []
        for i in 1..<10 {
            let model = TestViewControllrtModel()
            if i%9 == 0 {
                model.isExclusiveLine = true
                model.color = UIColor.brown
                model.canFloating = true
            }
            res.append(model)
        }
        for _ in 0..<100 {
            let model = TestViewControllrtModel()
            res.append(model)
        }
        return res
    }
    
    override func loadLayout() -> UICollectionViewFlowLayout {
        let config = MMLayoutConfig()
        config.columnCount = 2
        config.rowHeight = 0
        config.rowDefaultSpace = 4
        config.columnSpace = 4
        config.floating = true
        config.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return SHCollectionViewFlowLayout(config)
    }
    
    override func loadFetchs() -> [SHFetch<SHCollectionViewController.T>] {
        let res = self.testData()
        return [SHFetch(list: res)]
    }
}

class TestViewControllrtModel: SHCellModel {
    
    override init() {
        super.init()
        self.cellID = String(describing: TestViewControllerCell.self)
        self.cellHeight = 100
        self.anyClss = TestViewControllerCell.self
    }
    
    var color : UIColor = UIColor.red
}


class TestViewControllerCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sh_onDisplay(_ tableView: UIScrollView, model: AnyObject, atIndexPath indexPath: IndexPath, reused: Bool) {
        if let m = model as? TestViewControllrtModel {
            self.backgroundColor = m.color
        }
    }
    
}
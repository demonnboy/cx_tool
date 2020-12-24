//
//  PageViewController.swift
//  cx_tool
//
//  Created by Demon on 2020/12/7.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit

class PageViewController: SHBasePageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.reloadViewControllers()
    }

    override func collectionController() -> [UIViewController] {
        var res: [UIViewController] = []
        for i in 0...20 {
            let vc = TestViewController()
            vc.sh_pageIndex = i
            res.append(vc)
        }
        return res
    }
    
}

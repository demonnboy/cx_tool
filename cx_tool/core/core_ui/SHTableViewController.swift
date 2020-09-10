//
//  SHTableViewController.swift
//  Demon
//
//  Created by Demon on 2019/12/12.
//  Copyright © 2019 Demon. All rights reserved.
//

import UIKit

class SHTableViewController: UIViewController, UITableViewDelegate {
    
    typealias T = SHCellModelProtocol
    public var tableView: UITableView { get { return _tableView } }
    public var dops: SHDataOperationsController<T> { get { return _dops } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _tableView.dataSource = _dops
        self.view.addSubview(_tableView)
    }
    
    public func loadFetchs() -> [SHDataOperation<T>] {
        return [SHDataOperation<T>()]
    }
    
    private lazy var _tableView: UITableView = {
        let tb = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tb.delegate = self
        tb.separatorStyle = .none
        tb.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tb.estimatedRowHeight = 0
        tb.estimatedSectionFooterHeight = 0
        tb.estimatedSectionHeaderHeight = 0
        tb.contentInset = .zero
        if #available(iOS 11.0, *) {
            tb.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        return tb
    }()
    
    private final lazy var _dops: SHDataOperationsController<T> = {
        let ff = SHDataOperationsController(list: loadFetchs())
        return ff
    }()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let model = self.dops.object(at: indexPath) {
            return model.sh_cellHeight()
        }
        return 44
    }
    
    deinit {
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }
}

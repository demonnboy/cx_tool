//
//  SHFetchsController.swift
//  Demon
//
//  Created by Demon on 2020/6/11.
//  Copyright © 2020 Demon. All rights reserved.
//

import Foundation
import UIKit

public class SHDataOperation<T: SHCellModelProtocol>: NSObject {
    
    public var list = [T]()
    fileprivate weak var listener: SHDataOperationsController<T>?
    
    convenience init(list: [T]?) {
        self.init()
        if let l = list {
            self.list = l
        }
    }
    
    public func viewForItem(at indexPath: IndexPath) -> UIView? {
        guard let model = self.list[indexPath.row] as? SHCellModel, let table = self.transaction.table else { return nil }
        if let collectionView = table as? UICollectionView {
            if model.sh_canFloating() {
                return collectionView.supplementaryView(forElementKind: COLLECTION_HEADER_KIND, at: indexPath)
            } else {
                return collectionView.cellForItem(at: indexPath)
            }
        } else if let tableView = table as? UITableView {
            if model.sh_canFloating() {
                return tableView.headerView(forSection: indexPath.section)
            } else {
                return tableView.cellForRow(at: indexPath)
            }
        }
        return nil
    }
    
    public func append<C: Sequence>(_ newObjects: C) where C.Iterator.Element == T {
        self.insert(newObjects, at: self.count())
    }
    
    public func updates<C: Sequence>(start idx: Int, newObject: C, animated: Bool? = nil) where C.Iterator.Element == T {
        self.operation(updates: { (section) -> [IndexPath] in
            if idx < 0 || idx >= self.list.count {
                return []
            }
            var results: [IndexPath] = []
            var index = idx
            for obj in newObject {
                if self[index] == nil {
                    continue
                } else {
                    self.list[index] = obj
                    results.append(IndexPath(row: index, section: section))
                }
                index += 1
            }
            return results
        }, animated: animated)
    }
    
    public func delete(_ index: Int, length: Int, animated: Bool? = nil) {
        self.operation(deletes: { (section) -> [IndexPath] in
            if index < 0 || index >= self.list.count {
                return []
            }
            let len = self.list.count > (index + length) ? (index + length) : self.list.count
            var results: [IndexPath] = []
            for ii in (index..<len).reversed() {
                self.list.remove(at: ii)
                results.append(IndexPath(row: ii, section: section))
            }
            return results
        }, animated: animated)
    }
    
    public func insert<C: Sequence>(_ newObjects: C, at index: Int) where C.Iterator.Element == T {
        self.operation(inserts: { (section) -> [IndexPath] in
            var idx = index
            // compatibility out boundary
            if index < 0 || index > self.list.count {
                idx = self.list.count
            }
            var results: [IndexPath] = []
            for obj in newObjects {
                let at = idx
                self.list.insert(obj, at: at)
                results.append(IndexPath(row: at, section: section))
                idx += 1
            }
            return results
        }, animated: false)
    }
    
    public func reset<C: Sequence>(_ newObjects: C, start startIndex: Int = 0, animated: Bool? = nil) where C.Iterator.Element == T {
        self.operation(deletes: { (section) -> [IndexPath] in
            if self.list.isEmpty || startIndex >= self.list.count || startIndex < 0 {
                return []
            }
            var results: [IndexPath] = []
            for ii in (startIndex..<self.list.count).reversed() {
                self.list.remove(at: ii)
                results.append(IndexPath(row: ii, section: section))
            }
            return results
        }, inserts: { (section) -> [IndexPath] in
            if startIndex < 0 || startIndex > self.list.count {
                var idx = self.list.count
                var results: [IndexPath] = []
                for obj in newObjects {
                    let at = idx
                    self.list.insert(obj, at: at)
                    results.append(IndexPath(row: at, section: section))
                    idx += 1
                }
                return results
            }
            var idx = startIndex
            var results: [IndexPath] = []
            for obj in newObjects {
                let at = idx
                self.list.insert(obj, at: at)
                results.append(IndexPath(row: at, section: section))
                idx += 1
            }
            return results
        }, animated: animated)
    }
    
    public func clear(animated: Bool? = nil) {
        self.operation(deletes: { (section) -> [IndexPath] in
            if self.list.isEmpty {
                return []
            }
            var results: [IndexPath] = []
            for ii in (0..<self.list.count).reversed() {
                self.list.remove(at: ii)
                results.append(IndexPath(row: ii, section: section))
            }
            return results
        }, animated: animated)
    }
    
    public final func transaction(_ batch:@escaping () -> Void, animated: Bool? = nil) {
        if !Thread.isMainThread { fatalError("Must call the method operation(deletes: inserts: updates:) in main thread") }
        if self.transaction.has {
            batch()
        } else {
            self.listener?.shDataOperationChanging(self, batch: batch, transaction: self.transaction)
        }
    }
    
    internal final func operation(deletes:((_ section: Int) -> [IndexPath])? = nil, inserts:((_ section: Int) -> [IndexPath])? = nil, updates:((_ section: Int) -> [IndexPath])? = nil, animated: Bool?) {
        if !Thread.isMainThread { fatalError("Must call the method operation(deletes: inserts: updates:) in main thread") }
        self.transaction({ [weak self] in
            guard let sself = self else { return }
            sself.listener?.updates(deletes: deletes, inserts: inserts, updates: updates, at: sself.transaction.section, animated: animated ?? false)
            }, animated: nil)
    }
    
    private var transaction: Transaction = Transaction()
    
    public subscript(index: Int) -> T? {
        return self.get(index)
    }
    
    public func get(_ index: Int) -> T? {
        if index < 0 || index >= self.list.count {
            return nil
        }
        return self.list[index]
    }
    
    public func count() -> Int {
        return self.list.count
    }
    
    public func objects() -> [T]? {
        return Array(self.list)
    }
}

private class Transaction {
    var has = false
    var section = -1
    var table: UIScrollView?
    var animated: Bool = false
}

public class SHDataOperationsController <T: SHCellModelProtocol>: NSObject, UITableViewDataSource, UICollectionViewDataSource {
    
    public weak var eventDelegate: SHGlobalProtocol? // 传个对象进来
    private var _dopList = [] as [SHDataOperation<T>]
    private var _isRgst: Set<String> = Set<String>()
    private weak var _table: UIScrollView?
    
    public init(list: [SHDataOperation<T>]) {
        super.init()
        _dopList = list
        if _dopList.isEmpty {
            _dopList.append(SHDataOperation())
        }
        for dop in _dopList {
            dop.listener = self
        }
    }

    // MARK: - 计算
    public var dop: SHDataOperation<T> {
        return self[0]!
    }
    
    public subscript(index: Int) -> SHDataOperation<T>? {
        get {
            if index < 0 || index >= _dopList.count { return nil }
            return _dopList[index]
        }
    }
    
    public func count() -> Int {
        return _dopList.count
    }
    
    public func object(at indexPath: IndexPath) -> T? {
        return self[indexPath.section]?[indexPath.row]
    }
    
    private func indexOf(_ dop: SHDataOperation<T>) -> Int? {
        for index in 0..<_dopList.count {
            if _dopList[index] === dop {
                return index
            }
        }
        return nil
    }
    
    public func clear() {
        for dop in _dopList {
            dop.clear()
        }
    }
    
    fileprivate func shDataOperationChanging(_ dataOperation: SHDataOperation<T>, batch: @escaping () -> Void, animated: Bool? = nil, transaction: Transaction) {
        transaction.has = true
        transaction.table = _table
        if let section = self.indexOf(dataOperation) {
            transaction.section = section
        }
        if let ani = animated {
            transaction.animated = ani
        }
        batch()
        transaction.has = false
    }
    
    fileprivate func updates(deletes delete: ((_ section: Int) -> [IndexPath])? = nil, inserts: ((_ section: Int) -> [IndexPath])? = nil, updates: ((_ section: Int) -> [IndexPath])? = nil, at section: Int, animated: Bool) {
        guard let table = _table else { return }
        if let tb = table as? UITableView {
            tableViewPerform(tb, deletes: delete, inserts: inserts, updates: updates, at: section, animated: animated)
        } else if let cl = table as? UICollectionView {
            collectionViewPerform(cl, deletes: delete, inserts: inserts, updates: updates, at: section, animated: animated)
        }
    }
    
    private func tableViewPerform(_ table: UITableView, deletes delete: ((_ section: Int) -> [IndexPath])? = nil, inserts: ((_ section: Int) -> [IndexPath])? = nil, updates: ((_ section: Int) -> [IndexPath])? = nil, at section: Int, animated: Bool) {
        let animation = animated ? UITableView.RowAnimation.automatic : UITableView.RowAnimation.none
        table.beginUpdates()
        if let delete = delete {
            let indexPaths = delete(section)
            table.deleteRows(at: indexPaths, with: animation)
        }
        if let inserts = inserts {
            let indexPaths = inserts(section)
            table.insertRows(at: indexPaths, with: animation)
        }
        if let updates = updates {
            let indexPaths = updates(section)
            table.reloadRows(at: indexPaths, with: animation)
        }
        table.endUpdates()
    }
    
    private func collectionViewPerform(_ table: UICollectionView, deletes delete: ((_ section: Int) -> [IndexPath])? = nil, inserts: ((_ section: Int) -> [IndexPath])? = nil, updates: ((_ section: Int) -> [IndexPath])? = nil, at section: Int, animated: Bool) {
        let perform = {
            if let delete = delete {
                let indexPaths = delete(section)
                table.deleteItems(at: indexPaths)
            }
            if let inserts = inserts {
                let indexPaths = inserts(section)
                table.insertItems(at: indexPaths)
            }
            if let updates = updates {
                let indexPaths = updates(section)
                table.reloadItems(at: indexPaths)
            }
        }
        animated ? table.performBatchUpdates(perform, completion: nil) : UIView.performWithoutAnimation(perform)
    }
    
    private func generateCell(_ view: UIScrollView, cellForRowAt indexPath: IndexPath, isSupplementary: Bool = false) -> UIView {
        // 使用普通方式创建cell
        var cellID = "cell"
        var isFloating = false
        
        var table: UITableView?
        var collection: UICollectionView?
        var cell: UIView?
        if view is UITableView {
            table = (view as? UITableView)
        } else if view is UICollectionView {
            collection = (view as? UICollectionView)
        }
        guard let model = self[indexPath.section]?[indexPath.row] else {
            cell = generateDefaultCell(view, cellForRowAt: indexPath, isSupplementary: isSupplementary)
            cell?.shWeakSetDops(self as AnyObject)
            return cell!
        }
        cellID = model.sh_cellID()
        isFloating = model.sh_canFloating()
        if cellID.isEmpty {
            cellID = ".auto.cell." + String(describing: type(of: model))
        }
        // 1.创建cell,此时cell是可选类型
        if let table = table {
            if isFloating {
                cell = table.dequeueReusableHeaderFooterView(withIdentifier: cellID)
            } else {
                cell = table.dequeueReusableCell(withIdentifier: cellID)
            }
            cell?.shWeakSetDops(self as AnyObject)
        }
        
        if cell == nil {
            if table != nil, model.responds(to: #selector(SHCellModelProtocol.sh_cell(_:))) {
                SHTry.try({
                    cell = model.sh_cell?(cellID)
                }, catch: { (exception) in }, finally: nil)
            } else if model.responds(to: #selector(SHCellModelProtocol.sh_cellClass(_:isFloating:))) {
                if !_isRgst.contains(cellID) {
                    _isRgst.insert(cellID)
                    SHTry.try({
                        let clz: AnyClass = model.sh_cellClass!(cellID, isFloating: isFloating)
                        if table != nil {
                            if isFloating {//只做header
                                table?.register(clz, forHeaderFooterViewReuseIdentifier: cellID)
                            } else {
                                table?.register(clz, forCellReuseIdentifier: cellID)
                            }
                        } else {
                            if isFloating {
                                collection?.register(clz, forSupplementaryViewOfKind: COLLECTION_HEADER_KIND, withReuseIdentifier: cellID)
                            } else {
                                collection?.register(clz, forCellWithReuseIdentifier: cellID)
                            }
                        }
                    }, catch: { (exception) in print("error:\(String(describing: exception))") }, finally: nil)
                }
                SHTry.try({
                    if table != nil {
                        if isFloating {//只做header
                            cell = table?.dequeueReusableHeaderFooterView(withIdentifier: cellID)
                        } else {
                            cell = table?.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
                        }
                        
                    } else {
                        if isFloating {
                            cell = collection?.dequeueReusableSupplementaryView(ofKind: COLLECTION_HEADER_KIND, withReuseIdentifier: cellID, for: indexPath)
                        } else {
                            cell = collection?.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
                        }
                    }
                }, catch: { (exception) in print("error:\(String(describing: exception))") }, finally: nil)
            }
            cell?.shWeakSetDops(self as AnyObject)
        }
        if cell == nil {
            cell = generateDefaultCell(view, cellForRowAt: indexPath, isSupplementary: isSupplementary)
            cell?.shWeakSetDops(self as AnyObject)
        }
        SHTry.try({
            let reused = model.isEqual(cell?.shCellModel)
            cell?.eventDelegate = self.eventDelegate
            cell?.shSetCellModel(model)
            cell?.shSetIndexPath(indexPath)
            cell?.shOnDisplay(view, model: model, atIndexPath: indexPath, reused: reused)
        }, catch: { (exception) in print("error:\(String(describing: exception))") }, finally: nil)
        return cell!
    }
    
    private func generateDefaultCell(_ view: UIScrollView, cellForRowAt indexPath: IndexPath, isSupplementary: Bool = false) -> UIView {
        var table: UITableView?
        var collection: UICollectionView?
        var cell: UIView?
        if view is UITableView {
            table = (view as? UITableView)
        } else if view is UICollectionView {
            collection = (view as? UICollectionView)
        }
        
        if table != nil {
            if isSupplementary {
                cell = UITableViewHeaderFooterView(reuseIdentifier: DEFAULT_HEAD_ID)
            } else {
                cell = UITableViewCell(style: .default, reuseIdentifier: DEFAULT_CELL_ID)
            }
        } else {
            if isSupplementary {
                if !_isRgst.contains(DEFAULT_HEAD_ID) {
                    _isRgst.insert(DEFAULT_HEAD_ID)
                    collection?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: COLLECTION_HEADER_KIND, withReuseIdentifier: DEFAULT_HEAD_ID)
                }
                cell = collection?.dequeueReusableSupplementaryView(ofKind: COLLECTION_HEADER_KIND, withReuseIdentifier: DEFAULT_HEAD_ID, for: indexPath)
            } else {
                if !_isRgst.contains(DEFAULT_CELL_ID) {
                    _isRgst.insert(DEFAULT_CELL_ID)
                    collection?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: DEFAULT_CELL_ID)
                }
                cell = collection?.dequeueReusableCell(withReuseIdentifier: DEFAULT_CELL_ID, for: indexPath)
            }
        }
        return cell!
    }
    
    // MARK: - datasouce
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if _table == nil { _table = tableView }
        return self.count()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self[section]?.count() ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = generateCell(tableView, cellForRowAt: indexPath) as? UITableViewCell {
            return cell
        }
        return UITableViewCell()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if _table == nil { _table = collectionView }
        return self.count()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self[section]?.count() ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = generateCell(collectionView, cellForRowAt: indexPath) as? UICollectionViewCell {
            return cell
        }
        return UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let cell = generateCell(collectionView, cellForRowAt: indexPath, isSupplementary: true)  as? UICollectionReusableView {
            return cell
        }
        return UICollectionReusableView()
    }
}

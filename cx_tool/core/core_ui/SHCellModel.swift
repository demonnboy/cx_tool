//
//  SHCellBaseModel.swift
//  Demon
//
//  Created by Demon on 2019/12/16.
//  Copyright © 2019 Demon. All rights reserved.
//

import Foundation
import UIKit

/// Cell model is data obj
@objc public protocol SHCellModelProtocol: NSObjectProtocol {
    func sh_cellID() -> String
    func sh_canEdit() -> Bool
    func sh_canMove() -> Bool
    func sh_cellHeight() -> CGFloat // UITableViewDelegate heightForRowAt or UICollectionViewLayout layoutAttributesForItemAtIndexPath
    func sh_cellWidth() -> CGFloat // 在SHLabelLayout下 cell的宽度
    func sh_cellInsets() -> UIEdgeInsets //内边距，floating将忽略此致
    func sh_canFloating() -> Bool // 单个cell悬浮
    func sh_isExclusiveLine() -> Bool // 单个cell横向布局
    func sh_cellGridSpanSize() -> Int //占用列数，小于等于零表示1
    func sh_isRowSpace() -> Bool // 是否需要行间距(主要针对sh_canFloating/sh_isExclusiveLine)
    @objc optional func sh_cell(_ cellID: String) -> UITableViewCell //适应于UITableView，尽量不采用反射方式
    @objc optional func sh_cellSize(_ indexPath: IndexPath) -> CGSize
    @objc optional func sh_cellClass(_ cellID: String, isFloating: Bool) -> Swift.AnyClass //返回cell class类型
    @objc optional func sh_cellNib(_ cellID: String, isFloating: Bool) -> UINib //返回cell class类型
}

public class SHCellModel: NSObject, SHCellModelProtocol {
    
    @objc public dynamic var cellID: String = "cellID"
        
    @objc public dynamic var canEdit: Bool = false
    
    @objc public dynamic var canMove: Bool = false
    
    @objc public dynamic var cellHeight: CGFloat = 44.0
    
    @objc public dynamic var cellWidth: CGFloat = 100.0
    
    @objc public dynamic var cellInsets: UIEdgeInsets = UIEdgeInsets.zero
    /// 悬浮
    @objc public dynamic var canFloating: Bool = false
    
    @objc public dynamic var cellSize: CGSize = CGSize(width: 0, height: 0)
    /// 横向布局
    @objc public dynamic var isExclusiveLine: Bool = false
    
    @objc public dynamic var isRowSpace: Bool = true // ture: 需要行间距 : false: 不需要行间距
    
    @objc public dynamic var cellGridSpanSize: Int = 1
    
    @objc public dynamic var anyClss: Swift.AnyClass = UICollectionViewCell.self

    public func sh_cellSize(_ indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    @objc public dynamic func sh_cellID() -> String {
        return cellID
    }

    @objc public dynamic func sh_canEdit() -> Bool {
        return canEdit
    }
    
    @objc public dynamic func sh_canMove() -> Bool {
        return canMove
    }
    
    @objc public dynamic func sh_cellHeight() -> CGFloat {
        return cellHeight
    }
    
    @objc public dynamic func sh_cellInsets() -> UIEdgeInsets {
        return cellInsets
    }
    
    @objc public dynamic func sh_canFloating() -> Bool {
        return canFloating
    }
    
    @objc public dynamic func sh_isExclusiveLine() -> Bool {
        return isExclusiveLine
    }
    
    @objc public dynamic func sh_isRowSpace() -> Bool {
        return isRowSpace
    }
    
    @objc public dynamic func sh_cellGridSpanSize() -> Int {
        return cellGridSpanSize
    }
    
    @objc public dynamic func sh_cellWidth() -> CGFloat {
        return cellWidth
    }

    public func sh_cellClass(_ cellID: String, isFloating: Bool) -> AnyClass {
        return anyClss
    }
}

private var CELL_DELEGATE_PROPERTY = 0
private var CELL_MODEL_PROPERTY = 0
private var CELL_INDEXPATH_PROPERTY = 0
private var CELL_FETCHS_PROPERTY = 0

@objc public protocol SHGlobalProtocol: NSObjectProtocol {}

class SHWeakObject: NSObject { // 解决weak对象未被释放的问题
    
    weak var eventDelegate: SHGlobalProtocol?
    /// DataOperationsController
    weak var dops: AnyObject?
}

extension UIView {
    
    @objc final weak var eventDelegate: SHGlobalProtocol? {
        get {
            guard let weakObject = objc_getAssociatedObject(self, &CELL_DELEGATE_PROPERTY) as? SHWeakObject else { return nil }
            return weakObject.eventDelegate
        }
        set {
            let weakObject = SHWeakObject()
            weakObject.eventDelegate = newValue
            objc_setAssociatedObject(self, &CELL_DELEGATE_PROPERTY, weakObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc final var shCellModel: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &CELL_MODEL_PROPERTY) as AnyObject?
        }
    }
    
    @objc final func shSetCellModel(_ model: AnyObject?) {
        objc_setAssociatedObject(self, &CELL_MODEL_PROPERTY, model, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc final var shIndexPath: IndexPath? {
        get {
            return objc_getAssociatedObject(self, &CELL_INDEXPATH_PROPERTY) as? IndexPath
        }
    }
    
    @objc final func shSetIndexPath(_ indexPath: IndexPath?) {
        objc_setAssociatedObject(self, &CELL_INDEXPATH_PROPERTY, indexPath, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// SHDataOperationsController
    @objc final weak var shDataOperationsController: AnyObject? {
        get {
            guard let weakObjc = objc_getAssociatedObject(self, &CELL_FETCHS_PROPERTY) as? SHWeakObject else { return nil }
            return weakObjc.dops
        }
    }
    
    /// shDataOperationsController
    @objc final func shWeakSetDops(_ dops: AnyObject?) {
        let weakObjc = SHWeakObject()
        weakObjc.dops = dops
        objc_setAssociatedObject(self, &CELL_FETCHS_PROPERTY, weakObjc, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// 展示数据
    ///
    /// - Parameters:
    ///   - tableView: view
    ///   - model: model
    ///   - indexPath: index
    ///   - reused: 数据是否一样
    @objc public dynamic func shOnDisplay(_ tableView: UIScrollView, model: AnyObject, atIndexPath indexPath: IndexPath, reused: Bool) {}
}

extension UIEdgeInsets {

    public var topAndBottom: CGFloat {
        return self.top + self.bottom
    }

    public var leftAndRight: CGFloat {
        return self.left + self.right
    }
}

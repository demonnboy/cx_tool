//
//  SHCellBaseModel.swift
//  SHUIPlan
//
//  Created by Demon on 2019/12/16.
//  Copyright © 2019 Demon. All rights reserved.
//

import Foundation
import UIKit

/// Cell model is data obj
@objc public protocol SHCellModelProtocol: NSObjectProtocol {
    func sh_cellID() -> String
    func sh_groupID() -> String? //分组实现
    func sh_canEdit() -> Bool
    func sh_canMove() -> Bool
    func sh_cellHeight() -> CGFloat //UITableViewDelegate heightForRowAt or UICollectionViewLayout layoutAttributesForItemAtIndexPath
    func sh_cellWidth() -> CGFloat // 在SHLabelLayout下 cell的宽度
    func sh_cellInsets() -> UIEdgeInsets //内边距，floating将忽略此致
    func sh_canFloating() -> Bool
    func sh_isExclusiveLine() -> Bool
    func sh_cellGridSpanSize() -> Int //占用列数，小于等于零表示1
    @objc optional func sh_cell(_ cellID: String) -> UITableViewCell //适应于UITableView，尽量不采用反射方式
    @objc optional func sh_cellSize(_ indexPath: IndexPath) -> CGSize
    @objc optional func sh_cellClass(_ cellID: String, isFloating: Bool) -> Swift.AnyClass //返回cell class类型
    @objc optional func sh_cellNib(_ cellID: String, isFloating: Bool) -> UINib //返回cell class类型
}

public class SHCellModel: NSObject, SHCellModelProtocol {
    
    @objc public dynamic var cellID: String = "cellID"
    
    @objc public dynamic var groupID: String = "groupID"
    
    @objc public dynamic var canEdit: Bool = false
    
    @objc public dynamic var canMove: Bool = false
    
    @objc public dynamic var cellHeight: CGFloat = 44.0
    
    @objc public dynamic var cellWidth: CGFloat = 100.0
    
    @objc public dynamic var cellInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    @objc public dynamic var canFloating: Bool = false
    
    @objc public dynamic var cellSize: CGSize = CGSize(width: 0, height: 0)
    
    @objc public dynamic var isExclusiveLine: Bool = false
    
    @objc public dynamic var cellGridSpanSize: Int = 1
    
    @objc public dynamic var anyClss: Swift.AnyClass = UICollectionViewCell.self

    public func sh_cellSize(_ indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    @objc public dynamic func sh_cellID() -> String {
        return cellID
    }
    
    @objc public dynamic func sh_groupID() -> String? {
        return groupID
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

extension UIView {
    
    @objc final weak var eventDelegate: SHGlobalProtocol? {
        get {
            return objc_getAssociatedObject(self, &CELL_DELEGATE_PROPERTY) as? SHGlobalProtocol
        }
        set {
            objc_setAssociatedObject(self, &CELL_DELEGATE_PROPERTY, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @objc var sh_cellModel: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &CELL_MODEL_PROPERTY) as AnyObject?
        }
    }
    
    @objc func sh_set_cellModel(_ model: AnyObject?) {
        objc_setAssociatedObject(self, &CELL_MODEL_PROPERTY, model, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc final var sh_indexPath: IndexPath? {
        get {
            return objc_getAssociatedObject(self, &CELL_INDEXPATH_PROPERTY) as? IndexPath
        }
    }
    
    @objc final func sh_set_indexPath(_ indexPath: IndexPath?) {
        objc_setAssociatedObject(self, &CELL_INDEXPATH_PROPERTY, indexPath, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc final var sh_fetchs: AnyObject? {
        get{
            guard let result = objc_getAssociatedObject(self, &CELL_FETCHS_PROPERTY) else {  return nil }
            return result as AnyObject
        }
    }
    
    @objc final func sh_weak_set_fetchs(_ fetchs:AnyObject?) {
        objc_setAssociatedObject(self, &CELL_FETCHS_PROPERTY, fetchs, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
    /// 展示数据
    ///
    /// - Parameters:
    ///   - tableView: view
    ///   - model: model
    ///   - indexPath: index
    ///   - reused: 数据是否一样
    @objc func sh_onDisplay(_ tableView: UIScrollView, model: AnyObject, atIndexPath indexPath: IndexPath, reused: Bool) {}
}

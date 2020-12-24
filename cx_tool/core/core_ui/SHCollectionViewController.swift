//
//  SHCollectionViewController.swift
//  Demon
//
//  Created by Demon on 2020/6/11.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit

public class SHCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, SHCollectionViewDelegate, SHLabelLayoutDelegate {
    
    public typealias T = SHCellModelProtocol
    public var collectionView: UICollectionView { get { return _collectionView } }
    public var dops: SHDataOperationsController<T> { get { return _dops } }
    public var layout: UICollectionViewFlowLayout { get { return loadLayout() } }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        _collectionView.dataSource = _dops
        self.view.addSubview(_collectionView)
    }
    
    /// 设置布局
    public func loadLayout() -> UICollectionViewFlowLayout {
        return SHCollectionViewFlowLayout(SHLayoutConfig())
    }

    /// 设置区
    public func loadFetchs() -> [SHDataOperation<T>] {
        return []
    }
    
    private lazy var _collectionView: UICollectionView = {
        let cl = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.layout)
        cl.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        cl.delegate = self
        cl.backgroundColor = UIColor.lightText
        cl.bounces = true
        cl.alwaysBounceVertical = true
        return cl
    }()
    
    private lazy var _dops = SHDataOperationsController(list: loadFetchs())
    
    // MARK: - UICollectionViewDelegate SHCollectionViewDelegate 代理
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("点击了\(indexPath.row) section:\(indexPath.section)")
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    // MARK: - SHLabelLayoutDelegate
    func collectionView(_ collectionView: UICollectionView, _ layout: SHLabelFlowLayout, widthForItemAtIndex indexPath: IndexPath) -> CGFloat {
        if let m = self.dops.object(at: indexPath) { return m.sh_cellWidth() }
        return 100
    }
    
    // MARK: - SHCollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, canFloatingCellAt indexPath: IndexPath) -> Bool {
        guard let m = self.dops.object(at: indexPath) else { return false }
        return m.sh_canFloating()
    }
    
    public func collectionView(_ collectionView: UICollectionView, heightForCellAt indexPath: IndexPath) -> CGFloat {
        if let layout = layout as? SHCollectionViewFlowLayout, layout.config.rowHeight > 0 { return layout.config.rowHeight }
        guard let m = self.dops.object(at: indexPath) else { return 44 }
        return m.sh_cellHeight()
    }
    
    func collectionView(_ collectionView: UICollectionView, insetsForCellAt indexPath: IndexPath) -> UIEdgeInsets {
        guard let m = self.dops.object(at: indexPath) else { return UIEdgeInsets.zero }
        return m.sh_cellInsets()
    }
    
    public func collectionView(_ collectionView: UICollectionView, spanSizeForCellAt indexPath: IndexPath) -> Int {
        guard let m = self.dops.object(at: indexPath) else { return 1 }
        if (m.sh_canFloating() || m.sh_isExclusiveLine()), let layout = layout as? SHCollectionViewFlowLayout {
            return layout.config.columnCount
        }
        return m.sh_cellGridSpanSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, rowSpacesForCellAt indexPath: IndexPath) -> Bool {
        guard let m = self.dops.object(at: indexPath) else { return true }
        if m.sh_canFloating() || m.sh_isExclusiveLine() { return m.sh_isRowSpace() }
        return true
    }
    
    deinit {
//        self.collectionView.dataSource = nil
//        self.collectionView.delegate = nil
    }
}

//
//  SHCollectionViewController.swift
//  SHUI
//
//  Created by Demon on 2020/6/11.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit

class SHCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, SHCollectionViewDelegate, SHLabelLayoutDelegate {
    
    typealias T = SHCellModelProtocol
    public var collectionView: UICollectionView { get { return _collectionView } }
    public var fetchs: SHFetchsController<T> { get { return _fetchs } }
    public var layout: UICollectionViewFlowLayout { get {return loadLayout() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _collectionView.dataSource = _fetchs
        self.view.addSubview(_collectionView)
    }
    
    public func loadLayout() -> UICollectionViewFlowLayout {
        return SHCollectionViewFlowLayout(SHLayoutConfig())
    }

    public func loadFetchs() -> [SHFetch<T>] {
        return []
    }
    
    private lazy var _collectionView: UICollectionView = {
        let cl = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.layout)
        cl.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        cl.delegate = self
        cl.backgroundColor = UIColor.white
        cl.bounces = true
        cl.alwaysBounceVertical = true
        return cl
    }()
    
    private lazy var _fetchs = SHFetchsController(fetchs: loadFetchs())
    
    // MARK: - ICollectionViewDelegate MMCollectionViewDelegate 代理
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("点击了\(indexPath.row) section:\(indexPath.section)")
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    // MARK: - SHLabelLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, _ layout: SHLabelLayout, widthForItemAtIndex indexPath: IndexPath) -> CGFloat {
        if let m = self.fetchs.object(at: indexPath) {
            return m.sh_cellWidth()
        }
        return 100
    }
    
    // MARK: - SHCollectionViewDelegate
    //可以漂浮停靠在界面顶部
    func collectionView(_ collectionView: UICollectionView, canFloatingCellAt indexPath: IndexPath) -> Bool {
        guard let m = _fetchs.object(at: indexPath) else {
            return false
        }
        return m.sh_canFloating()
    }
    
    //cell的行高,若scrollDirection == .horizontal则返回的是宽度
    public func collectionView(_ collectionView: UICollectionView, heightForCellAt indexPath: IndexPath) -> CGFloat {
        if let layout = layout as? SHCollectionViewFlowLayout, layout.config.rowHeight > 0 {
            return layout.config.rowHeight
        }
        guard let m = _fetchs.object(at: indexPath) else {
            return 44
        }
        return m.sh_cellHeight()
    }
    
    func collectionView(_ collectionView: UICollectionView, insetsForCellAt indexPath: IndexPath) -> UIEdgeInsets {
        guard let m = _fetchs.object(at: indexPath) else {
            return UIEdgeInsets.zero
        }
        return m.sh_cellInsets()
    }
    
    //cell是否SpanSize，返回值小于等于零时默认为1
    public func collectionView(_ collectionView: UICollectionView, spanSizeForCellAt indexPath: IndexPath) -> Int {
        guard let m = _fetchs.object(at: indexPath) else {
            return 1
        }
        if m.sh_canFloating() || m.sh_isExclusiveLine() {
            if let layout = layout as? SHCollectionViewFlowLayout {
                return layout.config.columnCount
            }
        }
        return m.sh_cellGridSpanSize()
    }
    
    deinit {
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil
    }
}

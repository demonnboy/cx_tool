//
//  SHCollectionViewFlowLayout.swift
//  SHUIPlan
//
//  Created by Demon on 2019/12/13.
//  Copyright © 2019 Demon. All rights reserved.
//

import UIKit

public class SHLayoutConfig: NSObject {}

public class MMLayoutConfig: SHLayoutConfig {

    var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
    @objc dynamic var floating: Bool = false
    
    @objc dynamic var floatingOffsetY: CGFloat = -1 
    
    @objc dynamic var columnCount: Int = 1
    
    @objc dynamic var rowHeight: CGFloat = 44
    
    @objc dynamic var columnSpace: CGFloat = 6
    
    @objc dynamic var rowDefaultSpace: CGFloat = 1
    
    @objc dynamic var insets: UIEdgeInsets = UIEdgeInsets.zero 
    
    @objc dynamic var supportMagicHorizontalEdge: Bool = false//横向魔法边距，只有当cell返回支持时展示
}

// 控制UICollect所有瀑布流，无section headerView和footerView支持，
public class SHCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    @objc private dynamic var _config: MMLayoutConfig = MMLayoutConfig()

    public init(_ config: MMLayoutConfig = MMLayoutConfig()) {
        super.init()
        _config = config
        if config.floatingOffsetY >= 0 { // 表示不走默认情况
            setFloatingOffsetY(config.floatingOffsetY)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc open dynamic var config: MMLayoutConfig {
        get { return _config; }
        set {
            let changOffset =  _config.floatingOffsetY != newValue.floatingOffsetY
            _config = newValue
            if _config.columnCount <= 0 { // 防止设置为非法数字
                _config.columnCount = 1
            }
            if _config.rowHeight < 0 { // 防止设置为非法数字
                _config.rowHeight = 0
            }
            if _config.columnSpace < 0 { // 防止设置为非法数字
                _config.columnSpace = 1
            }
            if _config.rowDefaultSpace < 0 { // 防止设置为非法数字
                _config.rowDefaultSpace = 1
            }
            if changOffset {
                setFloatingOffsetY(_config.floatingOffsetY)
            }
            invalidateLayout()
        }
    }

    weak fileprivate final var delegate: SHCollectionViewDelegate? {
        get {
            guard let ds = self.collectionView?.delegate else { return nil }
            if ds is SHCollectionViewDelegate {
                return ds as? SHCollectionViewDelegate
            }
            return nil
        }
    }

    //采用一次性布局
    private var _cellLayouts: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var _headIndexs: [IndexPath] = [] 
    
    @objc private dynamic var _bottoms: [CGFloat] = []
    
    @objc override public dynamic func prepare() {
        super.prepare()

        //起始位计算
        _bottoms.removeAll()
        if _config.columnCount > 0 {
            for _ in 0..<_config.columnCount {
                _bottoms.append(0.0)
            }
        } else {
            _bottoms.append(0.0)
        }
        _cellLayouts.removeAll()
        _headIndexs.removeAll()

        guard let view = self.collectionView else {
            return
        }

        var respondCanFloating = false
        var respondHeightForCell = false
        var respondInsetForCell = false
        var respondSpanSize = false
        let ds = self.delegate
        if let ds = ds {
            respondCanFloating = ds.responds(to: #selector(SHCollectionViewDelegate.collectionView(_:canFloatingCellAt:)))
            respondHeightForCell = ds.responds(to: #selector(SHCollectionViewDelegate.collectionView(_:heightForCellAt:)))
            respondInsetForCell = ds.responds(to: #selector(SHCollectionViewDelegate.collectionView(_:insetsForCellAt:)))
            respondSpanSize = ds.responds(to: #selector(SHCollectionViewDelegate.collectionView(_:spanSizeForCellAt:)))
        }

        let floating = _config.floating
        let rowHeight = _config.rowHeight
        let columnCount = _config.columnCount
        let viewWidth = _config.scrollDirection == .vertical ? view.bounds.size.width : view.bounds.size.height
        let viewWidthInsets = _config.scrollDirection == .vertical ? (_config.insets.left + _config.insets.right) : (_config.insets.top + _config.insets.bottom)
        let floatingWidth = viewWidth

        let cellWidth = CGFloat(roundf(Float((viewWidth - viewWidthInsets - _config.columnSpace * CGFloat(columnCount - 1)) / CGFloat(columnCount))))
        let diffWidth = view.bounds.size.width - viewWidthInsets - _config.columnSpace * CGFloat(columnCount - 1) - cellWidth * CGFloat(columnCount)

        let sectionCount = view.numberOfSections
        for section in 0..<sectionCount {
            let cellCount = view.numberOfItems(inSection: section)
            for row in 0..<cellCount {
                let indexPath = IndexPath(row: row, section: section)
                //是否漂浮
                var isFloating: Bool = _config.floating && _config.scrollDirection == .vertical //水平暂时不支持停靠
                if let ds = ds, (floating && respondCanFloating) {
                    isFloating = ds.collectionView!(view, canFloatingCellAt: indexPath)
                }
                if isFloating {
                    _headIndexs.append(indexPath)
                }

                //行高
                var height: CGFloat = rowHeight
                if let ds = ds, ( height <= 0 && respondHeightForCell ) {
                    height = ds.collectionView!(view, heightForCellAt: indexPath)
                }

                //内边距
                var insets = UIEdgeInsets.zero
                if let ds = ds, !isFloating && respondInsetForCell {
                    insets = ds.collectionView!(view, insetsForCellAt: indexPath)
                }

                //占用各数
                var spanSize = 1
                if isFloating {//肯定是占满一行
                    spanSize = columnCount
                } else if let ds = ds, ( columnCount > 1 && respondSpanSize ) {
                    spanSize = ds.collectionView!(view, spanSizeForCellAt: indexPath)
                    if spanSize > columnCount {
                        spanSize = columnCount
                    } else if spanSize < 1 {
                        spanSize = 1
                    }
                }

                //取布局属性对象
                var attributes: UICollectionViewLayoutAttributes!
                if isFloating {
                    attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.zIndex = 1024
                } else {
                    attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)//layoutAttributesForCellWithIndexPath
                    attributes.ssn_setTag(CELL_INSETS_TAG, tag: insets)
                }
                _cellLayouts[indexPath] = attributes//记录下来，防止反复创建

                var suitableSetion = self.sectionOfLessHeight
                var y = _bottoms[suitableSetion] //起始位置，水平对应x值

                //说明当前位置并不合适,换到新的一行开始处理
                if isFloating || suitableSetion + spanSize > columnCount {
                    let mostSetion = self.sectionOfMostHeight
                    y = _bottoms[mostSetion] //起始位置
                    suitableSetion = 0 //new line
                } else if spanSize > 1 {//这种情况需要观察占用列的最高值
                    //取显示换位最长的
                    for index in suitableSetion..<(suitableSetion + spanSize) {
                        if y < _bottoms[index] {
                            y = _bottoms[index]
                        }
                    }
                }

                //y起始行特别处理
//                if section == 0 && row == 0 && y == 0.0 && !isFloating {
                if y == 0.0 && !isFloating {
                    y = y + (_config.scrollDirection == .vertical ? _config.insets.top : _config.insets.left)
                }

                //x起始位和宽度
                var x = (_config.scrollDirection == .vertical ? _config.insets.left : _config.insets.top) + (cellWidth + _config.columnSpace) * CGFloat(suitableSetion)
                var width = cellWidth * CGFloat(spanSize) + _config.columnSpace * CGFloat(spanSize - 1)
                //最后的宽度修正
                if diffWidth != 0 && abs(viewWidth - (x + width)) < abs(diffWidth) + 0.1 {
                    width = width + diffWidth
                }
                
                //对于floating,满行处理
                if isFloating {
                    x = 0
                    width = floatingWidth
                }

                //最终位置
                if _config.scrollDirection == .vertical {
                    attributes.frame = CGRect(x: x + insets.left, y: y + insets.top, width: width - (insets.left + insets.right), height: height - (insets.top + insets.bottom))
                } else {
                    attributes.frame = CGRect(x: y + insets.left, y: x + insets.top, width: height - (insets.left + insets.right), height: width - (insets.top + insets.bottom))
                }

                //更新每列位置信息
                for index in suitableSetion..<(suitableSetion + spanSize) {
                    _bottoms[index] = y + height + _config.rowDefaultSpace
                }
            }
        }
    }
    
    @objc override public dynamic func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //存在飘浮cell
        let hasFloating = !_headIndexs.isEmpty
        var hsets: Set<IndexPath> = Set<IndexPath>() //所有被列入header的key
//        //遍历所有 Attributes 看看哪些符合 rect
        var list: [UICollectionViewLayoutAttributes] = []
        _cellLayouts.forEach { (index, attbute) in
            var insets = UIEdgeInsets.zero
            if let sets = attbute.ssn_tag(CELL_INSETS_TAG) as? UIEdgeInsets {
                insets = sets
            }

            let frame = attbute.frame
            let oframe = CGRect(x: frame.origin.x - insets.left, y: frame.origin.y - insets.top, width: frame.size.width + insets.left + insets.right, height: frame.size.height + insets.top + insets.bottom)
            if rect.intersects(oframe) {
                list.append(attbute)
                hsets.insert(index)
                if hasFloating {
                    setFloatingCellLayout(indexPath: index, hsets: hsets, list: &list)
                }
            }
        }
        return list
    }
    
    @objc private dynamic var defaultAttributes: UICollectionViewLayoutAttributes!
    private func getDefaultAttributes(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        if defaultAttributes == nil {
            defaultAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            defaultAttributes.frame.size.height = 0
            defaultAttributes.isHidden = true
        }
        defaultAttributes.indexPath = indexPath
        return defaultAttributes!
    }

//    private var defaultHeadAttributes:UICollectionViewLayoutAttributes!
    private func getDefaultHeadAttributes(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let defaultHeadAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: COLLECTION_HEADER_KIND, with: indexPath)
        defaultHeadAttributes.frame.size.height = 0
        defaultHeadAttributes.isHidden = true
        defaultHeadAttributes.indexPath = indexPath
        return defaultHeadAttributes
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = _cellLayouts[indexPath] else { return getDefaultHeadAttributes(at: indexPath) }
        if attributes.representedElementKind == COLLECTION_HEADER_KIND {//必须兼容返回一个default的布局
            return getDefaultHeadAttributes(at: indexPath)
        } else {
            return attributes
        }
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = _cellLayouts[indexPath] else { return getDefaultAttributes(at: indexPath) }
        if attributes.representedElementKind == COLLECTION_HEADER_KIND {
            return attributes
        } else {
            return getDefaultAttributes(at: indexPath)
        }
    }
    
    @objc override public dynamic func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return _config.floating && _config.scrollDirection == .vertical
    }
    
    @objc override public dynamic var collectionViewContentSize: CGSize {
        get {
            guard let view = self.collectionView else {
                return CGSize.zero
            }
            let width = _config.scrollDirection == .vertical ? view.bounds.size.width : (_config.insets.left + _config.insets.right + _bottoms[self.sectionOfMostHeight])
            let height = _config.scrollDirection == .vertical ? (_config.insets.top + _config.insets.bottom + _bottoms[self.sectionOfMostHeight]) : view.bounds.size.height
            // self.navigationController.navigationBar.isTranslucent
            return CGSize(width: width, height: height)
        }
    }

    //设置飘浮位置
    private var floatingIndex: IndexPath?
    fileprivate final func setFloatingCellLayout(indexPath: IndexPath, hsets: Set<IndexPath>, list:inout [UICollectionViewLayoutAttributes]) {
        guard let view = self.collectionView else {
            return
        }

        guard let value = _cellLayouts[indexPath] else { return }
        if !hsets.contains(indexPath) {
            list.append(value)
        }
        var insets = UIEdgeInsets.zero
        if let sets = value.ssn_tag(CELL_INSETS_TAG) as? UIEdgeInsets {
            insets = sets
        }
        let offsetY = originOffsetY + view.contentOffset.y + view.contentInset.top //基准线
        if floatingIndex == nil {
            floatingIndex = _headIndexs.first
        }

        guard let fIndex = floatingIndex else { return }
        guard let fAttribute = _cellLayouts[fIndex] else { return }
        if fAttribute.frame.minY <= offsetY {
            fAttribute.frame = CGRect(x: fAttribute.frame.origin.x + insets.left, y: offsetY, width: fAttribute.frame.width, height: fAttribute.frame.height)
        } else {
            if let current = _headIndexs.firstIndex(of: fIndex), current > 0 {
                floatingIndex = _headIndexs[(current - 1)]
            }
        }

        if let current = _headIndexs.firstIndex(of: fIndex), current < (_headIndexs.count - 1) {
            let next = _cellLayouts[_headIndexs[(current + 1)]]
            if fAttribute.frame.maxY >= next!.frame.minY {
                let y = min(next!.frame.minY - fAttribute.frame.size.height, offsetY)
                fAttribute.frame = CGRect(x: fAttribute.frame.origin.x + insets.left, y: y, width: fAttribute.frame.width, height: fAttribute.frame.height)
            }
            if next!.frame.minY <= offsetY {
                floatingIndex = _headIndexs[(current + 1)]
            }
        }
    }

    fileprivate final func resetFloatingCellLayout(indexPath: IndexPath) {
        guard let attributes = _cellLayouts[indexPath] else {
            return
        }

        let frame = attributes.frame
        var insets = UIEdgeInsets.zero
        if let sets = attributes.ssn_tag(CELL_INSETS_TAG) as? UIEdgeInsets {
            insets = sets
        }
        var oframe = CGRect(x: frame.origin.x - insets.left, y: frame.origin.y - insets.top, width: frame.size.width + insets.left + insets.right, height: frame.size.height + insets.top + insets.bottom)

        if indexPath.section == 0 && indexPath.row == 0 {
            oframe.origin.y = 0
        } else {
            var next: IndexPath? = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if !_cellLayouts.keys.contains(next!) {
                next = IndexPath(row: 0, section: indexPath.section + 1)
                if !_cellLayouts.keys.contains(next!) {
                    next = nil
                }
            }

            //重新布局下header
            if let next = next {
                if let nextValue = _cellLayouts[next] {
                    if let insets = nextValue.ssn_tag(CELL_INSETS_TAG) as? UIEdgeInsets {
                        oframe.origin.y = nextValue.frame.origin.y + insets.top - _config.rowDefaultSpace - oframe.height
                    } else {
                        oframe.origin.y = nextValue.frame.origin.y - _config.rowDefaultSpace - oframe.height
                    }
                }
            }
        }
        attributes.frame = CGRect(x: oframe.origin.x + insets.left, y: oframe.origin.y + insets.top, width: oframe.size.width - (insets.left + insets.right), height: oframe.size.height - (insets.top + insets.bottom))
    }
    
    @objc dynamic var _setedOffsetY = false
    
    @objc dynamic var _offsetY: CGFloat = 0.0
    
    @objc fileprivate final dynamic func setFloatingOffsetY(_ offsetY: CGFloat) {
        if offsetY < 0 {
            _setedOffsetY = false
            _offsetY = 0
        } else {
            _setedOffsetY = true
            _offsetY = offsetY
        }
    }
    
    @objc fileprivate final dynamic var originOffsetY: CGFloat {
        get {
            if _setedOffsetY {
                return _offsetY
            }
            guard let view = self.collectionView else {
                return _offsetY
            }
            if #available(iOS 11.0, *) { //高于 iOS 11.0
//                _setedOffsetY = true
                return view.adjustedContentInset.top
            } else { //低于 iOS 11.0
                return _offsetY
            }
        }
    }
    
    @objc fileprivate final dynamic var sectionOfLessHeight: Int {
        get {
            var minIndex: Int = 0
            if _config.columnCount > 1 {
                for index in 1..<_config.columnCount {
                    if _bottoms[index] < _bottoms[minIndex] {
                        minIndex = index
                    }
                }
            }
            return minIndex
        }
    }
    
    @objc fileprivate final dynamic var sectionOfMostHeight: Int {
        get {
            var maxIndex: Int = 0
            if _config.columnCount > 1 {
                for index in 1..<_config.columnCount {
                    if _bottoms[index] > _bottoms[maxIndex] {
                        maxIndex = index
                    }
                }
            }
            return maxIndex
        }
    }
}

private var OBJ_TAGS_PROPERTY = 0

public extension NSObject {
    //tags，方便一个对象关联其他数据
    final func ssn_tag(_ key: String) -> Any? {
        guard let dic = objc_getAssociatedObject(self, &OBJ_TAGS_PROPERTY) as? [String: Any] else {  return nil }
        return dic[key]
    }

    final func ssn_setTag(_ key: String, tag: Any) {
        var dic: [String: Any]!
        if let dis = objc_getAssociatedObject(self, &OBJ_TAGS_PROPERTY) as? [String: Any] {
            dic = dis
        } else {
            dic = [String: Any]()
        }
        dic[key] = tag
        objc_setAssociatedObject(self, &OBJ_TAGS_PROPERTY, dic, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }

    final func ssn_delTag(_ key: String) {
        guard var dic = objc_getAssociatedObject(self, &OBJ_TAGS_PROPERTY) as? [String: Any] else {  return }
        dic.removeValue(forKey: key)
        objc_setAssociatedObject(self, &OBJ_TAGS_PROPERTY, dic, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

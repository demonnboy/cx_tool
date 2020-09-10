//
//  SHLabelLayout.swift
//  Demon
//
//  Created by Demon on 2020/6/11.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit

public class SHLabelFlowLayout: UICollectionViewFlowLayout {
    
    private var layoutConfig: SHLableLayoutConfig = SHLableLayoutConfig()
    private var cellAttributesArray: [UICollectionViewLayoutAttributes] = []
    private var cellMaxX: CGFloat = 0
    private var cellMaxY: CGFloat = 0
    
    weak fileprivate final var delegate: SHLabelLayoutDelegate? {
        get {
            guard let ds = self.collectionView?.delegate else { return nil }
            if ds is SHLabelLayoutDelegate {
                return ds as? SHLabelLayoutDelegate
            }
            return nil
        }
    }
    
    init(_ config: SHLableLayoutConfig) {
        super.init()
        layoutConfig = config
    }
    
    override public func prepare() {
        super.prepare()
        
        guard let collectionV = self.collectionView else { return }
        
        self.cellAttributesArray.removeAll()
        let collectionW = collectionV.bounds.width
        let itemsCount = collectionV.numberOfItems(inSection: 0)
        self.cellMaxX = layoutConfig.sectionInset.left
        self.cellMaxY = layoutConfig.sectionInset.top
        for i in 0..<itemsCount {
            let indexPath = IndexPath(item: i, section: 0)
            var cellWidth: CGFloat = 44
            if let delegate = self.delegate {
                cellWidth = delegate.collectionView(collectionV, self, widthForItemAtIndex: indexPath)
            }
            let cellAtt = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            if cellWidth >= (collectionW - cellMaxX - layoutConfig.sectionInset.left - layoutConfig.sectionInset.right) {
                cellMaxX = layoutConfig.sectionInset.left
                if i != 0 {
                    cellMaxY += (layoutConfig.rowSpacing + layoutConfig.cellHeight)
                } else {
                    cellWidth = collectionW - layoutConfig.sectionInset.left - layoutConfig.sectionInset.right
                }
                cellAtt.frame = CGRect(x: cellMaxX, y: cellMaxY, width: cellWidth, height: layoutConfig.cellHeight)
                cellMaxX += (cellWidth + layoutConfig.columnSpacing)
            } else {
                cellAtt.frame = CGRect(x: cellMaxX, y: cellMaxY, width: cellWidth, height: layoutConfig.cellHeight)
                cellMaxX += (cellWidth + layoutConfig.columnSpacing)
            }
            self.cellAttributesArray.append(cellAtt)
        }
        cellMaxY += layoutConfig.sectionInset.bottom
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result: [UICollectionViewLayoutAttributes] = []
        for att in self.cellAttributesArray {
            if rect.intersects(att.frame) {
                result.append(att)
            }
        }
        return result
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cellAttributesArray[indexPath.item]
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.bounds.width ?? 0, height: self.cellMaxY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

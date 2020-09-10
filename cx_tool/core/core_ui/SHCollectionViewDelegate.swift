//
//  SHCollectionViewDelegate.swift
//  ShihuoIPhone
//
//  Created by Demon on 2020/9/10.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit

@objc protocol SHCollectionViewDelegate: UICollectionViewDelegate {

    /// 可以漂浮停靠在界面顶部
    @objc optional func collectionView(_ collectionView: UICollectionView, canFloatingCellAt indexPath: IndexPath) -> Bool

    /// cell的行高,若scrollDirection == .horizontal则返回的是宽度，包含EdgeInsets.bottom+EdgeInsets.top的值
    @objc optional func collectionView(_ collectionView: UICollectionView, heightForCellAt indexPath: IndexPath) -> CGFloat

    /// cell的内边距, floating cell不支持
    @objc optional func collectionView(_ collectionView: UICollectionView, insetsForCellAt indexPath: IndexPath) -> UIEdgeInsets

    /// cell是否SpanSize，返回值小于等于零时默认为1
    @objc optional func collectionView(_ collectionView: UICollectionView, spanSizeForCellAt indexPath: IndexPath) -> Int
    
    /// cell是否需要行距
    @objc optional func collectionView(_ collectionView: UICollectionView, rowSpacesForCellAt indexPath: IndexPath) -> Bool
}

@objc protocol SHLabelLayoutDelegate: UICollectionViewDelegate {
    
    /// 标签的返回宽度
    @objc func collectionView(_ collectionView: UICollectionView, _ layout: SHLabelFlowLayout, widthForItemAtIndex indexPath: IndexPath) -> CGFloat
}

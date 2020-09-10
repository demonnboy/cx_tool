//
//  SHLayoutConfigs.swift
//  Demon
//
//  Created by Demon on 2020/9/10.
//  Copyright © 2020 Demon. All rights reserved.
//

import UIKit

let COLLECTION_HEADER_KIND = "Header"
let CELL_INSETS_TAG = "cell_content_insets"
let DEFAULT_CELL_ID = ".default.cell"
let DEFAULT_HEAD_ID = ".default.head"

public class SHLayoutConfig: NSObject {

    var scrollDirection: UICollectionView.ScrollDirection = .vertical
    /// 悬浮
    @objc dynamic public var floating: Bool = false
    /// 悬浮偏移
    @objc dynamic public var floatingOffsetY: CGFloat = -1
    /// 列数
    @objc dynamic public var columnCount: Int = 1
    /// 行高
    @objc dynamic public var rowHeight: CGFloat = 44
    /// 列间距
    @objc dynamic public var columnSpace: CGFloat = 6
    /// 行间距
    @objc dynamic public var rowDefaultSpace: CGFloat = 1
    /// 内边距
    @objc dynamic public var insets: UIEdgeInsets = UIEdgeInsets.zero
}

public class SHLableLayoutConfig: NSObject {
    
    /// 行间距
    @objc dynamic public var rowSpacing: CGFloat = 5.0
    /// 列间距
    @objc dynamic public var columnSpacing: CGFloat = 5.0
    /// 区边距
    @objc dynamic public var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    /// cell高度
    @objc dynamic public var cellHeight: CGFloat = 44.0
}

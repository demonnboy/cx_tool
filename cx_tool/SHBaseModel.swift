//
//  SHBaseModel.swift
//  cx_tool
//
//  Created by Demon on 2020/12/3.
//  Copyright © 2020 Demon. All rights reserved.
//

import Foundation

@objcMembers class BaseModel: NSObject {
    
    var component: String = ""
    var result: Any?
    
    func getRealModel<T>() -> T? where T: NSObject {
        if let com = Component<T>(rawValue: self.component)?.mapClass {
            if let res = result as? [String: Any] {
                return com.yy_model(with: res)
            }
        }
        return nil
    }
    
    func getRealModels<Y>() -> [Y]? where Y: NSObject {
        if let com = Component<Y>(rawValue: self.component)?.mapClass {
            if let res = result as? [[String: Any]] {
                return NSArray.yy_modelArray(with: com, json: res) as? [Y]
            }
        }
        return nil
    }
}

@objcMembers class Banner: NSObject, Codable {
    
    var img: String = ""
    var title: String = ""
}

enum Component<T>: String {
    case banner
    
    var mapClass: T.Type {
        switch self {
            case .banner:
                return Banner.self as! T.Type
        }
    }
}

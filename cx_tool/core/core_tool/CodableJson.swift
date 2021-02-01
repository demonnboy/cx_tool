//
//  CodableJson.swift
//  cx_tool
//
//  Created by Demon on 2020/9/29.
//  Copyright © 2020 Demon. All rights reserved.
//

import Foundation

public protocol CodableJsonConvertible {
    
    /// 转成data
    func convertData() -> Data?
    /// 转成json
    func toJsonString() -> String?
}

extension String: CodableJsonConvertible {
    
    public func convertData() -> Data? {
        return self.data(using: Encoding.utf8)
    }
    
    public func toJsonString() -> String? {
        return self
    }
}

extension Data: CodableJsonConvertible {
    
    public func convertData() -> Data? {
        return self
    }
    
    public func toJsonString() -> String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }
}

extension Dictionary: CodableJsonConvertible {
    
    public func convertData() -> Data? {
        if !JSONSerialization.isValidJSONObject(self) { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return data
    }
    
    public func toJsonString() -> String? {
        guard let data = self.convertData() else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}

extension Array: CodableJsonConvertible where Element == [String: Any] {
    
    public func convertData() -> Data? {
        if !JSONSerialization.isValidJSONObject(self) { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return data
    }
    
    public func toJsonString() -> String? {
        guard let data = self.convertData() else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}

extension Decodable {
    
    /// json或者data转模型
    static public func toModel(json: CodableJsonConvertible) -> Self? {
        guard let data = json.convertData() else { return nil }
        do {
            let model = try JSONDecoder().decode(Self.self, from: data)
            return model
        } catch {
            return nil
        }
    }
    
    /// json或者data转数组模型
    static public  func toModels(json: CodableJsonConvertible) -> [Self]? {
        guard let data = json.convertData() else { return nil }
        do {
            let models = try JSONDecoder().decode([Self].self, from: data)
            return models
        } catch {
            return nil
        }
    }
}

extension Encodable {
    
    /// 模型转json
    public func toJsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self)
            let jsonString = String(decoding: data, as: UTF8.self)
            return jsonString
        } catch  {
            printLog(error)
            return nil
        }
    }
    
    /// 模型转字典
    public func toDictionary() -> [String: Any]? {
        let enconder = JSONEncoder()
        enconder.outputFormatting = .prettyPrinted
        guard let data = try? enconder.encode(self) else { return nil }
        guard let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: Any] else {
            return nil
        }
        return dic
    }
    
    /// 数组模型转数组字典
    public func toArray() -> [[String: Any]]? {
        let enconder = JSONEncoder()
        enconder.outputFormatting = .prettyPrinted
        guard let data = try? enconder.encode(self) else { return nil }
        guard let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [[String: Any]] else {
            return nil
        }
        return dic
    }
}

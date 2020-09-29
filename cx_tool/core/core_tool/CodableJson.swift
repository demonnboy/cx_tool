//
//  CodableJson.swift
//  cx_tool
//
//  Created by Demon on 2020/9/29.
//  Copyright © 2020 Demon. All rights reserved.
//

import Foundation

protocol CodableJsonConvertible {
    
    func convertData() -> Data?
    func toJsonString() -> String?
}

extension String: CodableJsonConvertible {
    
    func convertData() -> Data? {
        return self.data(using: Encoding.utf8)
    }
    
    func toJsonString() -> String? {
        return self
    }
}

extension Data: CodableJsonConvertible {
    
    func convertData() -> Data? {
        return self
    }
    
    func toJsonString() -> String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }
}

extension Dictionary: CodableJsonConvertible {
    
    func convertData() -> Data? {
        if !JSONSerialization.isValidJSONObject(self) { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return data
    }
    
    func toJsonString() -> String? {
        guard let data = self.convertData() else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}

extension Array: CodableJsonConvertible where Element == [String: Any] {
    
    func convertData() -> Data? {
        if !JSONSerialization.isValidJSONObject(self) { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return data
    }
    
    func toJsonString() -> String? {
        guard let data = self.convertData() else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}

extension Decodable {
    
    static func toModel(json: CodableJsonConvertible) -> Self? {
        guard let data = json.convertData() else { return nil }
        do {
            let model = try JSONDecoder().decode(Self.self, from: data)
            return model
        } catch {
            return nil
        }
    }
    
    static func toModels(json: CodableJsonConvertible) -> [Self]? {
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
    
    func toJsonString() -> String? {
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
    
    func toDictionary() -> [String: Any]? {
        let enconder = JSONEncoder()
        enconder.outputFormatting = .prettyPrinted
        guard let data = try? enconder.encode(self) else { return nil }
        guard let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: Any] else {
            return nil
        }
        return dic
    }
    
    func toArray() -> [[String: Any]]? {
        let enconder = JSONEncoder()
        enconder.outputFormatting = .prettyPrinted
        guard let data = try? enconder.encode(self) else { return nil }
        guard let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [[String: Any]] else {
            return nil
        }
        return dic
    }
}

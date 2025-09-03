//
//  HTUserDefaultsTool.swift
//  SPMTestDemo
//
//  Created by Nansen on 2025/8/14.
//

import Foundation


public final class HTUserDefaultsTool {
    
    private init() {}
    
    private static let userDefaults = UserDefaults.standard
    
    /// string
    public static func set(_ value: String, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    public static func string(forKey key: String) -> String {
        return userDefaults.string(forKey: key) ?? ""
    }
    
    
    /// 存储 Int
    public static func set(_ value: Int, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    /// 获取 Int（提供默认值 0）
    public static func int(forKey key: String) -> Int {
        return userDefaults.integer(forKey: key)
    }
    
    /// 存储 Bool
    public static func set(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    /// 获取 Bool（提供默认值 false）
    public static func bool(forKey key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }
    
    /// 存储 Double
    public static func set(_ value: Double, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    /// 获取 Double（提供默认值 0.0）
    public static func double(forKey key: String) -> Double {
        return userDefaults.double(forKey: key)
    }
    
    /// 存储 URL
    public static func set(_ url: URL, forKey key: String) {
        userDefaults.set(url, forKey: key)
    }
    /// 获取 URL
    public static func url(forKey key: String) -> URL? {
        return userDefaults.url(forKey: key)
    }
    
    /// 存储 Data
    public static func set(_ data: Data, forKey key: String) {
        userDefaults.set(data, forKey: key)
    }
    /// 获取 Data
    public static func data(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
    
    
    // MARK: - 删除数据
    /// 删除指定 key 的数据
    public static func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    /// 清空所有数据（谨慎使用！）
    public static func clearAll() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    
    
    /// 对象存储
    public static func set<T: Codable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    public static func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = userDefaults.data(forKey: key) {
            if let decoded = try? JSONDecoder().decode(type, from: data) {
                return decoded
            }
        }
        return nil
    }
    
}

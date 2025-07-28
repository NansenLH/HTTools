//
//  Created by Nansen on 2025/6/24.
//

import Foundation
import UIKit

public struct HTColor {
    
    /// 随机色
    public static func random() -> UIColor {
        UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
    
    /// rgba
    public static func rgba(red: Int, green: Int, blue: Int, alpha: Double = 1.0) -> UIColor {
        let r = Double(max(0, min(red, 255))) / 255.0
        let g = Double(max(0, min(green, 255))) / 255.0
        let b = Double(max(0, min(blue, 255))) / 255.0
        let a = max(0.0, min(alpha, 1.0))
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 灰色
    public static func gray(_ rgb: Int, alpha: Double = 1.0) -> UIColor {
        let rgb = Double(max(0, min(rgb, 255))) / 255.0
        return UIColor(red: rgb, green: rgb, blue: rgb, alpha: alpha)
    }
    
    /// 十六进制颜色
    public static func hex(_ hexString: String, alpha: Double = 1.0) -> UIColor {
        var cString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard cString.count >= 6 else {
            return .clear
        }
        
        if cString.hasPrefix("0X") || cString.hasPrefix("0x") {
            cString = String(cString.dropFirst(2))
        }
        if cString.hasPrefix("#") {
            cString = String(cString.dropFirst(1))
        }
        guard cString.count == 6 else {
            return .clear
        }
        
        let rString = String(cString.prefix(2))
        let gString = String(cString.dropFirst(2).prefix(2))
        let bString = String(cString.dropFirst(4))
        
        // 转换为整数
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0
        if Scanner(string: rString).scanHexInt64(&r) {} else {
            print("HTColor.hexColor(\(hexString) failed")
        }
        Scanner(string: gString).scanHexInt64(&g)
        Scanner(string: bString).scanHexInt64(&b)
        
        let a = max(0.0, min(alpha, 1.0))
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    /// 从颜色获取 rgba
    public static func getRGBAFromColor(_ color: UIColor) -> (red: Double, green: Double, blue: Double, alpha: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r, g, b, a)
        }
        else {
            guard let cgColor = color.cgColor.components, cgColor.count >= 4 else {
                return (r, g, b, 1)
            }
            return (cgColor[0], cgColor[1], cgColor[2], cgColor[3])
        }
    }
}

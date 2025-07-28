//
//  Created by Nansen on 2025/6/24.
//

import UIKit

public struct HTFont {
    
    public static func regular(_ font: CGFloat, fitSize: Bool = false) -> UIFont {    
        if fitSize {
            return UIFont.systemFont(ofSize: HTSize.fitWidth(designW: font), weight: .regular) 
        }
        return UIFont.systemFont(ofSize: font, weight: .regular)
    }
    
    public static func ultralight(_ font: CGFloat, fitSize: Bool = false) -> UIFont {
        if fitSize {
            return UIFont.systemFont(ofSize: HTSize.fitWidth(designW: font), weight: .ultraLight) 
        }
        return UIFont.systemFont(ofSize: font, weight: .ultraLight)
    }
    
    public static func light(_ font: CGFloat, fitSize: Bool = false) -> UIFont {
        if fitSize {
            return UIFont.systemFont(ofSize: HTSize.fitWidth(designW: font), weight: .light) 
        }
        return UIFont.systemFont(ofSize: font, weight: .light)
    }
    
    public static func thin(_ font: CGFloat, fitSize: Bool = false) -> UIFont {
        if fitSize {
            return UIFont.systemFont(ofSize: HTSize.fitWidth(designW: font), weight: .thin) 
        }
        return UIFont.systemFont(ofSize: font, weight: .thin)
    }
    
    public static func medium(_ font: CGFloat, fitSize: Bool = false) -> UIFont {
        if fitSize {
            return UIFont.systemFont(ofSize: HTSize.fitWidth(designW: font), weight: .medium) 
        }
        return UIFont.systemFont(ofSize: font, weight: .medium)
    }
    
    public static func semibold(_ font: CGFloat, fitSize: Bool = false) -> UIFont {
        if fitSize {
            return UIFont.systemFont(ofSize: HTSize.fitWidth(designW: font), weight: .semibold) 
        }
        return UIFont.systemFont(ofSize: font, weight: .semibold)
    }
    
    public static func pingfangSC(_ font: CGFloat, fitSize: Bool = false, weight: UIFont.Weight = .regular) -> UIFont {
        
        var fontName = "PingFangSC-Semibold"
        switch weight {
            case .ultraLight:
                fontName = "PingFangSC-UltraLight"
            case .thin:
                fontName = "PingFangSC-Thin"
            case .light:
                fontName = "PingFangSC-Light"
            case .ultraLight:
                fontName = "PingFangSC-UltraLight"
            case .medium:
                fontName = "PingFangSC-Medium"
            case .regular:
                fontName = "PingFangSC-Regular"
            default:
                fontName = "PingFangSC-Semibold"
        }
        
        if fitSize {
            return UIFont(name: fontName, size: HTSize.fitWidth(designW: font)) ?? regular(HTSize.fitWidth(designW: font))
        }
        return UIFont(name: fontName, size: font) ?? regular(font)
    }
}

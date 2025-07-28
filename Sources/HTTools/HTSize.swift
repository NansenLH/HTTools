//
//  Created by Nansen on 2025/6/24.
//

import UIKit
import HTLogs

// MARK: - 尺寸工具类
public struct HTSize {
    
    public static let screenW = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    public static let screenH = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    public static let screenS = UIScreen.main.scale
    public static let screenSize = CGSizeMake(screenW, screenH)
    public static let screenRect = CGRectMake(0, 0, screenW, screenH)
    
    /// 状态栏高度
    public static let statusBarHeight: CGFloat = {
        
        var window: UIWindow?
        if #available(iOS 15.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    window = windowScene.windows.first
                }
            }
        }
        else {
            window = UIApplication.shared.windows.first
        }
        
        guard let w = window else {
            return 20
        }
        return w.safeAreaInsets.top
    }()
    
    /// 是否全面屏
    public static let screenIsFull: Bool = {
        var window: UIWindow?
        if #available(iOS 15.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    window = windowScene.windows.first
                }
            }
        }
        else {
            window = UIApplication.shared.windows.first
        }
        
        guard let w = window else {
            return false
        }
        return w.safeAreaInsets.bottom > 0
        
    }()
    
    /// 状态栏+导航栏高度
    public static let navigationBarHeight: CGFloat = statusBarHeight+44.0
    
    /// 底部安全区域高度
    public static let safeBottomHeight: CGFloat = {
        var window: UIWindow?
        if #available(iOS 15.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    window = windowScene.windows.first
                }
            }
        }
        else {
            window = UIApplication.shared.windows.first
        }
        
        guard let w = window else {
            return 0
        }
        return w.safeAreaInsets.bottom
    }()
    
    /// 底部安全区域+tabbar高度
    public static let tabbarHeight: CGFloat = safeBottomHeight + 49
    
    /// 屏幕高度-导航栏
    public static let showViewHeigth = screenH - navigationBarHeight
    
    
    
    
    
    /// 根据设计图计算尺寸
    public static func fitWidth(designW: CGFloat, standardW: CGFloat = 375.0) -> CGFloat {
        designW * screenW / standardW
    }
    
    /// 根据设计图计算高度
    public static func fitHeight(designH: CGFloat, standardH: CGFloat = 812.0) -> CGFloat {
        designH * screenH / standardH
    }
    
    /// 按比例计算宽度
    public static func ratioWidth(byH h: CGFloat, ratioW: CGFloat, ratioH: CGFloat) -> CGFloat {
        h * ratioW * 1.0 / ratioH
    }
    /// 按比例计算高度
    public static func ratioHeight(byW w: CGFloat, ratioW: CGFloat, ratioH: CGFloat) -> CGFloat {
        w * ratioH * 1.0 / ratioW
    }
    
    /// 按比例缩放尺寸
    public static func ratioSize(fromSize: CGSize, toSize: CGSize, isFit: Bool) -> CGSize {
        guard fromSize.height > 0, toSize.height > 0 else {
            return .zero
        }
        
        let ratioF = fromSize.width / fromSize.height
        let ratioT = toSize.width / toSize.height
        if ratioF >= ratioT {
            return isFit ? 
            CGSize(width: toSize.width, height: toSize.width/ratioF) : 
            CGSize(width: toSize.height*ratioF, height: toSize.height)
        }
        else {
            return isFit ? 
            CGSize(width: toSize.height*ratioF, height: toSize.height) : 
            CGSize(width: toSize.width, height: toSize.width/ratioF)
        }
    }
    
    /// 等比例适配 Rect
    public static func ratioRect(size: CGSize, toRect: CGRect, isFit: Bool) -> CGRect {
        guard size.height > 0, size.width > 0, toRect.size.width > 0, toRect.size.height > 0 else {
            HTLogs.logFatal("参数有误: size=\(size), toRect=\(toRect)")
            return CGRectZero
        }
        
        let targetW = toRect.size.width
        let targetH = toRect.size.height
        
        let sw = targetW/size.width
        let sh = targetH/size.height
        let scaleFactor = isFit ? min(sw, sh) : max(sw, sh) 
        
        let scaleW = size.width * scaleFactor
        let scaleH = size.height * scaleFactor
        
        return CGRect(x: toRect.origin.x+(targetW - scaleW)/2.0, 
                      y: toRect.origin.y+(targetH - scaleH)/2.0, 
                      width: scaleW, 
                      height: scaleH)
    }
    
    
    /// 计算单行文字的尺寸
    public static func calculateTextSize(text: String, font: UIFont) -> CGSize {
        let maxSize = CGSizeMake(CGFLOAT_MAX, font.lineHeight+5)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let size = (text as NSString).boundingRect(with: maxSize, 
                                                   options: [.usesLineFragmentOrigin, .usesFontLeading], 
                                                   attributes: attributes, 
                                                   context: nil)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    /// 计算多行文字的高度
    public static func calculateMultiLineTextHeight(text: String, 
                                                    font: UIFont,
                                                    maxW: CGFloat,
                                                    linespace: CGFloat = 0,
                                                    lineHeight: CGFloat = 0,
                                                    breakModel: NSLineBreakMode = .byCharWrapping
    ) -> CGFloat {
        let maxSize = CGSizeMake(maxW, CGFLOAT_MAX)
        let pStyle = NSMutableParagraphStyle()
        if linespace > 0 {
            pStyle.lineSpacing = linespace    
        }
        if lineHeight > 0 {
            pStyle.maximumLineHeight = lineHeight
            pStyle.minimumLineHeight = lineHeight
        }
        pStyle.lineBreakMode = breakModel
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: pStyle
        ]
        let rect = NSAttributedString(string: text, attributes: attributes).boundingRect(with: maxSize, 
                                                                                         options: [.usesLineFragmentOrigin, .usesFontLeading], 
                                                                                         context: nil)
        return ceil(rect.height)
    }
    
    /// 通过 UILabe 计算显示大小
    public static func calculateLabelSize(label: UILabel) -> CGSize {
        if label.numberOfLines == 1 {
            label.sizeToFit()
            return CGSizeMake(label.bounds.size.width, label.bounds.size.height)
        }
        
        return label.sizeThatFits(CGSizeMake(label.bounds.width, CGFLOAT_MAX))
    }
    
    
    
    private init() {}
}





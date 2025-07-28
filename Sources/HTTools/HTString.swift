//
//  Created by Nansen on 2025/6/24.
//

import UIKit

// MARK: - 富文本工具类
public struct HTAttributeInfo {
    /// 内容
    let text: String
    
    /// 颜色
    let color: UIColor
    
    /// 字体
    let font: UIFont
    
    /// 文字对齐. 默认: 左
    var alignment: NSTextAlignment = .left
    
    /// 换行模式. 默认:按照字符
    var breakMode: NSLineBreakMode = .byCharWrapping
    
    /// 行间距. 默认: 0
    var linespace: CGFloat = 0
    
    /// 行高. 默认使用字体高度
    var lineHeight: CGFloat = 0
    
    /// 删除线
    var deleteLine: Bool = false
    var deleteLineColor: UIColor = .clear
    
    /// 下划线
    var underLine: Bool = false
    var underLineColor: UIColor = .clear
    
    /// 倾斜度 0~1, 正值右倾, 负值左倾
    var oblique: Float = 0
    
    /// 字符间距
    var kern: CGFloat = 0
    
    
    public init(text: String, 
                color: UIColor, 
                font: UIFont, 
                alignment: NSTextAlignment = .left, 
                breakMode: NSLineBreakMode = .byCharWrapping, 
                linespace: CGFloat = 0, 
                lineHeight: CGFloat = 0, 
                deleteLine: Bool = false, 
                deleteLineColor: UIColor = .clear, 
                underLine: Bool = false, 
                underLineColor: UIColor = .clear, 
                oblique: Float = 0.0, 
                kern: CGFloat = 0.0) {
        self.text = text
        self.color = color
        self.font = font
        self.alignment = alignment
        self.breakMode = breakMode
        self.linespace = linespace
        self.lineHeight = lineHeight
        self.deleteLine = deleteLine
        self.deleteLineColor = deleteLineColor
        self.underLine = underLine
        self.underLineColor = underLineColor
        self.oblique = oblique
        self.kern = kern
    }
        
}
public struct HTString {
    
    /// 创建富文本
    public static func attString(texts: [HTAttributeInfo]) -> NSMutableAttributedString {
        let att = NSMutableAttributedString()
        for info in texts {
            
            var attributes: [NSAttributedString.Key: Any] = [:] 
            attributes[.font] = info.font
            attributes[.foregroundColor] = info.color
            
            if info.kern > 0 {
                attributes[.kern] = info.kern
            }
            
            if info.deleteLine {
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                attributes[.strikethroughColor] = info.deleteLineColor
            }
            
            if info.underLine {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                attributes[.underlineColor] = info.underLineColor
            }
            
            if info.oblique != 0 {
                attributes[.obliqueness] = info.oblique
            }
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineBreakMode = info.breakMode
            pStyle.alignment = info.alignment
            
            if info.linespace > 0 {
                pStyle.lineSpacing = info.linespace - (info.font.lineHeight - info.font.pointSize)
            }
            else if info.lineHeight > 0 {
                pStyle.maximumLineHeight = info.lineHeight
                pStyle.minimumLineHeight = info.lineHeight
                attributes[.baselineOffset] = (info.lineHeight - info.font.lineHeight) / 4
            }
            
            attributes[.paragraphStyle] = pStyle
            
            att.append(NSAttributedString(string: info.text, attributes: attributes))
        }
        return att
    }
    
    
    
    
    private init() {}
}

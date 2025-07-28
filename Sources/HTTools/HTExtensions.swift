//
//  Created by Nansen on 2025/6/26.
//

import Foundation
import UIKit
import HTLogs

public struct HTWrapper<T>: @unchecked Sendable {
    public let t: T
    public init(_ t: T) {
        self.t = t
    }
}
public protocol HTCompatible: AnyObject {}
public protocol HTCompatibleValue{}

extension HTCompatible {
    public var ht: HTWrapper<Self> {
        get { return HTWrapper(self) }
        set { }
    }
}
extension HTCompatibleValue {
    public var ht: HTWrapper<Self> {
        get { return HTWrapper(self) }
        set { }
    }
}


func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    if #available(iOS 14, macOS 11, watchOS 7, tvOS 14, *) { // swift 5.3 fixed this issue (https://github.com/swiftlang/swift/issues/46456)
        return objc_getAssociatedObject(object, key) as? T
    } else {
        return objc_getAssociatedObject(object, key) as AnyObject as? T
    }
}

func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}





// MARK: - UIView - Extension
extension UIView: HTCompatible {}
/// Frame
extension HTWrapper where T: UIView {
    
    public var x: CGFloat {
        set {
            t.frame = CGRect(x: newValue, 
                             y: t.frame.origin.y, 
                             width: t.frame.width, 
                             height: t.frame.height)
        }
        get {
            return t.frame.origin.x
        }
    }
    public var y: CGFloat {
        set {
            t.frame = CGRect(x: t.frame.origin.x, 
                             y: newValue, 
                             width: t.frame.width, 
                             height: t.frame.height)
        }
        get {
            return t.frame.origin.y
        }
    }
    public var w: CGFloat {
        set {
            t.frame = CGRect(x: t.frame.origin.x, 
                             y: t.frame.origin.y, 
                             width: newValue, 
                             height: t.frame.height)
        }
        get {
            return t.frame.width
        }
    }
    public var h: CGFloat {
        set {
            t.frame = CGRect(x: t.frame.origin.x, 
                             y: t.frame.origin.y, 
                             width: t.frame.width, 
                             height: newValue)
        }
        get {
            return t.frame.height
        }
    }
    
    public var left: CGFloat {
        set {
            t.frame = CGRect(x: newValue, 
                             y: t.frame.origin.y, 
                             width: t.frame.width, 
                             height: t.frame.height)
        }
        get {
            return t.frame.origin.x
        }
    }
    public var right: CGFloat {
        set {
            t.frame = CGRect(x: newValue - t.frame.width, 
                             y: t.frame.origin.y, 
                             width: t.frame.width, 
                             height: t.frame.height)
        }
        get {
            return t.frame.maxX
        }
    }
    public var top: CGFloat {
        set {
            t.frame = CGRect(x: t.frame.origin.x, 
                             y: newValue, 
                             width: t.frame.width, 
                             height: t.frame.height)
        }
        get {
            return t.frame.origin.y
        }
    }
    public var bottom: CGFloat {
        set {
            t.frame = CGRect(x: t.frame.origin.x, 
                             y: newValue-t.frame.height, 
                             width: t.frame.width, 
                             height: t.frame.height)
        }
        get {
            return t.frame.maxY
        }
    }
    
    public var centerX: CGFloat {
        set {
            t.center = CGPoint(x: newValue, y: t.center.y)
        }
        get {
            return t.center.x
        }
    }
    public var centerY: CGFloat {
        set {
            t.center = CGPoint(x: t.center.x, y: newValue)
        }
        get {
            return t.center.y
        }
    }
    
    public var center: CGPoint {
        get {
            return t.center
        }
        set {
            t.center = newValue
        }
    }
    public var topLeft: CGPoint {
        get {
            return t.frame.origin
        }
        set {
            t.frame = CGRect(origin: newValue, size: t.frame.size)
        }
    }
    public var topRight: CGPoint {
        get {
            return CGPoint(x: t.ht.right, y: t.ht.y)
        }
        set {
            t.frame = CGRect(x: newValue.x-t.ht.w, y: newValue.y, width: t.ht.w, height: t.ht.h)
        }
    }
    public var bottomLeft: CGPoint {
        set {
            t.frame = CGRect(origin: CGPoint(x: newValue.x, y: newValue.y-t.ht.h), size: t.ht.size)
        }
        get {
            return CGPoint(x: t.frame.origin.x, y: t.frame.origin.y+t.frame.height)
        }
    }
    public var bottomRight: CGPoint {
        set {
            t.frame = CGRect(origin: CGPoint(x: newValue.x-t.ht.w, y: newValue.y-t.ht.h), size: t.ht.size)
        }
        get {
            return CGPoint(x: t.frame.origin.x+t.frame.width, y: t.frame.origin.y+t.frame.height)
        }
    }
    
    public var size: CGSize {
        set {
            t.frame = CGRect(origin: t.frame.origin, size: newValue)
        }
        get {
            return t.frame.size
        }
    }
    
    /// 设置旋转角度
    public var rotationAngle: CGFloat {
        set {
            t.transform = CGAffineTransform(rotationAngle: radiansBy(angle: newValue))
        }
        get {
            let transform = t.transform
            let radians = atan2(transform.b, transform.a)
            return angleBy(radians: radians)
        }
    }
    
    /// 设置倒角
    public var cornerRadius: CGFloat {
        set {
            t.layer.cornerRadius = newValue
            t.layer.masksToBounds = true
        }
        get {
            return t.layer.cornerRadius
        }
    }
    

    private func angleBy(radians: CGFloat) -> CGFloat {
        radians * 180 / Double.pi
    }
    private func radiansBy(angle: CGFloat) -> CGFloat {
        angle * Double.pi / 180
    }
}

/// Animate
extension HTWrapper where T: UIView {
    /// 移动中心点
    public func moveCenter(to center: CGPoint, time: TimeInterval = 0.3) {
        UIView.animate(withDuration: time, delay: 0) { 
            t.center = center
        } 
    }
    /// 位移
    public func move(x: CGFloat, y: CGFloat, time: TimeInterval = 0.3) {
        UIView.animate(withDuration: time, delay: 0) { 
            t.frame = CGRect(origin: CGPoint(x: t.ht.x+x, y: t.ht.y+y), size: t.frame.size)
        }
    }
    
    /// 缩放
    public func scale(from: Double = 1.0, 
                      to: Double, 
                      time: TimeInterval = 0.3,
                      reverse: Bool = true, 
                      repeatCount: Float = 0) {
        
        t.layer.removeAnimation(forKey: "ht.scale")
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = from
        scaleAnimation.toValue = to
        scaleAnimation.duration = time
        scaleAnimation.autoreverses = reverse
        scaleAnimation.repeatCount = repeatCount
        t.layer.add(scaleAnimation, forKey: "ht.scale")
    }
    
    /// 自由落体动画
    /// 需要强引用返回的 UIDynamicAnimator
    /// 
    /// - Parameters:
    ///     - duration: 动画时间
    ///     - height: 下落的高度
    public func animate_tantiao(duration: TimeInterval, height: CGFloat) -> UIDynamicAnimator? {
        
        guard let superView = t.superview else {
            return nil
        }
        
        let animator = UIDynamicAnimator(referenceView: superView)
        // 重力行为
        let gravity = UIGravityBehavior(items: [t])
        
        // 添加碰撞平台
        let platformY: CGFloat = t.frame.maxY + height
        let boundaryPath = UIBezierPath.init(rect: CGRect(x: 0, y: platformY, width: superView.bounds.width, height: 1.0))
        
        let collision = UICollisionBehavior(items: [t])
        collision.addBoundary(withIdentifier: "platformBoundary" as NSCopying, for: boundaryPath)
        //        collision.translatesReferenceBoundsIntoBoundary = false // true 的话会把 superView作为边界
        
        // 设置物理特性
        let behavior = UIDynamicItemBehavior(items: [t])
        behavior.elasticity = 0.7 // 弹性系数（0 ~ 1，值越大越弹）
        behavior.friction = 0.3   // 摩擦力
        behavior.resistance = 0.1 // 空气阻力
        
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(behavior)
        
        return animator
    }
}


extension HTWrapper where T: UIView {
    
    /// 设置背景色, 圆角, 边框
    public func viewConfig(bgColor: UIColor = .clear, 
                           cornerRadius: CGFloat = 0,
                           clipsToBounds: Bool = true,
                           borderWidth: CGFloat = 0,
                           borderColor: UIColor = .clear) {
        t.backgroundColor = bgColor
        if cornerRadius > 0 {
            t.layer.cornerRadius = cornerRadius
            t.clipsToBounds = clipsToBounds
        }
        if borderWidth > 0 {
            t.layer.borderWidth = borderWidth
            t.layer.borderColor = borderColor.cgColor
        }
    }
    /// 设置阴影
    public func addShadow(color: UIColor, radius: CGFloat, offset: CGSize, opacity: Float) {
        t.clipsToBounds = false
        t.layer.masksToBounds = false
        
        t.layer.shadowColor = color.cgColor
        t.layer.shadowOffset = offset
        t.layer.shadowRadius = radius
        t.layer.shadowOpacity = opacity
    }

    /// 清空子控件
    public func removeAllSubviews() {
        t.subviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - UILabel - Extension
extension HTWrapper where T: UILabel {
    /// 配置
    public func labelConfig(textColor: UIColor,
                            textFont: UIFont,
                            text: String = "",
                            alignment: NSTextAlignment = .left,
                            lines: Int = 1) {
        t.font = textFont
        t.textColor = textColor
        
        t.text = text
        t.textAlignment = alignment
        t.numberOfLines = lines
    }
}

// MARK: - UIButton - Extension
extension HTWrapper where T: UIButton {
    
    public func buttonConfig(iconName: String, selectIconName: String? = nil) {
        t.setImage(UIImage(named: iconName), for: .normal)
        if let sIcon = selectIconName {
            t.setImage(UIImage(named: sIcon), for: .selected)
        }
    }
    
    public func buttonConfig(title: String, font: UIFont, color: UIColor, selectTitle: String? = nil, selectColor: UIColor? = nil) {
        t.setTitle(title, for: .normal)
        t.setTitleColor(color, for: .normal)
        t.titleLabel?.font = font
        
        if let st = selectTitle {
            t.setTitle(st, for: .selected)
        }
        if let sc = selectColor {
            t.setTitleColor(sc, for: .selected)
        }
    }
}

// MARK: - UIImageView - Extension
extension HTWrapper where T: UIImageView {
    
    public func imageViewConfig(iconName: String, mode: UIView.ContentMode = .scaleAspectFit, cornerRadius: CGFloat = 0, renderingColor: UIColor? = nil) {
        t.image = UIImage(named: iconName)
        t.contentMode = mode
        if cornerRadius > 0 {
            t.layer.cornerRadius = cornerRadius
            t.layer.masksToBounds = true
        }
        if let rc = renderingColor {
            t.tintColor = rc
            t.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        }
    }
}

// MARK: - UITextField - Extension
extension HTWrapper where T: UITextField {
    
    public func textFieldConfig(font: UIFont, 
                                color: UIColor, 
                                textAlignment: NSTextAlignment = .left, 
                                keyboardType: UIKeyboardType = .default,
                                returnType: UIReturnKeyType = .done,
                                clearButtonMode: UITextField.ViewMode = .whileEditing) {
        t.textColor = color
        t.font = font
        t.textAlignment = textAlignment
        t.keyboardType = keyboardType
        t.returnKeyType = returnType
        t.clearButtonMode = clearButtonMode
    }
    
    public func addPlaceHolder(placeHolder: String, color: UIColor, font: UIFont) {
        t.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [.font : font, .foregroundColor: color])
    }
    
    public func textFieldConfig(isCode: Bool, isPassword: Bool) {
        if isCode {
            t.textContentType = .oneTimeCode
        }
        if isPassword {
            t.isSecureTextEntry = true
        }
    }
}



// MARK: - UISwitch - Extension
extension HTWrapper where T: UISwitch {
    
    public func switchConfig(onColor: UIColor, offColor: UIColor, sliderColor: UIColor) {
        t.onTintColor = onColor
        t.backgroundColor = offColor
        t.tintColor = offColor
        t.thumbTintColor = sliderColor
    }
}

// MARK: - UITableView - Extension
extension HTWrapper where T: UITableView {
    
    public func tableViewConfig(separatorStyle: UITableViewCell.SeparatorStyle = .none,
                                showIndicator: Bool = false,
                                headerHeight: CGFloat = 0,
                                footerHeight: CGFloat = 0) {
        t.separatorStyle = separatorStyle
        t.showsVerticalScrollIndicator = showIndicator
        if #available(iOS 11.0, *) {
            t.contentInsetAdjustmentBehavior = .never
            t.estimatedRowHeight = 0
            t.estimatedSectionHeaderHeight = 0
            t.estimatedSectionFooterHeight = 0
        }
        if #available(iOS 15.0, *) {
            t.sectionHeaderTopPadding = 0
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: t.bounds.width, height: headerHeight))
        t.tableHeaderView = headerView
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: t.bounds.width, height: footerHeight))
        t.tableFooterView = footerView
    }
}


// MARK: - UIScrollView - Extension
extension HTWrapper where T: UIScrollView {
    /// 返回 contentView
    public func scrollViewConfig(bgColor: UIColor = .clear) -> UIView {
        t.backgroundColor = bgColor
        t.showsHorizontalScrollIndicator = false
        t.showsVerticalScrollIndicator = false
        t.contentInsetAdjustmentBehavior = .never
        
        let contentView = UIView(frame: .zero)
        contentView.backgroundColor = bgColor
        t.addSubview(contentView)
        
        return contentView
    }
    
    /// 是否滑动到最底部
    public func isScrollAtBottom() -> Bool {
        
        if t.contentSize.height <= t.bounds.height {
            return false
        }
        
        if t.contentOffset.y + t.bounds.height >= t.contentSize.height {
            return true
        }
        
        return false
    }
    
    /// 滑动到最底部
    public func scrollToBottom(animate: Bool) {
        let offY = t.contentSize.height - t.bounds.height
        t.setContentOffset(CGPoint(x: 0, y: offY), animated: animate)
    }
    
    /// 让 scrollView 中的某个 view 现实在顶部
    public func scrollViewToTop(view: UIView, animate: Bool) {
        let viewFrameInScrollView = view.superview?.convert(view.frame, to: t) ?? view.frame
        let targetOffY = viewFrameInScrollView.origin.y + t.contentInset.top
        t.setContentOffset(CGPoint(x: 0, y: targetOffY), animated: animate)
    }
}


// MARK: - UIStackView - Extension
extension HTWrapper where T: UIStackView {
    /// 大小相等, 固定间距
    public func stackViewConfigFillEqual(isVertical: Bool, space: CGFloat) {
        t.axis = isVertical ? .vertical : .horizontal
        t.alignment = .fill
        t.distribution = .fillEqually
        t.spacing = space
    }
}



// MARK: - String - Extension
extension String: HTCompatibleValue {}
extension HTWrapper where T == String {
    /// 复制到剪贴板
    public func copyToPasteboard() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = t
        HTLogs.logDebug(t+"  复制剪贴板成功!")
    }
    
    /// 去掉首尾的空格和换行符
    public func trimmed() -> String {
        return t.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 查找字符串
    public func rangeIndexOfSubstring(subString: String, caseInsensitive: Bool = false, fromEnd: Bool = false) -> Range<String.Index>? {
        guard !subString.isEmpty, !t.isEmpty else { return nil }
        
        var options: String.CompareOptions = []
        if caseInsensitive {
            options.insert(.caseInsensitive)
        }
        if fromEnd {
            options.insert(.backwards)
        }
        return t.range(of: subString, options: options)
    }
    
    
    /// 查询子字符串所在的位置
    /// - Parameters:
    ///     - subString: 字符串
    ///     - caseInsensitive: 不区分大小写. true-不区分
    ///     - fromEnd: 从后向前.
    /// - Returns: nil表示不存在该字符串.
    public func rangeOfSubstring(subString: String, caseInsensitive: Bool = false, fromEnd: Bool = false) -> Range<Int>? {
        guard !subString.isEmpty, !t.isEmpty else { return nil }
        
        var options: String.CompareOptions = []
        if caseInsensitive {
            options.insert(.caseInsensitive)
        }
        if fromEnd {
            options.insert(.backwards)
        }
        guard let stringIndexRange = t.range(of: subString, options: options) else {
            return nil
        } 
        let startIndex = t.distance(from: t.startIndex, to: stringIndexRange.lowerBound)
        let endIndex = t.distance(from: t.startIndex, to: stringIndexRange.upperBound)
        
        return startIndex..<endIndex
    }
    
    /// 截取字符串. 从index到最后
    public func substring(from index: Int) -> String {
        guard index >= 0, index < t.count else {
            HTLogs.logFatal("越界 string=\(t), count=\(t.count), index=\(index)")
            return ""
        }
        let start = t.index(t.startIndex, offsetBy: index)
        return String(t[start...])
    }
    
    /// 截取字符串. 从开始到index
    public func substring(to index: Int) -> String {
        guard index >= 0, index <= t.count else {
            HTLogs.logFatal("参数异常. string=\(t), toIndex=\(index)")
            return ""
        } 
        
        let end = t.index(t.startIndex, offsetBy: index)
        return String(t[t.startIndex..<end])
    }
    
    /// 截取字符串 范围
    public func substring(atRange: Range<Int>) -> String? {
        guard !t.isEmpty else {
            HTLogs.logFatal("empty. range=\(atRange)")
            return nil
        }
        guard atRange.lowerBound >= 0, 
                atRange.upperBound <= t.count, 
                atRange.lowerBound <= atRange.upperBound else {
            HTLogs.logFatal("参数错误. string=\(t), range=\(atRange)")
            return nil
        }
        
        let start = t.index(t.startIndex, offsetBy: atRange.lowerBound)
        let end = t.index(t.startIndex, offsetBy: atRange.upperBound)
        return String(t[start..<end])
    }
    
    /// url 编码 
    public func urlEncoded() -> String {
        return t.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    /// url 解码
    public func urlDecode() -> String {
        return t.removingPercentEncoding ?? t
    }
    
    /// base64 编码
    public func base64() -> String? {
        let data = t.data(using: .utf8)
        return data?.base64EncodedString()
    }
    
    /// base64 解码
    public func base64Decode() -> String? {
        /// 补齐 Base64 编码的 padding(=)
        let paddedBase64 = {
            let remainder = t.count % 4
            guard remainder != 0 else { return t }
            return t + String(repeating: "=", count: 4-remainder)
        }()
        
        guard let data = Data(base64Encoded: paddedBase64, options: .init(rawValue: 0)) else {
            HTLogs.logFatal("错误 decode failed")
            return nil 
        }
        guard let decodedString = String(data: data, encoding: .utf8) else {
            HTLogs.logFatal("错误2 invalid encoding")
            return nil 
        }
    
        return decodedString
    }
    

    /// 显示金额. show2表示保留两位小数. 默认显示
    public func moneyString(show2: Bool = true) -> String {
        let numberStr = t.trimmingCharacters(in: .whitespacesAndNewlines)
        if numberStr.isEmpty {
            return "0.00"
        }
        
        let decimalValue: NSDecimalNumber = NSDecimalNumber(string: numberStr)        
        if decimalValue.decimalValue.isInfinite || decimalValue.decimalValue.isNaN {
            return "0.00"
        }
        
        let behavior = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        let result = decimalValue.rounding(accordingToBehavior: behavior)
        
        if show2 {
            return String(format: "%.02f", result.doubleValue)
        }
        else {
            return result.stringValue
        }
    }
    
    
    
    
    /// 是否包含Emoji
    public func includesEmoji() -> Bool {
        let emojiRanges:[ClosedRange<UInt32>] = [
            0x1F600...0x1F64F, // Emoticons (表情符号)
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs (杂项符号和象形文字)
            0x1F680...0x1F6FF, // Transport and Map Symbols (交通和地图符号)
            0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs (补充符号和象形文字)
            0x2600...0x26FF,   // Misc Symbols (杂项符号)
            0x2700...0x27BF,   // Dingbats (装饰符号)
            0xFE00...0xFE0F,   // Variation Selectors (变体选择器)
            0x1F1E6...0x1F1FF  // Flags (旗帜)
        ]
        for scalar in t.unicodeScalars {
            let scalarValue = scalar.value
            for range in emojiRanges {
                if range.contains(scalarValue) {
                    return true
                }
            }
        }
        return false
    }
    
    
    /// 时间戳转Date
    public func convertToDate() -> Date? {
        
        let trimmedString = t.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let timestamp = TimeInterval(trimmedString) else {
            HTLogs.logError("时间戳不合法. \(t)")
            return nil
        }
        
        guard (trimmedString.count == 10 || trimmedString.count == 13) else {
            HTLogs.logError("时间戳位数不对. \(t)一共\(trimmedString.count)位")
            return nil
        } 
        
        if trimmedString.count == 10 {
            return Date(timeIntervalSince1970: timestamp)
        }
        else {
            return Date(timeIntervalSince1970: timestamp/1000)
        }
    }
}



// MARK: - Dictionary - Extension
extension Dictionary: HTCompatibleValue {}
extension HTWrapper where T == Dictionary<String, Any> {
    
    public func stringValue(_ key: String) -> String {
        if let value = t[key] {
            if let intValue = value as? Int {
                return String(intValue)
            }
            else if let doubleValue = value as? Double {
                return String(doubleValue)
            }
            else if let stringValue = value as? String {
                return stringValue
            }
            else {
                let typeString = String(describing: type(of: value))
                HTLogs.logWarning("\(key) 的值不是String类型, 是 \(typeString) 类型")
                return ""
            }
        }
        else {
            HTLogs.logWarning("字典中不包含: \(key)")
            return ""
        }
    }
    
    public func dictionaryValue(_ key: String) -> Dictionary<String, Any>? {
        if let value = t[key] {
            if let dictValue = value as? Dictionary<String, Any> {
                return dictValue
            }
            else {
                HTLogs.logWarning("\(key) 的值不是 Dictionary 类型, 是 \(String(describing: type(of: value))) 类型")
                return nil
            }
        }
        else {
            HTLogs.logWarning("字典中不包含: \(key)")
            return nil
        }
    }
    
    public func arrayValue(_ key: String) -> Array<Any> {
        if let value = t[key] {
            if let arrayValue = value as? Array<Any> {
                return arrayValue
            }
            else {
                HTLogs.logWarning("\(key) 的值不是 Array 类型, 是 \(String(describing: type(of: value))) 类型")
                return []
            }
        }
        else {
            HTLogs.logWarning("字典中不包含: \(key)")
            return []
        }
    }
    
    public func boolValue(_ key: String) -> Bool {
        guard let value = t[key] else {
            HTLogs.logWarning("字典中不包含: \(key)")
            return false
        }
        
        if let boolValue = value as? Bool {
            return boolValue
        }
        else if let stringValue = value as? String {
            return stringValue.lowercased() == "true"
        }
        else if let intValue = value as? Int {
            return intValue != 0
        }
        else if let doubleValue = value as? Double {
            return doubleValue != 0.0
        }
        else {
            HTLogs.logWarning("\(key) 的值不是 Bool 类型, 是 \(String(describing: type(of: value))) 类型")
            return false
        }
    }
    
    public func intValue(_ key: String) -> Int {
        guard let value = t[key] else {
            HTLogs.logWarning("字典中不包含: \(key)")
            return 0
        }
        if let intValue = value as? Int {
            return intValue
        }
        else if let doubleValue = value as? Double {
            return Int(doubleValue)
        }
        else if let stringValue = value as? String {
            return Int(stringValue) ?? 0
        }
        else {
            HTLogs.logWarning("\(key) 的值不是 Int 类型, 是 \(String(describing: type(of: value))) 类型")
            return 0
        }
    }
    
    public func doubleValue(_ key: String) -> Double {
        guard let value = t[key] else {
            HTLogs.logWarning("字典中不包含: \(key)")
            return 0.0
        }
        
        if let doubleValue = value as? Double {
            return doubleValue
        }
        else if let intValue = value as? Int {
            return Double(intValue)
        }
        else if let stringValue = value as? String {
            return Double(stringValue) ?? 0.0
        }
        else {
            HTLogs.logWarning("\(key) 的值不是 Double 类型, 是 \(String(describing: type(of: value))) 类型")
            return 0.0
        }
    }
    
    /// 转 jsonString
    public func jsonString() -> String {
        let sDict = t.ht.makeSerializable()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sDict, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            else {
                HTLogs.logError("转json失败1")
                return "{}"
            }
        } catch {
            HTLogs.logError("转json失败: \(error)")
            return  "{}"
        }
    }
    
    private func  makeSerializable() -> [String: Any] {
        
        var serializableDict: [String: Any] = [:]
        for (key, value) in t {
            if let stringValue = value as? String {
                serializableDict[key] = stringValue
            } 
            else if let intValue = value as? Int {
                serializableDict[key] = intValue
            } 
            else if let doubleValue = value as? Double {
                serializableDict[key] = doubleValue
            } 
            else if let boolValue = value as? Bool {
                serializableDict[key] = boolValue
            } 
            else if let dateValue = value as? Date {
                serializableDict[key] = Int(dateValue.timeIntervalSince1970 * 1000)
            } 
            else if let urlValue = value as? URL {
                serializableDict[key] = urlValue.absoluteString
            }
            else if let arrayValue = value as? [Any] {
                let array = arrayValue.ht.makeSerializable()
                if array.isEmpty == false {
                    serializableDict[key] = array    
                }
            } 
            else if let nestedDict = value as? [String: Any] {
                let serializableNestedDict = nestedDict.ht.makeSerializable()
                if !serializableNestedDict.isEmpty {
                    serializableDict[key] = serializableNestedDict
                }
            }
        }
        
        return serializableDict
    }
    
}

// MARK: - Array - Extension
extension Array<Any> : HTCompatibleValue {}
extension HTWrapper where T == Array<Any> {
    
    func makeSerializable() -> [Any] {
        
        var serializableArray: [Any] = []
        
        for element in t {
            if let stringValue = element as? String {
                serializableArray.append(stringValue)
            } 
            else if let intValue = element as? Int {
                serializableArray.append(intValue)
            } 
            else if let doubleValue = element as? Double {
                serializableArray.append(doubleValue)
            } 
            else if let boolValue = element as? Bool {
                serializableArray.append(boolValue)
            } 
            else if let dateValue = element as? Date {
                serializableArray.append(dateValue.timeIntervalSince1970 * 1000)
            } 
            else if let urlValue = element as? URL {
                serializableArray.append(urlValue.absoluteString)
            }
            else if let dictValue = element as? [String: Any] {
                let serializableNestedDict = dictValue.ht.makeSerializable()
                if !serializableNestedDict.isEmpty {
                    serializableArray.append(serializableNestedDict)
                }
            }
            else if let arrayValue = element as? Array<Any> {
                let array = arrayValue.ht.makeSerializable()
                if !array.isEmpty {
                    serializableArray.append(array)
                }
            }
            // 其他类型跳过（相当于移除）
        }
        
        return serializableArray
    }
    
    public func jsonString() -> String {
        let serializableArray = t.ht.makeSerializable()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: serializableArray, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            else {
                HTLogs.logError("转json失败1")
                return "[]"
            }
        } catch {
            HTLogs.logError("转json失败: \(error)")
            return "[]"
        }
    }
}


// MARK: - Date - Extension
extension Date: HTCompatibleValue {}
extension HTWrapper where T == Date {
    
    /// 获取时间
    public func getComponents() -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .weekday, .weekOfMonth, .weekOfYear, .quarter, .timeZone], from: t)
        return components
    }
    
    /// 按照格式输出日期: yyyy, MM, dd, hh(12小时), HH(24小时), mm, ss, EEE(周几), EEEE(星期几)
    public func formatString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "zh_Hans_CN")
        return dateFormatter.string(from: t)
    }
    
    /// 农历年,月,日
    public func nongli() -> (year: String, month: String, day: String, shengxiao: String) {
        
        let sxList = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
        let year = Calendar.current.dateComponents([.year], from: t).year ?? 1
        let index = (year+4796)%12
        let shengxiaoStr = sxList[index]
        
        let chineseCalender = Calendar(identifier: .chinese)
        let components = chineseCalender.dateComponents([.year, .month, .day], from: t)
//        HTLogs.logDebug("\(t) isLeapMonth: \(String(describing: components.isLeapMonth))")
        
        /// 干支纪年
        let chineseYears = ["甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉", "甲戌", "乙亥", 
                            "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛己", "壬午", "癸未", "甲申", "乙酉", "丙戌", "丁亥", 
                            "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳", "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", 
                            "庚子", "辛丑", "壬寅", "癸卯", "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", 
                            "壬子", "癸丑", "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"]
        let yIndex = components.year ?? 1
        let yearStr = chineseYears[yIndex-1]
        
        let chineseMonths = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
        let mIndex = components.month ?? 1
        var monthStr = chineseMonths[mIndex-1]
        if let isLeapMonth = components.isLeapMonth, isLeapMonth {
            monthStr = "闰" + chineseMonths[components.month!-1]
        }
        
        let chineseDays = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                           "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                           "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        let dIndex = components.day ?? 1
        let dayStr = chineseDays[dIndex-1]
        
        return (yearStr, monthStr, dayStr, shengxiaoStr)
    }
    
    /// 10位时间戳
    public func timestamp10() -> Int {
        return Int(t.timeIntervalSince1970)
    }
    
    /// 13位时间戳
    public func timestamp13() -> Int {
        return Int(t.timeIntervalSince1970*1000)
    }
    
    /// 几天后
    public func afterDays(_ days: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = days
        if let afterDate = calendar.date(byAdding: components, to: t) {
            return afterDate
        }
        else {
            let timestamp = t.timeIntervalSince1970 + Double(24*60*60*days)
            let newDate = Date(timeIntervalSince1970: timestamp)
            return newDate
        }
    }
    
    /// 几小时后
    public func afterHours(_ hours: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hours
        if let afterDate = calendar.date(byAdding: components, to: t) {
            return afterDate
        }
        else {
            let timestamp = t.timeIntervalSince1970 + Double(60*60*hours)
            let newDate = Date(timeIntervalSince1970: timestamp)
            return newDate
        }
    }
    
    /// 几分钟后
    public func afterMinutes(_ minutes: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.minute = minutes
        if let afterDate = calendar.date(byAdding: components, to: t) {
            return afterDate
        }
        else {
            let timestamp = t.timeIntervalSince1970 + Double(60*minutes)
            let newDate = Date(timeIntervalSince1970: timestamp)
            return newDate
        }
    }
    
    /// 几秒后
    public func afterSeconds(_ seconds: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.second = seconds
        if let afterDate = calendar.date(byAdding: components, to: t) {
            return afterDate
        }
        else {
            let timestamp = t.timeIntervalSince1970 + Double(seconds)
            let newDate = Date(timeIntervalSince1970: timestamp)
            return newDate
        }
    }
    
    /// 相差多少秒 (正数: date在后面, 负数: date在前面)
    public func secondsBetweenDate(_ date: Date) -> TimeInterval {
        return date.timeIntervalSince(t)
    }
    
    /// 是否同一年
    public func isSameYearWith(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let c1 = calendar.dateComponents([.year], from: t)
        let c2 = calendar.dateComponents([.year], from: date)
        return c1.year == c2.year
    }
    
    /// 是否同一个月
    public func isSameMonthWith(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let c1 = calendar.dateComponents([.year, .month], from: t)
        let c2 = calendar.dateComponents([.year, .month], from: date)
        return c1.year == c2.year && c1.month == c2.month
    }
    
    /// 是否同一星期
    public func isSameWeekWith(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let c1 = calendar.dateComponents([.year, .weekOfYear], from: t)
        let c2 = calendar.dateComponents([.year, .weekOfYear], from: date)
        return c1.year == c2.year && c1.weekOfYear == c2.weekOfYear
    }
    
    /// 是否同一天
    public func isSameDayWith(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let c1 = calendar.dateComponents([.year, .month, .day], from: t)
        let c2 = calendar.dateComponents([.year, .month, .day], from: date)
        return c1.year == c2.year && c1.month == c2.month && c1.day == c2.day
    }
    
    /// 是否是同一个小时
    public func isSameHourWith(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let c1 = calendar.dateComponents([.year, .month, .day, .hour], from: t)
        let c2 = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return c1.year == c2.year && c1.month == c2.month && c1.day == c2.day && c1.hour == c2.hour
    }
    
    /// 是否是闰年
    public func isLeapYear() -> Bool {
        let calendar = Calendar.current
        let year = calendar.dateComponents([.year], from: t).year!
        if year % 400 == 0 {
            return true
        }
        if year % 4 == 0, year % 100 != 0 {
            return true
        }
        return false
    }
    
}





// MARK: - Bool - Extension
extension Bool: HTCompatibleValue {}
extension HTWrapper where T == Bool {
    
    public var toInt: Int { return t ? 1 : 0 }
    
    /// 取反
    public var toggled: Bool {
        return !t
    }
    
    public var toString: String {
        return t ? "true" : "false"
    }
}

// MARK: - Double - Extension
extension Double: HTCompatibleValue {}
extension HTWrapper where T == Double {
    
    public var toString: String { 
        return String(t) 
    }
    
    /// 绝对值
    public var abs: Double {
        return t >= 0 ? t : -t
    }
    
    /// 四舍五入
    public var toInt: Int { 
        return Int(_math.round(t)) 
    }
    /// 向上取整
    public var ceilInt: Int {
        return Int(_math.ceil(t))
    }
    /// 向下取整
    public var floorInt: Int {
        return Int(_math.floor(t))
    }
    
    /// 保留小数 x 位
    public func xiaoshudian(_ weishu: Int) -> String {
        return String(format: "%.\(weishu)f", t)
    }
}

// MARK: - Int - Extension
extension Int: HTCompatibleValue {}
extension HTWrapper where T == Int {
    
    public var toString: String {
        return String(t)
    }
    
    /// 绝对值
    public var abs: Int {
        return t >= 0 ? t : -t
    }
    
    /// 是否偶数
    public var isEven: Bool {
        return (t % 2 == 0)
    }
    
    /// 是否奇数
    public var isOdd: Bool {
        return (t % 2 != 0)
    }
    
    public var isPositive: Bool { 
        return (t > 0) 
    }
    
    public var isNegative: Bool { 
        return (t < 0) 
    }
    
    public var toDouble: Double { 
        return Double(t) 
    }
    
    public var toFloat: Float { 
        return Float(t) 
    }
    
    public var toCGFloat: CGFloat { 
        return CGFloat(t) 
    }
    
    /// 当前数字的位数
    public var digits: Int {
        if t == 0 {
            return 1
        } 
        else if Int(fabs(Double(t))) <= LONG_MAX {
            return Int(log10(fabs(Double(t)))) + 1
        } 
        else {
            return -1; //out of bound
        }
    }
    
    /// 每一个位数上的数字
    public var digitArray: [Int] {
        var digits = [Int]()
        for char in String(t) {
            if let digit = Int(String(char)) {
                digits.append(digit)
            }
        }
        return digits
    }
    
    /// 从 0 到当前数字取一个随机数
    public var random: Int {
        return Int.random(in: 0...t)
    }
    
    /// 描述字节大小. 
    /// - Returns: 类似 1.94 GB, 341.6 MB 10 KB
    public var byteDescription: String {
        if t <= 0 {
            return "0 KB"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(t))
    }
    
}

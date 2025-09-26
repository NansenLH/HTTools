//
//  File.swift
//  HTTools
//
//  Created by Nansen on 2025/9/13.
//

import Foundation
import UIKit


public class HTTextView: UITextView {
    
    public convenience init(placeHolder: String,
                            placeHolderColor: UIColor,
                            textFont: UIFont,
                            textColor: UIColor,
                            lineSpace: CGFloat, 
                            minHeight: CGFloat, 
                            isAutoHeight: Bool,
                            limitCount: Int
    ) {
        self.init(frame: .zero, textContainer: nil)
    
        self.placeHolder = placeHolder
        self.placeHolderColor = placeHolderColor
        self.font = textFont
        self.textColor = textColor
        self.lineSpace = lineSpace
        self.minHeight = minHeight
        self.isAutoHeight = isAutoHeight
        self.limitCount = limitCount
        self.showCounter = limitCount > 0
    }
    
    /// 占位文字
    public var placeHolder: String = "请输入内容..." {
        didSet {
            placeHolderLabel.text = placeHolder
            updatePlaceHolderLayout()
        }
    }
    
    /// 占位文字颜色
    public var placeHolderColor: UIColor = UIColor.lightGray {
        didSet {
            placeHolderLabel.textColor = placeHolderColor
            counterLabel.textColor = placeHolderColor
        }
    }
    
    /// 行间距
    public var lineSpace: CGFloat = 5.0 {
        didSet {
            updateLineHeight()
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 字体
    public override var font: UIFont? {
        didSet {
            if let f = font {
                placeHolderLabel.font = font
                updatePlaceHolderLayout()
                updateLineHeight()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    /// 对齐模式
    public override var textAlignment: NSTextAlignment {
        didSet {
            placeHolderLabel.textAlignment = textAlignment
        }
    }
    
    public override var text: String! {
        didSet {
            updatePlaceholderVisibility()
            updatePlaceHolderLayout()
            updateLineHeight()
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 设置最小高度
    public var minHeight: CGFloat = 200.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 是否根据文字高度变化
    public var isAutoHeight: Bool = false {
        didSet {
            self.isScrollEnabled = !isAutoHeight // 关闭滚动
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 限制字符输入的个数. 0是不限制
    public var limitCount: Int = 0 {
        didSet {
            checkTextLimit()
        }
    }
    /// 是否显示字符统计 (右下角)
    public var showCounter: Bool = false {
        didSet {
            counterLabel.isHidden = !showCounter
            updateCounterLabel()
        }
    }
    

    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .clear
        return label
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    func createUI() {
        self.backgroundColor = .clear
        if self.font == nil {
            self.font = UIFont.systemFont(ofSize: 16)
        }
        if self.textColor == nil {
            self.textColor = .black
        }
        
        addSubview(placeHolderLabel)
        placeHolderLabel.text = placeHolder
        placeHolderLabel.textColor = placeHolderColor
        placeHolderLabel.font = self.font
        
        addSubview(counterLabel)
        counterLabel.textColor = placeHolderColor
        counterLabel.isHidden = !showCounter
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        self.isScrollEnabled = !isAutoHeight
        
        updatePlaceholderVisibility()
        updateLineHeight()
        updatePlaceHolderLayout()
        updateCounterLabel()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updatePlaceHolderLayout()
        updateCounterLabelFrame()
    }
    
    private func updatePlaceHolderLayout() {
        
        placeHolderLabel.sizeToFit()
        
        let edgeInsets = self.textContainerInset
        let contentInsets = self.contentInset
        let left = edgeInsets.left + contentInsets.left
        let top = edgeInsets.top + contentInsets.top
        
        placeHolderLabel.frame = CGRectMake(left+5, top, self.frame.width - left - edgeInsets.right, placeHolderLabel.frame.height)
    }
    
    private func updateCounterLabelFrame() {
        let edgeInsets = self.textContainerInset
        let labelWidth: CGFloat = 60
        let labelHeight: CGFloat = 15
        counterLabel.frame = CGRectMake(self.frame.width - labelWidth - edgeInsets.right - 2, 
                                        self.frame.height - labelHeight - edgeInsets.bottom - 2, 
                                        labelWidth,
                                        labelHeight)
    }
    
    @objc private func textDidChange() {
        
        if let markedRange = self.markedTextRange {
            if markedRange.start != markedRange.end {
                placeHolderLabel.isHidden = true
                return
            }
        }
        
        updatePlaceholderVisibility()
        updateLineHeight()
        invalidateIntrinsicContentSize()
        checkTextLimit()
        updateCounterLabel()
    }
    
    private func updatePlaceholderVisibility() {
        placeHolderLabel.isHidden = !self.text.isEmpty
    }
    
    private func updateCounterLabel() {
        guard showCounter else { return }
        
        let current = self.text.count
        let total = limitCount > 0 ? limitCount : 0
        if total > 0 {
            counterLabel.text = "\(current)/\(total)"
            counterLabel.textColor = current > total ? .red : placeHolderColor
        }
        else {
            counterLabel.text = "\(current)"
            counterLabel.textColor = placeHolderColor
        }
    }
    
    private func checkTextLimit() {
        guard limitCount > 0, self.text.count > limitCount else { return }
        let endIndex = self.text.index(self.text.startIndex, offsetBy: limitCount)
        self.text = String(self.text[..<endIndex])
    }
    
    private func updateLineHeight() {
        if self.font == nil {
            self.font = UIFont.systemFont(ofSize: 16)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = self.lineSpace - (self.font!.lineHeight - self.font!.pointSize)
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.alignment = self.textAlignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font!,
            .foregroundColor: self.textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // 应用到整个文本
        self.typingAttributes = attributes
        
        if !self.text.isEmpty {
            let attributedText = NSMutableAttributedString(string: self.text, attributes: attributes)
            self.attributedText = attributedText
        }
    }

    public override var intrinsicContentSize: CGSize {
        guard isAutoHeight else {
            return CGSizeMake(UIView.noIntrinsicMetric, minHeight)
        }
        
        let superSize = super.intrinsicContentSize
        let height = max(superSize.height, minHeight)
        return CGSizeMake(superSize.width, height)
    }
    
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        createUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createUI()
    }    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension HTTextView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let markedRange = textView.markedTextRange {
            if markedRange.start != markedRange.end {
                return true
            }
        }
        
        guard limitCount > 0 else { return true }
        
        let currentText = textView.text ?? ""
        let newLength = currentText.count + text.count - range.length
        return newLength <= limitCount
    }
}

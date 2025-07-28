//
//  File.swift
//  HTTools
//
//  Created by Nansen on 2025/7/19.
//

import Foundation
import UIKit

/// 图片文字自定义布局按钮
public class HTButton: UIButton {
    
    /// 图片相对文字的布局
    public enum HTButtonImageLayout {
        case top
        case bottom
        case left
        case right
    }
    
    /// 内容的整体布局
    public enum HTButtonContentLayout {
        case center
        case left
        case right
        
        case top
        case topLeft
        case topRight
        
        case bottom
        case bottomLeft
        case bottomRight
    }
    
    /// 图片的大小
    var imageSize: CGSize = .zero
    
    /// 图片和文字之间的间距
    var spacing: CGFloat = 8
    
    
    var imageLayout: HTButtonImageLayout = .left
    var contentLayout: HTButtonContentLayout = .center
    
    init(imageSize: CGSize, spacing: CGFloat, imageLayout: HTButtonImageLayout, contentLayout: HTButtonContentLayout = .center) {
        self.imageSize = imageSize
        self.spacing = spacing
        self.imageLayout = imageLayout
        self.contentLayout = contentLayout
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    func updateUI() {
        guard let label = self.titleLabel, let imageV = self.imageView else { return }
        
        let boundsW = bounds.width
        let boundsH = bounds.height
        
        if boundsW <= 0 || boundsH <= 0 {
            return
        }
        
        let textW = label.intrinsicContentSize.width
        let textH = label.intrinsicContentSize.height
        
        var imageX, imageY, labelX, labelY: CGFloat
        
        switch imageLayout {
            case .top:
                let contentH = imageSize.height + spacing + textH
                let contentW = max(imageSize.width, textW)
                let imageDx = (contentW - imageSize.width) / 2.0
                let textDx = (contentW - textW) / 2.0
                
                switch contentLayout {
                    case .center:
                        imageX = (boundsW - imageSize.width) / 2.0
                        imageY = (boundsH - contentH) / 2.0
                        
                        labelX = (boundsW - textW) / 2.0
                        labelY = imageY + imageSize.height + spacing
                        
                    case .left:
                        imageX = imageDx
                        imageY = (boundsH - contentH) / 2.0
                        
                        labelX = textDx
                        labelY = imageY + imageSize.height + spacing
                        
                    case .right:
                        imageX = boundsW - imageSize.width - imageDx
                        imageY = (boundsH - contentH) / 2.0
                        
                        labelX = boundsW - textW - textDx
                        labelY = imageY + imageSize.height + spacing
                        
                    case .top:
                        imageX = (boundsW - imageSize.width) / 2.0
                        imageY = 0
                        
                        labelX = (boundsW - textW) / 2.0
                        labelY = imageY + imageSize.height + spacing
                        
                    case .topLeft:
                        imageX = imageDx
                        imageY = 0
                        
                        labelX = textDx
                        labelY = imageY + imageSize.height + spacing
                        
                    case .topRight:
                        imageX = boundsW - imageSize.width - imageDx
                        imageY = 0
                        
                        labelX = boundsW - textW - textDx
                        labelY = imageY + imageSize.height + spacing
                        
                    case .bottom:
                        imageX = (boundsW - imageSize.width) / 2.0
                        imageY = boundsH - contentH
                        
                        labelX = (boundsW - textW) / 2.0
                        labelY = imageY + imageSize.height + spacing
                        
                    case .bottomLeft:
                        imageX = imageDx
                        imageY = boundsH - contentH
                        
                        labelX = textDx
                        labelY = imageY + imageSize.height + spacing
                        
                    case .bottomRight:
                        imageX = boundsW - imageSize.width - imageDx
                        imageY = boundsH - contentH
                        
                        labelX = boundsW - textW - textDx
                        labelY = imageY + imageSize.height + spacing
                }
                
            case .bottom:
                let contentH = imageSize.height + spacing + textH
                let contentW = max(imageSize.width, textW)
                let imageDx = (contentW - imageSize.width) / 2.0
                let textDx = (contentW - textW) / 2.0
                
                switch contentLayout {
                    case .center:
                        labelX = (boundsW - textW) / 2.0
                        labelY = (boundsH - contentH) / 2.0
                        
                        imageX = (boundsW - imageSize.width) / 2.0
                        imageY = labelY + textH + spacing
                        
                    case .left:
                        labelX = textDx
                        labelY = (boundsH - contentH) / 2.0
                        
                        imageX = imageDx
                        imageY = labelY + textH + spacing
                        
                    case .right:
                        labelX = boundsW - textW - textDx
                        labelY = (boundsH - contentH) / 2.0
                        
                        imageX = boundsW - imageSize.width - imageDx
                        imageY = labelY + textH + spacing
                        
                    case .top:
                        labelX = (boundsW - textW) / 2.0
                        labelY = 0
                        
                        imageX = (boundsW - imageSize.width) / 2.0
                        imageY = labelY + textH + spacing
                        
                    case .topLeft:
                        labelX = textDx
                        labelY = 0
                        
                        imageX = imageDx
                        imageY = labelY + textH + spacing
                        
                    case .topRight:
                        labelX = boundsW - textW - textDx
                        labelY = 0
                        
                        imageX = boundsW - imageSize.width - imageDx
                        imageY = labelY + textH + spacing
                        
                    case .bottom:
                        labelX = (boundsW - textW) / 2.0
                        labelY = boundsH - contentH
                        
                        imageX = (boundsW - imageSize.width) / 2.0
                        imageY = labelY + textH + spacing
                        
                    case .bottomLeft:
                        labelX = textDx
                        labelY = boundsH - contentH
                        
                        imageX = imageDx
                        imageY = labelY + textH + spacing
                        
                    case .bottomRight:
                        labelX = boundsW - textW - textDx
                        labelY = boundsH - contentH
                        
                        imageX = boundsW - imageSize.width - imageDx
                        imageY = labelY + textH + spacing
                }
                
            case .left:
                let contentW = imageSize.width + spacing + textW
                let contentH = max(imageSize.height, textH)
                let imageDy = (contentH - imageSize.height) / 2.0
                let textDy = (contentH - textH) / 2.0
                
                switch contentLayout {
                    case .center:
                        imageX = (boundsW - contentW) / 2.0
                        imageY = (boundsH - imageSize.height) / 2.0
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = (boundsH - textH) / 2.0
                        
                    case .left:
                        imageX = 0
                        imageY = (boundsH - imageSize.height) / 2.0
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = (boundsH - textH) / 2.0
                        
                    case .right:
                        imageX = boundsW - contentW
                        imageY = (boundsH - imageSize.height) / 2.0
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = (boundsH - textH) / 2.0
                        
                    case .top:
                        imageX = (boundsW - contentW) / 2.0
                        imageY = imageDy
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = textDy
                        
                    case .topLeft:
                        imageX = 0
                        imageY = imageDy
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = textDy
                        
                    case .topRight:
                        imageX = boundsW - contentW
                        imageY = imageDy
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = textDy
                        
                    case .bottom:
                        imageX = (boundsW - contentW) / 2.0
                        imageY = contentH - imageSize.height - imageDy
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = contentH - textH - textDy
                        
                    case .bottomLeft:
                        imageX = 0
                        imageY = contentH - imageSize.height - imageDy
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = contentH - textH - textDy
                        
                    case .bottomRight:
                        imageX = boundsW - contentW
                        imageY = contentH - imageSize.height - imageDy
                        
                        labelX = imageX + imageSize.width + spacing
                        labelY = contentH - textH - textDy
                }
                
            case .right:
                let contentW = imageSize.width + spacing + textW
                let contentH = max(imageSize.height, textH)
                let imageDy = (contentH - imageSize.height) / 2.0
                let textDy = (contentH - textH) / 2.0
                
                switch contentLayout {
                    case .center:
                        labelX = (boundsW - contentW) / 2.0
                        labelY = (boundsH - textH) / 2.0
                        
                        imageX = labelX + textW + spacing
                        imageY = (boundsH - imageSize.height) / 2.0
                        
                    case .left:
                        labelX = 0
                        labelY = (boundsH - textH) / 2.0
                        
                        imageX = labelX + textW + spacing
                        imageY = (boundsH - imageSize.height) / 2.0
                        
                    case .right:
                        labelX = boundsW - contentW
                        labelY = (boundsH - textH) / 2.0
                        
                        imageX = labelX + textW + spacing
                        imageY = (boundsH - imageSize.height) / 2.0
                        
                    case .top:
                        labelX = (boundsW - contentW) / 2.0
                        labelY = textDy
                        
                        imageX = labelX + textW + spacing
                        imageY = imageDy
                        
                    case .topLeft:
                        labelX = 0
                        labelY = textDy
                        
                        imageX = labelX + textW + spacing
                        imageY = imageDy
                        
                    case .topRight:
                        labelX = boundsW - contentW
                        labelY = textDy
                        
                        imageX = labelX + textW + spacing
                        imageY = imageDy
                        
                    case .bottom:
                        labelX = (boundsW - contentW) / 2.0
                        labelY = contentH - textDy - textH
                        
                        imageX = labelX + textW + spacing
                        imageY = contentH - imageDy - imageSize.height
                        
                    case .bottomLeft:
                        labelX = 0
                        labelY = contentH - textDy - textH
                        
                        imageX = labelX + textW + spacing
                        imageY = contentH - imageDy - imageSize.height
                        
                    case .bottomRight:
                        labelX = boundsW - contentW
                        labelY = contentH - textDy - textH
                        
                        imageX = labelX + textW + spacing
                        imageY = contentH - imageDy - imageSize.height
                }
                
        }
        
        imageV.frame = CGRect(origin: CGPoint(x: imageX, y: imageY), size: imageSize)
        label.frame = CGRect(origin: CGPoint(x: labelX, y: labelY), size: CGSize(width: textW, height: textH))
    }
}

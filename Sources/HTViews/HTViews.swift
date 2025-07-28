//
//  Created by Nansen on 2025/7/19.
//

import Foundation
import UIKit
import HTLogs

public enum HTViewBorderSide {
    case top
    case bottom
    case left
    case right
}


public class HTView: UIView {
    
    var borderLayer: HTViewBorderLayer?
    /// 添加指定位置的边框
    public func addBorder(sides: Set<HTViewBorderSide>, borderWidth: CGFloat, borderColor: UIColor) {
        
        if let bLayer = borderLayer {
            bLayer.sides = sides
            bLayer.lineWidth = borderWidth
            bLayer.strokeColor = borderColor.cgColor
            bLayer.update(cornerRadius: self.layer.cornerRadius, viewSize: self.bounds.size)
        }
        else {
            let bLayer = HTViewBorderLayer(sides: sides, lineW: borderWidth, lineColor: borderColor)
            self.layer.addSublayer(bLayer)
            bLayer.frame = bounds
            bLayer.update(cornerRadius: self.layer.cornerRadius, viewSize: bounds.size)
            
            borderLayer = bLayer
        }
    }
    
    
    public var gradientLayer: CAGradientLayer?
    /// 添加渐变色背景: colors和locations个数一致. 取值范围 0~1.0
    /// - Parameters:
    ///   - colors: 渐变颜色
    ///   - locations: 渐变位置. 个数和colors保持一致(0~1.0)
    ///   - startPoint: 开始位置(0~1.0)
    ///   - endPoint: 结束位置(0~1.0)
    public func addGradientBackground(colors: [UIColor], 
                                      locations: [Double], 
                                      startPoint: CGPoint = CGPoint(x: 0, y: 0.5), 
                                      endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5)) {
        
        guard colors.count == locations.count else {
            HTLogs.logFatal("HTCustomView.addGradientBackground 参数错误1. colors[\(colors.count)] locations[\(locations.count)], locations=\(locations)")
            return
        }
        
        var s = startPoint
        if !((0...1).contains(startPoint.x) && (0...1).contains(startPoint.y)) {
            HTLogs.logFatal("HTCustomView.addGradientBackground 参数错误2. startX=\(startPoint.x) startY=\(startPoint.y)")
            let sx = max(0.0, min(1.0, startPoint.x)) 
            let sy = max(0.0, min(1.0, startPoint.y))
            s = CGPoint(x: sx, y: sy)
        }
        
        var e = endPoint
        if !((0...1).contains(endPoint.x) && (0...1).contains(endPoint.y)) {
            HTLogs.logFatal("HTCustomView.addGradientBackground 参数错误3. endX=\(endPoint.x) endY=\(endPoint.y)")
            let ex = max(0.0, min(1.0, endPoint.x)) 
            let ey = max(0.0, min(1.0, endPoint.y))
            e = CGPoint(x: ex, y: ey)
        }
        
        if let gLayer = gradientLayer {
            
            gLayer.frame = self.bounds
            gLayer.colors = colors.map { $0.cgColor }
            gLayer.locations = locations.map { NSNumber(value: $0) }
            gLayer.startPoint = s
            gLayer.endPoint = e
            gLayer.cornerRadius = layer.cornerRadius
        }
        else {
            let gLayer = CAGradientLayer()
            gLayer.frame = self.bounds
            gLayer.colors = colors.map { $0.cgColor }
            gLayer.locations = locations.map { NSNumber(value: $0) }
            gLayer.startPoint = s
            gLayer.endPoint = e
            gLayer.cornerRadius = self.layer.cornerRadius
            self.layer.insertSublayer(gLayer, at: 0)
            
            gradientLayer = gLayer
        }
        
    }
    
    
    /// 设置点击事件
    public var didClick: ( (_ viewTag:Int)->Void )? {
        didSet {
            if didClick == nil {
                if self.tapG != nil {
                    self.removeGestureRecognizer(self.tapG!)
                    self.tapG = nil
                }
            }
            else {
                if self.tapG == nil {
                    self.tapG = UITapGestureRecognizer(target: self, action: #selector(tapGAction(_ :)))
                    self.addGestureRecognizer(self.tapG!)
                }
            }
        }
    }
    private var tapG: UITapGestureRecognizer?
    @objc private func tapGAction(_ gesture: UITapGestureRecognizer) {
        if let action = didClick {
            action(self.tag)
        }
    }
    
    
    
    
    /// 处理 border 和 gradientLayer 的更新
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layer = borderLayer {
            layer.update(cornerRadius: self.layer.cornerRadius, viewSize: bounds.size)
        }
        
        if let gLayer = gradientLayer {
            gLayer.frame = self.bounds
        }
    }
    
}

class HTViewBorderLayer: CAShapeLayer {
    
    var sides: Set<HTViewBorderSide> = [.top, .bottom, .left, .right]
    
    init(sides: Set<HTViewBorderSide>, lineW: CGFloat, lineColor: UIColor) {
        self.sides = sides
        super.init()
        
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = lineColor.cgColor
        self.lineWidth = lineW
        self.lineCap = .butt
        self.lineJoin = .round  
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(cornerRadius: CGFloat, viewSize: CGSize) {
        guard viewSize.width > 0, viewSize.height > 0 else { return }
        
        if sides.isEmpty {
            self.path = nil
            return
        }
        
        let viewW = viewSize.width
        let viewH = viewSize.height
        let lineW = self.lineWidth
        
        let path = UIBezierPath()
        
        let p1 = CGPoint(x: cornerRadius, y: lineW/2.0)
        let p2 = CGPoint(x: viewW - cornerRadius, y: lineW/2.0)
        let p3 = CGPoint(x: viewW - lineW/2.0, y: cornerRadius)
        let p4 = CGPoint(x: viewW - lineW/2.0, y: viewH - cornerRadius)
        let p5 = CGPoint(x: viewW - cornerRadius, y: viewH - lineW/2.0)
        let p6 = CGPoint(x: cornerRadius, y: viewH - lineW/2.0)
        let p7 = CGPoint(x: lineW/2.0, y: viewH - cornerRadius)
        let p8 = CGPoint(x: lineW/2.0, y: cornerRadius)
        
        let c1 = CGPoint(x: viewW - lineW/2.0, y: lineW/2.0)
        let c2 = CGPoint(x: viewW - lineW/2.0, y: viewH - lineW/2.0)
        let c3 = CGPoint(x: lineW/2.0, y: viewH - lineW/2.0)
        let c4 = CGPoint(x: lineW/2.0, y: lineW/2.0)
        
        /**
         c4 p1--------------p2 c1
         p8                    p3
         |                    | 
         |                    |
         |                    |
         p7                    p4
         c3 p6--------------p5 c2
         */
        if self.sides == [.top, .bottom, .left, .right] {
            // all                
            path.move(to: p1)
            path.addLine(to: p2)
            path.addQuadCurve(to: p3, controlPoint: c1)
            path.addLine(to: p4)
            path.addQuadCurve(to: p5, controlPoint: c2)
            path.addLine(to: p6)
            path.addQuadCurve(to: p7, controlPoint: c3)
            path.addLine(to: p8)
            path.addQuadCurve(to: p1, controlPoint: c4)
        }
        else if self.sides == [.top, .left, .bottom] {
            // 上, 左, 下
            path.move(to: p2)
            path.addLine(to: p1)
            path.addQuadCurve(to: p8, controlPoint: c4)
            path.addLine(to: p7)
            path.addQuadCurve(to: p6, controlPoint: c3)
            path.addLine(to: p5)
        }
        else if self.sides == [.top, .right, .bottom] {
            // 上, 右, 下
            path.move(to: p1)
            path.addLine(to: p2)
            path.addQuadCurve(to: p3, controlPoint: c1)
            path.addLine(to: p4)
            path.addQuadCurve(to: p5, controlPoint: c2)
            path.addLine(to: p6)
        }
        else if self.sides == [.top, .left, .right] {
            // 左, 上, 右
            path.move(to: p7)
            path.addLine(to: p8)
            path.addQuadCurve(to: p1, controlPoint: c4)
            path.addLine(to: p2)
            path.addQuadCurve(to: p3, controlPoint: c1)
            path.addLine(to: p4)
        }
        else if self.sides == [.right, .bottom, .left] {
            // 右, 下, 左 
            path.move(to: p3)
            path.addLine(to: p4)
            path.addQuadCurve(to: p5, controlPoint: c2)
            path.addLine(to: p6)
            path.addQuadCurve(to: p7, controlPoint: c3)
            path.addLine(to: p8)
        }
        else if self.sides == [.left, .top] {
            // 左, 上
            path.move(to: p7)
            path.addLine(to: p8)
            path.addQuadCurve(to: p1, controlPoint: c4)
            path.addLine(to: p2)
        }
        else if self.sides == [.left, .bottom] {
            // 左, 下
            path.move(to: p8)
            path.addLine(to: p7)
            path.addQuadCurve(to: p6, controlPoint: c3)
            path.addLine(to: p5)
        }
        else if self.sides == [.left, .right] {
            // 左, 右
            path.move(to: p8)
            path.addLine(to: p7)
            
            path.move(to: p3)
            path.addLine(to: p4)
        }
        else if self.sides == [.right, .top] {
            // 右, 上
            path.move(to: p1)
            path.addLine(to: p2)
            path.addQuadCurve(to: p3, controlPoint: c1)
            path.addLine(to: p4)
        }
        else if self.sides == [.right, .bottom] {
            // 右, 下
            path.move(to: p3)
            path.addLine(to: p4)
            path.addQuadCurve(to: p5, controlPoint: c2)
            path.addLine(to: p6)
        }
        else if self.sides == [.top, .bottom] {
            // 上, 下
            path.move(to: p1)
            path.addLine(to: p2)
            path.move(to: p6)
            path.addLine(to: p5)
        }
        else if self.sides == [.top] {
            // 上
            path.move(to: p1)
            path.addLine(to: p2)
        }
        else if self.sides == [.bottom] {
            // 下
            path.move(to: p6)
            path.addLine(to: p5)
        }
        else if self.sides == [.left] {
            // 左
            path.move(to: p8)
            path.addLine(to: p7)
        }
        else if self.sides == [.right] {
            // 右
            path.move(to: p3)
            path.addLine(to: p4)
        }
        
        self.path = path.cgPath
    }
}

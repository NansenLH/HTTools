//
//  Created by Nansen on 2025/6/24.
//

import UIKit
import Photos
import PhotosUI
import HTLogs
import CoreGraphics

// MARK: - 图片工具类
public class HTImage {
    
    /// 使用 UIImage(contentsOfFile:) 加载本地图片
    public static func imageFromFile(_ imageName: String) -> UIImage? {
        let scale = Int(UIScreen.main.scale)
        let scaleImgName = imageName+"@\(scale)x.png"
        if let imgPath = Bundle.main.path(forResource: scaleImgName, ofType: nil) {
            if let image = UIImage(contentsOfFile: imgPath) {
                return image
            }
        }
        
        if let imgPath = Bundle.main.path(forResource: imageName, ofType: "png") {
            if let image = UIImage(contentsOfFile: imgPath) {
                return image
            }
        }
        
        HTLogs.logWarning("未找到图片文件: \(imageName)")
        return UIImage(named: "cicon_imgFailed", in: Bundle.module, compatibleWith: nil)
    }
    
    /// 等比例压缩图片到指定的分辨率. 如果原图比目标分辨率低, 直接返回原图
    public static func compressImageToMaxPixel(sourceImage: UIImage, maxPixel: CGFloat) -> UIImage {
        
        let width = sourceImage.size.width*sourceImage.scale
        let height = sourceImage.size.height*sourceImage.scale
        
        // 如果图片已经小于等于目标尺寸，直接返回原图
        guard width > maxPixel || height > maxPixel else {
            return sourceImage
        }
        
        // 计算目标尺寸
        let aspectRatio = width / height
        var targetSize: CGSize
        if width > height {
            // 以宽度为基准缩放
            let targetWidth = maxPixel
            let targetHeight = targetWidth / aspectRatio
            targetSize = CGSize(width: targetWidth, height: targetHeight)
        } 
        else {
            // 以高度为基准缩放
            let targetHeight = maxPixel
            let targetWidth = targetHeight * aspectRatio
            targetSize = CGSize(width: targetWidth, height: targetHeight)
        }
        
        // 开始绘制新图像
        UIGraphicsBeginImageContext(targetSize)
        defer { UIGraphicsEndImageContext() } // 确保上下文一定会被关闭
        
        sourceImage.draw(in: CGRect(origin: .zero, size: targetSize))
        if let compressedImage = UIGraphicsGetImageFromCurrentImageContext() {
            return compressedImage
        } 
        else {
            HTLogs.logWarning("")
            // 如果绘制失败，返回原图（防止崩溃）
            return sourceImage
        }
        
    }
    
    /// 压缩图片到限制的大小 (kb)
    public static func compressImageToMaxJpgData(sourceImage: UIImage, maxSize: Int) -> Data {
        var maxBytes = maxSize*1024
        if maxBytes < 1024 {
            HTLogs.logFatal("HTImage.compressImageToMaxJpgData 参数错误: maxSize=\(maxSize)")
            maxBytes = 1024
        }
        
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.1
        
        guard var imageData = sourceImage.jpegData(compressionQuality: compression) else {
            HTLogs.logFatal("HTImage.compressImageToMaxJpgData jpegData失败 maxSize=\(maxSize)")
            return Data()
        }
        
        if imageData.count <= maxBytes {
            return imageData
        }
        
        while imageData.count > maxBytes && compression > maxCompression {
            compression -= 0.1
            imageData = sourceImage.jpegData(compressionQuality: compression) ?? Data()
        }
        HTLogs.logDebug("HTImage.compressImageToMaxJpgData 压缩率:\(compression)")
        
        return imageData
    }
    
    /// 修正 UIImage 的方法
    public static func fixOrientation(sourceImage: UIImage) -> UIImage {
        guard let cgImage = sourceImage.cgImage else {
            HTLogs.logFatal("cgImage 不存在（理论上不应该发生）")
            return sourceImage 
        }
        
        let orientation = sourceImage.imageOrientation
        if orientation == .up {
            return sourceImage
        }
        HTLogs.logDebug("原始图片方向:\(orientation)")
        
        
        var transform = CGAffineTransform.identity
        let imageW = sourceImage.size.width*sourceImage.scale
        let imageH = sourceImage.size.height*sourceImage.scale
        // 第一步：根据方向进行旋转
        switch orientation {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: imageW, y: imageH)
                transform = transform.rotated(by: .pi)
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: imageW, y: 0)
                transform = transform.rotated(by: .pi / 2)
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: imageH)
                transform = transform.rotated(by: -.pi / 2)
            default:
                break
        }
        
        // 第二步：根据是否镜像进行水平或垂直翻转
        switch orientation {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: imageW, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: imageH, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            default:
                break
        }
        
        // 创建位图上下文
        guard let context = CGContext(
            data: nil,
            width: Int(imageW),
            height: Int(imageH),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: cgImage.bitmapInfo.rawValue
        ) 
        else {
            HTLogs.logFatal("创建上下文失败")
            return sourceImage
        }
        
        // 应用变换
        context.concatenate(transform)
        
        // 根据方向决定绘制区域
        switch orientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                // 这些方向需要交换宽高
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageW, height: imageH))
            default:
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageW, height: imageH))
        }
        
        // 从上下文中生成新的 CGImage
        guard let cgimg = context.makeImage() else {
            HTLogs.logFatal("context.makeImage() 失败")
            return sourceImage
        }

        return UIImage(cgImage: cgimg)
    }
    
    /// 裁剪图片. 裁剪的位置(像素)
    public static func cropImage(sourceImage: UIImage, cropX: Int, cropY: Int, cropW: Int, cropH: Int) -> UIImage {
        
        let imageWidth = Int(sourceImage.size.width*sourceImage.scale)
        let imageHeight = Int(sourceImage.size.height*sourceImage.scale)
        
        guard cropX >= 0 && cropY >= 0 &&
                cropW > 0 && cropH > 0 &&
                cropX + cropW <= imageWidth &&
                cropY + cropH <= imageHeight else {
            HTLogs.logFatal("裁剪区域不合法: imageSize=\(sourceImage.size), cropRect=[\(cropX), \(cropY), \(cropW), \(cropH)]")
            return sourceImage
        }
        
        // 计算裁剪区域
        let cropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
        
        // 开启图形上下文，按照裁剪区域的大小创建新图像
        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // 将原图绘制到上下文中，并应用负偏移，使裁剪区域对齐到上下文左上角
        sourceImage.draw(in: CGRect(
            x: -cropX,
            y: -cropY,
            width: imageWidth,
            height: imageHeight
        ))
        
        // 从上下文中获取裁剪后的图像
        if let croppedImage = UIGraphicsGetImageFromCurrentImageContext() {
            return croppedImage
        } 
        else {
            HTLogs.logFatal("生成图片失败")
            return sourceImage
        }
    }
    
    /// 图片添加图片水印
    public static func addWaterMask(sourceImage: UIImage, wmImage: UIImage, rect: CGRect) -> UIImage {
        let imageW = Int(sourceImage.size.width * sourceImage.scale)
        let imageH = Int(sourceImage.size.height * sourceImage.scale)
        let imageSize = CGSize(width: imageW, height: imageH)
        
        guard rect.origin.x >= 0 && rect.origin.y >= 0 &&
                rect.width > 0 && rect.height > 0 &&
                Int(rect.maxX) <= imageW && Int(rect.maxY) <= imageH else {
            // 如果水印超出范围，返回原图
            HTLogs.logFatal("参数问题. sourceImgSize=\(sourceImage.size), rect=\(rect)")
            return sourceImage
        }
        
        // 开启图形上下文，按照原图大小创建新的图像
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // 1. 先将原始图片绘制到上下文中
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: imageW, height: imageH))
        
        // 2. 再将水印图片绘制到指定的 rect 区域
        let showRect = HTSize.ratioRect(size: imageSize, toRect: rect, isFit: true)
        wmImage.draw(in: showRect)
        
        // 3. 从上下文中获取添加水印后的新图片
        if let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext() {
            return watermarkedImage
        } else {
            // 如果绘图失败，返回原图
            return sourceImage
        }
    }
    
    /// 图片添加文字水印
    public static func addWaterMask(sourceImage: UIImage, wmString: String, color: UIColor, font: UIFont, rect: CGRect) -> UIImage {
        let imageWidth = Int(sourceImage.size.width * sourceImage.scale)
        let imageHeight = Int(sourceImage.size.height * sourceImage.scale)
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        
        // 检查 rect 是否在图片范围内
        guard rect.origin.x >= 0 && rect.origin.y >= 0 &&
                rect.width > 0 && rect.height > 0 &&
                Int(rect.maxX) <= imageWidth && Int(rect.maxY) <= imageHeight else {
            // 如果 rect 超出图片范围，返回原图
            HTLogs.logFatal("参数有误 imageSize=\(sourceImage.size), textRect=\(rect)")
            return sourceImage
        }
        
        // 开启图形上下文，按照原图大小创建新的图像
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // 1. 先将原始图片绘制到上下文中
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        // 2. 计算合适尺寸
        let fontSize = calculateMaxFontSize(text: wmString, fontName: font.fontName, size: rect.size)
        guard let showFont = UIFont(name: font.fontName, size: fontSize) else {
            HTLogs.logFatal("Font失败 name=\(font.fontName), size=\(fontSize)")
            return sourceImage
        }
        
        let drawAttributes: [NSAttributedString.Key: Any] = [
            .font: showFont,
            .foregroundColor: color,
        ]
        let drawTextSize = wmString.size(withAttributes: drawAttributes)
        let fontMetrics = showFont.ascender + abs(showFont.descender)
        let textVOffset = (rect.height - fontMetrics) / 2.0 - showFont.ascender
        let textDrawRect = CGRect(x: rect.origin.x + (rect.width - drawTextSize.width)/2.0, 
                                  y: rect.origin.y + textVOffset, 
                                  width: drawTextSize.width, 
                                  height: fontMetrics)
        
        // 3. 将文字绘制到指定的 rect 区域内
        wmString.draw(in: textDrawRect, withAttributes: drawAttributes)
        
        // 4. 从上下文中获取添加水印后的新图片
        if let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext() {
            return watermarkedImage
        } 
        else {
            HTLogs.logFatal("图片生成失败")
            // 如果绘图失败，返回原图
            return sourceImage
        }
    }
    private static func calculateMaxFontSize(text: String, fontName: String, size: CGSize) -> CGFloat {
        var minFont: CGFloat = 12
        var maxFont: CGFloat = size.height
        var bestFont: CGFloat = minFont
        
        while minFont < maxFont {
            let midFont = (minFont + maxFont) / 2.0
            guard let font = UIFont(name: fontName, size: midFont) else {
                break
            }
            let currentAttributes: [NSAttributedString.Key: Any] = [.font : font]
            let textSize = text.size(withAttributes: currentAttributes)
            if textSize.width <= size.width && textSize.height <= size.height {
                // 如果文字能完整显示，尝试更大的字号
                bestFont = midFont
                minFont = midFont + 1
            } else {
                // 如果文字超出区域，尝试更小的字号
                maxFont = midFont - 1
            }
        }
        return bestFont
    }
    
    /// 生成一张纯色图片
    public static func createImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // 获取当前图形上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            // 如果获取上下文失败，返回空图片（理论上不应该发生）
            HTLogs.logFatal("初始化失败")
            return UIImage()
        }
        
        // 设置填充颜色
        color.setFill()
        
        // 填充整个上下文区域
        context.fill(CGRect(origin: .zero, size: size))
        
        // 从上下文中获取生成的 UIImage
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        } else {
            HTLogs.logFatal("生成图片失败")
            // 如果生成失败，返回空图片（理论上不应该发生）
            return UIImage()
        }
    }
}




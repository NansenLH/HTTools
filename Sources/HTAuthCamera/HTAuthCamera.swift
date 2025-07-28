//
//  Created by Nansen on 2025/7/19.
//

/**
 Info.plist 中添加描述
 在 Build Settings - Info.plist Values 中设置
 
 相机权限:
     Privacy - Camera Usage Description
     NSCameraUsageDescription
     请允许以使用相机进行扫码或者拍照上传图片
 */

import Foundation
import AVFoundation
import HTLogs


@objc public class HTAuthCamera: NSObject {
    
    /// 请求摄像头权限
    @objc public static func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completion(true)
            case .denied, .restricted:
                completion(false)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            @unknown default:
                completion(false)
        }
    }
    
    
    /// 闪光灯是否打开 (只能检查闪光灯是否由当前App打开)
    @objc public static func flashIsOn() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            HTLogs.logWarning("当前设备不支持闪光灯")
            return false
        }
        
        do {
            try device.lockForConfiguration()
            let isActive = device.isTorchActive
            device.unlockForConfiguration()
            return isActive
        }
        catch {
            HTLogs.logWarning("当前设备闪光灯无法配置")
            return false
        }
    }
    
    /// 设置闪光灯 开/关
    @objc public static func flastSet(mode: AVCaptureDevice.TorchMode, level:Float = 1.0) -> Bool {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            HTLogs.logWarning("当前设备不支持闪光灯")
            return false
        }
        
        do {
            var could = false
            try device.lockForConfiguration()
            
            if device.isTorchModeSupported(mode) {
                device.torchMode = mode
                could = true
                if mode == .on {
                    try device.setTorchModeOn(level: level)
                }
            }
            
            device.unlockForConfiguration()
            
            return could
        }
        catch {
            HTLogs.logWarning("当前设备闪光灯无法配置")
            return false
        }
    }
    
    /// 获取默认后摄像头
    @objc public static func defaultBackCamera() -> AVCaptureDevice? {
        
        let desiredDeviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,       // 三摄
            .builtInDualWideCamera,     // 双广角
            .builtInDualCamera,         // 双摄
            .builtInWideAngleCamera     // 基本广角
        ]
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: desiredDeviceTypes, mediaType: .video, position: .back)
        
        return discoverySession.devices.first
    }
    
    /// 获取默认前摄像头
    @objc public static func defaultFronCamera() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [], mediaType: .video, position: .front)
        return discoverySession.devices.first
    }
    
    /// 是否是三摄像头
    @objc public static func isTripleCameraSupported() -> Bool {
        // 创建一个发现会话
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera], mediaType: .video, position: .back)
        
        // 检查是否有任何设备被发现。
        return !discoverySession.devices.isEmpty
    }
    
    /// 是否是双摄像头
    @objc public static func isDualCameraSupported() -> Bool {
        // 创建一个发现会话
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera], mediaType: .video, position: .back)
        
        // 检查是否有任何设备被发现。
        return !discoverySession.devices.isEmpty
    }
    
    /// 是否支持景深摄像头
    @objc public static func isTrueDepthSupported() -> Bool {
        // 创建一个发现会话
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera], mediaType: .video, position: .front)
        
        // 检查是否有任何设备被发现。
        return !discoverySession.devices.isEmpty
    }
}

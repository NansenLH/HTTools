//
//  Created by Nansen on 2025/7/19.
//

/**
 Info.plist 中添加描述
 在 Build Settings - Info.plist Values 中设置
 
 麦克风权限:
     Privacy - Microphone Usage Description
     NSMicrophoneUsageDescription
     请允许使用麦克风来录制音频
 */

import Foundation
import AVFoundation

@objc public class HTAuthMicro {
    
    /// 请求麦克风权限
    @objc public static func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        switch audioSession.recordPermission {
            case .undetermined:
                audioSession.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            case .denied:
                completion(false)
            case .granted:
                completion(true)
            @unknown default:
                completion(false)
        }
    }
    
}


//
//  HTAlertController.swift
//
//  Created by Nansen on 2025/8/14.
//

import Foundation
import UIKit
import HTLogs


public enum HTAlertScene {
    
    case tip(title: String, message: String?)
    
    case motion
    
    case auth(HTAuthDeny)
    
    public enum HTAuthDeny {
        case photos
        case camera
        case microphone
        case location
        case contact
        
        var message: String {
            let appName = HTTools.appName ?? "App"
            var authName = ""
            switch self {
                case .photos:
                    authName = "照片"
                case .camera:
                    authName = "相机"
                case .microphone:
                    authName = "麦克风"
                case .location:
                    authName = "位置"
                case .contact:
                    authName = "通讯录"
            }
            return """
                请允许"\(appName)"访问"\(authName)"权限!
                您可以点击"去设置"后将\(authName)对应权限打开.
                """
        }
    }
    
    var title: String {
        switch self {
            case .tip(let title, _):
                return title
            case .motion:
                return "切换环境"
            case .auth(let auth):
                return "提醒"
        }
    }
    
    var message: String {
        switch self {
            case .tip(_, let message):
                return message ?? ""
            case .motion:
                return "当前环境:App-"+HTDebugTool.shared.appMode.name+",小程序-"+HTDebugTool.shared.wxMiniMode.name
            case .auth(let auth):
                return auth.message
        }
    }
}

public class HTAlertController: UIAlertController {
    
    public static func alertScene(_ scene: HTAlertScene, onVC: UIViewController) {
      
        switch scene {
            case .motion:
                let sheetAlert = HTAlertController.init(title: scene.title, message: scene.message, preferredStyle: .actionSheet)
                
                let action1 = UIAlertAction(title: "App-开发", style: .default) { action in
                    HTDebugTool.shared.changeAppMode(.debug)
                }
                sheetAlert.addAction(action1)
                
                let action2 = UIAlertAction(title: "App-正式", style: .default) { action in
                    HTDebugTool.shared.changeAppMode(.release)
                }
                sheetAlert.addAction(action2)
                
                let action3 = UIAlertAction(title: "小程序-开发", style: .default) { action in
                    HTDebugTool.shared.changeWXMiniMode(.debug)
                }
                sheetAlert.addAction(action3)
                
                let action4 = UIAlertAction(title: "小程序-正式", style: .default) { action in
                    HTDebugTool.shared.changeWXMiniMode(.release)
                }
                sheetAlert.addAction(action4)
                
                let action5 = UIAlertAction(title: "日志", style: .default) { action in
                    HTLogs.showLogFile(in: onVC)
                }
                sheetAlert.addAction(action5)
                
                let cancel = UIAlertAction(title: "取消", style: .cancel)
                sheetAlert.addAction(cancel)
                
                onVC.present(sheetAlert, animated: true)
                
            case .auth(let auth):
                let alert = HTAlertController.init(title: scene.title, message: scene.message, preferredStyle: .alert)
                
                let cancelBtn = UIAlertAction(title: "稍后再说", style: .cancel)
                alert.addAction(cancelBtn)
                
                let setBtn = UIAlertAction(title: "去设置", style: .default) { action in
                    HTTools.openAppSetting()
                }
                
                onVC.present(alert, animated: true, completion: nil)
                
                
            case .tip(let title, let message):
                let alert = HTAlertController.init(title: title, message: message, preferredStyle: .alert)
                let cancelBtn = UIAlertAction(title: "知道了", style: .cancel)
                alert.addAction(cancelBtn)
                onVC.present(alert, animated: true)

        }
        
        
    } 
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    
}

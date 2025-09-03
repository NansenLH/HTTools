//
//  XSH_DebugTool.swift
//  SPMTestDemo
//
//  Created by Nansen on 2025/8/14.
//

import Foundation

let UDKey_AppMode: String = "AppDebugMode"
let UDKey_WXMode: String = "WxMiniMode"

public enum WXMiniMode: Int {
    
    case debug   = 0
    
    case release = 1
    
    case preview = 2
    
    var name: String {
        switch self {
            case .release:
                "正式"
            case .debug:
                "开发"
            case .preview:
                "体验"
        }
    }
}

public enum AppMode: Int {
    
    case debug   = 0
    
    case release = 1
    
    var name: String {
        switch self {
            case .debug:
                return "开发"
            case .release:
                return "正式"
        }
    }
}


public final class HTDebugTool {
    
    public static let shared = HTDebugTool()

    public var baseApi: String = ""
    public var debugApi: String = ""
    public var releaseApi: String = ""
    
    public var wxMiniMode: WXMiniMode = .debug
    
    public var appMode: AppMode = .release
    
    public func config(debugApi: String, releaseApi: String) {
        self.debugApi = debugApi
        self.releaseApi = releaseApi
        
        let miniModeUD = HTUserDefaultsTool.int(forKey: UDKey_WXMode)
        let appModeUD = HTUserDefaultsTool.int(forKey: UDKey_AppMode)
        
#if DEBUG
        self.appMode = AppMode(rawValue: appModeUD) ?? AppMode.debug
        self.wxMiniMode = WXMiniMode(rawValue: miniModeUD) ?? WXMiniMode.debug
        self.baseApi = (appMode == .debug) ? debugApi : releaseApi
#else
        self.appMode = .release
        self.wxMiniMode = .release
        self.baseApi = releaseApi
#endif
    }
    
    
    @MainActor public func changeWXMiniMode(_ mode: WXMiniMode) {
        if mode == wxMiniMode {
            return
        }
        
        wxMiniMode = mode
        HTUserDefaultsTool.set(mode.rawValue, forKey: UDKey_WXMode)
        
        if let topVC = HTTools.topViewController() {
            HTAlertController.alertScene(.tip(title: "小程序环境切换成功!", message: nil), onVC: topVC)    
        }
        
    }
    
    @MainActor public func changeAppMode(_ mode: AppMode) {
        
        if mode == appMode {
            if let topVC = HTTools.topViewController() {
                HTAlertController.alertScene(.tip(title: "当前已是\(appMode.name)环境,无需切换!", message: nil), onVC: topVC)    
            }
            return
        }
        
        HTUserDefaultsTool.clearAll()
        HTUserDefaultsTool.set(mode.rawValue, forKey: UDKey_AppMode)
        
        
        if let topVC = HTTools.topViewController() {
            HTAlertController.alertScene(.tip(title: "即将退出App", message: nil), onVC: topVC)    
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) { [weak self] in
            exit(0)
        }
    }
}

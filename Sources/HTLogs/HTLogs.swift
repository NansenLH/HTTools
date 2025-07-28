//
//  Created by Nansen on 2025/7/19.
//

import Foundation
import QuickLook
import UIKit
import SwiftyBeaver


public class HTLogs {
    
    public static let shared = HTLogs()
    
    private static var didConfig = false
    
    public static func appConfig(file: String = #file, function: String = #function, line: Int = #line) {
        
        if didConfig {
            return
        }
        
        didConfig = true
        
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? 
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        
        let log = SwiftyBeaver.self
        let console = ConsoleDestination()
        
        console.levelColor.debug    = "❇️"     
        console.levelColor.info     = "🌐"     
        console.levelColor.warning  = "⚠️"     
        console.levelColor.error    = "🚫"       
        
        console.levelString.debug   = "DEB"
        console.levelString.info    = "INF"
        console.levelString.warning = "WAR"
        console.levelString.error   = "ERR"
        
        
        
        let fileD = FileDestination()
        fileD.levelColor.debug    = "❇️"     
        fileD.levelColor.info     = "🌐"     
        fileD.levelColor.warning  = "⚠️"     
        fileD.levelColor.error    = "🚫"       
        
        fileD.levelString.debug     = "DEB"
        fileD.levelString.info      = "INF"
        fileD.levelString.warning   = "WAR"
        fileD.levelString.error     = "ERR"
        
        // 可选：设置日志格式（如颜色、时间戳）
        console.format = "\n[$L$C$C]$Dyyyy-MM-dd HH:mm:ss.SSS$d [\(appName)] $N.$F[$l]\n$M"
        fileD.format = "\n[$L$C$C]$Dyyyy-MM-dd HH:mm:ss.SSS$d [\(appName)] $N.$F[$l]\n$M"
        //        console.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c $N.$F:$l $M"
        //        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c $N.$F:$l $M"
        
#if DEBUG
        console.minLevel = .verbose
        fileD.minLevel = .verbose
#else
        console.minLevel = .info
        fileD.minLevel = .info
#endif
        
        log.addDestination(console)
        log.addDestination(fileD)   
        
        SwiftyBeaver.info("AppLogConfig", file: file, function: function, line: line)
    }
    
    /// [🐞🐞 DEB]
    public static func logDebug(_ message: @autoclosure () -> Any,
                                file: String = #file, function: String = #function, line: Int = #line) {
        SwiftyBeaver.debug(message(), file: file, function: function, line: line)
    }
    
    /// [🌐🌐 INF]
    public static func logInfo(_ message: @autoclosure () -> Any,
                               file: String = #file, function: String = #function, line: Int = #line) {
        SwiftyBeaver.info(message(), file: file, function: function, line: line)
    }
    
    /// [⚠️⚠️ WAR]
    public static func logWarning(_ message: @autoclosure () -> Any,
                                  file: String = #file, function: String = #function, line: Int = #line) {
        SwiftyBeaver.warning(message(), file: file, function: function, line: line)
    }
    
    /// [🚫🚫 ERR]
    public static func logError(_ message: @autoclosure () -> Any,
                                file: String = #file, function: String = #function, line: Int = #line) {
        SwiftyBeaver.error(message(), file: file, function: function, line: line)
    }
    
    /// 
    public static func logFatal(_ message: @autoclosure () -> Any,
                                file: String = #file, function: String = #function, line: Int = #line) {
        SwiftyBeaver.error(message(), file: file, function: function, line: line)
        
        #if DEBUG
        let value = message()
        if let str = value as? String {
            fatalError(str)    
        }
        else {
            fatalError()
        }
        #endif
    }
    
    private var logFileURL: URL? {
        guard let fileDestination = SwiftyBeaver.destinations.first(where: { $0 is FileDestination }) as? FileDestination, let url = fileDestination.logFileURL else {
            return nil
        }
        return url
    }
    
    public static func showLogFile(in viewController: UIViewController) {
        guard let url = self.shared.logFileURL, FileManager.default.fileExists(atPath: url.path) else {
            showAlert(message: "未找到日志文件", in: viewController)
            return
        } 
        
        let previewController = QLPreviewController()
        previewController.dataSource = self.shared
        viewController.present(previewController, animated: true)
    }
    
    // 辅助方法：显示提示
    private static func showAlert(message: String, in viewController: UIViewController) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        viewController.present(alert, animated: true)
    }
    
}

extension HTLogs: QLPreviewControllerDataSource {
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = logFileURL else {
            fatalError("日志文件 URL 无效")
        }
        return url as QLPreviewItem
    }
}

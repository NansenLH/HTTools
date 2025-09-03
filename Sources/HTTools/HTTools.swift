//
//  Created by Nansen on 2025/6/24.
//

import HTLogs
import UIKit
//import Network
import Security
import AdSupport

// MARK: - App相关
public class HTTools {
    
    public static var appBundleID: String? {
        return Bundle.main.bundleIdentifier
    }
    
    public static func appInit() {
        HTLogs.appConfig()
        //    SDWebImageDownloader.shared.setValue("image/webp,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
        
        HTTools.logDeviceInfo()
    }
    
    
    public static var appName: String? {
        
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
        
        //        if let bundleDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
        //            return bundleDisplayName
        //        } 
        //        else if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
        //            return bundleName
        //        }
        //        
        //        return nil
    }
    
    /// App版本号  1.0.0
    public static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    /// App版本号改成数字
    public static var appVersionInt: Int {
        if let v = appVersion {
            return Int(v.replacingOccurrences(of: ".", with: "")) ?? 0
        }
        return 0
    }
    
    /// App build号 1
    public static var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    
    public static var isDebug: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    public static var isSimulator: Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
    
#if !os(macOS)
    /// 是否沙盒测试环境. 主要用于在内购功能开发的时候区分环境
    public static var isInTestFlight: Bool {
        return Bundle.main.appStoreReceiptURL?.path.contains("sandboxReceipt") == true
    }
#endif
    
}

// MARK: - 系统硬件相关
extension HTTools {
    
    public static func logDeviceInfo() {
        let memory = self.deviceMemoryInfo()
        let ssd = self.deviceDiskSizeInfo()
        
        // 不要调用 UIDevice.current.name, 苹果在ios16之后严格限制, 除非获取了权限: User-Assigned Device Name Entitlement.
        let deviceInfo: String = """
            App 启动
            [\(self.deviceType)] : \(self.deviceVersion),
            \(self.appName ?? "New App") : \(self.appVersion ?? "1.0.0").\(self.appBuild ?? "0")
            Battery :\(self.deviceBatteryLevel()),
            RAM: \(memory.free.ht.byteDescription) / \(memory.total.ht.byteDescription),
            SSD: \(ssd.free.ht.byteDescription) / \(ssd.total.ht.byteDescription)
            """
        HTLogs.logInfo(deviceInfo)
    }
    
    /// 设备标识. 
    /// 类似 iPhone16,1 表示的事 iPhone15Pro 机型
    public static var deviceType: String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
        
        //        // 实现方式2
        //        var systemInfo = utsname()
        //        uname(&systemInfo)
        //        let machinePtr = withUnsafePointer(to: &systemInfo.machine) { 
        //            $0.withMemoryRebound(to: Int8.self, capacity: Int(_SYS_NAMELEN)) {
        //                $0
        //            }
        //        }
        //        return String(cString: machinePtr)
    }
    
    /// 设备类型
    public static var deviceTypeName: String {
        switch UIDevice.current.userInterfaceIdiom {
            case .unspecified:
                return "unknown"
            case .phone:
                return "iPhone"
            case .pad:
                return "iPad"
            case .tv:
                return "Apple TV"
            case .carPlay:
                return "CarPlay"
            case .mac:
                return "Mac"
            case .vision:
                return "Apple Vision"
            default:
                return "New Device"
        }
    }
    
    /// 设备地区.  
    /// 中国大陆对应的返回是: CN
    public static var deviceRegion: String? {
        return (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String
    }
    
    /// 系统版本
    public static var deviceVersion: String {
        return UIDevice.current.systemVersion
    }
    
    
#if os(iOS)
    /// 获取屏幕方向
    public static var screenOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?
                .interfaceOrientation ?? .unknown
        } 
        else {
            return UIApplication.shared.statusBarOrientation
        }
    }
#endif
    
    
    /// 获取电量 0~1.0
    public static func deviceBatteryLevel() -> Float {
        return UIDevice.current.batteryLevel
    }
    /// 是否正在充电
    public static func deviceIsCharging() -> Bool {
        switch UIDevice.current.batteryState {
            case .charging:
                return true
            default:
                return false
        }
    }
    
    
    
    /// 内存大小 (和 Xcode 不一致)
    public static func deviceMemoryInfo() -> (total:Int, free:Int, used:Int)  {
        
        var used: Int = 0
        let total: Int = Int(ProcessInfo.processInfo.physicalMemory)
        
        var host_port = mach_host_self()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.size / MemoryLayout<integer_t>.size)
        let pagesize: vm_size_t = vm_page_size
        
        var vm_stat = vm_statistics_data_t()
        
        let kern = withUnsafeMutablePointer(to: &vm_stat) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(host_port, HOST_VM_INFO, $0, &size)
            }
        }
        
        if kern != KERN_SUCCESS {
            HTLogs.logError("Error with host_statistics(): \(String(cString: mach_error_string(kern), encoding: String.Encoding.ascii) ?? "unknown error")")
        }
        else {
            // free_count 是空闲内存页数，active_count + inactive_count + wire_count 是已使用的内存页数
            let usedPages = vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count
            used = Int(usedPages) * Int(pagesize)
        }
        
        let free = total - used
        
        return (total, free, used)
    }

    
    /// App占用的内存大小 (和 Xcode 不一致
    public static func appMemoryUsed() -> Int {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)
        let kerr = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        let appUsed = kerr == KERN_SUCCESS ? Int(taskInfo.resident_size/4) : 0
        return appUsed
    }
    
    public static func appMemoryUsed2() -> Int {
        var usedBytes: Int = 0
        
        var taskInfo = task_basic_info()
        
        // task_info 使用的是 "integer_t" 单位，通常是 4 字节
        var size = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size) / 4
        let kernelReturn = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), $0, &size)
            }
        }
        if kernelReturn == KERN_SUCCESS {
            usedBytes = Int(taskInfo.resident_size)
        }
        else {
            let errorMsg = String(cString: mach_error_string(kernelReturn), encoding: .ascii) ?? "error"
            HTLogs.logWarning(errorMsg)
        }
        return usedBytes
    }
    
    /// 磁盘空间情况
    public static func deviceDiskSizeInfo() -> (total:Int, free:Int, used:Int) {
        do {
            let values = try URL(fileURLWithPath: NSHomeDirectory()).resourceValues(forKeys: [
                .volumeAvailableCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeAvailableCapacityForOpportunisticUsageKey,
                .volumeTotalCapacityKey
            ])
            
            let total = Int(values.volumeTotalCapacity ?? 0)
            let free = Int(values.volumeAvailableCapacity ?? 0)
            let used = total - free
            return (total, free, used)
            
        } 
        catch {
            print("获取存储信息错误: \(error.localizedDescription)")
            return (0, 0, 0)
        }
    }
    
    public static func getDeviceIdentityKeychain() async -> String {
        let keychainTool = HTKeychainManager()
        var identity = await keychainTool.getDeviceIdentifier()
        if identity.isEmpty {
            identity = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            if identity.isEmpty {
                identity = UUID().uuidString
            }
            await keychainTool.saveDeviceIdentifier(identity)
        }
        return identity
    }
}

// MARK: - 系统软件相关
extension HTTools {
    
    /// 拨打电话
    @MainActor
    public static func callTel(number: String) {
        if let url = URL(string: "tel:"+number), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// 浏览器打开链接
    @MainActor
    public static func safariOpenUrl(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// 打开App设置页面
    @MainActor
    public static func openAppSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// 获取粘贴板数据
    public static func getPasteboardString() -> String? {
        return UIPasteboard.general.string
    }
    
    /// 获取剪贴板文字
    public static func getPasteboardText() async -> String? {
        /**
         UIPasteboard.general.string 尽量放到异步线程中执行, 在主线程会一定几率卡死. 
         */
        return await Task.detached { 
            return UIPasteboard.general.string
        }.value
    }
    
    /// 复制到粘贴板
    public static func saveToPasteboard(str: String) {
        UIPasteboard.general.string = str
    }
    
    /// 获得根控制器
    @MainActor
    public static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first?.rootViewController
    }
    
    /// 获得最上层控制器
    @MainActor
    public static func topViewController() -> UIViewController? {
        guard let rootVC = rootViewController() else {
            return nil
        }
        return findTopVC(rootVC: rootVC)
    }
    @MainActor
    static func findTopVC(rootVC: UIViewController?) -> UIViewController? {
        if rootVC == nil {
            return nil
        }
        
        if let naviVC = rootVC as? UINavigationController {
            return findTopVC(rootVC: naviVC.visibleViewController)
        }
        if let tabVC = rootVC as? UITabBarController {
            if let selectVC = tabVC.selectedViewController {
                return findTopVC(rootVC: selectVC)    
            }
            else {
                return tabVC
            }
        }
        if let presented = rootVC?.presentedViewController {
            return findTopVC(rootVC: presented)
        }
        return rootVC
    }
}




actor HTKeychainManager {
    
    /// 钥匙串 服务名称
    private let service: String = "CreateDeviceIdentifierByKeychain"
    /// 钥匙串 账户名称
    private let account: String = "VirtualDeviceIdentifier"
    
    /// 从钥匙串中获取设备标识符
    func getDeviceIdentifier() async -> String {
        
        // 构建查询字典
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrSynchronizable as String: kCFBooleanFalse!,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        
        // 查询钥匙串
        var keychainPassword: CFTypeRef?
        let queryResult = SecItemCopyMatching(query as CFDictionary, &keychainPassword)
        
        if queryResult == errSecSuccess {
            if let data = keychainPassword as? Data {
                if let identifier = String(data: data, encoding: .utf8) {
                    if !identifier.isEmpty {
                        return identifier
                    } 
                    else {
                        // 数据为空，删除该项并重新创建
                        await deleteDeviceIdentifier()
                    }
                } 
                else {
                    // 数据不是字符串，删除该项并重新创建
                    await deleteDeviceIdentifier()
                }
            } 
            else {
                // keychainPassword 不是 Data 类型，删除该项并重新创建
                await deleteDeviceIdentifier()
            }
        }
        // 查询失败，返回空字符串（调用者需处理）
        return ""
    }
    
    /// 删除钥匙串中的设备标识符
    func deleteDeviceIdentifier() async {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(deleteQuery as CFDictionary)
        if status != errSecSuccess {
            HTLogs.logError("删除钥匙串项失败！错误码: \(status)")
        }
    }
    
    /// 将设备标识符保存到钥匙串中
    func saveDeviceIdentifier(_ identifier: String) async {
        guard !identifier.isEmpty else { return }
        
        let data = identifier.data(using: .utf8)!
        let createQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kCFBooleanFalse!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: data
        ]
        
        let createResult = SecItemAdd(createQuery as CFDictionary, nil)
        if createResult != errSecSuccess {
            HTLogs.logError("通过钥匙串创建设备唯一ID不成功！错误码: \(createResult)")
        }
    }
}











// MARK: - 不使用
extension HTTools {
    /// 电池监控通知 (否则不会更新电池数据)
    func openBatteryMonitor() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateChanged), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelChanged), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    func stopBatteryMonitor() {
        UIDevice.current.isBatteryMonitoringEnabled = false
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
    }
    @objc func batteryStateChanged() {
        let newState = UIDevice.current.batteryState
    }
    @objc func batteryLevelChanged() {
        let newLevel = UIDevice.current.batteryLevel
    }
}








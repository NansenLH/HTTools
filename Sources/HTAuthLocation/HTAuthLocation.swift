//
//  Created by Nansen on 2025/7/19.
//

/**
 Info.plist 中添加描述
 在 Build Settings - Info.plist Values 中设置
 
 通讯录权限:
    Privacy - Location Always Usage Description
    NSLocationAlwaysUsageDescription
    
 
    Privacy - Location When In Use Usage Description
    NSLocationWhenInUseUsageDescription
 
 
 是否精确定位
    如果您的 App 不需要精确定位,  可以直接在 info.plist 中添加 NSLocationDefaultAccuracyReduced 为 true 设置为默认请求大概位置。但是这样设置之后，即使用户想要为该 App 开启精确定位权限，也无法开启。
 
    但是如果 info.plist 中配置了 NSLocationTemporaryUsageDescriptionDictionary，则仍可以在没有精确定位权限的情况下申请临时的一次精确定位权限.
    这是一个字典, key-string. 每个 key 用来单独说明该临时申请的文案
 
    需要注意的是，当 App 在 Background 模式下，如果并未获得精确位置授权，那么 Beacon 及其他位置敏感功能都将受到限制。
 */

import Foundation
import CoreLocation
import MapKit
import Combine

import HTLogs

@objc public enum HTDaohangType: Int {
    case iPhone = 0
    case gaode = 1
    case baidu = 2
    case tecent = 3
    
    var name: String {
        switch self {
            case .iPhone:
                return "苹果地图"
            case .gaode:
                return "高德地图"
            case .baidu:
                return "百度地图"
            case .tecent:
                return "腾讯地图"
        }
    }
}

@objcMembers public class HTDaohangInfo: NSObject {

    public var mapType: HTDaohangType
    
    public var longitude: String
    public var latitude: String
    
    public var poiName: String?
    public var poiId: String?
    
    public init(mapType: HTDaohangType, longitude: String, latitude: String, poiName: String? = nil, poiId: String? = nil) {
        self.mapType = mapType
        self.longitude = longitude
        self.latitude = latitude
        self.poiName = poiName
        self.poiId = poiId
    }
}

@objcMembers public class HTAuthLocation: NSObject {
    
    public static let shared = HTAuthLocation()
    
    let manager: CLLocationManager = CLLocationManager()
    public private(set) var currentAccuracy: CLAccuracyAuthorization = .fullAccuracy
    public private(set) var currentStatus: CLAuthorizationStatus = .notDetermined
    
    public typealias authClosure = (_ permit: Bool) -> Void
    private var alwaysAgreeHandler: authClosure?
    private var whenInUseAgreeHandler: authClosure?
    private var isRequestAlways = false
    
    /// 当前的定位
    public private(set) var currentLocation: CLLocation? {
        didSet {
            if let l = currentLocation {
                HTLogs.logDebug("更新定位信息: 经度=\(l.coordinate.longitude), 纬度=\(l.coordinate.latitude), 高度=\(l.altitude)")
                locationPublisher.send(l)
            }
        }
    }
    
    public override init() {
        super.init()
        
        manager.delegate = self
        currentStatus = manager.authorizationStatus
        currentAccuracy = manager.accuracyAuthorization
    }
    
    /// 请求权限
    public func requestAlways(complete: @escaping authClosure) {
        guard CLLocationManager.locationServicesEnabled() else {
            complete(false)
            return
        }
        
        resetHandlers()
        
        currentStatus = manager.authorizationStatus
        switch currentStatus {
            case .notDetermined:
                alwaysAgreeHandler = complete
                isRequestAlways = true
                manager.requestAlwaysAuthorization()
            case .authorizedAlways:
                complete(true)
            default:
                complete(false)
        }
    }
    
    /// 请求权限
    public func requestWhenInUse(complete: @escaping authClosure) {
        guard CLLocationManager.locationServicesEnabled() else {
            complete(false)
            return
        }
        
        resetHandlers()
        
        currentStatus = manager.authorizationStatus
        switch currentStatus {
            case .notDetermined:
                whenInUseAgreeHandler = complete
                isRequestAlways = false
                manager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                complete(true)
            default:
                complete(false)
        }
    }
    
    /// 请求权限
    public func requestFullAccuracyWithKey(_ key: String, complete: @escaping authClosure) {
        guard CLLocationManager.locationServicesEnabled() else {
            complete(false)
            return
        }
        
        resetHandlers()
        
        var status = manager.authorizationStatus
        switch status {
            case .notDetermined:
                whenInUseAgreeHandler = complete
                isRequestAlways = false
                manager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                if manager.accuracyAuthorization == .fullAccuracy {
                    complete(true)
                }
                else {
                    manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: key) { error in
                        DispatchQueue.main.async {
                            if let err = error {
                                HTLogs.logError("请求定位权限(\(key)) 错误: \(err.localizedDescription)")
                                complete(false)
                            }
                            else {
                                complete(true)
                            }
                        }
                    }
                }
            default:
                complete(false)
        }
    }
    
    
    
    let locationPublisher = PassthroughSubject<CLLocation, Error>()
    /// 添加定位信息订阅者
    public func addLocationSubscribe(valueClosure: @escaping (CLLocation) -> Void, 
                                     failClosure: @escaping (String) -> Void) -> AnyCancellable {
        locationPublisher.sink(receiveCompletion: { completion in
            switch completion {
                case .finished:
                    
                case .failure(let error):
                    failClosure(error.localizedDescription)
            }
        }, receiveValue: valueClosure)
    }
    
    /// 获取定位
    public func getBestLocation() {
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.startUpdatingLocation()
    }
    
    
    func resetHandlers() {
        alwaysAgreeHandler = nil
        whenInUseAgreeHandler = nil
    }
    
}
extension HTAuthLocation: CLLocationManagerDelegate {
        
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        currentStatus = manager.authorizationStatus
        currentAccuracy = manager.accuracyAuthorization
        checkStatus(currentStatus)
    }
    
    func checkStatus(_ status: CLAuthorizationStatus) {
        switch status {
            case .denied, .restricted:
                DispatchQueue.main.async { [weak self] in
                    guard let ws = self else {
                        return
                    }
                    if ws.isRequestAlways {
                        ws.alwaysAgreeHandler?(false)
                    }
                    else {
                        ws.whenInUseAgreeHandler?(false)
                    }
                }
            case .authorizedAlways:
                DispatchQueue.main.async { [weak self] in
                    guard let ws = self else {
                        return
                    }
                    if ws.isRequestAlways {
                        ws.alwaysAgreeHandler?(true)
                    }
                    else {
                        ws.whenInUseAgreeHandler?(true)
                    }
                }
            case .authorizedWhenInUse:
                DispatchQueue.main.async { [weak self] in
                    guard let ws = self else {
                        return
                    }
                    if ws.isRequestAlways {
                        ws.alwaysAgreeHandler?(false)
                    }
                    else {
                        ws.whenInUseAgreeHandler?(true)
                    }
                }
            default:
                break
                
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
             
        currentLocation = location
        manager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        manager.stopUpdatingLocation()
        locationPublisher.send(completion: .failure(error))
    }
    
}

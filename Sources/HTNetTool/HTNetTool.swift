//
//  HTNetTool.swift
//  SPMTestDemo
//
//  Created by Nansen on 2025/7/26.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import CoreTelephony
import Network


public protocol HTNetProtocal: AnyObject {
    func netChanged(connected: Bool)
    func netInfoChanged()
}

public class HTNetTool {
    
    public static let shared = HTNetTool()
    
    /// 联网状态
    public var connectState: HTNetConnectState = HTNetConnectState()
    
    let monitor = NWPathMonitor()
    
    /// 启动网络状态监听
    public func startMonitor() {
        monitor.start(queue: DispatchQueue.global(qos: .background))
        monitor.pathUpdateHandler = { [weak self] path in
            guard let ws = self else { return }
            ws.connectState.update(with: path)
        }
    }
    
    /// 停止网络状态监听
    public func stopMonitor() {
        monitor.cancel()
    }
    
    public func addSubscribe(_ sub: HTNetProtocal) {
        subQueue.async {
            self.subscribes.add(sub)
        }
    }
    public func removeSubscribe(_ sub: HTNetProtocal) {
        subQueue.async {
            self.subscribes.remove(sub)
        }
    }
    
    
    
    init() {
        connectState.connectClosure = { [weak self] connect in
            guard let ws = self else { return }
            
            ws.subQueue.async {
                ws.subscribes.allObjects.forEach { sub in
                    if let obj = sub as? HTNetProtocal {
                        DispatchQueue.main.async {
                            obj.netChanged(connected: connect)
                        }
                    }
                } 
            }
                    
        }
        
        connectState.connectInfoClosure = { [weak self] in
            guard let ws = self else { return }
            
            ws.subQueue.async {
                ws.subscribes.allObjects.forEach { sub in
                    if let obj = sub as? HTNetProtocal {
                        DispatchQueue.main.async {
                            obj.netInfoChanged()
                        }
                    }
                }
            }
        }
    }
    
    private var subscribes = NSHashTable<AnyObject>.weakObjects()
    private let subQueue = DispatchQueue(label: "com.ht.nettool.subQueue")
    
}














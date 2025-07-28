//
//  HTNetConnectState.swift
//  SPMTestDemo
//
//  Created by Nansen on 2025/7/28.
//

import Foundation
import Network
import CoreTelephony

public class HTNetConnectState: CustomStringConvertible {
    
    /// 蜂窝网络支持: [4G (LTE), 5G (NR SA)] 这样的结果, 如果不支持,就为空[]
    public var celluars: [HTCelluarType] = []
    
    var connectClosure: ((Bool) -> Void)?
    /// 是否联网
    public var connected: Bool = false {
        didSet {
            if connected != oldValue {
                connectClosure?(connected)    
            }
        }
    }
    
    /// 无法联网原因
    public var unConnectReason: String = ""
    
    var connectInfoClosure: (()->Void)?
    /// 已联网的信息
    public var connectInfo: HTNetConnectInfo? = nil {
        didSet {
            
        }
    }
    
    public var description: String {
        var info = "\n------------------------------\n网络状态:\(connected ? "已联网" : "未联网")\n"
        if connected == false {
            info += "原因: \(unConnectReason)"
        }
        else if let connect = connectInfo {
            info += "蜂窝网络支持: "
            celluars.forEach { type in
                info += "[\(type.description)] "
            }
            info += "\n"
            info += "当前联网信息: " + connect.htDescription()
        }
        
        info += "\n------------------------------"
        return info
    }
    
    func update(with path: Network.NWPath) {
        
        switch path.status {
            case .satisfied:
                
                unConnectReason = ""
                
                getCelluarRadioTec()
                
                let connectInfo = HTNetConnectInfo()
                connectInfo.update(with: path)
                self.connectInfo = connectInfo
                
                connected = true
                
            case .unsatisfied:
                switch path.unsatisfiedReason {
                    case .notAvailable:
                        unConnectReason = "notAvailable"
                    case .cellularDenied:
                        unConnectReason = "cellularDenied"
                    case .wifiDenied:
                        unConnectReason = "wifiDenied"
                    case .localNetworkDenied:
                        unConnectReason = "localNetworkDenied"
                    case .vpnInactive:
                        unConnectReason = "vpnInactive"
                    default:
                        unConnectReason = "other"
                }
                connectInfo = nil
                
                connected = false
                
            case .requiresConnection:
                
                unConnectReason = "requiresConnection"
                connectInfo = nil
                
                connected = false
                
            default:
                unConnectReason = "other"
                connectInfo = nil
                
                connected = false
        }
    }
    
    /// 更新当前蜂窝网络支持的类型
    func getCelluarRadioTec() {
        /// iOS16 以后苹果禁用了 CTCarrier 并且无替代方案. 无法获取蜂窝网络运营商相关的信息.
        celluars.removeAll()
        let networkInfo = CTTelephonyNetworkInfo()
        guard let radios = networkInfo.serviceCurrentRadioAccessTechnology?.values, !radios.isEmpty else {
            return
        }
        
        for radioType in radios {
            switch radioType {
                case CTRadioAccessTechnologyGPRS:
                    self.celluars.append(._2G(type: .GPRS))
                case CTRadioAccessTechnologyEdge:
                    self.celluars.append(._2G(type: .EDGE))
                case CTRadioAccessTechnologyWCDMA:
                    self.celluars.append(._3G(type: .WCDMA))
                case CTRadioAccessTechnologyHSDPA:
                    self.celluars.append(._3G(type: .HSDPA))
                case CTRadioAccessTechnologyHSDPA:
                    self.celluars.append(._3G(type: .HSDPA))
                case CTRadioAccessTechnologyHSUPA:
                    self.celluars.append(._3G(type: .HSUPA))
                case CTRadioAccessTechnologyCDMA1x:
                    self.celluars.append(._3G(type: .CDMA1x))
                case CTRadioAccessTechnologyCDMAEVDORev0:
                    self.celluars.append(._3G(type: .CDMAEVDORev0))
                case CTRadioAccessTechnologyCDMAEVDORevA:
                    self.celluars.append(._3G(type: .CDMAEVDORevA))
                case CTRadioAccessTechnologyCDMAEVDORevB:
                    self.celluars.append(._3G(type: .CDMAEVDORevB))
                case CTRadioAccessTechnologyeHRPD:
                    self.celluars.append(._3G(type: .eHRPD))
                case CTRadioAccessTechnologyLTE:
                    self.celluars.append(._4G)
                case CTRadioAccessTechnologyNRNSA:
                    self.celluars.append(._5G(type: .NRNSA))
                case CTRadioAccessTechnologyNR:
                    self.celluars.append(._5G(type: .NR))
                default:
                    self.celluars.append(.undefined)
            }
        }
    }
}

public enum HTCelluarType: Equatable, CustomStringConvertible {
    
    case undefined
    case _2G(type: HTCellular2G)
    case _3G(type: HTCellular3G)
    case _4G
    case _5G(type: HTCelluar5G)
    
    public var description: String {
        switch self {
            case .undefined:
                return "?"
            case ._2G(let type):
                return type.description
            case ._3G(let type):
                return type.description
            case ._4G:
                return "4G (LTE)"
            case ._5G(let type):
                return type.description
        }
    }
    
    public enum HTCellular2G: CustomStringConvertible {
        case GPRS
        case EDGE
        
        public var description: String {
            switch self {
                case .GPRS:
                    "2G (GPRS)"
                case .EDGE:
                    "2G (EDGE)"
            }
        }
    } 
    
    public enum HTCellular3G: CustomStringConvertible {
        case WCDMA
        case HSDPA
        case HSUPA
        case CDMA1x
        case CDMAEVDORev0
        case CDMAEVDORevA
        case CDMAEVDORevB
        case eHRPD
        
        public var description: String {
            switch self {
                case .WCDMA:
                    "3G (WCDMA)"
                case .HSDPA:
                    "3G (HSDPA)"
                case .HSUPA:
                    "3G (HSUPA)"
                case .CDMA1x:
                    "2G/3G (CDMA1x)"
                case .CDMAEVDORev0:
                    "3G (EVDO Rev 0)"
                case .CDMAEVDORevA:
                    "3G (EVDO Rev A)"
                case .CDMAEVDORevB:
                    "3G (EVDO Rev B)"
                case .eHRPD:
                    "3G (eHRPD)"
            }
        }
    }
    
    public enum HTCelluar5G: CustomStringConvertible {
        case NRNSA
        case NR
        public var description: String {
            switch self {
                case .NRNSA:
                    "5G (NR NSA)"
                case .NR:
                    "5G (NR SA)"
            }
        }
    }
}

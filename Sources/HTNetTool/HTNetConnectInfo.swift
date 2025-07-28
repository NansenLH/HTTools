//
//  HTNetConnectInfo.swift
//  SPMTestDemo
//
//  Created by Nansen on 2025/7/28.
//

import Foundation
import Network

public class HTNetConnectInfo {
    
    /// 网络模式
    public var interfaceType: NWInterface.InterfaceType = .other
    
    /// 接口信息
    public var interfaceInfo: [NWInterface] = []
    
    /// 路由信息
    public var gatewayInfo: [NWEndpoint] = []
    
    public var localEndPointInfo: NWEndpoint? = nil
    
    public var remoteEndPointInfo: NWEndpoint? = nil
    
    /// 是否 ipv4
    public var ipv4: Bool = false
    public var ipv4Value: String = ""
    
    /// 是否 ipv6
    public var ipv6: Bool = false
    public var ipv6Value: String = ""
    
    /// 是否支持 DNS
    public var dns: Bool = false
    
    /// 是否为低数据模式
    public var isConstrained: Bool = false
    
    public var path: NWPath? = nil
    
    func update(with path: NWPath) {
        
        self.path = path
        
        if path.usesInterfaceType(.wifi) {
            interfaceType = .wifi
        }
        else if path.usesInterfaceType(.cellular) {
            interfaceType = .cellular
        }
        else if path.usesInterfaceType(.wiredEthernet) {
            interfaceType = .wiredEthernet
        }
        else if path.usesInterfaceType(.loopback) {
            interfaceType = .loopback
        }
        
        isConstrained = path.isConstrained
        ipv4 = path.supportsIPv4
        if ipv4 {
            ipv4Value = getIPAddress(isV4: true)
        }
        
        ipv6 = path.supportsIPv6
        if ipv6 {
            ipv6Value = getIPAddress(isV4: false)
        }
        
        dns = path.supportsDNS
        
        interfaceInfo = path.availableInterfaces
        gatewayInfo = path.gateways
        
        localEndPointInfo = path.localEndpoint
        remoteEndPointInfo = path.remoteEndpoint
    }
    
    func endPointDescription(endPoint: Network.NWEndpoint) -> String {
        var endPointStr = ""
        switch endPoint {
            case .hostPort(let host, let port):
                switch host {
                    case .name(let string, let nWInterface):
                        endPointStr += "hostPort: name=\(string), interface=" + (nWInterface?.debugDescription ?? "")
                    case .ipv4(let iPv4Address):
                        endPointStr += "hostPort: ipv4=" + iPv4Address.debugDescription
                    case .ipv6(let iPv6Address):
                        endPointStr += "hostPort: ipv6=" + iPv6Address.debugDescription
                    default:
                        endPointStr += "hostPort: other=" + endPoint.debugDescription
                }
                endPointStr += ", port=\(port.debugDescription)"
            case .service(let name, let type, let domain, let interface):
                endPointStr += "service: name=\(name), type=\(type), domain=\(domain), interface=\(interface?.debugDescription ?? "")"
            case .unix(let path):
                endPointStr += "unix: path=\(path)"
            case .url(let url):
                endPointStr += "url: url=\(url)"
            case .opaque( _):
                endPointStr += "opaque: \(endPoint.debugDescription)"
            default:
                endPointStr += "other: \(endPoint.debugDescription)"
        }
        return endPointStr
    }
    
    func htDescription() -> String {
        
        var str = "\(interfaceType.description)"
        if isConstrained {
            str += " [低数据模式]"
        }
        str += "\n"
        if ipv4 {
            str += "IPv4: \(ipv4Value)"
            str += "\n"
        }
        if ipv6 {
            str += "IPv6: \(ipv6Value)"
            str += "\n"
        }
        if dns {
            str += "Supports DNS"
            str += "\n"
        }
        
        if interfaceInfo.isEmpty == false {
            str += "interface: \n"
            interfaceInfo.forEach { interface in
//                str += "    \(interface.debugDescription)\n"
                str += "  \(interfaceDescription(interface: interface))\n"
            }
        }
        
        if gatewayInfo.isEmpty == false {
            str += "gateway: \n"
            gatewayInfo.forEach { gw in
                str += "  \(gw.debugDescription)\n"
            }
        }
        
        if let local = localEndPointInfo {
            str += "local: \(local.debugDescription)"
            str += "\n"
        }
        if let remote = remoteEndPointInfo {
            str += "remote: \(remote.debugDescription)"
            str += "\n"
        }
        
        if let p = path {
            str += "description: \(p.debugDescription)"    
        }
        
        return str
    }
    
    func getIPAddress(isV4: Bool) -> String {
        
        let iosCellular = "pdp_ip0"
        let iosWifi = "en0"
        let iosVPN = "utun0"
        let ipAddrV4 = "ipv4"
        let ipAddrV6 = "ipv6"
        
//        let searchArray = isV4 ?
//        [iosVPN + "/" + ipAddrV4, iosVPN + "/" + ipAddrV6, 
//         iosWifi + "/" + ipAddrV4, iosWifi + "/" + ipAddrV6, 
//         iosCellular + "/" + ipAddrV4, iosCellular + "/" + ipAddrV6] :
//        [iosVPN + "/" + ipAddrV6, iosVPN + "/" + ipAddrV4, 
//         iosWifi + "/" + ipAddrV6, iosWifi + "/" + ipAddrV4, 
//         iosCellular + "/" + ipAddrV6, iosCellular + "/" + ipAddrV4]
        let searchArray = isV4 ?
        [iosVPN + "/" + ipAddrV4,
         iosWifi + "/" + ipAddrV4,
         iosCellular + "/" + ipAddrV4] :
        [iosVPN + "/" + ipAddrV6, 
         iosWifi + "/" + ipAddrV6,
         iosCellular + "/" + ipAddrV6]
        
        
        let addresses = getIPAddr()
        
        var address: String?
        for key in searchArray {
            if let ip = addresses[key], isValidatIP(ipAddress: ip) {
                address = ip
                break
            }
        }
        
        let ip = address ?? "0.0.0.0"
        
        return ip
    }
    func getIPAddr() -> [String: String] {
        
        let ipAddrV4 = "ipv4"
        let ipAddrV6 = "ipv6"
        
        var addresses = [String: String]()
        
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else {
            return [:]
        }
        
        guard let interfacePtr = interfaces else {
            return [:]
        }
        
        var interface = interfacePtr
        while interface.pointee.ifa_next != nil {
            interface = interface.pointee.ifa_next
            
            let ifaName = String(cString: interface.pointee.ifa_name)
            let addr = interface.pointee.ifa_addr.pointee
            
            if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.pointee.ifa_addr, socklen_t(interface.pointee.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                
                let address = String(cString: hostname)
                
                if addr.sa_family == UInt8(AF_INET) {
                    addresses[ifaName + "/" + ipAddrV4] = address
                } else if addr.sa_family == UInt8(AF_INET6) {
                    addresses[ifaName + "/" + ipAddrV6] = address
                }
            }
        }
        
        freeifaddrs(interfaces)
        
        return addresses.isEmpty ? [:] : addresses
    }
    func isValidatIP(ipAddress: String) -> Bool {
        if ipAddress.isEmpty {
            return false
        }
        
        let urlRegEx = "^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\." +
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\." +
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\." +
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$"
        
        do {
            let regex = try NSRegularExpression(pattern: urlRegEx, options: [])
            let nsString = ipAddress as NSString
            let results = regex.matches(in: ipAddress, options: [], range: NSRange(location: 0, length: nsString.length))
            
            return results.count > 0
        } catch {
            return false
        }
    }
    
    
    func interfaceDescription(interface: NWInterface) -> String {
        
        var desc = "\(interface.name) [\(interface.type.description)]:\n"
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return desc }
        guard let firstAddr = ifaddr else { return desc }
        
        var address = ""
        
        var ptr: UnsafeMutablePointer? = firstAddr
        while ptr != nil {
            if let pp = ptr {
                defer { ptr = pp.pointee.ifa_next }    
                
                let currentInterfaceName = String(cString: pp.pointee.ifa_name)
                if currentInterfaceName == interface.name {
                    let addr = pp.pointee.ifa_addr.pointee
                    if addr.sa_family == UInt8(AF_INET) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(
                            pp.pointee.ifa_addr,
                            socklen_t(pp.pointee.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            0,
                            NI_NUMERICHOST
                        )
                        address = String(cString: hostname)
                        desc += "    IPv4: \(address)\n"
                    }
                    if addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(
                            pp.pointee.ifa_addr,
                            socklen_t(pp.pointee.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            0,
                            NI_NUMERICHOST
                        )
                        address = String(cString: hostname)
                        desc += "    IPv6: \(address)\n"
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        return desc
    }
    
}

extension NWInterface.InterfaceType: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
            case .other:
                return "other"
            case .wifi:
                return "wifi"
            case .cellular:
                return "cellular"
            case .wiredEthernet:
                return "wiredEthernet"
            case .loopback:
                return "loopback"
            @unknown default:
                return "undefine"
        }
    }
}

extension NWEndpoint {
    func htDescription() -> String {
        var endPointStr = ""
        switch self {
            case .hostPort(let host, let port):
                switch host {
                    case .name(let string, let nWInterface):
                        endPointStr += "hostPort: name=\(string), interface=" + (nWInterface?.debugDescription ?? "")
                    case .ipv4(let iPv4Address):
                        endPointStr += "hostPort: ipv4=" + iPv4Address.debugDescription
                    case .ipv6(let iPv6Address):
                        endPointStr += "hostPort: ipv6=" + iPv6Address.debugDescription
                    default:
                        endPointStr += "hostPort: other=" + self.debugDescription
                }
                endPointStr += ", port=\(port.debugDescription)"
            case .service(let name, let type, let domain, let interface):
                endPointStr += "service: name=\(name), type=\(type), domain=\(domain), interface=\(interface?.debugDescription ?? "")"
            case .unix(let path):
                endPointStr += "unix: path=\(path)"
            case .url(let url):
                endPointStr += "url: url=\(url)"
            case .opaque( _):
                endPointStr += "opaque: \(self.debugDescription)"
            default:
                endPointStr += "other: \(self.debugDescription)"
        }
        return endPointStr
    }
}

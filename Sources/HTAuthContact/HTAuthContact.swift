//
//  Created by Nansen on 2025/7/19.
//

/**
 Info.plist 中添加描述
 在 Build Settings - Info.plist Values 中设置
 
 通讯录权限:
    Privacy - Contacts Usage Description
    NSContactsUsageDescription
    请允许以方便填写资料
 */

import Foundation
import UIKit
import Contacts
import ContactsUI
import HTLogs

@objc public class HTContactInfo: NSObject {
    var name: String = ""
    
    var number: String?
    
    var state: String?
    var city: String?
    var district: String?
    var house: String?
    var fullAddress: String?
}

@objc public class HTAuthContact: NSObject, CNContactPickerDelegate {
    
    /// 请求通讯录权限
    @objc public static func requestAuth(completion: @escaping (Bool) -> Void) {
        
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .notDetermined {
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts) { granted, error in
                if let err = error {
                    HTLogs.logWarning("禁用通讯录. \(err.localizedDescription)")
                }
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
        else if status == .authorized {
            completion(true)
        }
        else {
            completion(false)
        }
        
    }
    
    /// 权限被拒的提醒文案
    @objc public static func alertText() -> String {
        "请前往设置中开启通讯录权限以继续使用该功能"
    }
    
    
    public static let shared = HTAuthContact()
    public typealias ChooseContactCompletion = (HTContactInfo?) -> Void
    private var completion: ChooseContactCompletion?
    
    /// 选择某个联系人
    @objc public static func chooseContact(from vc: UIViewController, complete: @escaping ChooseContactCompletion) {
        
        let obj = self.shared
        
        if obj.completion != nil {
            HTLogs.logFatal("不能同时操作选择联系人")
            return
        }
        
        obj.completion = complete
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = obj
        vc.present(contactPicker, animated: true, completion: nil)
    }

    // MARK: CNContactPickerDelegate
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let name = CNContactFormatter.string(from: contact, style: .fullName)
        var number: String? = nil
        if let phoneValue = contact.phoneNumbers.first?.value {
            number = phoneValue.stringValue
        }
        
        let contactInfo = HTContactInfo()
        contactInfo.name = name ?? ""
        contactInfo.number = number
        
        if let firstPostalAddress = contact.postalAddresses.first {
            contactInfo.state = firstPostalAddress.value.state
            contactInfo.city = firstPostalAddress.value.city
            
            let street = firstPostalAddress.value.street
            let components = street.components(separatedBy: "区")
            if components.count > 1 {
                contactInfo.district = components[0] + "区"
                contactInfo.house = components.dropFirst().joined(separator: "区")
            }
            else {
                contactInfo.house = street
            }
            
            contactInfo.fullAddress = (contactInfo.state ?? "") + (contactInfo.city ?? "") + (contactInfo.district ?? "") + (contactInfo.house ?? "")
        }
    
        completion?(contactInfo)
    }
    
    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        completion?(nil)
    }
    
}

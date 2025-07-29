//
//  Created by Nansen on 2025/7/19.
//


/**
 Info.plist 中添加描述
 在 Build Settings - Info.plist Values 中设置
 
 相册权限:
     Privacy - Photo Library Additions Usage Description
     请允许App保存图片到您的相册
 
     Privacy - Photo Library Usage Description
     请允许App访问您的相册以使用头像,店铺实景,二维码等图片
 */


import Foundation
import Photos
import PhotosUI
import HTLogs

@objc public enum HTAuthPhotosError: Int, Error {
    
    case forbidden = 30000
    case notSelectImages = 30001
    case convertImageFailed = 30002
    
    
    var domain: String {
        "HTError" 
    }
    
    public var code: Int {
        return self.rawValue
    }
    
    
    public var localizedDescription: String { 
        switch self {
            case .forbidden:
                return "请同意\"照片\"权限后再试"
            case .notSelectImages:
                return "未选择照片"
            case .convertImageFailed:
                return "相册获取图片失败"
        }
    }
}



@objc public class HTAuthPhotos: NSObject {
    
    /// 检查相册权限
    @objc public static func checkAuth(onlyAdd: Bool = false, complete: @escaping (Bool) -> Void) {
        let level = onlyAdd ? PHAccessLevel.addOnly : PHAccessLevel.readWrite
        let status = PHPhotoLibrary.authorizationStatus(for: level)
        switch status {
            case .authorized, .limited:
                complete(true)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: level) { newStatus in
                    DispatchQueue.main.async {
                        complete(newStatus == .authorized || newStatus == .limited)
                    }
                }
            case .denied, .restricted:
                complete(false)
            @unknown default:
                complete(false)
        }
    }
    
    /// 保存一个url图片到相册中
    public static func saveUrlImageToAlbum(imageUrl: URL, albumName: String? = nil, complete: @escaping (_ success: Bool, _ asset: PHAsset?, _ errorMsg: String?) -> Void) {
        
        checkAuth { authed in
            if !authed {
                complete(false, nil, HTAuthPhotosError.forbidden.localizedDescription)
                return
            }
            
            let taskConfig = URLSessionConfiguration.default
            taskConfig.timeoutIntervalForRequest = 5.0     // 单个请求超时
            taskConfig.timeoutIntervalForResource = 30.0    // 资源下载超时
            let session = URLSession(configuration: taskConfig)
            let task = session.dataTask(with: imageUrl) { data, response, error in
                DispatchQueue.main.async {
                    guard let imgData = data, let image = UIImage(data: imgData) else {
                        var msg = "图片下载失败"
                        if let errMsg = error?.localizedDescription {
                            msg = errMsg
                        }
                        complete(false, nil, msg)
                        return
                    }
                    canSaveImageToAlbum(image: image, albumName: albumName, complete: complete)
                }
            }
            task.resume()
        }
    }
    
    /// 保存图片到相册中
    public static func saveImageToAlbum(image: UIImage, albumName: String? = nil, complete: @escaping (_ success: Bool, _ asset: PHAsset?, _ errorMsg: String?) -> Void) {
        
        checkAuth { authed in
            if !authed {
                HTLogs.logWarning("用户未开启相册权限")
                complete(false, nil, HTAuthPhotosError.forbidden.localizedDescription)
                return
            }
            canSaveImageToAlbum(image: image, albumName: albumName, complete: complete)
        }
    }
    
    /// 有相册权限后, 保存图片
    static func canSaveImageToAlbum(image: UIImage, albumName: String? = nil, complete: @escaping (_ success: Bool, _ asset: PHAsset?, _ errorMsg: String?) -> Void) {
        
        DispatchQueue.global(qos:.default).async {
            
            var assetCollection: PHAssetCollection? = nil
            if let albumName = albumName {
                assetCollection = getCustomAlbumCollection(albumName: albumName)
            }
            
            var assetId: String?
            PHPhotoLibrary.shared().performChanges { 
                let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = result.placeholderForCreatedAsset
                assetId = assetPlaceholder?.localIdentifier
                if let addCollection = assetCollection {
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: addCollection)
                    albumChangeRequest!.addAssets([assetPlaceholder!] as NSArray)
                }
            } completionHandler: { (success: Bool, error: Error?) in
                DispatchQueue.main.async {
                    if success, let localId = assetId, let asset = getAssetById(localId) {
                        complete(true, asset, nil)
                    }
                    else {
                        HTLogs.logError("保存图片到相册失败")
                        complete(false, nil, error?.localizedDescription ?? "保存相册失败!")
                    }
                }   
            }
            
        }
    }
    
    /// 自定义相册
    static func getCustomAlbumCollection(albumName: String) -> PHAssetCollection? {
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        for i in 0..<fetchResult.count {
            let collection: PHAssetCollection = fetchResult[i]
            if collection.localizedTitle == albumName {
                return collection
            }
        }
        
        var albumId: String?
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                albumId = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName).placeholderForCreatedAssetCollection.localIdentifier
            }
        } catch let error as NSError {
            HTLogs.logError("创建自定义相册[\(albumName)]失败, error=\(error.localizedDescription)")
            return nil
        }
        
        if let collectionId = albumId {
            let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [collectionId], options: nil)
            return result.firstObject
        }
        else {
            HTLogs.logError("创建自定义相册[\(albumName)]失败!!!!")
            return nil
        }
    }
    
    /// 获取指定对象
    public static func getAssetById(_ localIdentifier: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        return result.firstObject
    }
    
    
    /// 从相册选择图片
    public static let shared = HTAuthPhotos()
    public typealias ChooseImageCompletion = (Result<[UIImage], Error>) -> Void
    private var completion: ChooseImageCompletion?
    public static func chooseAlbumImage(maxCount: Int = 1, fromVC: UIViewController, completion: @escaping ChooseImageCompletion) {
        
        let obj = self.shared
        
        if obj.completion != nil {
            HTLogs.logFatal("不能同时操作选择照片")
            return
        }
        
        obj.completion = completion
        
        DispatchQueue.main.async {
            
            var chooseConfig = PHPickerConfiguration()
            chooseConfig.filter = .images
            chooseConfig.selectionLimit = maxCount
            
            let picker = PHPickerViewController(configuration: chooseConfig)
            picker.delegate = obj
            fromVC.present(picker, animated: true)
        }
        
    }
}

extension HTAuthPhotos: PHPickerViewControllerDelegate {
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        if results.isEmpty {
            completion?(.failure(HTAuthPhotosError.notSelectImages))
            completion = nil
            return
        }
        
        var imageDict = [Int: UIImage]()
        let dispatchGroup = DispatchGroup()
        var lastError: Error?
        
        for (index, result) in results.enumerated() {
            
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                defer {
                    dispatchGroup.leave()
                }
                
                if let error = error {
                    lastError = error
                    return
                }
                
                if let image = object as? UIImage {
                    imageDict[index] = image
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in 
            
            guard let weakS = self else {
                return
            }
            
            if let error = lastError {
                weakS.completion?(.failure(error))
            }
            else if imageDict.isEmpty {
                weakS.completion?(.failure(HTAuthPhotosError.convertImageFailed))
            }
            else {
                let images = results.indices.compactMap { imageDict[$0] }
                weakS.completion?(.success(images))
            }
            
            weakS.completion = nil
        }
    }
}

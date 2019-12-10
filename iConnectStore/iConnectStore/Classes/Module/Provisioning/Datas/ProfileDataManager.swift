//
//  ProfileDataManager.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/4.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Foundation
import PromiseKit

class ProfileDataManager: ConnectDataManager {
    
    func listRegisterdDevices() -> Promise<[Device]> {
        
        let p = Promise<[Device]> { resolver in
            
            let endpoint = APIEndpoint.listDevices(
                fields: [.devices([.addedDate, .udid, .deviceClass, .model, .name, .platform, .status])],
                limit: 100,
                sort: [.udidAscending])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let devicesResponse):
                    let devices = devicesResponse.data as [Device]
                    resolver.fulfill(devices)
                    for device in devices.sorted(by: { $0.attributes!.addedDate! > $1.attributes!.addedDate! }) {
                        print("device - \(device.attributes!.name!): \(device.attributes!.udid!)")
                    }
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong list the registerd devices: \(error)")
                }
            }
        }
        
        return p
    }
    
    func registerdNewDevices(names:[String], udids: [String], platform: Platform) -> Promise<[Device]> {
        
        print("register new devices: \(udids)")
        let p = Promise<[Device]> { resolver in
            
            if udids.count == 0 {
                resolver.fulfill([])
                return
            }
            
            // 创建调度组
            let workingGroup = DispatchGroup()
            let workingQueue = DispatchQueue(label: "request_register_device")
            var register_devices: [Device] = []
            
            var i = 0
            for udid in udids {
                
                workingGroup.enter()
                workingQueue.async {
                    
                    let endpoint = APIEndpoint.registerNewDevice(name: names[i], udid: udid, platform: platform.rawValue)
                    self.provider!.request(endpoint) {
                        switch $0 {
                        case .success(let deviceResponse):
                            let device = deviceResponse.data
                            register_devices.append(device)
                        case .failure(let error):
                            resolver.reject(error)
                        }
                        // 出组
                        workingGroup.leave()
                    }
                    
                    i += 1
                }
            }
            
            // 调度组里的任务都执行完毕
            workingGroup.notify(queue: workingQueue) {
                resolver.fulfill(register_devices)
            }
        }
        
        return p
    }
    
    func updateDevice(id: String,  name: String, status: DeviceStatus) -> Promise<Device> {
        
        let p = Promise<Device> { resolver in
            
            let endpoint = APIEndpoint.modifyRegisteredDevice(id: id, name: name, status: status)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let response):
                    let device: Device = response.data
                    resolver.fulfill(device)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func listBundles() -> Promise<[BundleId]> {
        
        let p = Promise<[BundleId]> { resolver in
            
            let endpoint = APIEndpoint.bundleIds(fields: [.bundleIds([.bundleIdCapabilities, .identifier, .name, .platform, .profiles, .seedId]), .profiles([.bundleId, .certificates, .createdDate, .devices, .expirationDate, .name, .platform, .profileContent, .profileState, .profileType, .uuid]), .bundleIdCapabilities([.bundleId, .capabilityType, .settings])])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let bundleIdResponse):
                    let bundleIds = bundleIdResponse.data
                    resolver.fulfill(bundleIds)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func creatBundleId(id: String, name: String, platform: Platform) -> Promise<BundleId> {
        
        let p = Promise<BundleId> { resolver in
            
            let endpoint = APIEndpoint.register(bundle_id: id, name: name, platform: platform)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let bundleIdResponse):
                    let bundleId: BundleId = bundleIdResponse.data
                    resolver.fulfill(bundleId)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func updateBundleId(id: String, new_name: String) -> Promise<BundleId> {
        
        let p = Promise<BundleId> { resolver in
            
            let endpoint = APIEndpoint.modifyBundleID(id: id, new_name: new_name)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let bundleIdResponse):
                    let bundleId: BundleId = bundleIdResponse.data
                    resolver.fulfill(bundleId)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    
    func listAllCertificates() -> Promise<[Certificate]> {
        
        let p = Promise<[Certificate]> { resolver in
            
            let endpoint = APIEndpoint.listAndDownloadCertificates()
            provider!.request(endpoint) {
                switch $0 {
                case .success(let certificatesResponse):
                    let certificates = certificatesResponse.data
                    resolver.fulfill(certificates)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func creatCertificate(CSRPath: String, cerType: CertificateType) -> Promise<Certificate> {
        
        let p = Promise<Certificate> { resolver in
            
            var CSR_Data: Data?
            do {
                CSR_Data = try Data.init(contentsOf: URL.init(fileURLWithPath: CSRPath))
            } catch let error as NSError {
                resolver.reject(error)
            }
            guard let CSRData = CSR_Data else {
                let error = NSError.init(domain: "failed read data from CSR", code: 0, userInfo: nil)
                resolver.reject(error)
                return
            }
            
            guard let csrContent = String.init(data: CSRData, encoding: .utf8) else {
                let error = NSError.init(domain: "failed creat certificate", code: 0, userInfo: nil)
                resolver.reject(error)
                return
            }
            
            //name: "Created via API"
            let endpoint = APIEndpoint.creatCertificate(certificateType: cerType, csrContent: csrContent)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let certificateResponse):
                    let  certificate = certificateResponse.data
                    resolver.fulfill( certificate)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    
    func listAllProfiles() -> Promise<[Profile]> {
        
        let p = Promise<[Profile]> { resolver in
            
            let endpoint = APIEndpoint.listAndDownloadProfiles(fields: [.profiles([.bundleId, .certificates, .createdDate, .devices, .expirationDate, .name, .platform, .profileContent, .profileState, .profileType, .uuid]), .certificates([.certificateContent, .certificateType, .csrContent, .displayName, .expirationDate, .name, .platform, .serialNumber]), .devices([.addedDate, .deviceClass, .model, .name, .platform, .status, .udid])], include:[.devices])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let profilesResponse):
                    let profiles = profilesResponse.data
                    resolver.fulfill(profiles)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func creatProvisionFile(name : String,
                            bundleId : String,
                            profileType: String,
                            certificates : [String],
                            devices : [String]) -> Promise<Profile> {
        
        let p = Promise<Profile> { resolver in
            
            let endpoint = APIEndpoint.creatProfile(name: name, profileType: profileType, bundle_id: bundleId, certificates: certificates, devices: devices)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let profileResponse):
                    let profile = profileResponse.data
                    resolver.fulfill(profile)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func deleteProvisionFile(id : String) -> Promise<Bool> {
        
        let p = Promise<Bool> { resolver in
            
            let endpoint = APIEndpoint.deleteProfile(id: id)
            provider!.request(endpoint) {
                switch $0 {
                case .success(_):
                    resolver.fulfill(true)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func deleteCertificate(id : String) -> Promise<Bool> {
        
        let p = Promise<Bool> { resolver in
            
            let endpoint = APIEndpoint.revokeCertificate(id: id)
            provider!.request(endpoint) {
                switch $0 {
                case .success(_):
                    resolver.fulfill(true)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func deleteBundle(id : String) -> Promise<Bool> {
        
        let p = Promise<Bool> { resolver in
            
            let endpoint = APIEndpoint.delete(id: id)
            provider!.request(endpoint) {
                switch $0 {
                case .success(_):
                    resolver.fulfill(true)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    func downloadCertificate(certificate: Certificate, save_name: String, complete:@escaping (Bool, String?)->(Void)) {

        self.choosePath(fileType: "", can_directory: true, can_file: false, message: "Please choose a directory to save .cer").then { (path) -> Promise<String> in
            let cerContent = certificate.attributes?.certificateContent
            return self.saveFileWithContent(cerContent, filePath: path.stringByAppendingPathComponent(save_name+".cer"))
        }.done { (save_path) in
            complete(true, save_path)
        }.catch { (error) in
            complete(false, nil)
        }
    }
    
    func downloadProfile(profile: Profile, save_name: String, complete:@escaping (Bool, String?)->(Void)){
        self.choosePath(fileType: "", can_directory: true, can_file: false, message: "Please choose a directory to save .mobilePrividsion").then { (path) -> Promise<String> in
            let cerContent = profile.attributes?.profileContent
            return self.saveFileWithContent(cerContent, filePath: path.stringByAppendingPathComponent(save_name+".mobileprovision"))
        }.done { (save_path) in
            complete(true, save_path)
        }.catch { (error) in
            complete(false, nil)
        }
    }
    
    //echo content | base64 -D > fileName
    private func saveFileWithContent(_ content: String?, filePath:String) -> Promise<String> {
        
        let p = Promise<String> { resolver in
            
            guard content != nil else {
                
                let def_error = NSError.init(domain: "failed download certificate", code: 0, userInfo: nil)
                resolver.reject(def_error)
                return
            }
            guard let data = NSData.init(base64Encoded: content!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else {
                let def_error = NSError.init(domain: "failed download certificate", code: 0, userInfo: nil)
                resolver.reject(def_error)
                return
            }
            data.write(to: URL.init(fileURLWithPath: filePath), atomically: false)
            
            //导入证书 security add-certificates
            if filePath.hasSuffix(".cer") {
                
                let _ = Process().execute("/usr/bin/security", workingDirectory: nil, arguments: ["add-certificates",filePath])
                resolver.fulfill(filePath)
                
            } else {
                
                let fileManager = FileManager()
                if let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
                    let provisioningProfilesPath = libraryDirectory.path.stringByAppendingPathComponent("MobileDevice/Provisioning Profiles") as NSString
                    let destinationPath = provisioningProfilesPath.appendingPathComponent(filePath.lastPathComponent)
                    if fileManager.fileExists(atPath: destinationPath) {
                        try? fileManager.removeItem(atPath: destinationPath)
                    }
                    do {
                        try fileManager.copyItem(atPath: filePath, toPath: destinationPath)
                    } catch {
                        
                    }
                }
                
                resolver.fulfill(filePath)
            }
        }
        
        return p
    }
    
    func choosePath(fileType: String, can_directory: Bool, can_file: Bool, message: String) -> Promise<String> {
        
        let p = Promise<String> { resolver in
            
            let openDialog = NSOpenPanel()
            openDialog.canChooseFiles = can_file
            openDialog.canChooseDirectories = can_directory
            openDialog.allowsMultipleSelection = false
            openDialog.allowsOtherFileTypes = false
            openDialog.allowedFileTypes = [fileType] //["certSigningRequest"]
            openDialog.message = message//"Choose .certSigningRequest(Only need once，form Keychain-assistant）"
            openDialog.title = "Please Choose"
            openDialog.runModal()
            if let filename = openDialog.urls.first {
                resolver.fulfill(filename.path)
            } else {
                let error = NSError.init(domain: "Choose failed", code: 0, userInfo: nil)
                resolver.reject(error)
            }
            
        }
        
        return p
    }
}

//
//  ProfileDataManager.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/4.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Foundation
import PromiseKit

struct ProfileDataManager {
    
    private var configuration: APIConfiguration?
    private var provider: APIProvider?
    
    init() {
        let issuer = UserDefaults.standard.value(forKey: "issuerId"), key = UserDefaults.standard.value(forKey: "privateKey"),keyId = UserDefaults.standard.value(forKey: "privateKeyId")
        if issuer == nil || key == nil || keyId == nil{
            
            let alert = NSAlert.init()
            alert.messageText = "Error!"
            alert.informativeText = "login failed, please goto Setting to input your keys"
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
            return
        }
        configuration = APIConfiguration(issuerID: issuer as! String, privateKeyID: keyId as! String, privateKey: key as! String)
        provider = APIProvider(configuration: configuration!)
    }

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
    
    func registerdNewDevices(udids: [String], platform: Platform) -> Promise<[Device]> {
        
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
            
            for udid in udids {
                
                workingGroup.enter()
                workingQueue.async {
                    
                    let endpoint = APIEndpoint.registerNewDevice(name: udid, udid: udid, platform: platform.rawValue)
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
                }
            }
            
            // 调度组里的任务都执行完毕
            workingGroup.notify(queue: workingQueue) {
                resolver.fulfill(register_devices)
            }
        }
        
        return p
    }
    
    func listBundles() -> Promise<[BundleId]> {
        
        let p = Promise<[BundleId]> { resolver in
            
            let endpoint = APIEndpoint.bundleIds(fields: [.bundleIds([.bundleIdCapabilities, .identifier, .name, .platform, .profiles, .seedId]), .profiles([.bundleId, .certificates, .createdDate, .devices, .expirationDate, .name, .platform, .profileContent, .profileState, .profileType, .uuid])])
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
    
    func creatBundleId(id: String, name: String) -> Promise<BundleId> {
        
        let p = Promise<BundleId> { resolver in
            
            let endpoint = APIEndpoint.register(bundle_id: id, name: name, platform: .ios)
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
    
    func creatCertificate(CSRPath: String) -> Promise<Certificate> {
        
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
            let endpoint = APIEndpoint.creatCertificate(certificateType: .ios_development, csrContent: csrContent)
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
            
            let endpoint = APIEndpoint.listAndDownloadProfiles(fields: [.profiles([.bundleId, .certificates, .createdDate, .devices, .expirationDate, .name, .platform, .profileContent, .profileState, .profileType, .uuid]), .certificates([.certificateContent, .certificateType, .csrContent, .displayName, .expirationDate, .name, .platform, .serialNumber])])
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
                                    certificates : [String],
                                    devices : [String]) -> Promise<Profile> {
        
        let p = Promise<Profile> { resolver in
            
            let endpoint = APIEndpoint.creatProfile(name: name, profileType: ProfileType.ios_development.rawValue, bundle_id: bundleId, certificates: certificates, devices: devices)
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
}

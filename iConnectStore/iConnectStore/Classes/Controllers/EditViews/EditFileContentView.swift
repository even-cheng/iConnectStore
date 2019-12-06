//
//  EditFileContentView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/5.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa

class EditFileContentView: NSView {
    
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var doneButton: NSButton!

    open var fileType:FileType? {
        didSet {
            self.addViews()
        }
    }
    open var edit_profile: Profile?
    open var edit_bundleID: BundleId?
    open var edit_device: Device?
    
    open var bundleIDs: [BundleId]?
    open var devices: [Device]?
    open var certificates: [Certificate]?

    private lazy var editCertificateView: EditCertificateView = {
        
        let editView = self.viewForXIB(class_name: "EditCertificateView") as! EditCertificateView
        return editView
    }()
    
    private lazy var editBundleIDView: EditBundleIDView = {
        
        let editView = self.viewForXIB(class_name: "EditBundleIDView") as! EditBundleIDView
        return editView
    }()
    
    private lazy var editDeviceView: EditDeviceView = {
        
        let editView = self.viewForXIB(class_name: "EditDeviceView") as! EditDeviceView
        return editView
    }()
    
    private lazy var editProfileView: EditProfileView = {
        
        let editView = self.viewForXIB(class_name: "EditProfileView") as! EditProfileView
        return editView
    }()
    
    private func viewForXIB(class_name: String) -> NSView?{
        
        let xib = NSNib.init(nibNamed: class_name, bundle: nil)
        var views: NSArray?
        xib!.instantiate(withOwner: nil, topLevelObjects: &views)
        for view in views! {
            if let editView = view as? NSView {
                return editView
            }
        }
        return nil
    }

        
    //MARK: Functions
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func addViews() {

        switch fileType {
        case .certificate?:
            self.titleField.stringValue = "Add Certificate"
            if self.editCertificateView.superview == nil {
                self.addSubview(self.editCertificateView)
                self.editCertificateView.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self)
                }
            }
            
        case .bundleId?:
            if self.editBundleIDView.superview == nil {
                self.addSubview(self.editBundleIDView)
                self.editBundleIDView.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self)
                }
            }
            if self.edit_bundleID == nil {
                self.titleField.stringValue = "Add BundleID"
                self.editBundleIDView.clear()
            } else {
                self.titleField.stringValue = "Edit BundleID"
                self.editBundleIDView.bundleID = self.edit_bundleID
            }
           
        case .device?:
            if self.editDeviceView.superview == nil {
                self.addSubview(self.editDeviceView)
                self.editDeviceView.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self)
                }
            }
            if self.edit_device == nil {
                self.titleField.stringValue = "Add Device"
                self.editDeviceView.clear()
            } else {
                self.titleField.stringValue = "Edit Device"
                self.editDeviceView.device = self.edit_device
            }

        case .profile?:
            if self.editProfileView.superview == nil {
                self.addSubview(self.editProfileView)
                self.editProfileView.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self)
                }
            }
            if self.edit_profile == nil {
                self.titleField.stringValue = "Add Profile"
                self.editProfileView.clear()
            } else {
                self.titleField.stringValue = "Edit Profile"
                self.editProfileView.profile = self.edit_profile
                self.editProfileView.devices = self.devices
                self.editProfileView.certificates = self.certificates
                self.editProfileView.bundleIDs = self.bundleIDs
            }
        case .none: break
        }
        
        self.editCertificateView.isHidden = (fileType != .certificate)
        self.editBundleIDView.isHidden = (fileType != .bundleId)
        self.editDeviceView.isHidden = (fileType != .device)
        self.editProfileView.isHidden = (fileType != .profile)
    }
    
    @IBAction func DoneAction(_ sender: NSButton) {
        
        self.upldateOrCreat { (res) -> (Void) in
            if res == true {
                self.isHidden = true
                self.edit_bundleID = nil
                self.edit_device = nil
                self.edit_profile = nil
                self.bundleIDs = nil
                self.devices = nil
                self.certificates = nil
                self.editCertificateView.clear()
                self.editBundleIDView.clear()
                self.editDeviceView.clear()
                self.editProfileView.clear()
            }
        }
    }
    
    private func upldateOrCreat(complete: @escaping (Bool)->(Void)) {
        
        switch fileType {
        case .certificate?:
            //add cer
            guard let CSR_path = self.editCertificateView.CSRFile_path else {
                return
            }
            guard let selectTitle = self.editCertificateView.SelectCerTypeButton.selectedItem?.title else {
                return
            }
            ProfileDataManager().creatCertificate(CSRPath: CSR_path, cerType: CertificateType(rawValue: selectTitle)!).done { (cer) in
                complete(true)
            }.catch { (Error) in
                print(Error)
                complete(false)
            }
            
        case .bundleId?:
            
            if self.edit_bundleID == nil {
                //add bundleID
                let bundle_id = self.editBundleIDView.bundleIDField.stringValue
                let name = self.editBundleIDView.nameField.stringValue
                guard let selectPlatform = self.editBundleIDView.platformButton.selectedItem?.title else {
                    return
                }
                guard bundle_id.count*name.count > 0 else {return}
                ProfileDataManager().creatBundleId(id: bundle_id, name: name, platform: Platform(rawValue: selectPlatform)!).done { (bundleID) in
                    complete(true)
                }.catch { (Error) in
                    print(Error)
                    complete(false)
                }

            } else {
                //update bundleID
            }
            
        case .device?:
            if self.edit_device == nil {
                // Add Device
                let udids = self.editDeviceView.UDIDField.stringValue.components(separatedBy: "&")
                let names = self.editDeviceView.nameField.stringValue.components(separatedBy: "&")
                guard let selectPlatform = self.editDeviceView.platformButton.selectedItem?.title else {
                    return
                }
                guard udids.count == names.count && udids.count != 0 else {return}
                ProfileDataManager().registerdNewDevices(names:names ,udids: udids, platform: Platform(rawValue: selectPlatform)!).done { (devices) in
                    complete(true)
                }.catch { (Error) in
                    print(Error)
                    complete(false)
                }
                
            } else {
                // update Device
                
            }
            
        case .profile?:
            if self.edit_profile == nil {
                // Add Profile
                let name = self.editProfileView.nameField.stringValue
                guard let selectBundleID = self.editProfileView.selectBundleButton.selectedItem?.title else {
                    return
                }
                guard let selectProfileType = self.editProfileView.selectProfileTypeButton.selectedItem?.title else {
                    return
                }
                guard let selectDevices = self.editProfileView.devices else {
                    return
                }
                guard let selectCertificates = self.editProfileView.certificates else {
                    return
                }
                guard selectDevices.count*selectCertificates.count != 0 else {return}
                var device_ids: [String] = []
                for device in selectDevices {
                    device_ids.append(device.id)
                }
                var certificate_ids: [String] = []
                for cer in selectCertificates {
                    certificate_ids.append(cer.id)
                }
                ProfileDataManager().creatProvisionFile(name: name, bundleId: selectBundleID, profileType:selectProfileType, certificates: certificate_ids, devices: device_ids).done { (devices) in
                    complete(true)
                }.catch { (Error) in
                    print(Error)
                    complete(false)
                }

            } else {
                // update Profile
               
            }
        case .none: break
        }
    }
}

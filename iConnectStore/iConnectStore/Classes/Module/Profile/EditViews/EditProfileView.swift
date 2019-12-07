
//
//  EditProfileView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/6.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//
import Cocoa

class EditProfileView: NSView {
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var selectBundleButton: NSPopUpButton!
    @IBOutlet weak var selectProfileTypeButton: NSPopUpButton!
    @IBOutlet weak var selectDevicesField: NSTextField!
    @IBOutlet weak var selectCertificatesField: NSTextField!
    
    open var selectDevices: [Device]?
    open var selectCertificates: [Certificate]?
    
    open var profile: Profile? {
        didSet{
            self.nameField.stringValue = profile?.attributes?.name ?? ""
        }
    }
    
    open var devices: [Device]? {
        didSet{
            self.selectDevicesField.stringValue = "\(devices?.count ?? 0) devices"
            selectDevices = devices
            self.resetDatas()
        }
    }
    
    open var certificates: [Certificate]? {
        didSet{
            self.selectCertificatesField.stringValue = "\(certificates?.count ?? 0) certificates"
            selectCertificates = certificates
            self.resetDatas()
        }
    }

    open var bundleIDs: [BundleId]? {
        didSet{
            if bundleIDs == nil || bundleIDs!.count == 0 {
                return
            }
            self.selectBundleButton.isEnabled = true
            self.selectBundleButton.removeAllItems()
            for bundleID in bundleIDs! {
                self.selectBundleButton.addItem(withTitle: bundleID.attributes?.name ?? "")
            }
        }
    }
    
    private func resetDatas() {
        if devices != nil && certificates != nil && devices!.count > 0 && certificates!.count > 0 {
            self.selectProfileTypeAction(self.selectProfileTypeButton!)
        }
    }
    
    public func clear() {
        
        self.nameField.stringValue = ""
        self.profile = nil
    }
    
    //MARK: Functions
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
   
    @IBAction func selectProfileTypeAction(_ sender: Any) {
        
        selectDevices?.removeAll()
        let selectProfileType = self.selectProfileTypeButton.selectedItem!.title
        for device in devices! {
            if selectProfileType.hasPrefix("IOS") && device.attributes?.platform == .ios{
                selectDevices?.append(device)
            } else if selectProfileType.hasPrefix("MAC") && device.attributes?.platform == .macOs{
                selectDevices?.append(device)
            } else if selectProfileType.hasPrefix("TV") && device.attributes?.platform == .tvOs{
                selectDevices?.append(device)
            }
        }
        self.selectDevicesField.stringValue = "\(selectDevices?.count ?? 0) devices"

        selectCertificates?.removeAll()
        for cer in certificates! {
            if selectProfileType.hasPrefix("IOS") && cer.attributes!.certificateType!.rawValue.hasPrefix("IOS"){
                selectCertificates?.append(cer)
            } else if selectProfileType.hasPrefix("MAC") && cer.attributes!.certificateType!.rawValue.hasPrefix("MAC"){
                selectCertificates?.append(cer)
            }
        }
        self.selectCertificatesField.stringValue = "\(selectCertificates?.count ?? 0) certificates"
    }
    
    @IBAction func showAllDevices(_ sender: Any) {
        
        if selectDevices == nil || selectDevices!.count == 0 {
            return
        }
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        alert.messageText = "All Devices"
        alert.icon = NSImage.init(named: "device_info")
        var infomation = "\n"
        for device in selectDevices! {
            infomation.append("\(device.attributes!.udid ?? "UDID")")
            infomation.append("\n")
        }
        alert.informativeText = infomation
        alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
    }
    
    @IBAction func showAllCertificates(_ sender: Any) {
        
        if selectCertificates == nil || selectCertificates!.count == 0 {
            return
        }
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        alert.messageText = "All Certificates"
        alert.icon = NSImage.init(named: "certificate_info")
        var infomation = "\n"
        for certificate in selectCertificates! {
            infomation.append("\(certificate.attributes!.name ?? "name") [ID: \(certificate.id)]")
            infomation.append("\n")
        }
        alert.informativeText = infomation
        alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectBundleButton.wantsLayer = true
        selectBundleButton.layer?.backgroundColor = NSColor.white.cgColor
        selectBundleButton.layer?.cornerRadius = 3
        
        selectProfileTypeButton.wantsLayer = true
        selectProfileTypeButton.layer?.backgroundColor = NSColor.white.cgColor
        selectProfileTypeButton.layer?.cornerRadius = 3

        self.selectProfileTypeButton.removeAllItems()
        self.selectProfileTypeButton.addItems(withTitles: [ProfileType.ios_development.rawValue,
                                                           ProfileType.ios_store.rawValue,
                                                           ProfileType.ios_adhoc.rawValue,
                                                           ProfileType.ios_inhouse.rawValue,
                                                           ProfileType.mac_development.rawValue,
                                                           ProfileType.mac_store.rawValue,
                                                           ProfileType.mac_direct.rawValue,
                                                           ProfileType.tv_development.rawValue,
                                                           ProfileType.tv_store.rawValue,
                                                           ProfileType.tv_adhoc.rawValue,
                                                           ProfileType.tv_inhouse.rawValue])
        
    }
}

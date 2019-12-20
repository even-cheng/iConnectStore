
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
   
    open var profile: Profile? {
        didSet{
            self.nameField.stringValue = profile?.attributes?.name ?? ""
            if profile != nil {
                loadDevicesInProfile()
                loadCersInProfile()
                loadBundleIDInProfile()
                for item: NSMenuItem in self.selectProfileTypeButton.itemArray {
                    if item.title == profile!.attributes!.profileType!.rawValue {
                        self.selectProfileTypeButton.select(item)
                    }
                }
            }
        }
    }
    
    open var devices: [Device]? {
        didSet{
            self.resetDatas()
        }
    }
    open var choosed_device_indexs: [Int] = []{
        didSet{
            self.selectDevicesField.stringValue = "\(choosed_device_indexs.count) devices"
        }
    }
    
    open var certificates: [Certificate]? {
        didSet{
            self.resetDatas()
        }
    }
    open var choosed_certificate_indexs: [Int] = []{
        didSet{
            self.selectCertificatesField.stringValue = "\(choosed_certificate_indexs.count) certificates"
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
    
    private func loadDevicesInProfile() {
    
        guard self.profile != nil && self.devices != nil else {return}
        ProfileDataManager().listDevicesInProfile(id: self.profile!.id).done {[weak self] (devs) in
            
            var index = 0
            var choose_devs: [Int] = []
            for device in self!.devices! {
                if devs.contains(where: { (dev) -> Bool in
                    return dev.id == device.id
                }) {
                    choose_devs.append(index)
                }
                index += 1
            }
            self?.choosed_device_indexs = choose_devs
            
        }.catch { (error) in
            print(error)
        }
    }
    
    private func loadBundleIDInProfile() {
        
        guard self.profile != nil else {return}
        ProfileDataManager().loadBundleIDInProfile(id: self.profile!.id).done {[weak self] (bundleId) in
            
            var index = 0
            for item: NSMenuItem in self!.selectBundleButton!.itemArray {
                if item.title == bundleId.attributes?.name {
                    self!.selectBundleButton.select(item)
                }
                index += 1
            }
            
        }.catch { (error) in
            print(error)
        }
    }
    
    private func loadCersInProfile() {
        
        guard self.profile != nil && self.certificates != nil else {return}
        ProfileDataManager().listCertificatesInProfile(id: self.profile!.id).done {[weak self] (cers) in
            
            var index = 0
            var choose_cers: [Int] = []
            for certificate in self!.certificates! {
                if cers.contains(where: { (cer) -> Bool in
                    return cer.id == certificate.id
                }) {
                    choose_cers.append(index)
                }
                index += 1
            }
            self?.choosed_certificate_indexs = choose_cers
            
        }.catch { (error) in
            print(error)
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
        
        var selectDevices: [Device]?
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

        var selectCers: [Certificate]?
        for cer in certificates! {
            if selectProfileType.hasPrefix("IOS") && cer.attributes!.certificateType!.rawValue.hasPrefix("IOS"){
                selectCers?.append(cer)
            } else if selectProfileType.hasPrefix("MAC") && cer.attributes!.certificateType!.rawValue.hasPrefix("MAC"){
                selectCers?.append(cer)
            }
        }
        self.selectCertificatesField.stringValue = "\(selectCers?.count ?? 0) certificates"
    }
    
    @IBAction func showAllDevices(_ sender: NSButton) {
        
        if devices == nil || devices!.count == 0 {
            return
        }
        chooseAction(sender)
    }
    
    @IBAction func showAllCertificates(_ sender: NSButton) {
        
        if certificates == nil || certificates!.count == 0 {
            return
        }
        chooseAction(sender)
    }
    
    private func chooseAction(_ sender: NSButton) {
        
        let chooseTag = sender.tag
        let editView = viewForXIB(class_name: "MultipleChooseView") as! MultipleChooseView
        if chooseTag == 0 {
            
            guard devices != nil else {return}
            editView.choose_source = devices!.map({ (device) -> String in
                return device.attributes?.name ?? ""
            })
            editView.choosed = choosed_device_indexs
            
        } else if chooseTag == 1{
            
            guard certificates != nil else {return}
            editView.choose_source = certificates!.map({ (cer) -> String in
                return cer.attributes?.name ?? ""
            })
            editView.choosed = choosed_certificate_indexs
        }
        
        editView.choosedDone = {[weak self] (choosed: [Int]?) in
            
            self?.isHidden = false
            guard choosed != nil else{
                return
            }
            if chooseTag == 0 {
                self?.choosed_device_indexs = choosed!
            } else if chooseTag == 1{
                self?.choosed_certificate_indexs = choosed!
            }
        }
        guard let contentView = self.superview else {return}
        self.isHidden = true
        contentView.addSubview(editView)
        editView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(contentView)
        }
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

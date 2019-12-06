
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
        }
    }
    
    open var devices: [Device]? {
        didSet{
            self.selectDevicesField.stringValue = "\(devices?.count ?? 0) devices"
        }
    }
    
    open var bundleIDs: [BundleId]? {
        didSet{
            if bundleIDs == nil || bundleIDs!.count == 0 {
                return
            }
            self.selectBundleButton.removeAllItems()
            for bundleID in bundleIDs! {
                self.selectBundleButton.addItem(withTitle: bundleID.attributes?.name ?? "")
            }
        }
    }
    
    open var certificates: [Certificate]? {
        didSet{
            self.selectCertificatesField.stringValue = "\(certificates?.count ?? 0) certificates"
        }
    }
    
    public func clear() {
        
        self.nameField.stringValue = ""
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

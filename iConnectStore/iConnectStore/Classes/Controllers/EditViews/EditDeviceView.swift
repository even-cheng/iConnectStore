//
//  EditDeviceView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/6.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//
import Cocoa

class EditDeviceView: NSView {
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var UDIDField: NSTextField!
    @IBOutlet weak var platformButton: NSPopUpButton!
    
    open var device: Device? {
        didSet{
            self.nameField.stringValue = device?.attributes?.name ?? ""
            self.UDIDField.stringValue = device?.attributes?.udid ?? ""
        }
    }
    
    public func clear() {
        
        self.nameField.stringValue = ""
        self.UDIDField.stringValue = ""
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
        
        platformButton.wantsLayer = true
        platformButton.layer?.backgroundColor = NSColor.white.cgColor
        platformButton.layer?.cornerRadius = 3
        
        self.platformButton.removeAllItems()
        self.platformButton.addItems(withTitles: [Platform.ios.rawValue,
                                                  Platform.macOs.rawValue,
                                                  Platform.tvOs.rawValue,
                                                  Platform.watchOs.rawValue])
    }
}

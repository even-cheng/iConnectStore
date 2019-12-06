//
//  EditBundleIDView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/6.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//
import Cocoa

class EditBundleIDView: NSView {
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var bundleIDField: NSTextField!
    @IBOutlet weak var platformButton: NSPopUpButton!
    
    open var bundleID: BundleId? {
        didSet{
            guard nameField != nil else {return}
            nameField.stringValue = bundleID?.attributes?.name ?? ""
            bundleIDField.stringValue = bundleID?.attributes?.identifier ?? ""
            platformButton.isEnabled = false
        }
    }
    
    public func clear() {
        
        platformButton.isEnabled = true
        self.nameField.stringValue = ""
        self.bundleIDField.stringValue = ""
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
        
        self.nameField.stringValue = bundleID?.attributes?.name ?? ""
        self.bundleIDField.stringValue = bundleID?.attributes?.identifier ?? ""
        
        self.platformButton.removeAllItems()
        self.platformButton.addItems(withTitles: [Platform.ios.rawValue,
                                                  Platform.macOs.rawValue,
                                                  Platform.tvOs.rawValue,
                                                  Platform.watchOs.rawValue])
    }
}

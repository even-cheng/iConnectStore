//
//  EditCertificateView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/6.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa

class EditCertificateView: NSView {
    
    @IBOutlet weak var ChooseCSRField: NSTextField!
    @IBOutlet weak var SelectCerTypeButton: NSPopUpButton!
    
    public func clear() {
        
        self.ChooseCSRField.stringValue = ""
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
        
        SelectCerTypeButton.wantsLayer = true
        SelectCerTypeButton.layer?.backgroundColor = NSColor.white.cgColor
        SelectCerTypeButton.layer?.cornerRadius = 3
        
        self.SelectCerTypeButton.removeAllItems()
        self.SelectCerTypeButton.addItems(withTitles: [CertificateType.ios_development.rawValue,
                                                       CertificateType.ios_distribution.rawValue,
                                                       CertificateType.mac_app_distribution.rawValue,
                                                       CertificateType.mac_install_distribution.rawValue,
                                                       CertificateType.mac_app_development.rawValue,
                                                       CertificateType.developer_id_kext.rawValue,
                                                       CertificateType.developer_id_application.rawValue])
    }
}

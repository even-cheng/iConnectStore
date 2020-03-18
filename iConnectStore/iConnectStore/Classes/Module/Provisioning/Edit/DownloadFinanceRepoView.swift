//
//  DownloadFinanceRepoView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/24.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa

class DownloadFinanceRepoView: NSView {
    
    @IBOutlet weak var regionCodeButton: NSPopUpButton!
    @IBOutlet weak var yearButton: NSPopUpButton!
    @IBOutlet weak var monthButton: NSPopUpButton!
    @IBOutlet weak var reportTypeButton: NSPopUpButton!
    @IBOutlet weak var verdorNumberField: NSTextField!
    
    //MARK: Functions
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.init(white: 0.28, alpha: 1).cgColor
        
        regionCodeButton.wantsLayer = true
        regionCodeButton.layer?.backgroundColor = NSColor.white.cgColor
        regionCodeButton.layer?.cornerRadius = 3
        regionCodeButton.removeAllItems()
        regionCodeButton.addItems(withTitles: ["US","AU","BR","BG","CA","CL","CN","CO","CZ","HR","DK","EG","HK","HU","IN","ID","IL","JP","KZ","KR","MY","MX","NZ","NG","NO","PK","PE","PH","PL","QA","RO","RU","SA","SG","ZA","SE","CH","TW","TH","TR","AE","GB","TZ","VN","EU","WW","ZZ"])
        
        yearButton.wantsLayer = true
        yearButton.layer?.backgroundColor = NSColor.white.cgColor
        yearButton.layer?.cornerRadius = 3
        yearButton.removeAllItems()
        yearButton.addItems(withTitles: ["2019","2020"])
        
        monthButton.wantsLayer = true
        monthButton.layer?.backgroundColor = NSColor.white.cgColor
        monthButton.layer?.cornerRadius = 3
        monthButton.removeAllItems()
        monthButton.addItems(withTitles: ["1","2","3","4","5","6","7","8","9","10","11","12"])
        
        reportTypeButton.wantsLayer = true
        reportTypeButton.layer?.backgroundColor = NSColor.white.cgColor
        reportTypeButton.layer?.cornerRadius = 3
        reportTypeButton.removeAllItems()
        reportTypeButton.addItems(withTitles: ["SALES","SUBSCRIPTION","SUBSCRIPTION_EVENT","SUBSCRIBER","NEWSSTAND","SALES","PRE_ORDER"])
    }
    
    
    @IBAction func downloadAction(_ sender: Any) {
        
    }
}

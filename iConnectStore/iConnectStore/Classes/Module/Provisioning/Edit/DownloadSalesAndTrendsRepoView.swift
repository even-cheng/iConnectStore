//
//  DownloadSalesAndTrendsRepoView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/24.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa

class DownloadSalesAndTrendsRepoView: NSView {
    
    @IBOutlet weak var frequencyButton: NSPopUpButton!
    @IBOutlet weak var yearButton: NSPopUpButton!
    @IBOutlet weak var monthButton: NSPopUpButton!
    @IBOutlet weak var dayButton: NSPopUpButton!
    @IBOutlet weak var reportTypeButton: NSPopUpButton!
    @IBOutlet weak var subTypeButton: NSPopUpButton!
    @IBOutlet weak var vendorNumberField: NSTextField!
    @IBOutlet weak var versionField: NSTextField!
    
    
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
        
        
        frequencyButton.wantsLayer = true
        frequencyButton.layer?.backgroundColor = NSColor.white.cgColor
        frequencyButton.layer?.cornerRadius = 3
        frequencyButton.removeAllItems()
        frequencyButton.addItems(withTitles: ["DAILY", "WEEKLY", "MONTHLY", "YEARLY"])
        
        yearButton.wantsLayer = true
        yearButton.layer?.backgroundColor = NSColor.white.cgColor
        yearButton.layer?.cornerRadius = 3
        yearButton.removeAllItems()
        yearButton.addItems(withTitles: ["2019","2020"])
        
        monthButton.wantsLayer = true
        monthButton.layer?.backgroundColor = NSColor.white.cgColor
        monthButton.layer?.cornerRadius = 3
        monthButton.removeAllItems()
        for i in 1...12 {
            monthButton.addItem(withTitle: "\(i)")
        }
        
        dayButton.wantsLayer = true
        dayButton.layer?.backgroundColor = NSColor.white.cgColor
        dayButton.layer?.cornerRadius = 3
        dayButton.removeAllItems()
        for i in 1...31 {
            dayButton.addItem(withTitle: "\(i)")
        }
        
        reportTypeButton.wantsLayer = true
        reportTypeButton.layer?.backgroundColor = NSColor.white.cgColor
        reportTypeButton.layer?.cornerRadius = 3
        reportTypeButton.removeAllItems()
        reportTypeButton.addItems(withTitles: ["SALES","SUBSCRIPTION","SUBSCRIPTION_EVENT","SUBSCRIBER","NEWSSTAND","SALES","PRE_ORDER"])
        
        subTypeButton.wantsLayer = true
        subTypeButton.layer?.backgroundColor = NSColor.white.cgColor
        subTypeButton.layer?.cornerRadius = 3
        subTypeButton.removeAllItems()
        subTypeButton.addItems(withTitles: ["SUMMARY", "DETAILED", "OPT_IN"])
    }
    
    @IBAction func downloadAction(_ sender: Any) {
        
    }
    
}

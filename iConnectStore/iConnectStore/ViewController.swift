//
//  ViewController.swift
//  iConnectStore
//
//  Created by 快游 on 2019/11/25.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var leftToolsView: NSView!
    @IBOutlet weak var TestingButton: NSButton!
    @IBOutlet weak var UserRolesButton: NSButton!
    @IBOutlet weak var ProvisioningButton: NSButton!
    @IBOutlet weak var ReportingButton: NSButton!
    @IBOutlet weak var provisionContainerView: NSView!
    @IBOutlet weak var settingContainerView: NSView!
    
    var lastSelectLeftButton: NSButton?
    var provisioningController: ProvisionController?
    var settingController: SettingController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.leftToolsView.wantsLayer = true
        self.leftToolsView.layer!.backgroundColor = NSColor(red:0.35, green:0.35, blue:0.35, alpha:1.00).cgColor
        
        setupButton(btn: UserRolesButton)
        setupButton(btn: ProvisioningButton)
        setupButton(btn: ReportingButton)
        setupButton(btn: TestingButton)
        lastSelectLeftButton = UserRolesButton
        provisioningController?.segmentType = SegmentType(rawValue: lastSelectLeftButton!.tag)!
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        let vc: NSViewController = segue.destinationController as! NSViewController
        if vc.className == "iConnectStore.ProvisionController" {
            provisioningController = segue.destinationController as? ProvisionController
        } else if vc.className == "iConnectStore.SettingController" {
            settingController = segue.destinationController as? SettingController
        }
    }

    private func setupButton(btn: NSButton){
        btn.wantsLayer = true
        if btn.state == .on {
            btn.layer!.backgroundColor = NSColor(red:0.00, green:0.63, blue:0.78, alpha:1.00).cgColor
            btn.titleTextColor = NSColor.init(white: 1, alpha: 1)
        } else {
            btn.layer?.backgroundColor = NSColor.clear.cgColor
            btn.titleTextColor = NSColor.init(white: 1, alpha: 1)
        }
    }
    
    @IBAction func leftButtonSelect(_ sender: NSButton) {
        if lastSelectLeftButton == sender {
            return
        }
        lastSelectLeftButton?.state = .off
        setupButton(btn: lastSelectLeftButton!)
        sender.state = .on
        setupButton(btn: sender)
        lastSelectLeftButton = sender
        
        provisioningController?.segmentType = SegmentType(rawValue: sender.tag)!
        self.provisionContainerView.isHidden = sender.tag == 5
        self.settingContainerView.isHidden = sender.tag != 5
    }
}

extension NSButton {
    
    var titleTextColor : NSColor {
        get {
            let attrTitle = self.attributedTitle
            return attrTitle.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as! NSColor
        }
        
        set(newColor) {
            let attrTitle = NSMutableAttributedString(attributedString: self.attributedTitle)
            let titleRange = NSMakeRange(0, self.title.count)
            
            attrTitle.addAttributes([NSAttributedString.Key.foregroundColor: newColor], range: titleRange)
            self.attributedTitle = attrTitle
        }
    }
    
}

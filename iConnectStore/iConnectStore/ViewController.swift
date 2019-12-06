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
    @IBOutlet weak var PagingButton: NSButton!
    @IBOutlet weak var testContainerView: NSView!
    @IBOutlet weak var userContainerView: NSView!
    @IBOutlet weak var provisionContainerView: NSView!
    @IBOutlet weak var reportContainerView: NSView!
    @IBOutlet weak var DataContainerView: NSView!
    @IBOutlet weak var settingContainerView: NSView!
    
    var lastSelectLeftButton: NSButton?
    
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
        
        setupButton(btn: TestingButton)
        setupButton(btn: UserRolesButton)
        setupButton(btn: ProvisioningButton)
        setupButton(btn: ReportingButton)
        setupButton(btn: PagingButton)
        lastSelectLeftButton = TestingButton
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
        
        self.testContainerView.isHidden = sender.tag != 0
        self.userContainerView.isHidden = sender.tag != 1
        self.provisionContainerView.isHidden = sender.tag != 2
        self.reportContainerView.isHidden = sender.tag != 3
        self.DataContainerView.isHidden = sender.tag != 4
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

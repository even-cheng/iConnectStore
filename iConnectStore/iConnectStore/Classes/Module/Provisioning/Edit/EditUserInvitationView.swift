//
//  EditUserInvitationView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/9.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa

class EditUserInvitationView: NSView {
    
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var firstNameField: NSTextField!
    @IBOutlet weak var lastNameField: NSTextField!
    @IBOutlet weak var chooseRolesField: NSTextField!
    @IBOutlet weak var chooseAppsField: NSTextField!
    @IBOutlet weak var allAppsVisibleButton: NSPopUpButton!
    @IBOutlet weak var provisioningAllowedButton: NSPopUpButton!
    
    var choosed_role_indexs: [Int] = []
    var choose_role_sources: [String] = {
        var chooses: [String] = []
        UserRole.allCases.forEach{
            chooses.append($0.rawValue)
        }
        return chooses
    }()
    
    open var apps: [App]?
    open var choosed_apps_indexs: [Int] = []{
        didSet{
            self.chooseAppsField.stringValue = "\(choosed_apps_indexs.count) apps"
        }
    }

    func clear() {
        choosed_role_indexs = []
        choosed_apps_indexs = []
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
        
        allAppsVisibleButton.removeAllItems()
        provisioningAllowedButton.removeAllItems()
        allAppsVisibleButton.addItems(withTitles: ["YES","NO"])
        provisioningAllowedButton.addItems(withTitles: ["YES","NO"])
        
        allAppsVisibleButton.wantsLayer = true
        allAppsVisibleButton.layer?.backgroundColor = NSColor.white.cgColor
        allAppsVisibleButton.layer?.cornerRadius = 3
        
        provisioningAllowedButton.wantsLayer = true
        provisioningAllowedButton.layer?.backgroundColor = NSColor.white.cgColor
        provisioningAllowedButton.layer?.cornerRadius = 3
    }
 
    @IBAction func chooseAction(_ sender: NSButton) {
    
        let chooseTag = sender.tag
        let editView = viewForXIB(class_name: "MultipleChooseView") as! MultipleChooseView
        if chooseTag == 0 {
            
            editView.choose_source = choose_role_sources
            editView.choosed = choosed_role_indexs
            
        } else if chooseTag == 1{
            
            guard apps != nil else {return}
            editView.choose_source = apps!.map({ (app) -> String in
                return app.attributes?.name ?? ""
            })
            editView.choosed = choosed_apps_indexs
        }
        
        editView.choosedDone = {[weak self] (choosed: [Int]?) in
            
            self?.isHidden = false
            guard choosed != nil else{
                return
            }
            if chooseTag == 0 {
                self?.choosed_role_indexs = choosed!
                self?.chooseRolesField.stringValue = "\(choosed!.count) roles"
            } else if chooseTag == 1{
                self?.choosed_apps_indexs = choosed!
                self?.chooseAppsField.stringValue = "\(choosed!.count) apps"
            }
        }
        guard let contentView = self.superview else {return}
        self.isHidden = true
        contentView.addSubview(editView)
        editView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(contentView)
        }
    }
}

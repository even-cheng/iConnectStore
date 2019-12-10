//
//  UserRoleEditContentView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/9.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa
import PromiseKit

class UserRoleEditContentView: NSView {
    
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var doneButton: NSButton!

    
    open var fileType:UserRoleFileType? {
        didSet {
            self.addViews()
        }
    }
    
    open var submitSuccessAction: (()->(Void))?
    
    open var edit_user: User?
    open var apps: [App]?

    private lazy var editUserView: EditUserView = {
        
        let editView = viewForXIB(class_name: "EditUserView") as! EditUserView
        return editView
    }()
    
    private lazy var editUserInvitationView: EditUserInvitationView = {
        
        let editView = viewForXIB(class_name: "EditUserInvitationView") as! EditUserInvitationView
        return editView
    }()
    
    
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
    }
    
    private func addViews() {
        
        switch fileType {
        case .users?:
            self.titleField.stringValue = "Edit User"
            self.editUserView.apps = self.apps
            self.editUserView.edit_user = self.edit_user
            if self.editUserView.superview == nil {
                self.addSubview(self.editUserView)
                self.editUserView.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self)
                }
            }
            
        case .user_invitations?:
            self.titleField.stringValue = "Add UserInvitation"
            self.editUserInvitationView.apps = self.apps
            if self.editUserInvitationView.superview == nil {
                self.addSubview(self.editUserInvitationView)
                self.editUserInvitationView.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self)
                }
            }
            
        case .none: break
        }
        
        self.editUserView.isHidden = (fileType != .users)
        self.editUserInvitationView.isHidden = (fileType != .user_invitations)
    }
    
    @IBAction func CloseAction(_ sender: Any?) {
        self.isHidden = true
        self.edit_user = nil
        self.editUserView.clear()
        self.editUserInvitationView.clear()
    }
    
    @IBAction func DoneAction(_ sender: NSButton) {
        
        self.upldateOrCreat { (res) -> (Void) in
            if res == true {
                self.CloseAction(sender)
                if self.submitSuccessAction != nil {
                    self.submitSuccessAction!()
                }
            }
        }
    }
    
    private func upldateOrCreat(complete: @escaping (Bool)->(Void)) {
        
        switch fileType {
        case .users?:
            //add cer
            var roles: [UserRole] = []
            for i in self.editUserView.choosed_role_indexs {
                roles.append(UserRole(rawValue: self.editUserView.choose_role_sources[i])!)
            }
            var appIds: [String] = []
            for i in self.editUserView.choosed_apps_indexs {
                let app: App = self.editUserView.apps![i]
                appIds.append(app.id)
            }
            let allAppsVisible = self.editUserView.allAppsVisibleButton.state == .on
            let provisioningAllowed = self.editUserView.provisioningAllowedButton.state == .on
            
            UserRoleData().modifyUserAccount(userWithId: self.edit_user!.id, allAppsVisible: allAppsVisible, provisioningAllowed: provisioningAllowed, roles: roles, appsVisibleIds: appIds).done { (_) in
                complete(true)
            }.catch { (error) in
                complete(false)
                print(error)
            }

        case .user_invitations?:
            //add cer
            var roles: [UserRole] = []
            for i in self.editUserInvitationView.choosed_role_indexs {
                roles.append(UserRole(rawValue: self.editUserInvitationView.choose_role_sources[i])!)
            }
            var appIds: [String] = []
            for i in self.editUserInvitationView.choosed_apps_indexs {
                let app: App = self.editUserInvitationView.apps![i]
                appIds.append(app.id)
            }
            let allAppsVisible = self.editUserInvitationView.allAppsVisibleButton.state == .on
            let provisioningAllowed = self.editUserInvitationView.provisioningAllowedButton.state == .on
            let email = self.editUserInvitationView.emailField.stringValue
            let firstName = self.editUserInvitationView.firstNameField.stringValue
            let lastName = self.editUserInvitationView.lastNameField.stringValue
            
            UserRoleData().inviteUser(email: email, firstName: firstName, lastName: lastName, allAppsVisible: allAppsVisible, provisioningAllowed: provisioningAllowed, roles: roles, appsVisibleIds: appIds).done { (_) in
                complete(true)
            }.catch { (error) in
                complete(false)
                print(error)
            }
        case .none:
            break
        }
    }
}

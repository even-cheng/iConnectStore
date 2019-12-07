//
//  SettingController.swift
//  iConnectStore
//
//  Created by 快游 on 2019/11/28.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa
import PromiseKit

class SettingController: NSViewController {
    
    var configuration: APIConfiguration?
    var provider: APIProvider?

    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var accountIDField: NSTextField!
    @IBOutlet weak var ISSUERIDField: NSTextField!
    @IBOutlet weak var PrivateKeyField: NSTextField!
    @IBOutlet weak var PrivateKeyIDField: NSTextField!
    @IBOutlet weak var signActionButton: NSButton!
    @IBOutlet weak var tipField: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let issuer = UserDefaults.standard.value(forKey: "issuerId")
        if issuer != nil {
            ISSUERIDField.stringValue = issuer as! String
        }

        let key = UserDefaults.standard.value(forKey: "privateKey")
        if key != nil {
            PrivateKeyField.stringValue = key as! String
        }

        let keyId = UserDefaults.standard.value(forKey: "privateKeyId")
        if keyId != nil {
            PrivateKeyIDField.stringValue = keyId as! String
        }

        let username = UserDefaults.standard.value(forKey: "username")
        if username != nil {
            usernameField.stringValue = username as! String
        }

        let account = UserDefaults.standard.value(forKey: "account")
        if account != nil {
            accountIDField.stringValue = account as! String
            self.tipField.stringValue = "WELCOME!"
            self.signActionButton.tag = 1
            self.signActionButton.image = NSImage.init(imageLiteralResourceName: "sign-out")
        }        
    }

    override func mouseDown(with event: NSEvent) {
        self.view.window?.makeFirstResponder(nil)
    }
    
    @IBAction func signIn(_ sender: Any) {
        
        if self.signActionButton.tag == 1 {
            usernameField.stringValue = "***"
            accountIDField.stringValue = "***"
            ISSUERIDField.stringValue = ""
            PrivateKeyField.stringValue = ""
            PrivateKeyIDField.stringValue = ""
            self.signActionButton.tag = 0
            self.signActionButton.image = NSImage.init(imageLiteralResourceName: "sign-in")
            self.tipField.stringValue = "INPUT TO SIGNIN"
            return
        }
        
        let issuer = ISSUERIDField.stringValue
        let key = PrivateKeyField.stringValue
        let keyId = PrivateKeyIDField.stringValue
        if issuer.count*key.count*keyId.count == 0 {
            return;
        }
        
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        signActionButton.isHidden = true
        
        getDeveloperInfo(issuerId: issuer, privateKey: key, privateKeyId: keyId, complete: { (admin: User?) in
            
            self.progressIndicator.isHidden = true
            self.progressIndicator.stopAnimation(nil)
            self.signActionButton.isHidden = false
            
            if admin != nil {
                
                let username = admin!.attributes!.firstName! + " " + admin!.attributes!.lastName!
                let account = admin!.attributes!.username!

                UserDefaults.standard.setValue(issuer, forKey: "issuerId")
                UserDefaults.standard.setValue(key, forKey: "privateKey")
                UserDefaults.standard.setValue(keyId, forKey: "privateKeyId")
                UserDefaults.standard.setValue(username, forKey: "username")
                UserDefaults.standard.setValue(account, forKey: "account")

                self.signActionButton.tag = 1
                self.signActionButton.image = NSImage.init(imageLiteralResourceName: "sign-out")
                self.tipField.stringValue = "WELCOME!"
                self.usernameField.stringValue = username
                self.accountIDField.stringValue = account
            
            } else {
                
                let alert = NSAlert.init()
                alert.messageText = "Error!"
                alert.informativeText = "login failed, please check your keys"
                alert.addButton(withTitle: "OK")
                alert.alertStyle = .warning
                alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            }
        })
        
    }
    
    private func getDeveloperInfo(issuerId: String, privateKey: String, privateKeyId: String, complete: @escaping (User?) -> ()) {
        
        configuration = APIConfiguration(issuerID: issuerId, privateKeyID: privateKeyId, privateKey: privateKey)
        provider = APIProvider(configuration: configuration!)
        listAllUsers().then { (users: [User]) -> Promise<User?> in
            
            let p = Promise<User?> {resolver in
                
                for user in users {
                    if user.attributes!.roles!.contains(.admin) {
                        resolver.fulfill(user)
                        return
                    }
                }
                
                resolver.fulfill(nil)
            }
            
            return p
            
        }.done { (user: User?) in
            complete(user)
        }.catch { (error:Error) in
            print(error)
            complete(nil)
        }
    }
    
    private func listAllUsers() -> Promise<[User]> {
        
        let p = Promise<[User]> { resolver in
            
            let endpoint = APIEndpoint.users()
            provider!.request(endpoint) {
                switch $0 {
                case .success(let response):
                    resolver.fulfill(response.data)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
}

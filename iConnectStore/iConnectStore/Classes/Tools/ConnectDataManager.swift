//
//  ConnectDataManager.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/9.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Foundation
import Cocoa

class ConnectDataManager: NSObject {

    var configuration: APIConfiguration?
    var provider: APIProvider?
    override init() {
        var issuer = UserDefaults.standard.value(forKey: "issuerId"), key = UserDefaults.standard.value(forKey: "privateKey"),keyId = UserDefaults.standard.value(forKey: "privateKeyId")
        if issuer == nil {
            issuer = ""
        }
        if key == nil {
            key = ""
        }
        if keyId == nil {
            keyId = ""
        }
            
//            let alert = NSAlert.init()
//            alert.messageText = "Error!"
//            alert.informativeText = "login failed, please goto Setting to input your keys"
//            alert.addButton(withTitle: "OK")
//            alert.alertStyle = .warning
//            alert.beginSheetModal(for: NSApplication.shared.windows.last!, completionHandler: nil)
           
        configuration = APIConfiguration(issuerID: issuer as! String, privateKeyID: keyId as! String, privateKey: key as! String)
        provider = APIProvider(configuration: configuration!)
    }
}

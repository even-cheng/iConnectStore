//
//  ProvisionController.swift
//  iConnectStore
//
//  Created by 快游 on 2019/11/28.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa
import PromiseKit

public enum SegmentType: Int {
    case userRole        = 1
    case provisioning    = 2
    case reportAndSales  = 3
    case testFlight      = 4
    case settings        = 5
}

public enum UserRoleFileType: Int {
    case users            = 0
    case user_invitations = 1
}

public enum ProvisionFileType: Int {
    case certificate = 0
    case bundleId    = 1
    case device      = 2
    case profile     = 3
}

public enum MenuItemType: String {
    case check        = "check"
    case edit         = "edit"
    case add          = "add"
    case download     = "download"
    case delete       = "delete"
}

class ProvisionController: NSViewController {
    
    @IBOutlet weak var leftStackView: NSStackView!
    @IBOutlet weak var leftBgView: NSView!
    @IBOutlet weak var headerStackView: NSStackView!
    @IBOutlet weak var contentTableView: ContentTableView!
    @IBOutlet weak var reloadButton: NSButton!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var editContentView: EditFileContentView!
    
    var segmentType: SegmentType = .userRole {
        didSet{
            reloadContentViews()
            setupContentDatas()
        }
    }

    private var lastSelectLeftButton: NSButton?
    private var originFrame: NSRect?
    private var editMenu: NSMenu = NSMenu()

    private var headerTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.leftBgView.wantsLayer = true
        self.leftBgView.layer!.backgroundColor = NSColor.lightBlackColor().cgColor
       
        self.view.wantsLayer = true
        self.view.layer!.backgroundColor = NSColor.grayBackgroundColor().cgColor

        self.editContentView.wantsLayer = true
        self.editContentView.layer!.backgroundColor = NSColor.darkBlackColor().cgColor

        headerStackView.wantsLayer = true
        headerStackView.layer!.backgroundColor = NSColor.titleBarBackgroundColor().cgColor
        
        originFrame = self.reloadButton.frame
        self.contentTableView.menuDelegate = self
        
        self.editContentView.submitSuccessAction = {
            self.reloadDatasAction(self.reloadButton)
        }
    }
    
    private func setupContentDatas() {
        
        switch self.segmentType {
        case .userRole:
            self.reloadUserRoleDatas(forceToUpdate: false)
        case .provisioning:
            self.reloadProvisioningDatas(forceToUpdate: false)
        case .reportAndSales:
            return
        case .testFlight:
            return
        case .settings:
            return
        }
    }
    
    private func reloadContentViews() {
        
        var buttonNames: [String]?
        var btnTag = 0
        
        switch self.segmentType {
        case .userRole:
            buttonNames = ["Usr", "Inv"]
        case .provisioning:
            buttonNames = ["Cer", "Bud", "Dev", "Prv"]
        case .reportAndSales:
            buttonNames = ["Repo", "Sale"]
        case .testFlight:
            buttonNames = ["App", "Usr", "Add"]
        case .settings:
            return
        }
        
        guard buttonNames != nil else {return}
        
        for view in self.leftStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for name in buttonNames! {
            
            let button = SYFlatButton.init(frame: NSRect.init(x: 0, y: 0, width: 80, height: 100))
            button.title = name
            button.target = self
            button.action = #selector(leftButtonClick(_:))
            button.titleHighlightColor = NSColor.mainColor()
            button.titleNormalColor = NSColor.white
            button.tag = btnTag
            button.state = .off
            button.font = NSFont.boldSystemFont(ofSize: 25)
            self.leftStackView.addArrangedSubview(button)
            if btnTag == 0 {
                button.state = .on
                lastSelectLeftButton = button
            }
            setupButton(btn: button)
            btnTag += 1
        }
        
        self.contentTableView.selectTag = 0
        self.contentTableView.segmentType = self.segmentType
        self.reloadHeaderViews()
    }
    
    @objc func leftButtonClick(_ sender: NSButton) {
        
        if lastSelectLeftButton == sender {
            return
        }
        lastSelectLeftButton?.state = .off
        setupButton(btn: lastSelectLeftButton!)
        sender.state = .on
        setupButton(btn: sender)
        lastSelectLeftButton = sender
        self.editContentView.isHidden = true
        
        setupContentDatas()
        self.contentTableView.selectTag = lastSelectLeftButton!.tag
        reloadHeaderViews()
    }
    
    private func reloadHeaderViews() {
        
        let columnCount = contentTableView.tableColumns.count
        var need_columnCount: Int = 0
        
        switch self.segmentType {
        case .userRole:
            do {
                let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
                switch selectType {
                case .users:
                    headerTitles = ["Name","AppleID","ID","Roles","ProvisioningAllowed","AllAppsVisible"]
                    need_columnCount = 6
                    if contentTableView.users != nil {
                        addButton.isHidden = contentTableView.users!.count > 0
                    }
                case .user_invitations:
                    headerTitles = ["Name","Email","ID","Roles","ProvisioningAllowed","AllAppsVisible","expirationDate"]
                    need_columnCount = 7
                    if contentTableView.user_invitations != nil {
                        addButton.isHidden = contentTableView.user_invitations!.count > 0
                    }
                }
            }
            break
            
        case .provisioning:
            do {
                let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
                switch selectType {
                case .certificate:
                    headerTitles = ["DisplayName","Type","Platform","Name","Expiration"]
                    need_columnCount = 5
                    if contentTableView.certificates != nil {
                        addButton.isHidden = contentTableView.certificates!.count > 0
                    }
                    
                case .bundleId:
                    headerTitles = ["Name","Identifier","Platform"]
                    need_columnCount = 3
                    if contentTableView.bundleIDs != nil {
                        addButton.isHidden = contentTableView.bundleIDs!.count > 0
                    }
                    
                case .device:
                    headerTitles = ["Name","UDID","Type"]
                    need_columnCount = 3
                    if contentTableView.devices != nil {
                        addButton.isHidden = contentTableView.devices!.count > 0
                    }
                    
                case .profile:
                    headerTitles = ["Name","ID","Type","Expiration"]
                    need_columnCount = 4
                    if contentTableView.profiles != nil {
                        addButton.isHidden = contentTableView.profiles!.count > 0
                    }
                }
            }
            break
        case .reportAndSales:
            return
        case .testFlight:
            return
        case .settings:
            return
        }
        
        for view in headerStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for title in headerTitles {
            let titleField = NSTextField()
            titleField.isBordered = false
            titleField.isEditable = false
            titleField.textColor = NSColor.white
            titleField.drawsBackground = false
            titleField.alignment = .center
            titleField.stringValue = title
            titleField.font = NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.bold)
            headerStackView.addArrangedSubview(titleField)
        }
        
        contentTableView.reloadData()
        
        if columnCount > need_columnCount {
            for _ in 0..<(columnCount-need_columnCount) {
                contentTableView.removeTableColumn(contentTableView.tableColumns.last!)
            }
        } else if columnCount < need_columnCount {
            for _ in 0..<(need_columnCount-columnCount) {
                let column = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier(rawValue: "ProfileTextCell"))
                contentTableView.addTableColumn(column)
            }
        }
        
        for column in contentTableView.tableColumns {
            column.resizingMask = .autoresizingMask
            column.width = 200
            column.minWidth = 20
            column.maxWidth = 1000
        }
        
        contentTableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        contentTableView.sizeToFit()
    }
    
    
    /// Add
    ///
    /// - Parameter sender: add file
    @IBAction func addFilesAction(_ sender: Any) {
        
        self.tableViewItemAdd()
    }
    
    @objc private func tableViewItemDownload() {
        guard contentTableView.selectedRow >= 0 else {return}

        switch self.segmentType {
        case .userRole:
            return
        case .provisioning:
            donwloadProvisioningFile()
        case .reportAndSales:
            return
        case .testFlight:
            return
        case .settings:
            return
        }
    }
    
    private func donwloadProvisioningFile() {
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            let certificate = self.contentTableView.certificates![contentTableView.selectedRow]
            ProfileDataManager().downloadCertificate(certificate: certificate, save_name: "iconnect-store") { (res, save_path) -> (Void) in
                if res {
                    print("save success: \(save_path ?? "")")
                }
            }
            
        case .bundleId:
            break
        case .device:
            break
        case .profile:
            let profile = self.contentTableView.profiles![contentTableView.selectedRow]
            ProfileDataManager().downloadProfile(profile: profile, save_name: "iconnect-store") { (res, save_path) -> (Void) in
                if res {
                    print("save success: \(save_path ?? "")")
                }
            }
        }
    }
    
    @objc private func tableViewItemDelete() {
        
        guard contentTableView.selectedRow >= 0 else {return}
        
        let alert = NSAlert.init()
        alert.messageText = "Are you sure to delete this record?"
        alert.informativeText = "Your actions will be synchronized to your developer account"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Delete")
        alert.alertStyle = .warning
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertSecondButtonReturn {
            
            switch self.segmentType {
            case .userRole:
                deleteUserRoleRecord()
            case .provisioning:
                deleteProvisioningRecord()
            case .reportAndSales:
                return
            case .testFlight:
                return
            case .settings:
                return
            }
        }
    }
    
    private func deleteUserRoleRecord() {
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            break
        case .user_invitations:
            let invitation = self.contentTableView.user_invitations![contentTableView.selectedRow]
            UserRoleData().deleteInviteUser(id: invitation.id).then { (res) -> Promise<[UserInvitation]> in
                return UserRoleData().listAllUserInvitations()
            }.done {[weak self] (invitations) in
                self?.contentTableView?.user_invitations = invitations
                self?.contentTableView.reloadData()
            }.catch { (error) in
                print(error)
            }
        }
    }
    
    private func deleteProvisioningRecord() {
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            let certificate = self.contentTableView.certificates![contentTableView.selectedRow]
            self.deleteCerficate(id: certificate.id) { (res) -> (Void) in
                if res{
                    self.contentTableView.certificates?.remove(at: self.contentTableView.selectedRow)
                    self.contentTableView.reloadData()
                }
            }
        case .bundleId:
            let bundleId = self.contentTableView.bundleIDs![contentTableView.selectedRow]
            self.deleteBundleID(id: bundleId.id) { (res) -> (Void) in
                if res{
                    self.contentTableView.bundleIDs?.remove(at: self.contentTableView.selectedRow)
                    self.contentTableView.reloadData()
                }
            }
        case .device:
            break
        case .profile:
            let profile = self.contentTableView.profiles![contentTableView.selectedRow]
            self.deleteProfile(id: profile.id) { (res) -> (Void) in
                if res{
                    self.contentTableView.profiles?.remove(at: self.contentTableView.selectedRow)
                    self.contentTableView.reloadData()
                }
            }
        }
    }
    
    @objc private func tableViewItemInfo() {
        
        guard contentTableView.selectedRow >= 0 else {return}
        
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        
        var infomation: String = ""
        
        switch self.segmentType {
        case .userRole:
            let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
            switch selectType {
            case .users:
                let user = self.contentTableView.users![contentTableView.selectedRow]
                alert.messageText = "User Info"
                alert.icon = NSImage.init(named: "certificate_info")
                infomation = """
                \n
                username: \(user.attributes!.firstName ?? "") \(user.attributes!.lastName ?? "")\n
                appleID: \(user.attributes!.username ?? "")\n
                id: \(user.id)\n
                roles: \((user.attributes!.roles!.map{ $0.rawValue }).joined(separator: "•"))\n
                provisioningAllowed: \(user.attributes?.provisioningAllowed ?? false)\n
                allAppsVisible: \(user.attributes?.allAppsVisible ?? false)\n
                """
                
            case .user_invitations:
                let invitation = self.contentTableView.user_invitations![contentTableView.selectedRow]
                alert.messageText = "Invitation Info"
                alert.icon = NSImage.init(named: "bundle_info")
                infomation = """
                \n
                username: \(invitation.attributes!.firstName ?? "") \(invitation.attributes!.lastName ?? "")\n
                email: \(invitation.attributes!.email ?? "")\n
                id: \(invitation.id)\n
                roles: \((invitation.attributes!.roles!.map{ $0.rawValue }).joined(separator: "\n"))\n
                provisioningAllowed: \(invitation.attributes?.provisioningAllowed ?? false)\n
                allAppsVisible: \(invitation.attributes?.allAppsVisible ?? false)\n
                expirationDate: \(invitation.attributes!.expirationDate!.dateConvertString())\n
                """
            }
        case .provisioning:
            let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
            switch selectType {
            case .certificate:
                let certificate = self.contentTableView.certificates![contentTableView.selectedRow]
                alert.messageText = "Certificate Info"
                alert.icon = NSImage.init(named: "certificate_info")
                infomation = """
                \n
                id: \(String(describing: certificate.id))\n
                displayName: \(String(describing: certificate.attributes!.displayName!))\n
                platform: \(String(describing: certificate.attributes!.platform!))\n
                name: \(String(describing: certificate.attributes!.name!))\n
                certificateType: \(String(describing: certificate.attributes!.certificateType!))\n
                expirationDate: \(String(describing: certificate.attributes!.expirationDate!.dateConvertString()))\n
                """
                
            case .bundleId:
                let bundleId = self.contentTableView.bundleIDs![contentTableView.selectedRow]
                alert.messageText = "BundleID Info"
                alert.icon = NSImage.init(named: "bundle_info")
                infomation = """
                \n
                id: \(String(describing: bundleId.id))\n
                identifier: \(String(describing: bundleId.attributes!.identifier!))\n
                platform: \(String(describing: bundleId.attributes!.platform!))\n
                name: \(String(describing: bundleId.attributes!.name!))\n
                seedId: \(String(describing: bundleId.attributes!.seedId!))\n
                """
                
            case .device:
                let device = self.contentTableView.devices![contentTableView.selectedRow]
                alert.messageText = "Device Info"
                alert.icon = NSImage.init(named: "device_info")
                infomation = """
                \n
                id: \(String(describing: device.id))\n
                model: \(String(describing: device.attributes!.model!))\n
                platform: \(String(describing: device.attributes!.platform!))\n
                udid: \(String(describing: device.attributes!.udid!))\n
                addedDate: \(String(describing: device.attributes!.addedDate!.dateConvertString()))\n
                """
                
            case .profile:
                let profile = self.contentTableView.profiles![contentTableView.selectedRow]
                alert.messageText = "Profile Info"
                alert.icon = NSImage.init(named: "profile_info")
                infomation = """
                \n
                id: \(String(describing: profile.id))\n
                platform: \(String(describing: profile.attributes!.platform!))\n
                name: \(String(describing: profile.attributes!.name!))\n
                uuid: \(String(describing: profile.attributes!.uuid!))\n
                profileType: \(String(describing: profile.attributes!.profileType!))\n
                createdDate: \(String(describing: profile.attributes!.createdDate!.dateConvertString()))\n
                expirationDate: \(String(describing: profile.attributes!.expirationDate!.dateConvertString()))\n
                """
            }
        case .reportAndSales:
            return
        case .testFlight:
            return
        case .settings:
            return
        }
        
        alert.informativeText = infomation
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    @objc private func tableViewItemAdd() {
        
        switch self.segmentType {
        case .userRole:
            addUserRoleRecord()
        case .provisioning:
            addProvisioningRecord()
        case .reportAndSales:
            return
        case .testFlight:
            return
        case .settings:
            return
        }
    }
    
    private func addUserRoleRecord() {
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        self.editContentView.isHidden = false
        self.editContentView.apps = self.contentTableView.apps
        self.editContentView.userRoleFileType = selectType
    }
    
    private func addProvisioningRecord() {
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        self.editContentView.isHidden = false
        self.editContentView.certificates = self.contentTableView.certificates
        self.editContentView.devices = self.contentTableView.devices
        self.editContentView.bundleIDs = self.contentTableView.bundleIDs
        self.editContentView.provisionFileType = selectType
    }
    
    @objc private func tableViewItemEdit() {
        
        guard contentTableView.selectedRow >= 0 else {return}
        
        switch self.segmentType {
        case .userRole:
            editUserRoleRecord()
        case .provisioning:
            editProvisioningRecord()
        case .reportAndSales:
            return
        case .testFlight:
            return
        case .settings:
            return
        }
    }
    
    private func editUserRoleRecord() {
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            let user = self.contentTableView.users![contentTableView.selectedRow]
            self.editContentView.edit_user = user
            break
        default:
            break
        }
        self.editContentView.apps = self.contentTableView.apps
        self.editContentView.userRoleFileType = selectType
        self.editContentView.isHidden = false
    }
    
    private func editProvisioningRecord() {
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            break
        case .bundleId:
            let bundleID = self.contentTableView.bundleIDs![contentTableView.selectedRow]
            self.editContentView.edit_bundleID = bundleID
        case .device:
            let device = self.contentTableView.devices![contentTableView.selectedRow]
            self.editContentView.edit_device = device
        case .profile:
            self.editContentView.edit_profile = self.contentTableView.profiles![contentTableView.selectedRow]
            self.editContentView.certificates = self.contentTableView.certificates
            self.editContentView.devices = self.contentTableView.devices
            self.editContentView.bundleIDs = self.contentTableView.bundleIDs
        }
        self.editContentView.provisionFileType = selectType
        self.editContentView.isHidden = false
    }
    
    private func addItemToMenu(itemTypes: [MenuItemType]) {
        
        for itemType in itemTypes {
            
            var title: String = ""
            let icon: String = "alert_\(itemType.rawValue)"
            var action: Selector?
            
            switch itemType {
            case .check:
                title = "  Info "
                action = #selector(tableViewItemInfo)
            case .edit:
                title = "  Edit "
                action = #selector(tableViewItemEdit)
            case .add:
                title = "  Add "
                action = #selector(tableViewItemAdd)
            case .download:
                title = "  Download "
                action = #selector(tableViewItemDownload)
            case .delete:
                title = "  Delete "
                action = #selector(tableViewItemDelete)
            }
            
            let item = NSMenuItem.init(title: title, action: action, keyEquivalent: "")
            item.image = NSImage(named: icon)
            editMenu.minimumWidth = 120
            editMenu.font = NSFont.systemFont(ofSize: 16)
            editMenu.addItem(item)
        }
    }
    
    
    @IBAction func reloadDatasAction(_ sender: NSButton) {
        
        switch self.segmentType {
        case .userRole:
            self.reloadUserRoleDatas(forceToUpdate: true)
        case .provisioning:
            self.reloadProvisioningDatas(forceToUpdate: true)
        case .reportAndSales:
            return
        case .testFlight:
            return
        case .settings:
            return
        }
    }
    
    private func reloadProvisioningDatas(forceToUpdate: Bool) {
        
        guard lastSelectLeftButton != nil else {return}
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            if self.contentTableView.certificates == nil || forceToUpdate == true {
                getAllCerficates()
            }
        case .bundleId:
            if self.contentTableView.bundleIDs == nil || forceToUpdate == true {
                getAllBundleIDs()
            }
        case .device:
            if self.contentTableView.devices == nil || forceToUpdate == true {
                getAllDevices()
            }
        case .profile:
            if self.contentTableView.profiles == nil || forceToUpdate == true {
                getAllProfiles()
            }
        }
    }
    
    private func reloadUserRoleDatas(forceToUpdate: Bool) {
        
        guard lastSelectLeftButton != nil else {return}
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            if self.contentTableView.users == nil || forceToUpdate == true {
                getAllUsers()
            }
        case .user_invitations:
            if self.contentTableView.user_invitations == nil || forceToUpdate == true {
                getAllInvitations()
            }
        }
    }

    private func setupButton(btn: NSButton){
        if btn.state == .on {
            btn.titleTextColor = NSColor.mainColor()
        } else {
            btn.titleTextColor = NSColor.titleWhiteColor()
        }
    }
}

extension ProvisionController {
    
    private func getAllCerficates() {
        
        self.startReload()
        _ = ProfileDataManager().listAllCertificates().done {[weak self] (cers) in
            self?.contentTableView.certificates = cers
            self?.endReload()
            self?.addButton.isHidden = cers.count > 0
            self?.contentTableView.reloadData()
        }
    }
    
    private func deleteCerficate(id: String, complete:@escaping ((Bool)->(Void))) {
        
        _ = ProfileDataManager().deleteCertificate(id: id).done({ (_) in
            complete(true)
        }).catch({ (_) in
            complete(false)
        })
    }
    
    private func getAllBundleIDs() {
        
        self.startReload()
        _ = ProfileDataManager().listBundles().done {[weak self] (bundles) in
            self?.contentTableView.bundleIDs = bundles
            self?.endReload()
            self?.addButton.isHidden = bundles.count > 0
            self?.contentTableView.reloadData()
        }
    }
    
    private func deleteBundleID(id: String, complete:@escaping ((Bool)->(Void))) {
        
        _ = ProfileDataManager().deleteBundle(id: id).done({ (_) in
            complete(true)
        }).catch({ (_) in
            complete(false)
        })
    }
    
    private func getAllDevices() {
        
        self.startReload()
        _ = ProfileDataManager().listRegisterdDevices().done {[weak self] (devices) in
            self?.contentTableView.devices = devices
            self?.endReload()
            self?.addButton.isHidden = devices.count > 0
            self?.contentTableView.reloadData()
        }
    }
    
    private func getAllProfiles() {
        
        self.startReload()
        _ = ProfileDataManager().listAllProfiles().done {[weak self] (profiles) in
            self?.contentTableView.profiles = profiles
            self?.endReload()
            self?.addButton.isHidden = profiles.count > 0
            self?.contentTableView.reloadData()
        }
    }
    
    private func deleteProfile(id: String, complete:@escaping ((Bool)->(Void))) {
        
        _ = ProfileDataManager().deleteProvisionFile(id: id).done({ (_) in
            complete(true)
        }).catch({ (_) in
            complete(false)
        })
    }
    
    private func getAllUsers() {
        
        self.startReload()
        _ = UserRoleData().listAllUsers().then({[weak self] (users) -> Promise<[App]> in
            
            self?.contentTableView.users = users
            return UserRoleData().listAllApps()
            
        }).done {[weak self] (apps) in
            
            self?.contentTableView.apps = apps
            self?.endReload()
            self?.addButton.isHidden = self!.contentTableView.users!.count > 0
            self?.contentTableView.reloadData()
            
        }.catch({ (error) in
            self.endReload()
        })
    }
    
    private func getAllInvitations() {
        
        self.startReload()
        _ = UserRoleData().listAllUserInvitations().then({[weak self] (invitions) -> Promise<[App]> in
            
            self?.contentTableView.user_invitations = invitions
            return UserRoleData().listAllApps()
            
        }).done {[weak self] (apps) in
            
            self?.contentTableView.apps = apps
            self?.endReload()
            self?.addButton.isHidden = self!.contentTableView.user_invitations!.count > 0
            self?.contentTableView.reloadData()
        
        }.catch({ (error) in
            self.endReload()
        })
    }
}

extension ProvisionController {

    func startReload() {
        
        self.reloadButton.wantsLayer = true
        self.reloadButton.layer?.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.toValue = CGFloat(Double.pi*2)
        animation.duration = 1;
        animation.repeatCount = Float(INT_MAX)
        self.reloadButton.layer?.add(animation, forKey: "animation");
        
        let frame = self.originFrame!
        let xCoord = frame.size.width
        let yCoord = frame.size.height;
        let point = CGPoint.init(x: xCoord*0.5+frame.origin.x, y: yCoord*0.5)
        self.reloadButton.layer?.position = point
    }
    
    func endReload() {
        self.reloadButton.layer?.removeAllAnimations()
    }
}

@objc protocol ContextMenu {
    @objc func tableView(_ tableView: NSTableView, menuForRows rows:IndexSet)->NSMenu?
    @objc func tableView(_ tableView: NSTableView, clickForRow row: Int) -> Void
}

extension ProvisionController: ContextMenu{
    
    @objc func tableView(_ tableView: NSTableView, menuForRows rows:IndexSet)->NSMenu?{
        
        self.editMenu.removeAllItems()
        
        switch self.segmentType {
        case .userRole:
            let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
            switch selectType {
            case .users:
                addItemToMenu(itemTypes: [.check, .edit])
            case .user_invitations:
                addItemToMenu(itemTypes: [.check, .add, .delete])
            }
        case .provisioning:
            let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
            switch selectType {
            case .certificate:
                addItemToMenu(itemTypes: [.check, .add, .download, .delete])
            case .bundleId:
                addItemToMenu(itemTypes: [.check, .edit, .add, .delete])
            case .device:
                addItemToMenu(itemTypes: [.check, .edit, .add])
            case .profile:
                addItemToMenu(itemTypes: [.check, .edit ,.add, .download, .delete])
            }
        case .reportAndSales:
            break
        case .testFlight:
            break
        case .settings:
            break
        }
        
        return self.editMenu
    }
    
    @objc func tableView(_ tableView: NSTableView, clickForRow row: Int) -> Void {
        
    }
}


//
//  UserRoleController.swift
//  iConnectStore
//
//  Created by 快游 on 2019/11/28.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa
import PromiseKit

public enum UserRoleFileType: Int {
    case users = 0
    case user_invitations = 1
}

class UserRoleController: NSViewController {
    
    @IBOutlet weak var leftBgView: NSView!
    @IBOutlet weak var headerStackView: NSStackView!
    @IBOutlet weak var userButton: NSButton!
    @IBOutlet weak var inviteUserButton: NSButton!
    @IBOutlet weak var contentTableView: NSTableView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var editContentView: UserRoleEditContentView!
    
    var users: [User]?
    var user_invitations: [UserInvitation]?
    var apps: [App]?

    private var headerTitles: [String] = []
    private var lastSelectLeftButton: NSButton?
    private var originFrame: NSRect?
    private var editMenu: NSMenu = NSMenu()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastSelectLeftButton = userButton
        
        // Do any additional setup after loading the view.
        self.leftBgView.wantsLayer = true
        self.leftBgView.layer!.backgroundColor = NSColor.init(white: 0.35, alpha: 1).cgColor
        
        self.view.wantsLayer = true
        self.view.layer!.backgroundColor = NSColor.init(white: 0.5, alpha: 1).cgColor
        
        headerStackView.wantsLayer = true
        headerStackView.layer!.backgroundColor = NSColor.init(white: 0.5, alpha: 0.8).cgColor
                
        setupButton(btn: userButton)
        setupButton(btn: inviteUserButton)
        
        getAllDatas()
    }
    
    @IBAction func kindButtonChoosed(_ sender: NSButton) {
        
        if lastSelectLeftButton == sender {
            return
        }
        lastSelectLeftButton?.state = .off
        setupButton(btn: lastSelectLeftButton!)
        sender.state = .on
        setupButton(btn: sender)
        lastSelectLeftButton = sender
        reloadHeaderViews()
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.tableViewItemAdd()
    }
    
    private func setupButton(btn: NSButton){
        if btn.state == .on {
            btn.titleTextColor = NSColor(red:0.00, green:0.63, blue:0.78, alpha:1.00)
        } else {
            btn.titleTextColor = NSColor.init(white: 0.95, alpha: 1)
        }
    }
    
    private func reloadHeaderViews() {
        
        let columnCount = contentTableView.tableColumns.count
        var need_columnCount: Int = 0
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            headerTitles = ["Name","AppleID","ID","Roles","ProvisioningAllowed","AllAppsVisible"]
            need_columnCount = 6
            if users != nil {
                addButton.isHidden = users!.count > 0
            }
        case .user_invitations:
            headerTitles = ["Name","Email","ID","Roles","ProvisioningAllowed","AllAppsVisible","expirationDate"]
            need_columnCount = 7
            if user_invitations != nil {
                addButton.isHidden = user_invitations!.count > 0
            }
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
                let column = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier(rawValue: "UserRoleTextCell"))
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
    
    private func getAllDatas() {
        
        UserRoleData().listAllUsers().then({[weak self] (users) -> Promise<[UserInvitation]> in
            
            self?.users = users
            return UserRoleData().listAllUserInvitations()
            
        }).then({[weak self] (invitations) -> Promise<[App]> in
            
            self?.user_invitations = invitations
            return UserRoleData().listAllApps()
        
        }).done {[weak self] (apps) in
            
            self?.apps = apps
            self?.reloadHeaderViews()

        }.catch { (error) in
            print(error)
        }
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
            case .delete:
                title = "  Delete "
                action = #selector(tableViewItemDelete)
            default:
                break
            }
            
            let item = NSMenuItem.init(title: title, action: action, keyEquivalent: "")
            item.image = NSImage(named: icon)
            editMenu.minimumWidth = 120
            editMenu.font = NSFont.systemFont(ofSize: 16)
            editMenu.addItem(item)
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
            
            let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
            switch selectType {
            case .users:
                break
            case .user_invitations:
                let invitation = self.user_invitations![contentTableView.selectedRow]
                UserRoleData().deleteInviteUser(id: invitation.id).then { (res) -> Promise<[UserInvitation]> in
                    return UserRoleData().listAllUserInvitations()
                }.done {[weak self] (invitations) in
                    self?.user_invitations = invitations
                    self?.reloadHeaderViews()
                }.catch { (error) in
                    print(error)
                }
            }
        }
    }
    
    @objc private func tableViewItemInfo() {
        
        guard contentTableView.selectedRow >= 0 else {return}
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            let user = self.users![contentTableView.selectedRow]
            self.alert(user)
            
        case .user_invitations:
            let invitation = self.user_invitations![contentTableView.selectedRow]
            self.alert(invitation)
        }
    }
    
    @objc private func tableViewItemAdd() {
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        self.editContentView.isHidden = false
        self.editContentView.apps = apps
        self.editContentView.fileType = selectType
    }
    
    @objc private func tableViewItemEdit() {
        
        guard contentTableView.selectedRow >= 0 else {return}
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            let user = self.users![contentTableView.selectedRow]
            self.editContentView.edit_user = user
            break
        default:
            break
        }
        self.editContentView.apps = apps
        self.editContentView.fileType = selectType
        self.editContentView.isHidden = false
    }
}

extension UserRoleController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "UserRoleTextCell"), owner: self) as! NSTableCellView
        
        var columnIndex = 0
        if tableColumn != nil {
            columnIndex = tableView.tableColumns.firstIndex(of: tableColumn!) ?? 0
        }
        
        cellView.wantsLayer = true
        if row % 2 == 1 {
            cellView.layer!.backgroundColor = NSColor.init(white: 0.29, alpha: 1).cgColor
        } else {
            cellView.layer!.backgroundColor = NSColor.init(white: 0.29, alpha: 0).cgColor
        }
        
        var text: String = ""
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            if let user = self.users?[row] {
                switch columnIndex {
                case 0:
                    text = "\(user.attributes?.firstName ?? "") \(user.attributes?.lastName ?? "")"
                case 1:
                    text = user.attributes?.username ?? ""
                case 2:
                    text = user.id
                case 3:
                    text = (user.attributes!.roles!.map{ $0.rawValue }).joined(separator: "\n")
                case 4:
                    text = "\(user.attributes?.provisioningAllowed ?? false)"
                case 5:
                    text = "\(user.attributes?.allAppsVisible ?? false)"

                default:
                    text = ""
                }
            }
        case .user_invitations:
            if let invitation = self.user_invitations?[row] {
                switch columnIndex {
                case 0:
                    text = "\(invitation.attributes?.firstName ?? "") \(invitation.attributes?.lastName ?? "")"
                case 1:
                    text = invitation.attributes?.email ?? ""
                case 2:
                    text = invitation.id
                case 3:
                    text = (invitation.attributes!.roles!.map{ $0.rawValue }).joined(separator: "\n")
                case 4:
                    text = "\(invitation.attributes?.provisioningAllowed ?? false)"
                case 5:
                    text = "\(invitation.attributes?.allAppsVisible ?? false)"
                case 6:
                    text = invitation.attributes?.expirationDate?.dateConvertString() ?? ""
                default:
                    text = ""
                }
            }
        }
        
        cellView.textField?.alignment = .center
        cellView.textField?.stringValue = text
        cellView.textField?.textColor = NSColor.white
        cellView.textField?.maximumNumberOfLines = 2
        cellView.textField?.font = NSFont.systemFont(ofSize: 15)
        
        return cellView
    }
    
    func alert(_ obj: Any) {
        
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        
        var infomation: String = ""
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            let user = self.users![contentTableView.selectedRow]
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
            let invitation = self.user_invitations![contentTableView.selectedRow]
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
        
        alert.informativeText = infomation
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}

extension UserRoleController: NSTableViewDataSource {
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .users:
            return self.users?.count ?? 0
        case .user_invitations:
            return self.user_invitations?.count ?? 0
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        return 40
    }
}

extension UserRoleController: ContextMenu{
    
    @objc func tableView(_ tableView: NSTableView, menuForRows rows:IndexSet)->NSMenu?{
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: lastSelectLeftButton!.tag)!
        self.editMenu.removeAllItems()
        switch selectType {
        case .users:
            addItemToMenu(itemTypes: [.check, .edit])
        case .user_invitations:
            addItemToMenu(itemTypes: [.check, .add, .delete])
        }
        return self.editMenu
    }
    
    @objc func tableView(_ tableView: NSTableView, clickForRow row: Int) -> Void {
        
    }
}

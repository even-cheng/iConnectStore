//
//  ContentTableView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/16.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa
import PromiseKit

class ContentTableView: NSTableView {
    
    var segmentType: SegmentType = .userRole {
        didSet{
            self.reloadTableViewContent()
        }
    }
    
    var selectTag: Int = 0 {
        didSet{
            self.reloadTableViewContent()
        }
    }
    
    var menuDelegate: ContextMenu?
    
    //ProvisioningDatas
    var certificates: [Certificate]?
    var bundleIDs: [BundleId]?
    var devices: [Device]?
    var profiles: [Profile]?
    
    //UserRoleDatas
    var users: [User]?
    var user_invitations: [UserInvitation]?
    var apps: [App]?
    
    override func awakeFromNib() {
        self.delegate = self
        self.dataSource = self
    }
    
    func reloadTableViewContent() {
        
        self.reloadData()
    }
}

extension ContentTableView {
    
    func creatUserRoleRowName(row:Int, column: Int) -> String {
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: selectTag)!
        switch selectType {
        case .users:
            if let user = self.users?[row] {
                switch column {
                case 0:
                    return "\(user.attributes?.firstName ?? "") \(user.attributes?.lastName ?? "")"
                case 1:
                    return user.attributes?.username ?? ""
                case 2:
                    return user.id
                case 3:
                    return (user.attributes!.roles!.map{ $0.rawValue }).joined(separator: "\n")
                case 4:
                    return "\(user.attributes?.provisioningAllowed ?? false)"
                case 5:
                    return "\(user.attributes?.allAppsVisible ?? false)"
                    
                default:
                    return ""
                }
            }
        case .user_invitations:
            if let invitation = self.user_invitations?[row] {
                switch column {
                case 0:
                    return "\(invitation.attributes?.firstName ?? "") \(invitation.attributes?.lastName ?? "")"
                case 1:
                    return invitation.attributes?.email ?? ""
                case 2:
                    return invitation.id
                case 3:
                    return (invitation.attributes!.roles!.map{ $0.rawValue }).joined(separator: "\n")
                case 4:
                    return "\(invitation.attributes?.provisioningAllowed ?? false)"
                case 5:
                    return "\(invitation.attributes?.allAppsVisible ?? false)"
                case 6:
                    return invitation.attributes?.expirationDate?.dateConvertString() ?? ""
                default:
                    return ""
                }
            }
        }
        
        return ""
    }
    
    func creatProvisioningRowName(row:Int, column: Int) -> String {
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: selectTag)!
        switch selectType {
        case .certificate:
            if let certificate = self.certificates?[row] {
                switch column {
                case 0:
                    return certificate.attributes?.displayName ?? ""
                case 1:
                    return (certificate.attributes?.certificateType).map { $0.rawValue } ?? ""
                case 2:
                    return (certificate.attributes?.platform).map { $0.rawValue } ?? ""
                case 3:
                    return certificate.attributes?.name ?? ""
                case 4:
                    return certificate.attributes?.expirationDate?.dateConvertString() ?? ""
                default:
                    return ""
                }
            }
        case .bundleId:
            if let bundleID = self.bundleIDs?[row] {
                switch column {
                case 0:
                    return bundleID.attributes?.name ?? ""
                case 1:
                    return bundleID.attributes?.identifier ?? ""
                case 2:
                    return bundleID.attributes?.platform.map { $0.rawValue } ?? ""
                default:
                    return ""
                }
            }
        case .device:
            if let device = self.devices?[row] {
                switch column {
                case 0:
                    return device.attributes?.name ?? ""
                case 1:
                    return device.attributes?.udid ?? ""
                case 2:
                    return device.attributes?.platform.map { $0.rawValue } ?? ""
                default:
                    return ""
                }
            }
        case .profile:
            if let profile = self.profiles?[row] {
                switch column {
                case 0:
                    return profile.attributes?.name ?? ""
                case 1:
                    return profile.id
                case 2:
                    return profile.attributes?.profileType.map { $0.rawValue } ?? ""
                case 3:
                    return profile.attributes?.expirationDate?.dateConvertString() ?? ""
                default:
                    return ""
                }
            }
        }
        
        return ""
    }
    
    func numberOfProvisioningRows() -> Int {
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: selectTag)!
        switch selectType {
        case .certificate:
            return self.certificates?.count ?? 0
        case .bundleId:
            return self.bundleIDs?.count ?? 0
        case .device:
            return self.devices?.count ?? 0
        case .profile:
            return self.profiles?.count ?? 0
        }
    }
    
    func numberOfUserRoleRows() -> Int {
        
        let selectType: UserRoleFileType = UserRoleFileType(rawValue: selectTag)!
        switch selectType {
        case .users:
            return self.users?.count ?? 0
        case .user_invitations:
            return self.user_invitations?.count ?? 0
        }
    }
}

extension ContentTableView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProfileTextCell"), owner: self) as! NSTableCellView
        
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
        
        switch self.segmentType {
        case .userRole:
            text = self.creatUserRoleRowName(row: row, column: columnIndex)
        case .provisioning:
           text = self.creatProvisioningRowName(row: row, column: columnIndex)
        case .reportAndSales:
            break
        case .testFlight:
            break
        case .settings:
            break
        }
        
        cellView.textField?.alignment = .center
        cellView.textField?.stringValue = text
        cellView.textField?.textColor = NSColor.white
        cellView.textField?.maximumNumberOfLines = 2
        cellView.textField?.font = NSFont.systemFont(ofSize: 15)
        
        return cellView
    }
}

extension ContentTableView: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        switch self.segmentType {
        case .userRole:
            return self.numberOfUserRoleRows()
        case .provisioning:
            return self.numberOfProvisioningRows()
        case .reportAndSales:
            return 0
        case .testFlight:
            return 0
        case .settings:
            return 0            
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        return 40
    }
}


extension ContentTableView {
    
    open override func menu(for event: NSEvent) -> NSMenu? {
        let location = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: location)
        if row >= 0 && event.type == .rightMouseDown {
            
            var selected = self.selectedRowIndexes
            if  false ==  selected.contains(row) {
                selected = IndexSet.init(integer: row)
                self.selectRowIndexes(selected, byExtendingSelection: false)
            }
            if  let dele:ContextMenu = self.menuDelegate {
                return   dele.tableView(self, menuForRows: selected)
            }else{
                return super.menu(for: event)
            }
        }
        
        return super.menu(for: event)
    }
    open override func mouseDown(with event: NSEvent) {
        let location = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: location)
        if row >= 0 && event.type == .leftMouseDown {
            
            var selected = self.selectedRowIndexes
            if  false ==  selected.contains(row) {
                selected = IndexSet.init(integer: row)
                self.selectRowIndexes(selected, byExtendingSelection: false)
            }
            if  let dele:ContextMenu = self.menuDelegate  {
                dele.tableView(self, clickForRow: row)
            }
        }
        return super.mouseDown(with: event)
    }
    open override func mouseEntered(with event: NSEvent) {
        
        
    }
    open override func mouseExited(with event: NSEvent) {
        
    }
}

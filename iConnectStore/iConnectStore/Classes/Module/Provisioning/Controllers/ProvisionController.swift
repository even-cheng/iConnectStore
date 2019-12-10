//
//  ProvisionController.swift
//  iConnectStore
//
//  Created by 快游 on 2019/11/28.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa
import PromiseKit

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
    @IBOutlet weak var certificatesButton: NSButton!
    @IBOutlet weak var provisionsButton: NSButton!
    @IBOutlet weak var devicesButton: NSButton!
    @IBOutlet weak var bundlesButton: NSButton!
    @IBOutlet weak var leftBgView: NSView!
    @IBOutlet weak var headerStackView: NSStackView!
    @IBOutlet weak var contentTableView: NSTableView!
    @IBOutlet weak var reloadButton: NSButton!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var editContentView: EditFileContentView!
    
    var certificates: [Certificate]?
    var bundleIDs: [BundleId]?
    var devices: [Device]?
    var profiles: [Profile]?
    
    private var headerTitles: [String] = []
    private var lastSelectLeftButton: NSButton?
    private var originFrame: NSRect?
    private var editMenu: NSMenu = NSMenu()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastSelectLeftButton = certificatesButton

        // Do any additional setup after loading the view.
        self.leftBgView.wantsLayer = true
        self.leftBgView.layer!.backgroundColor = NSColor.init(white: 0.35, alpha: 1).cgColor
       
        self.view.wantsLayer = true
        self.view.layer!.backgroundColor = NSColor.init(white: 0.5, alpha: 1).cgColor

        self.editContentView.wantsLayer = true
        self.editContentView.layer!.backgroundColor = NSColor.init(white: 0.28, alpha: 1).cgColor

        headerStackView.wantsLayer = true
        headerStackView.layer!.backgroundColor = NSColor.init(white: 0.5, alpha: 0.8).cgColor
        
        originFrame = self.reloadButton.frame
        
        setupButton(btn: certificatesButton)
        setupButton(btn: provisionsButton)
        setupButton(btn: devicesButton)
        setupButton(btn: bundlesButton)
        
        self.editContentView.submitSuccessAction = {
            self.reloadDatasAction(self.reloadButton)
        }
        
        getAllDatas()
    }
    
    private func getAllDatas() {
        
        self.startReload()
        ProfileDataManager().listAllCertificates().then {[weak self] (certificates) -> Promise<[BundleId]> in
            
            self?.certificates = certificates
            return ProfileDataManager().listBundles()
            
        }.then {[weak self] (bundleIDs) -> Promise<[Device]> in
            
            self?.bundleIDs = bundleIDs
            return ProfileDataManager().listRegisterdDevices()
            
        }.then {[weak self] (devices) -> Promise<[Profile]> in
            
            self?.devices = devices
            return ProfileDataManager().listAllProfiles()
            
        }.done {[weak self] (profiles) in
            
            self?.endReload()
            self?.profiles = profiles
            self?.reloadHeaderViews()
            
        }.catch {[weak self] (error) in
            print(error)
            self?.endReload()
        }
    }
    
    /// Add
    ///
    /// - Parameter sender: add file
    @IBAction func addFilesAction(_ sender: Any) {
        
        self.tableViewItemAdd()
    }
    
    @objc private func tableViewItemDownload() {
        guard contentTableView.selectedRow >= 0 else {return}

        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            let certificate = self.certificates![contentTableView.selectedRow]
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
            let profile = self.profiles![contentTableView.selectedRow]
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
            
            let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
            switch selectType {
            case .certificate:
                let certificate = self.certificates![contentTableView.selectedRow]
                self.deleteCerficate(id: certificate.id) { (res) -> (Void) in
                    if res{
                        self.certificates?.remove(at: self.contentTableView.selectedRow)
                        self.contentTableView.reloadData()
                    }
                }
            case .bundleId:
                let bundleId = self.bundleIDs![contentTableView.selectedRow]
                self.deleteBundleID(id: bundleId.id) { (res) -> (Void) in
                    if res{
                        self.bundleIDs?.remove(at: self.contentTableView.selectedRow)
                        self.contentTableView.reloadData()
                    }
                }
            case .device:
                break
            case .profile:
                let profile = self.profiles![contentTableView.selectedRow]
                self.deleteProfile(id: profile.id) { (res) -> (Void) in
                    if res{
                        self.profiles?.remove(at: self.contentTableView.selectedRow)
                        self.contentTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc private func tableViewItemClick() {
        
        guard contentTableView.selectedRow >= 0 else {return}

        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            let certificate = self.certificates![contentTableView.selectedRow]
            self.alert(certificate)
       
        case .bundleId:
            let bundleId = self.bundleIDs![contentTableView.selectedRow]
            self.alert(bundleId)
        
        case .device:
            let device = self.devices![contentTableView.selectedRow]
            self.alert(device)
        
        case .profile:
            let profile = self.profiles![contentTableView.selectedRow]
            self.alert(profile)
        }
    }
    
    @objc private func tableViewItemAdd() {
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        self.editContentView.isHidden = false
        self.editContentView.certificates = self.certificates
        self.editContentView.devices = self.devices
        self.editContentView.bundleIDs = self.bundleIDs
        self.editContentView.fileType = selectType
    }
    
    @objc private func tableViewItemEdit() {
        
        guard contentTableView.selectedRow >= 0 else {return}
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            break
        case .bundleId:
            let bundleID = self.bundleIDs![contentTableView.selectedRow]
            self.editContentView.edit_bundleID = bundleID
        case .device:
            let device = self.devices![contentTableView.selectedRow]
            self.editContentView.edit_device = device
        case .profile:
            self.editContentView.edit_profile = self.profiles![contentTableView.selectedRow]
            self.editContentView.certificates = self.certificates
            self.editContentView.devices = self.devices
            self.editContentView.bundleIDs = self.bundleIDs
        }
        self.editContentView.fileType = selectType
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
                action = #selector(tableViewItemClick)
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
    
    private func reloadHeaderViews() {
        
        let columnCount = contentTableView.tableColumns.count
        var need_columnCount: Int = 0
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            headerTitles = ["DisplayName","Type","Platform","Name","Expiration"]
            need_columnCount = 5
            if certificates != nil {
                addButton.isHidden = certificates!.count > 0
            }
        
        case .bundleId:
            headerTitles = ["Name","Identifier","Platform"]
            need_columnCount = 3
            if bundleIDs != nil {
                addButton.isHidden = bundleIDs!.count > 0
            }

        case .device:
            headerTitles = ["Name","UDID","Type"]
            need_columnCount = 3
            if devices != nil {
                addButton.isHidden = devices!.count > 0
            }

        case .profile:
            headerTitles = ["Name","ID","Type","Expiration"]
            need_columnCount = 4
            if profiles != nil {
                addButton.isHidden = profiles!.count > 0
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
    
    @IBAction func reloadDatasAction(_ sender: NSButton) {
        
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            getAllCerficates()
        case .bundleId:
            getAllBundleIDs()
        case .device:
            getAllDevices()
        case .profile:
            getAllProfiles()
        }
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
        self.editContentView.isHidden = true
        reloadHeaderViews()
    }
    
    private func setupButton(btn: NSButton){
        if btn.state == .on {
            btn.titleTextColor = NSColor(red:0.00, green:0.63, blue:0.78, alpha:1.00)
        } else {
            btn.titleTextColor = NSColor.init(white: 0.95, alpha: 1)
        }
    }
}

extension ProvisionController {
    
    private func getAllCerficates() {
        
        self.startReload()
        _ = ProfileDataManager().listAllCertificates().done {[weak self] (cers) in
            self?.certificates = cers
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
            self?.bundleIDs = bundles
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
            self?.devices = devices
            self?.endReload()
            self?.addButton.isHidden = devices.count > 0
            self?.contentTableView.reloadData()
        }
    }
    
    private func getAllProfiles() {
        
        self.startReload()
        _ = ProfileDataManager().listAllProfiles().done {[weak self] (profiles) in
            self?.profiles = profiles
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
}

extension ProvisionController: NSTableViewDelegate {
    
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
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            if let certificate = self.certificates?[row] {
                switch columnIndex {
                case 0:
                    text = certificate.attributes?.displayName ?? ""
                case 1:
                    text = (certificate.attributes?.certificateType).map { $0.rawValue } ?? ""
                case 2:
                    text = (certificate.attributes?.platform).map { $0.rawValue } ?? ""
                case 3:
                    text = certificate.attributes?.name ?? ""
                case 4:
                    text = certificate.attributes?.expirationDate?.dateConvertString() ?? ""
                default:
                    text = ""
                }
            }
        case .bundleId:
            if let bundleID = self.bundleIDs?[row] {
                switch columnIndex {
                case 0:
                    text = bundleID.attributes?.name ?? ""
                case 1:
                    text = bundleID.attributes?.identifier ?? ""
                case 2:
                    text = bundleID.attributes?.platform.map { $0.rawValue } ?? ""
                default:
                    text = ""
                }
            }
        case .device:
            if let device = self.devices?[row] {
                switch columnIndex {
                case 0:
                    text = device.attributes?.name ?? ""
                case 1:
                    text = device.attributes?.udid ?? ""
                case 2:
                    text = device.attributes?.platform.map { $0.rawValue } ?? ""
                default:
                    text = ""
                }
            }
        case .profile:
            if let profile = self.profiles?[row] {
                switch columnIndex {
                case 0:
                    text = profile.attributes?.name ?? ""
                case 1:
                    text = profile.id 
                case 2:
                    text = profile.attributes?.profileType.map { $0.rawValue } ?? ""
                case 3:
                    text = profile.attributes?.expirationDate?.dateConvertString() ?? ""
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
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        switch selectType {
        case .certificate:
            let certificate = self.certificates![contentTableView.selectedRow]
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
            let bundleId = self.bundleIDs![contentTableView.selectedRow]
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
            let device = self.devices![contentTableView.selectedRow]
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
            let profile = self.profiles![contentTableView.selectedRow]
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
        
        alert.informativeText = infomation
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}

extension ProvisionController: NSTableViewDataSource {
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
      
        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
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
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        return 35
    }
}

extension ProvisionController: ContextMenu{
    
    @objc func tableView(_ tableView: NSTableView, menuForRows rows:IndexSet)->NSMenu?{

        let selectType: ProvisionFileType = ProvisionFileType(rawValue: lastSelectLeftButton!.tag)!
        self.editMenu.removeAllItems()
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
        return self.editMenu
    }
    
    @objc func tableView(_ tableView: NSTableView, clickForRow row: Int) -> Void {
        
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

extension Date {
    
     func dateConvertString(_ dateFormat:String="yyyy-MM-dd") -> String {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: self)
        return date.components(separatedBy: " ").first!
    }
}


@objc protocol ContextMenu {
    @objc func tableView(_ tableView: NSTableView, menuForRows rows:IndexSet)->NSMenu?
    @objc func tableView(_ tableView: NSTableView, clickForRow row: Int) -> Void
}

extension NSTableView {
    
    open override func menu(for event: NSEvent) -> NSMenu? {
        let location = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: location)
        if row >= 0 && event.type == .rightMouseDown {
            
            var selected = self.selectedRowIndexes
            if  false ==  selected.contains(row) {
                selected = IndexSet.init(integer: row)
                self.selectRowIndexes(selected, byExtendingSelection: false)
            }
            if  let dele:ContextMenu = (self.delegate as? ContextMenu)  {
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
            if  let dele:ContextMenu = (self.delegate as? ContextMenu)  {
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

//
//  MultipleChooseView.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/9.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa

class MultipleChooseView: NSView {
 
    @IBOutlet weak var allChooseButton: NSButton!
    @IBOutlet weak var contentTableView: NSTableView!
    
    private var all_choosed: Bool = false{
        didSet{
            self.choosed.removeAll()
            if all_choosed {
                for i in 0..<choose_source.count {
                    self.choosed.append(i)
                }
            }
            self.contentTableView.reloadData()
        }
    }
    
    var choosed: [Int] = [] {
        didSet{
            self.contentTableView.reloadData()
        }
    }

    var choosedDone: (([Int]?)->())?
    
    var choose_source: [String] = [] {
        didSet{
            self.contentTableView.reloadData()
        }
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
        
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.init(white: 0.28, alpha: 1).cgColor
        
        allChooseButton.titleTextColor = NSColor.white
    }
    
    @IBAction func chooseCellAction(_ sender: NSButton) {
        let isOn = sender.state == .on
        let index = sender.tag
        if isOn {
            self.choosed.append(index)
        } else {
            self.choosed.removeAll { (item) -> Bool in
                return item == index
            }
        }
    }
    @IBAction func allSelectAction(_ sender: NSButton) {
        self.all_choosed = !self.all_choosed
    }
    @IBAction func backAction(_ sender: Any) {
        if self.choosedDone != nil {
            self.choosedDone!(nil)
        }
        self.removeFromSuperview()
    }
    @IBAction func doneAction(_ sender: Any) {
        if self.choosedDone != nil {
            let choosedSortElements = self.choosed.sorted()
            self.choosedDone!(choosedSortElements)
        }
        self.removeFromSuperview()
    }
}

extension MultipleChooseView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MultipleChooseCell"), owner: self) as! NSTableCellView
        
        var chooseButton: NSButton = NSButton()
        for view in cellView.subviews {
            if view.className == NSButton.className() {
                chooseButton = view as! NSButton
                chooseButton.tag = row
                break
            }
        }
        
        cellView.wantsLayer = true
        cellView.layer!.backgroundColor = NSColor.init(white: 0.35, alpha: 1).cgColor
        
        let text: String = self.choose_source[row]
        
        cellView.textField?.alignment = .center
        cellView.textField?.stringValue = text
        cellView.textField?.textColor = NSColor.white
        cellView.textField?.font = NSFont.systemFont(ofSize: 15)
        
        let isOn = self.choosed.contains(row)
        if isOn {
            chooseButton.state = .on
        } else {
            chooseButton.state = .off
        }
        
        return cellView
    }
}

extension MultipleChooseView: NSTableViewDataSource {
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return self.choose_source.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        return 30
    }
}

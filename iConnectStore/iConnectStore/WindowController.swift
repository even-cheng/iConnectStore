//
//  WindowController.swift
//  iConnectStore
//
//  Created by 快游 on 2019/11/27.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa
import SnapKit
import PromiseKit

class WindowController: NSWindowController {
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.setup()
    }
    
    
    func setup(){
        
        self.window?.contentView?.wantsLayer = true
        self.window?.contentView?.layer!.backgroundColor = NSColor(red:0.28, green:0.28, blue:0.28, alpha:1.00).cgColor

        //设置为点击背景可以移动窗口
        self.window?.isMovableByWindowBackground = true
    }
}

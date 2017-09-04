//
//  KeyValueObserver.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation

class KeyValueObserver: NSObject {
    typealias KeyValueObservingCallback = (_ change: [AnyHashable: Any]?) -> Void
    
    fileprivate let object: NSObject
    fileprivate let keyPath: String
    fileprivate let callback: KeyValueObservingCallback
    fileprivate var kvoContext = 0
    
    @objc init(object: NSObject, keyPath: String, options: NSKeyValueObservingOptions, callback: @escaping KeyValueObservingCallback) {
        self.object = object
        self.keyPath = keyPath
        self.callback = callback
        super.init()
        object.addObserver(self, forKeyPath: keyPath, options: options, context: &kvoContext)
    }
    
    deinit {
        object.removeObserver(self, forKeyPath: keyPath, context: &kvoContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            self.callback(change)
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

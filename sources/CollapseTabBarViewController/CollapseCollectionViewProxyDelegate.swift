//
//  CollapseCollectionViewProxyDelegate.swift
//  PageTabBarController
//
//  Created by Mingloan Chan on 11/18/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
class CollapseCollectionViewProxy: NSObject, CollapseCollectionViewExtendedDelegate {
    
    weak var extendedDelegate: CollapseCollectionViewExtendedDelegate?
    // dirty
    weak var extendedDelegateObject: AnyObject?
    
    override func responds(to aSelector: Selector!) -> Bool {
        return (extendedDelegateObject?.responds(to: aSelector))! || super.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return extendedDelegate
    }
}

extension CollapseCollectionViewProxy: UICollectionViewDelegate {}

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
    
//    override func responds(to aSelector: Selector!) -> Bool {
//        return
//    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return extendedDelegate
    }
}

extension CollapseCollectionViewProxy: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //extendedDelegate?.scrollViewDidEnd
//        if ([self.delegate respondsToSelector:_cmd]) {
//            [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        [(MXScrollView *)scrollView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//        if ([self.delegate respondsToSelector:_cmd]) {
//            [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//        }
    }
}

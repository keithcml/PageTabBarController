//
//  PageTabBarCollectionView.swift
//  PageTabBarController
//
//  Created by Keith Chan on 12/12/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit

// MARK: - CollectionView Flow Layout Subclass
internal final class PageTabBarCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        let oldBounds = cv.bounds
        if newBounds.height != oldBounds.height {
            cv.collectionViewLayout.invalidateLayout()
            return false
        }
        return false
    }
    
}

// MARK: - PageTabBarCollectionViewTouchDelegate
@objc
public protocol PageTabBarCollectionViewTouchDelegate: NSObjectProtocol {
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldReceivePress press: UIPress) -> Bool
}

// MARK: - PageTabBarCollectionView

@objcMembers
open class PageTabBarCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    
    var touchDelegate: PageTabBarCollectionViewTouchDelegate?
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        panGestureRecognizer.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
            let translation = panGestureRecognizer.translation(in: gestureRecognizer.view)
            return abs(velocity.x) > abs(velocity.y) && abs(translation.x) > abs(translation.y)
        }
        
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizerShouldBegin: gestureRecognizer) {
            return boolean
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer) {
            return boolean
        }
        return false
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer) {
            return boolean
        }
        return false
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return boolean
        }
        return false
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldReceive: touch) {
            return boolean
        }
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldReceivePress: press) {
            return boolean
        }
        return true
    }
}

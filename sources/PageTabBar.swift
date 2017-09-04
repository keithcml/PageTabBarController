//
//  PageTabBar.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

internal class PageTabBar: UIView {
    
    var isInteracting = false {
        didSet {
            isUserInteractionEnabled = !isInteracting
        }
    }
    
    var toIndex: ((Int) -> ()) = { _ in }
    
    var selectedIndex = 0
    
    fileprivate var items = [PageTabBarItem]()
    fileprivate var itemWidth: CGFloat {
        if items.count == 0 {
            return 0
        }
        return bounds.width/CGFloat(items.count)
    }
    fileprivate var indicatorOriginX: CGFloat {
        return itemWidth * CGFloat(selectedIndex)
    }
    
    fileprivate var indicatorLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.darkJungleGreen()
        return line
    }()
    
    fileprivate var topLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.platinum().withAlphaComponent(0.3)
        return line
    }()
    fileprivate var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.platinum()
        return line
    }()
    
    fileprivate var indicatorLocationObserver: KeyValueObserver?
    
    convenience init(frame: CGRect, tabBarItems: [PageTabBarItem]) {
        self.init(frame: frame)
        items = tabBarItems
        commonInit()
    }
    
    fileprivate func commonInit() {
        var previous: PageTabBarItem?
        for (idx, item) in items.enumerated() {
            addSubview(item)
            if let p = previous {
                constrain(item, p) { (targetView, pRef) in
                    targetView.top == targetView.superview!.top
                    targetView.bottom == targetView.superview!.bottom
                    targetView.left == pRef.right
                    pRef.width == targetView.width
                    if idx == items.count - 1 {
                        targetView.right == targetView.superview!.right
                    }
                }
            }
            else {
                constrain(item) { (targetView) in
                    targetView.top == targetView.superview!.top
                    targetView.bottom == targetView.superview!.bottom
                    targetView.left == targetView.superview!.left
                }
                // initial color
                item.set(color: UIColor.darkJungleGreen())
            }
            previous = item
            
            item.didSelect = { [unowned self] _ in
                self.selectedIndex = idx
                // update page view controller
                self.toIndex(idx)
            }
        }
        
        topLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        addSubview(topLine)
        constrain(topLine) { (targetView) in
            targetView.right == targetView.superview!.right
            targetView.top == targetView.superview!.top
            targetView.left == targetView.superview!.left
            targetView.height == 1
        }
        
        bottomLine.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        addSubview(bottomLine)
        constrain(bottomLine) { (targetView) in
            targetView.right == targetView.superview!.right
            targetView.bottom == targetView.superview!.bottom
            targetView.left == targetView.superview!.left
            targetView.height == 1
        }
        
        indicatorLine.frame = CGRect(x: 0, y: bounds.height - 1, width: itemWidth, height: 1)
        addSubview(indicatorLine)
        indicatorLocationObserver =
            KeyValueObserver(
                object: indicatorLine,
                keyPath: "frame",
                options: [.new]){ [weak self] (change) in
                    if let
                        strongSelf = self,
                        let callbackChanges = change,
                        let newFrameValue = callbackChanges[NSKeyValueChangeKey.newKey] as? NSValue {
                        
                        let newFrame = newFrameValue.cgRectValue
                        let location = newFrame.origin.x + newFrame.width/2
                        let index = Int(ceil(location/newFrame.width)) - 1
                        for (idx, button) in strongSelf.items.enumerated() {
                            button.set(color: idx == index ? UIColor.darkJungleGreen() : UIColor.pastelGray())
                        }
                    }
        }
    }
    
    deinit {
        indicatorLocationObserver = nil
    }
    
    func setIndicatorPosition(_ position: CGFloat) {
        let indicatorLineWidth = UIScreen.main.bounds.width / CGFloat(items.count)
        indicatorLine.frame = CGRect(x: position, y: indicatorLine.frame.origin.y, width: indicatorLineWidth, height: indicatorLine.frame.height)
    }
}

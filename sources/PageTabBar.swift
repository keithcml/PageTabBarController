//
//  PageTabBar.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objc public enum PageTabBarPosition: Int {
    case top = 0
    case bottom
}


internal enum PageTabBarItemArrngement {
    case fixedWidth(width: CGFloat)
    case compact
}

internal class PageTabBar: UIView {
    
    internal static var indicatorLineColor = UIColor.blue
    internal static var topLineColor = UIColor.lightGray
    internal static var bottomLineColor = UIColor.lightGray
    
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
        line.backgroundColor = PageTabBar.indicatorLineColor
        return line
    }()
    
    fileprivate var topLine: UIView = {
        let line = UIView()
        line.backgroundColor = PageTabBar.topLineColor
        return line
    }()
    fileprivate var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = PageTabBar.bottomLineColor
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
            item.translatesAutoresizingMaskIntoConstraints = false
            
            item.topAnchor.constraint(equalTo: topAnchor).isActive = true
            item.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            if let p = previous {
                
                item.leadingAnchor.constraint(equalTo: p.trailingAnchor).isActive = true
                item.widthAnchor.constraint(equalTo: p.widthAnchor, multiplier: 1.0)
                
                if idx == items.count - 1 {
                    item.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                }
            }
            else {
                item.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                // initial color
                // item.set(color: UIColor.darkJungleGreen())
            }
            previous = item
            
            item.didSelect = { [unowned self] _ in
                self.selectedIndex = idx
                // update page view controller
                self.toIndex(idx)
            }
        }
        
        topLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)
        addSubview(topLine)
        topLine.translatesAutoresizingMaskIntoConstraints = false
        topLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        bottomLine.frame = CGRect(x: 0, y: bounds.height - 0.5, width: bounds.width, height: 0.5)
        addSubview(bottomLine)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
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
                            button.overlayColor = idx == index ? UIColor.gray : UIColor.lightGray
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

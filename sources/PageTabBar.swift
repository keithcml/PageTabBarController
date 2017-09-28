//
//  PageTabBar.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
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

@objc public enum PageTabBarPosition: Int {
    case top = 0
    case bottom
}


internal enum PageTabBarItemArrangement {
    case fixedWidth(width: CGFloat)
    case compact
}

open class PageTabBar: UIView {
    
    open var barTintColor: UIColor = .white {
        didSet {
            backgroundColor = barTintColor
            setNeedsDisplay()
        }
    }
    
    open var indicatorLineHidden = false {
        didSet {
            indicatorLine.isHidden = indicatorLineHidden
        }
    }
    open var topLineHidden = false {
        didSet {
            topLine.isHidden = topLineHidden
        }
    }
    open var bottomLineHidden = false {
        didSet {
            bottomLine.isHidden = bottomLineHidden
        }
    }
    open var indicatorLineColor = UIColor.blue  {
        didSet {
            indicatorLine.backgroundColor = indicatorLineColor
            setNeedsDisplay()
        }
    }
    open var indicatorLineHeight: CGFloat = 1.0  {
        didSet {
            indicatorLine.frame = CGRect(x: indicatorLine.frame.minX, y: bounds.height - indicatorLineHeight, width: itemWidth, height: indicatorLineHeight)
        }
    }
    open var topLineColor = UIColor.lightGray  {
        didSet {
            topLine.backgroundColor = topLineColor
            setNeedsDisplay()
        }
    }
    open var bottomLineColor = UIColor.lightGray  {
        didSet {
            bottomLine.backgroundColor = bottomLineColor
            setNeedsDisplay()
        }
    }
    
    internal var isInteracting = false {
        didSet {
            isUserInteractionEnabled = !isInteracting
        }
    }
    
    internal var toIndex: ((Int) -> ()) = { _ in }
    
    fileprivate var items = [PageTabBarItem]()
    fileprivate var itemWidth: CGFloat {
        if items.count == 0 {
            return 0
        }
        return bounds.width/CGFloat(items.count)
    }

    fileprivate var indicatorLine: UIView = {
        let line = UIView()
        line.backgroundColor = .blue
        return line
    }()
    
    fileprivate var topLine: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        return line
    }()
    fileprivate var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        return line
    }()
    
    convenience init(frame: CGRect, tabBarItems: [PageTabBarItem], initialIndex: Int = 0) {
        self.init(frame: frame)
        items = tabBarItems
        commonInit(initialIndex: initialIndex)
    }
    
    fileprivate func commonInit(initialIndex: Int) {
        
        var previous: PageTabBarItem?
        
        for (idx, item) in items.enumerated() {
            addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
            
            item.topAnchor.constraint(equalTo: topAnchor).isActive = true
            item.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            if let p = previous {
                
                item.leadingAnchor.constraint(equalTo: p.trailingAnchor).isActive = true
                item.widthAnchor.constraint(equalTo: p.widthAnchor, multiplier: 1.0).isActive = true
                
                if idx == items.count - 1 {
                    item.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                }
            }
            else {
                item.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                // initial color
                item.isSelected = initialIndex == idx
            }
            previous = item
            
            item.didTap = { [unowned self] _ in
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
        
        indicatorLine.frame = CGRect(x: CGFloat(initialIndex) * itemWidth, y: bounds.height - indicatorLineHeight, width: itemWidth, height: indicatorLineHeight)
        addSubview(indicatorLine)
    }
    
    internal func setIndicatorPosition(_ position: CGFloat) {
        indicatorLine.frame = CGRect(x: position, y: bounds.height - indicatorLineHeight, width: itemWidth, height: indicatorLineHeight)
        
        let location = position + itemWidth/2
        let index = Int(ceil(location/itemWidth)) - 1
        
        for (idx, button) in items.enumerated() {
            button.isSelected = idx == index ? true : false
        }
    }
    
    internal func getCurrentIndex() -> Int {
        let index = ceil(indicatorLine.frame.minX/itemWidth)
        return Int(index)
    }
}

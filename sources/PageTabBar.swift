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

internal protocol PageTabBarDelegate: class {
    func pageTabBar(_ tabBar: PageTabBar, indexDidChanged index: Int)
}

@objc
public enum PageTabBarPosition: Int {
    case topAttached = 0
    case top
    case bottom
}


internal enum PageTabBarItemArrangement {
    case fixedWidth(width: CGFloat)
    case compact
}

@objcMembers
open class PageTabBar: UIView {
    
    internal weak var delegate: PageTabBarDelegate?
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: barHeight)
    }
    
    override open var bounds: CGRect {
        didSet {
            scrollToItem(at: currentIndex, animated: false)
        }
    }
    
    open var barHeight: CGFloat = 44.0 {
        didSet {
            guard oldValue != barHeight else { return }
            indicatorLine.frame.origin = CGPoint(x: indicatorLine.frame.minX, y: barHeight - indicatorLineHeight)
            bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: barHeight)
            //superview?.setNeedsLayout()
        }
    }
    
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
            indicatorLine.frame = CGRect(x: indicatorLine.frame.minX, y: barHeight - indicatorLineHeight, width: itemWidth, height: indicatorLineHeight)
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
    
    internal var currentIndex: Int = 0 {
        didSet {
            guard oldValue != currentIndex else { return }
            delegate?.pageTabBar(self, indexDidChanged: currentIndex)
        }
    }
    
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
    
    private var itemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    convenience init(tabBarItems: [PageTabBarItem]) {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        items = tabBarItems
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        items.forEach {
            itemStackView.addArrangedSubview($0)
            $0.delegate = self
        }
        
        itemStackView.frame = bounds
        itemStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(itemStackView)
        
        
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
        
        addSubview(indicatorLine)
        scrollToItem(at: currentIndex, animated: false)
    }
    
    internal func setIndicatorPosition(_ position: CGFloat) -> Int {

        indicatorLine.frame = CGRect(x: position, y: barHeight - indicatorLineHeight, width: itemWidth, height: indicatorLineHeight)
        
        let location = position + itemWidth/2
        let index = Int(ceil(location/itemWidth)) - 1
        
        for (idx, button) in items.enumerated() {
            button.isSelected = idx == index ? true : false
        }
        
        return index
    }
    
    internal func updateCurrentIndex() {
        let index = ceil(indicatorLine.frame.minX/itemWidth)
        currentIndex = Int(index)
    }
    
    internal func scrollToItem(at index: Int, animated: Bool) {
        let origin = CGPoint(x: ceil(CGFloat(index) * itemWidth), y: barHeight - indicatorLineHeight)
        let size = CGSize(width: itemWidth, height: indicatorLineHeight)
        indicatorLine.frame = CGRect(origin: origin, size: size)
        for (idx, button) in items.enumerated() {
            button.isSelected = idx == index ? true : false
        }
    }
    
    internal func replaceTabBarItems(_ newTabBarItems: [PageTabBarItem], targetIndex: Int = 0, animated: Bool = true) {
        
        itemStackView.arrangedSubviews.forEach {
            itemStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        newTabBarItems.forEach {
            itemStackView.addArrangedSubview($0)
            $0.delegate = self
        }
        
        items = newTabBarItems
        currentIndex = targetIndex
        scrollToItem(at: currentIndex, animated: animated)
    }
    
    open func setBarHeight(_ height: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.barHeight = height
            })
        } else {
            barHeight = height
        }
    }
}

extension PageTabBar: PageTabBarItemDelegate {
    func pageTabBarItemDidTap(_ item: PageTabBarItem) {
        if let index = items.index(of: item) {
            currentIndex = index
        }
    }
}

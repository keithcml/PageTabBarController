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
    func pageTabBarCurrentIndex(_ tabBar: PageTabBar) -> Int
    func pageTabBar(_ tabBar: PageTabBar, indexDidChanged index: Int)
}

@objc
public enum PageTabBarPosition: Int {
    case topAttached = 0
    case topInsetAttached
    case bottom
}

internal enum PageTabBarItemArrangement {
    case fixedWidth(width: CGFloat)
    case compact
}

public typealias LineWidthUnit = Int

@objcMembers
open class PageTabBar: UIView {
    
    internal weak var delegate: PageTabBarDelegate?
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: barHeight)
    }
    
    override open var bounds: CGRect {
        didSet {
            repositionAndResizeIndicatorView()
        }
    }
    
    open var barHeight: CGFloat = 44.0 {
        didSet {
            guard oldValue != barHeight else { return }
            indicatorLine.frame.origin = CGPoint(x: indicatorLine.frame.minX, y: barHeight - indicatorLineHeight)
            bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: barHeight)
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
    
    open var indicatorLineColor = UIColor.blue {
        didSet {
            indicatorLine.backgroundColor = indicatorLineColor
            setNeedsDisplay()
        }
    }
    
    open var indicatorLineHeight: CGFloat = 1.0 {
        didSet {
            indicatorLine.frame = CGRect(x: indicatorLine.frame.minX, y: barHeight - indicatorLineHeight, width: itemWidth, height: indicatorLineHeight)
        }
    }
    
    open var topLineColor = UIColor.lightGray {
        didSet {
            topLine.backgroundColor = topLineColor
            setNeedsDisplay()
        }
    }
    
    open var bottomLineColor = UIColor.lightGray {
        didSet {
            bottomLine.backgroundColor = bottomLineColor
            setNeedsDisplay()
        }
    }
    
    open var topLineWidth: LineWidthUnit = 1 {
        didSet {
            let lineWidth = CGFloat(topLineWidth) / UIScreen.main.scale
            topLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: lineWidth)
        }
    }
    
    open var bottomLineWidth: LineWidthUnit = 1 {
        didSet {
            let lineWidth = CGFloat(bottomLineWidth) / UIScreen.main.scale
            bottomLine.frame = CGRect(x: 0, y: bounds.height - lineWidth, width: bounds.width, height: lineWidth)
        }
    }
    
    internal var isInteracting = false {
        didSet {
            isUserInteractionEnabled = !isInteracting
        }
    }
    
    private var items = [PageTabBarItem]()
    private var itemWidth: CGFloat {
        if items.count == 0 {
            return 0
        }
        return bounds.width/CGFloat(items.count)
    }

    private var indicatorLine: UIView = {
        let line = UIView()
        line.backgroundColor = .blue
        return line
    }()
    
    private var topLine: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        return line
    }()
    
    private var bottomLine: UIView = {
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
    
    private func commonInit() {
        
        backgroundColor = barTintColor
        
        items.forEach {
            itemStackView.addArrangedSubview($0)
            $0.delegate = self
        }
        
        itemStackView.frame = bounds
        itemStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(itemStackView)
        
        var lineWidth = CGFloat(topLineWidth) / UIScreen.main.scale
        topLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: lineWidth)
        addSubview(topLine)
        topLine.translatesAutoresizingMaskIntoConstraints = false
        topLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        lineWidth = CGFloat(bottomLineWidth) / UIScreen.main.scale
        bottomLine.frame = CGRect(x: 0, y: bounds.height - lineWidth, width: bounds.width, height: lineWidth)
        addSubview(bottomLine)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(indicatorLine)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        var lineWidth = CGFloat(topLineWidth) / UIScreen.main.scale
        topLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: lineWidth)
        lineWidth = CGFloat(bottomLineWidth) / UIScreen.main.scale
        bottomLine.frame = CGRect(x: 0, y: bounds.height - lineWidth, width: bounds.width, height: lineWidth)
    }
    
    internal func setIndicatorPosition(_ position: CGFloat, animated: Bool = false) {

        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.setIndicatorPosition(position)
            })
            return
        }
        
        indicatorLine.center.x = position + itemWidth/2
        
        let index = Int(indicatorLine.center.x/itemWidth)
        for (idx, button) in items.enumerated() {
            button.isSelected = idx == index ? true : false
        }
    }
    
    private func repositionAndResizeIndicatorView() {
        guard let index = delegate?.pageTabBarCurrentIndex(self) else { return }
        
        let origin = CGPoint(x: ceil(CGFloat(index) * itemWidth), y: barHeight - indicatorLineHeight)
        let size = CGSize(width: itemWidth, height: indicatorLineHeight)
        indicatorLine.frame = CGRect(origin: origin, size: size)
        for (idx, button) in items.enumerated() {
            button.isSelected = idx == index ? true : false
        }
    }
    
    internal func replaceTabBarItems(_ newTabBarItems: [PageTabBarItem]) {
        
        itemStackView.arrangedSubviews.forEach {
            itemStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        newTabBarItems.forEach {
            itemStackView.addArrangedSubview($0)
            $0.delegate = self
        }
        
        items = newTabBarItems
        
        layoutIfNeeded()
        repositionAndResizeIndicatorView()
    }
    
    /*  Public Methods
     *
     */
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
            delegate?.pageTabBar(self, indexDidChanged: index)
        }
    }
}

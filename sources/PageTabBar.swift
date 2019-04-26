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

public enum PageTabBarIndicatorPosition {
    case top(offset: CGFloat)
    case bottom(offset: CGFloat)
}

public enum PageTabBarIndicatorLineWidth {
    case fill
    case contentWidth
}

internal enum PageTabBarItemArrangement {
    case fixedWidth(width: CGFloat)
    case compact
}

public typealias LineWidthUnit = Int

@objcMembers
open class PageTabBar: UIView {
    
    public struct BarAppearanceSettings {
        public var isTranslucent: Bool
        public var translucentFactor: CGFloat
        public var barTintColor: UIColor?
        public var topLineHidden: Bool
        public var bottomLineHidden: Bool
        public var topLineColor: UIColor?
        public var bottomLineColor: UIColor?
        public var topLineWidth: LineWidthUnit
        public var bottomLineWidth: LineWidthUnit
    }
    
    public struct IndicatorLineAppearanceSettings {
        public var isHidden: Bool
        public var lineHeight: CGFloat
        public var lineWidth: PageTabBarIndicatorLineWidth
        public var lineColor: UIColor?
        public var position: PageTabBarIndicatorPosition
    }
    
    public static var defaultBarAppearanceSettings = BarAppearanceSettings(isTranslucent: false,
                                                                         translucentFactor: 0.6,
                                                                         barTintColor: .white,
                                                                         topLineHidden: false,
                                                                         bottomLineHidden: false,
                                                                         topLineColor: .lightGray,
                                                                         bottomLineColor: .lightGray,
                                                                         topLineWidth: 1,
                                                                         bottomLineWidth: 1)
    
    public static var defaultIndicatorLineAppearanceSettings = IndicatorLineAppearanceSettings(isHidden: false,
                                                                                             lineHeight: 1,
                                                                                             lineWidth: .fill,
                                                                                             lineColor: UIApplication.shared.delegate?.window??.tintColor,
                                                                                             position: PageTabBarIndicatorPosition.bottom(offset: 0))
    
    open var appearance: BarAppearanceSettings = PageTabBar.defaultBarAppearanceSettings {
        didSet {

            backdropView.translucentFactor = appearance.translucentFactor
            backdropView.barTintColor = appearance.barTintColor ?? .white
            backdropView.isTranslucent = appearance.isTranslucent
            
            topLine.isHidden = appearance.topLineHidden
            bottomLine.isHidden = appearance.bottomLineHidden
            
            topLine.backgroundColor = appearance.topLineColor
            bottomLine.backgroundColor = appearance.bottomLineColor
            
            let topLineWidth = CGFloat(appearance.topLineWidth) / UIScreen.main.scale
            topLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: topLineWidth)
            
            let bottomLineWidth = CGFloat(appearance.bottomLineWidth) / UIScreen.main.scale
            bottomLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bottomLineWidth)
            
            setNeedsDisplay()
        }
    }
    
    open var indicatorLineAppearance: IndicatorLineAppearanceSettings = PageTabBar.defaultIndicatorLineAppearanceSettings {
        didSet {
            indicatorLine.isHidden = indicatorLineAppearance.isHidden
            indicatorLine.backgroundColor = indicatorLineAppearance.lineColor
            indicatorLine.frame = CGRect(x: indicatorLine.frame.minX, y: indicatorLineOriginY, width: indicatorLineWidth(at: 0), height: indicatorLineHeight)
        }
    }
    
    // Private Getter
    
    private var indicatorLineHeight: CGFloat {
        return indicatorLineAppearance.lineHeight
    }
    
    private var indicatorLineOriginY: CGFloat {
        switch indicatorLineAppearance.position {
        case let .top(offset):
            return offset
        case let .bottom(offset):
            return barHeight - indicatorLineHeight - offset
        }
    }
    
    // Delegates
    
    internal weak var delegate: PageTabBarDelegate?
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: barHeight)
    }
    
    override open var bounds: CGRect {
        didSet {
            repositionAndResizeIndicatorView()
        }
    }
    
    open var barHeight = CGFloat(44) {
        didSet {
            guard oldValue != barHeight else { return }
            indicatorLine.frame.origin = CGPoint(x: indicatorLine.frame.minX, y: indicatorLineOriginY)
            bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: barHeight)
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
    
    private let backdropView: PageTabBarBackdropView = {
        let backdropView = PageTabBarBackdropView(frame: CGRect(x: 0, y: 0, width: 375, height: 44))
        backdropView.barTintColor = UIColor.white
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        return backdropView
    }()
    
    convenience init(tabBarItems: [PageTabBarItem]) {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        items = tabBarItems
        commonInit()
    }
    
    private func commonInit() {
        
        backdropView.isTranslucent = false
        backdropView.barTintColor = appearance.barTintColor ?? .white
        addSubview(backdropView)
        
        NSLayoutConstraint.activate([backdropView.topAnchor.constraint(equalTo: topAnchor),
                                     backdropView.leftAnchor.constraint(equalTo: leftAnchor),
                                     backdropView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     backdropView.rightAnchor.constraint(equalTo: rightAnchor)])
        
        items.forEach {
            itemStackView.addArrangedSubview($0)
            $0.delegate = self
        }
        
        itemStackView.frame = bounds
        itemStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(itemStackView)
        
        var lineWidth = CGFloat(appearance.topLineWidth) / UIScreen.main.scale
        topLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: lineWidth)
        addSubview(topLine)
        topLine.translatesAutoresizingMaskIntoConstraints = false
        topLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        lineWidth = CGFloat(appearance.bottomLineWidth) / UIScreen.main.scale
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
        var lineWidth = CGFloat(appearance.topLineWidth) / UIScreen.main.scale
        topLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: lineWidth)
        lineWidth = CGFloat(appearance.bottomLineWidth) / UIScreen.main.scale
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
        
        let oldWidth = indicatorLine.bounds.width
        let newWidth = indicatorLineWidth(at: index)
        
        if oldWidth != newWidth {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
                self.indicatorLine.bounds = CGRect(x: 0, y: 0, width: newWidth, height: self.indicatorLineHeight)
            }, completion: nil)
        } else {
            indicatorLine.bounds = CGRect(x: 0, y: 0, width: newWidth, height: self.indicatorLineHeight)
        }
        
        for (idx, button) in items.enumerated() {
            button.isSelected = idx == index ? true : false
        }
    }
    
    private func repositionAndResizeIndicatorView() {
        guard let index = delegate?.pageTabBarCurrentIndex(self) else { return }
        
        layoutIfNeeded()
        
        let centerX = itemWidth / 2 + ceil(CGFloat(index) * itemWidth)
        indicatorLine.center = CGPoint(x: centerX, y: indicatorLineOriginY + indicatorLineHeight / 2)
        indicatorLine.bounds = CGRect(x: 0, y: 0, width: indicatorLineWidth(at: index), height: indicatorLineHeight)

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
    
    /**
     *  Line Width Calculation
     */
    private func indicatorLineWidth(at index: Int) -> CGFloat {
        switch indicatorLineAppearance.lineWidth {
        case .fill:
            return itemWidth
        case .contentWidth:
            return items[index].tabBarButtonContentWidth
        }
    }
}

extension PageTabBar: PageTabBarItemDelegate {
    func pageTabBarItemDidTap(_ item: PageTabBarItem) {
        if let index = items.firstIndex(of: item) {
            delegate?.pageTabBar(self, indexDidChanged: index)
        }
    }
}

//
//  PageTabBarItem.swift
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

protocol PageTabBarItemDelegate: NSObjectProtocol {
    func pageTabBarItemDidTap(_ item: PageTabBarItem)
}

internal enum PageTabBarItemType {
    case text
    case icon
}

private class PageTabBarButton: UIButton {
    
    fileprivate var pageTabBarItemType = PageTabBarItemType.text
    
    override var intrinsicContentSize: CGSize {
        
        // use natural size
        if designatedContentSize.equalTo(.zero) {
            return super.intrinsicContentSize
        }
        
        switch pageTabBarItemType {
        case .text:
            return CGSize(width: super.intrinsicContentSize.width, height: designatedContentSize.height)
        case .icon:
            return designatedContentSize
        }
    }
    
    fileprivate var designatedContentSize: CGSize = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    fileprivate var color: UIColor? = UIColor.lightGray
    fileprivate var selectedColor: UIColor? = UIColor.blue
    
    override var isHighlighted: Bool {
        didSet {
            switch pageTabBarItemType {
            case .text:
                alpha = isHighlighted ? 0.5 : 1.0
                break
            case .icon:
                if isHighlighted {
                    tintColor = isSelected ? selectedColor?.withAlphaComponent(0.5) : color?.withAlphaComponent(0.5)
                }
                else {
                    tintColor = isSelected ? selectedColor : color
                }
                break
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            switch pageTabBarItemType {
            case .text:
                break
            case .icon:
                tintColor = isSelected ? selectedColor : color
                break
            }
        }
    }
}

@objcMembers
open class PageTabBarItem: UIView {
    
    public struct AppearanceSettings {
        public var font: UIFont
        public var unselectedColor: UIColor?
        public var selectedColor: UIColor?
        public var contentHeight: CGFloat
        public var offset: CGSize
        
        public static let automaticDimemsion = CGFloat(0)
    }
    
    public static var defaultAppearanceSettings = AppearanceSettings(font: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium),
                                                                   unselectedColor: UIColor.lightGray,
                                                                   selectedColor: UIApplication.shared.delegate?.window??.tintColor,
                                                                   contentHeight: AppearanceSettings.automaticDimemsion,
                                                                   offset: .zero)
    
    open var appearance: AppearanceSettings = PageTabBarItem.defaultAppearanceSettings {
        didSet {
            tabBarButton.titleLabel?.font = appearance.font
            tabBarButton.color = appearance.unselectedColor
            tabBarButton.selectedColor = appearance.selectedColor
            tabBarButton.setTitleColor(appearance.unselectedColor, for: .normal)
            tabBarButton.setTitleColor(appearance.selectedColor, for: .selected)
            
            switch type {
            case .text:
                tabBarButton.designatedContentSize = CGSize(width: AppearanceSettings.automaticDimemsion, height: appearance.contentHeight)
                break
            case .icon:
                tabBarButton.designatedContentSize = CGSize(width: appearance.contentHeight, height: appearance.contentHeight)
                break
            }
            
            tabBarButtonHorizontalOffsetConstraint?.constant = appearance.offset.width
            tabBarButtonVerticalOffsetConstraint?.constant = appearance.offset.height
            layoutIfNeeded()
        }
    }
    
    internal var isSelected = false {
        didSet {
            tabBarButton.isSelected = isSelected
        }
    }
    
    internal var tabBarButtonContentWidth: CGFloat {
        return tabBarButton.bounds.width
    }
    
    internal var badgeCount = 0 {
        didSet {
            badgeView.badgeValue = badgeCount
        }
    }
    
    internal var delegate: PageTabBarItemDelegate?
    
    private let tabBarButton: PageTabBarButton = {
        let button = PageTabBarButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.contentEdgeInsets = .zero
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public let badgeView: Badge = {
        let badgeView = Badge(type: .number)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        return badgeView
    }()
    
    private var type = PageTabBarItemType.text
    
    // MARK: Layout Constraints
    private var tabBarButtonVerticalOffsetConstraint: NSLayoutConstraint?
    private var tabBarButtonHorizontalOffsetConstraint: NSLayoutConstraint?
    
    public convenience init(title: String?) {
    
        self.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
        type = .text

        tabBarButton.pageTabBarItemType = .text
        tabBarButton.setTitle(title, for: .normal)
        tabBarButton.titleLabel?.font = appearance.font
        tabBarButton.setTitleColor(appearance.unselectedColor, for: .normal)
        tabBarButton.setTitleColor(appearance.selectedColor, for: .selected)
        
        tabBarButton.designatedContentSize = CGSize(width: AppearanceSettings.automaticDimemsion, height: appearance.contentHeight)
        
        commonInit()
    }
    
    public convenience init(unselectedImage: UIImage?, selectedImage: UIImage?) {
        self.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        type = .icon
        
        tabBarButton.pageTabBarItemType = .icon
        tabBarButton.setTitle("", for: .normal)
        tabBarButton.setImage(unselectedImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        tabBarButton.setImage(selectedImage?.withRenderingMode(.alwaysTemplate), for: .selected)
        tabBarButton.imageView?.contentMode = .scaleAspectFit
        tabBarButton.designatedContentSize = CGSize(width: appearance.contentHeight, height: appearance.contentHeight)
        tabBarButton.tintColor = appearance.unselectedColor
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        tabBarButton.color = appearance.unselectedColor
        tabBarButton.selectedColor = appearance.selectedColor
        
        tabBarButton.addTarget(self, action: #selector(press(_:)), for: .touchUpInside)
        
        addSubview(tabBarButton)
        
        tabBarButtonHorizontalOffsetConstraint = tabBarButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: appearance.offset.width)
        tabBarButtonHorizontalOffsetConstraint?.isActive = true
        tabBarButtonVerticalOffsetConstraint = tabBarButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: appearance.offset.height)
        tabBarButtonVerticalOffsetConstraint?.isActive = true
        
        addSubview(badgeView)
        
        if case .icon = type {
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
            badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        } else {
            badgeView.centerYAnchor.constraint(equalTo: tabBarButton.centerYAnchor).isActive = true
            badgeView.leadingAnchor.constraint(equalTo: tabBarButton.trailingAnchor, constant: 6).isActive = true
        }
        
    }
    
    @objc private func press(_ sender: UIButton) {
        delegate?.pageTabBarItemDidTap(self)
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitTestView = super.hitTest(point, with: event), hitTestView == self {
            return tabBarButton
        }
        return super.hitTest(point, with: event)
    }
}

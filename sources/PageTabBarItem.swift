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

protocol PageTabBarItemDelegate: class {
    func pageTabBarItemDidTap(_ item: PageTabBarItem)
}

internal enum PageTabBarItemType {
    case text
    case icon
}

private class PageTabBarButton: UIButton {
    
    fileprivate var color = UIColor.lightGray {
        didSet {
            setTitleColor(color, for: .normal)
            setTitleColor(color.withAlphaComponent(0.5), for: .highlighted)
        }
    }
    
    fileprivate var selectedColor = UIColor.blue {
        didSet {
            setTitleColor(selectedColor, for: .selected)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                tintColor = isSelected ? selectedColor.withAlphaComponent(0.5) : color.withAlphaComponent(0.5)
            }
            else {
                tintColor = isSelected ? selectedColor : color
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            tintColor = isSelected ? selectedColor : color
        }
    }
}

@objc open class PageTabBarItem: UIView {
    
    @objc open var font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium) {
        didSet {
            tabBarButton.titleLabel?.font = font
        }
    }
    @objc open var color = UIColor.lightGray {
        didSet {
            tabBarButton.color = color
        }
    }
    @objc open var selectedColor = UIColor.blue {
        didSet {
            tabBarButton.selectedColor = selectedColor
        }
    }
    
    internal var isSelected = false {
        didSet {
            tabBarButton.isSelected = isSelected
        }
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
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()
    
    @objc open let badgeView: Badge = {
        let badgeView = Badge(type: .number)
        return badgeView
    }()
    
    private var type = PageTabBarItemType.text
    
    @objc public convenience init(title: String?) {
    
        self.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
        type = .text

        tabBarButton.setTitle(title, for: .normal)
        tabBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        commonInit()
    }
    
    @objc public convenience init(icon: UIImage?) {
        self.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        type = .icon
        
        let img = icon?.withRenderingMode(.alwaysTemplate)
        tabBarButton.setTitle("", for: .normal)
        tabBarButton.setImage(img, for: .normal)
        tabBarButton.imageView?.contentMode = .scaleAspectFit
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        tabBarButton.setTitleColor(color, for: .normal)
        tabBarButton.setTitleColor(selectedColor, for: .highlighted)
        tabBarButton.tintColor = color
        
        tabBarButton.addTarget(self, action: #selector(press(_:)), for: .touchUpInside)
        
        addSubview(tabBarButton)
        tabBarButton.translatesAutoresizingMaskIntoConstraints = false
        tabBarButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tabBarButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tabBarButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tabBarButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        if case .icon = type {
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
            badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        } else {
            badgeView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            if let label = tabBarButton.titleLabel {
                badgeView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 6).isActive = true
            }
            
        }
        
    }
    
    @objc private func press(_ sender: UIButton) {
        delegate?.pageTabBarItemDidTap(self)
    }
}

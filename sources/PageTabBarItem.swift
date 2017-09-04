//
//  PageTabBarItem.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objc public final class PageTabBarItem: UIView {
    
    public static var tintColor = UIColor.gray
    public static var selectedTintColor = UIColor.lightGray
    
    internal var badgeCount = 0 {
        didSet {
            badgeView.badgeValue = badgeCount
        }
    }
    
    internal var overlayColor = UIColor.gray {
        didSet {
            tabBarButton.setTitleColor(overlayColor, for: .normal)
        }
    }
    
    internal var didSelect: ((UIButton) -> ()) = { _ in }
    private let tabBarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(PageTabBarItem.tintColor, for: .normal)
        button.setTitleColor(PageTabBarItem.selectedTintColor, for: .highlighted)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return button
    }()
    
    private let badgeView: Badge = {
        let badgeView = Badge(type: .number)
        return badgeView
    }()
    
    convenience init(frame: CGRect, title: String?, icon: UIImage?) {
        self.init(frame: frame)
        backgroundColor = .white
        tabBarButton.setTitle(title, for: .normal)
        tabBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
        tabBarButton.addTarget(self, action: #selector(selecting(_:)), for: .touchUpInside)
        addSubview(tabBarButton)
        tabBarButton.translatesAutoresizingMaskIntoConstraints = false
        tabBarButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tabBarButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tabBarButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tabBarButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
    }
    
    @objc private func selecting(_ sender: UIButton) {
        didSelect(sender)
    }
}

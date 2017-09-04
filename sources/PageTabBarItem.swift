//
//  PageTabBarItem.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

public final class PageTabBarItem: UIView {
    
    var didSelect: ((UIButton) -> ()) = { _ in }
    
    fileprivate let titleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(UIColor.pastelGray(), for: UIControlState())
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return button
    }()
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        backgroundColor = .white
        titleButton.setTitle(title, for: UIControlState())
        if #available(iOS 8.2, *) {
            titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
        } else {
            titleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        }
        titleButton.addTarget(self, action: #selector(selecting(_:)), for: .touchUpInside)
        addSubview(titleButton)
        constrain(titleButton) { (targetView) in
            targetView.edges == inset(targetView.superview!.edges, 0)
        }
    }
    
    @objc func selecting(_ sender: UIButton) {
        didSelect(sender)
    }
    
    func set(color c: UIColor) {
        titleButton.setTitleColor(c, for: UIControlState())
    }
}

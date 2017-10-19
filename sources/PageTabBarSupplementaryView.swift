//
//  PageTabBarSupplementaryView.swift
//  PageTabBarController
//
//  Created by Keith Chan on 18/10/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objc public final class PageTabBarSupplementaryView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

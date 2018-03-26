//
//  ParallaxHeaderContainerView.swift
//  PageTabBarController
//
//  Created by Keith Chan on 23/3/2018.
//  Copyright © 2018 com.mingloan. All rights reserved.
//

import UIKit

final internal class ParallaxHeaderContainerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

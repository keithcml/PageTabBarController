//
//  ParallaxHeaderContainerView.swift
//  PageTabBarController
//
//  Created by Keith Chan on 23/3/2018.
//  Copyright © 2018 com.mingloan. All rights reserved.
//

import UIKit

final internal class ParallaxHeaderContainerView: UIView {
    
    private var contentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContentView(_ view: UIView?) {
        
        if let currentContentView = contentView, currentContentView == view {
            
            if currentContentView == view {
                currentContentView.frame = bounds
            }

            return
        }
                
        contentView?.frame = bounds
        
        if let view = view {
            addSubview(view)
        }
        
    }
    
    func removeContentView() {
        contentView?.removeFromSuperview()
        contentView = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView?.frame = bounds
    }
}

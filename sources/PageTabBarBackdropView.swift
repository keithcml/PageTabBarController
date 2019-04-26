//
//  PageTabBarBackdropView.swift
//  PageTabBarController
//
//  Created by Keith Chan on 7/3/2018.
//  Copyright © 2018 com.mingloan. All rights reserved.
//

import UIKit


final class PageTabBarBackdropView: UIView {
    
    var translucentFactor: CGFloat = 0.6
    
    var isTranslucent: Bool = true {
        didSet {
            backgroundColor = isTranslucent ? barTintColor.withAlphaComponent(translucentFactor) : barTintColor
        }
    }
    
    var barBlurStyle: UIBlurEffect.Style = .light {
        didSet {
            backDropBlurView.effect = UIBlurEffect(style: barBlurStyle)
        }
    }
    
    var barTintColor: UIColor = .white {
        didSet {
            backgroundColor = isTranslucent ? barTintColor.withAlphaComponent(translucentFactor) : barTintColor
        }
    }
    
    private let backDropBlurView: UIVisualEffectView = {
        let backDropBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
        backDropBlurView.translatesAutoresizingMaskIntoConstraints = false
        return backDropBlurView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(backDropBlurView)
        NSLayoutConstraint.activate([backDropBlurView.topAnchor.constraint(equalTo: topAnchor),
                                     backDropBlurView.leftAnchor.constraint(equalTo: leftAnchor),
                                     backDropBlurView.rightAnchor.constraint(equalTo: rightAnchor),
                                     backDropBlurView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ParallaxHeaderPageTabBarController.swift
//  PageTabBarController
//
//  Created by Mingloan Chan on 12/11/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
open class ParallaxHeaderPageTabBarController: UIViewController {
    
    open let pageTabBarController: PageTabBarController
    open let parallaxHeaderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    let supplementaryContainerView: SupplementaryView = {
        let view = SupplementaryView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    
    open var parallaxOffset = CGFloat(1)
    open var minimumRevealHeight = CGFloat(0)
    open var parallaxHeaderHeight = CGFloat(200)
    
    private var parallaxHeaderViewTopConstraint: NSLayoutConstraint?
    private var parallaxHeaderViewHeightConstraint: NSLayoutConstraint?
    private var supplementaryViewBottomConstraint: NSLayoutConstraint?
    private var supplementaryViewHeightConstraint: NSLayoutConstraint?
    private var pageTabBarTopConstraint: NSLayoutConstraint?
    
    public required init(viewControllers: [UIViewController],
                         items: [PageTabBarItem],
                         parallaxHeaderHeight: CGFloat) {
        
        pageTabBarController = PageTabBarController(viewControllers: viewControllers, items: items, tabBarPosition: .top)
        super.init(nibName: nil, bundle: nil)
        
        self.parallaxHeaderHeight = parallaxHeaderHeight
        pageTabBarController.delegate = self
        
        addChildViewController(pageTabBarController)
        pageTabBarController.didMove(toParentViewController: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(pageTabBarController.view)
        view.addSubview(parallaxHeaderContainerView)
        view.addSubview(supplementaryContainerView)
        
        parallaxHeaderContainerView.translatesAutoresizingMaskIntoConstraints = false
        pageTabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        supplementaryContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // var topAnchor = view.topAnchor
        // var bottomAnchor = view.bottomAnchor
        var leadingAnchor = view.leadingAnchor
        var trailingAnchor = view.trailingAnchor
        if #available(iOS 11.0, *) {
            //topAnchor = view.safeAreaLayoutGuide.topAnchor
            //bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
            leadingAnchor = view.safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = view.safeAreaLayoutGuide.trailingAnchor
        }
        
        NSLayoutConstraint.activate([parallaxHeaderContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     parallaxHeaderContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        parallaxHeaderViewTopConstraint = parallaxHeaderContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        parallaxHeaderViewTopConstraint?.isActive = true
        parallaxHeaderViewHeightConstraint = parallaxHeaderContainerView.heightAnchor.constraint(equalToConstant: parallaxHeaderHeight)
        parallaxHeaderViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([supplementaryContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     supplementaryContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        supplementaryViewBottomConstraint = supplementaryContainerView.bottomAnchor.constraint(equalTo: parallaxHeaderContainerView.bottomAnchor)
        supplementaryViewBottomConstraint?.isActive = true
        supplementaryViewHeightConstraint = supplementaryContainerView.heightAnchor.constraint(equalToConstant: 60)
        supplementaryViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([pageTabBarController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     pageTabBarController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     pageTabBarController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        pageTabBarTopConstraint = pageTabBarController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: parallaxHeaderHeight)
        pageTabBarTopConstraint?.isActive = true
    }
    
    open func addViewOnHeaderView(_ view: UIView?) {
        
    }
    
}

extension ParallaxHeaderPageTabBarController: PageTabBarControllerDelegate {
    public func pageTabBarController(_ controller: PageTabBarController,
                                     selectedViewController: UIViewController,
                                     observedScrollView: UIScrollView,
                                     contentOffsetObservingWithOldValue oldValue: CGPoint,
                                     newValue: CGPoint) -> Bool {
        
        guard let currentSpacing = self.pageTabBarTopConstraint?.constant else {
            return true
        }
        
        // diff < 0 => scroll up, diff > 0 => scroll down
        let diff = oldValue.y - newValue.y
    
        guard diff != 0 else { return true }
        
        var contentInset = observedScrollView.contentInset
        if #available(iOS 11.0, *) {
            contentInset = observedScrollView.adjustedContentInset
        }
        
        if observedScrollView.contentOffset.y < -contentInset.top {
            let gap = -(contentInset.top + newValue.y)
            let scale = (parallaxHeaderContainerView.frame.height + gap * 2)/parallaxHeaderContainerView.frame.height
            parallaxHeaderContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            supplementaryViewBottomConstraint?.constant = gap
        } else {
            parallaxHeaderContainerView.transform = .identity
        }
        
        if newValue.y < -contentInset.top {
            
            // finger moving down
            if currentSpacing < parallaxHeaderHeight {
                
                let newConstant = min(parallaxHeaderHeight, max(minimumRevealHeight, currentSpacing + diff))
                pageTabBarTopConstraint?.constant = newConstant
                parallaxHeaderViewTopConstraint?.constant = newConstant - parallaxHeaderHeight
                view.layoutIfNeeded()
                
                return false
            }
            
        } else if newValue.y > -contentInset.top {
            
            // finger moving up
            if currentSpacing > minimumRevealHeight {
                
                let newConstant = min(parallaxHeaderHeight, max(minimumRevealHeight, currentSpacing + diff))
                pageTabBarTopConstraint?.constant = newConstant
                parallaxHeaderViewTopConstraint?.constant = newConstant - parallaxHeaderHeight
                view.layoutIfNeeded()
                
                return false
            }
        }
        
        return true
    }
}

//
//  ParallaxHeaderPageTabBarController.swift
//  PageTabBarController
//
//  Created by Mingloan Chan on 12/11/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol ParallaxHeaderPageTabBarControllerDelegate: NSObjectProtocol {
    @objc optional func parallaxHeaderPageTabBarController(_ controller: ParallaxHeaderPageTabBarController, revealPercentage: CGFloat, revealPercentageIncludingTopSafeAreaInset: CGFloat)
}

@objcMembers
open class ParallaxHeaderPageTabBarController: UIViewController {
    
    open weak var delegate: ParallaxHeaderPageTabBarControllerDelegate?
    
    open let pageTabBarController: PageTabBarController
    open let parallaxHeaderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    let supplementaryContainerView: SupplementaryView = {
        let view = SupplementaryView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    open var isStretchy = true {
        didSet {
            if isStretchy {
                pageTabBarController.setTabBarTopPosition(.topInsetAttached)
            } else {
                pageTabBarController.setTabBarTopPosition(.topAttached)
            }
        }
    }
    open var parallaxOffset = CGFloat(1)
    open var minimumRevealHeight = CGFloat(0)
    open var parallaxHeaderHeight = CGFloat(200)
    open var supplementaryViewHeight = CGFloat(60) {
        didSet {
            supplementaryViewHeightConstraint?.constant = supplementaryViewHeight
            view.setNeedsLayout()
        }
    }
    
    private var minimumCollapseOffset: CGFloat {
        if #available(iOS 11.0, *) {
            return max(minimumRevealHeight, view.safeAreaInsets.top) - parallaxHeaderHeight
        } else {
            return minimumRevealHeight - parallaxHeaderHeight
        }
    }
    
    private var parallaxHeaderViewTopConstraint: NSLayoutConstraint?
    private var parallaxHeaderViewHeightConstraint: NSLayoutConstraint?
    private var supplementaryViewBottomConstraint: NSLayoutConstraint?
    private var supplementaryViewHeightConstraint: NSLayoutConstraint?
    
    private weak var currentChildScrollViewWeakReference: UIScrollView?
    private var previousChildScrollViewOffset: CGPoint = .zero
    private var isLatestScrollingUp = false
    
    public required init(viewControllers: [UIViewController],
                         items: [PageTabBarItem],
                         parallaxHeaderHeight: CGFloat) {
        
        pageTabBarController = PageTabBarController(viewControllers: viewControllers, items: items, tabBarPosition: .topInsetAttached)
        super.init(nibName: nil, bundle: nil)
        
        self.parallaxHeaderHeight = parallaxHeaderHeight
        pageTabBarController.parallaxDelegate = self
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addChildViewController(pageTabBarController)
        
        view.addSubview(pageTabBarController.view)
        view.addSubview(parallaxHeaderContainerView)
        view.addSubview(supplementaryContainerView)

        parallaxHeaderContainerView.translatesAutoresizingMaskIntoConstraints = false
        pageTabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        supplementaryContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        var leadingAnchor = view.leadingAnchor
        var trailingAnchor = view.trailingAnchor
        if #available(iOS 11.0, *) {
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
        supplementaryViewHeightConstraint = supplementaryContainerView.heightAnchor.constraint(equalToConstant: supplementaryViewHeight)
        supplementaryViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([pageTabBarController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     pageTabBarController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     pageTabBarController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     pageTabBarController.view.topAnchor.constraint(equalTo: parallaxHeaderContainerView.bottomAnchor)])
        
        pageTabBarController.didMove(toParentViewController: self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func tabBarPositionYDidChange() {
        if let constant = parallaxHeaderViewTopConstraint?.constant {
            let revealPercentage = 1 - abs(constant) / abs(minimumCollapseOffset)
            if #available(iOS 11.0, *) {
                let revealPercentageWithSafeAreaInset = 1 - abs(constant) / (parallaxHeaderHeight - min(minimumRevealHeight, view.safeAreaInsets.top))
                delegate?.parallaxHeaderPageTabBarController?(self, revealPercentage: revealPercentage, revealPercentageIncludingTopSafeAreaInset: revealPercentageWithSafeAreaInset)
            } else {
                delegate?.parallaxHeaderPageTabBarController?(self, revealPercentage: revealPercentage, revealPercentageIncludingTopSafeAreaInset: revealPercentage)
            }
        }
    }
}

// MARK: - Public Methods

extension ParallaxHeaderPageTabBarController {
    
    open func scrollToTop(_ toTop: Bool, animated: Bool = false) {

        if toTop {
            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    self.parallaxHeaderViewTopConstraint?.constant = 0
                    self.tabBarPositionYDidChange()
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                parallaxHeaderViewTopConstraint?.constant = 0
                tabBarPositionYDidChange()
                view.layoutIfNeeded()
            }
        }
        else {
            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    self.parallaxHeaderViewTopConstraint?.constant = self.minimumRevealHeight - self.parallaxHeaderHeight
                    self.tabBarPositionYDidChange()
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                parallaxHeaderViewTopConstraint?.constant = self.minimumRevealHeight - self.parallaxHeaderHeight
                tabBarPositionYDidChange()
                view.layoutIfNeeded()
            }
        }
    }
    
    open func setSupplementaryView(_ supplementaryView: UIView?, height: CGFloat) {
        supplementaryViewHeight = height
        supplementaryContainerView.configureWithContentView(supplementaryView)
    }
    
    open func setParallexHeaderView(_ view: UIView?, height: CGFloat, sizeToFitHeader: Bool = false) {
        
        defer {
            if sizeToFitHeader {
                setParallexHeaderHeight(height, animated: false)
            }
        }
        parallaxHeaderContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let customView = view else { return }
        
        parallaxHeaderContainerView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([customView.leadingAnchor.constraint(equalTo: parallaxHeaderContainerView.leadingAnchor),
                                     customView.trailingAnchor.constraint(equalTo: parallaxHeaderContainerView.trailingAnchor),
                                     customView.topAnchor.constraint(equalTo: parallaxHeaderContainerView.topAnchor),
                                     customView.heightAnchor.constraint(equalToConstant: height)])
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        //parallaxHeaderContainerView.setNeedsLayout()
        //parallaxHeaderContainerView.layoutIfNeeded()
    }
    
    /* @param height - new height
     * @param animated - run default animation
     */
    open func setParallexHeaderHeight(_ newHeight: CGFloat, animated: Bool, scrollToTop: Bool = true) {
        
        guard parallaxHeaderHeight != newHeight else { return }
        parallaxHeaderHeight = newHeight
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                if scrollToTop {
                    self.parallaxHeaderViewTopConstraint?.constant = 0
                }
                self.parallaxHeaderViewHeightConstraint?.constant = newHeight
                self.tabBarPositionYDidChange()
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            if scrollToTop {
                parallaxHeaderViewTopConstraint?.constant = 0
            }
            parallaxHeaderViewHeightConstraint?.constant = newHeight
            tabBarPositionYDidChange()
            view.layoutIfNeeded()
        }
    }
    
    open func minimizesTabsContent(animated: Bool, scrollToTop: Bool = true) {
        var maximumHeight = CGFloat(0)
        if #available(iOS 11.0, *) {
            maximumHeight = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - pageTabBarController.pageTabBar.frame.height
        } else {
            
        }
        setParallexHeaderHeight(maximumHeight, animated: animated, scrollToTop: scrollToTop)
    }
    
    open func childScrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let currentScrollView = currentChildScrollViewWeakReference, currentScrollView == scrollView else { return }
        
        guard let topConstraint = parallaxHeaderViewTopConstraint else { return }
        
        var contentInset = scrollView.contentInset
        if #available(iOS 11.0, *) {
            
            contentInset = scrollView.adjustedContentInset
            
            // Hotfixes: jumping scrollView contentInsets
            if let superview = scrollView.superview, superview.safeAreaInsets.top > contentInset.top {
                contentInset = superview.safeAreaInsets
            }
        }

        if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y > 0 {
            isLatestScrollingUp = true
        } else if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y < 0 {
            isLatestScrollingUp = false
        }
        
        let diff = scrollView.contentOffset.y - previousChildScrollViewOffset.y
        let shouldCollapse = topConstraint.constant > minimumCollapseOffset && scrollView.contentOffset.y > -contentInset.top && !isLatestScrollingUp
        let shouldExpand = topConstraint.constant < 0 && isLatestScrollingUp && scrollView.contentOffset.y < -contentInset.top
        
        if shouldCollapse || shouldExpand {
            let newConstant = max(minimumCollapseOffset, min(0, topConstraint.constant - diff))
            parallaxHeaderViewTopConstraint?.constant = newConstant
        }
        
        tabBarPositionYDidChange()

        // transformations
        if case .topAttached = pageTabBarController.tabBarPosition {
            parallaxHeaderContainerView.transform = .identity
            supplementaryViewBottomConstraint?.constant = 0
        } else {
            
            pageTabBarController.transformTabBarWithScrollViewBounces(scrollView)
            
            if scrollView.contentOffset.y < -contentInset.top {
                let gap = -contentInset.top - scrollView.contentOffset.y
                let scale = 1 + (gap * 2)/parallaxHeaderHeight
                parallaxHeaderContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)

                supplementaryViewBottomConstraint?.constant = gap
            } else {
                parallaxHeaderContainerView.transform = .identity
                supplementaryViewBottomConstraint?.constant = 0
            }
        }

        if shouldCollapse || shouldExpand {
            scrollView.contentOffset = previousChildScrollViewOffset
        } else {
            previousChildScrollViewOffset = scrollView.contentOffset
        }
    }
}

extension ParallaxHeaderPageTabBarController: PageTabBarControllerParallaxDelegate {
    
    func pageTabBarController(_ controller: PageTabBarController, childScrollViewDidChange scrollView: UIScrollView) {
        
        guard currentChildScrollViewWeakReference != scrollView else {
            return
        }
        
        if let currentChildScrollView = currentChildScrollViewWeakReference {
            view.removeGestureRecognizer(currentChildScrollView.panGestureRecognizer)
        }
        
        currentChildScrollViewWeakReference = scrollView
        
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
        
        previousChildScrollViewOffset = scrollView.contentOffset
        isLatestScrollingUp = false
    }
}

extension UIViewController {
    
    @objc(ml_parallaxHeaderPageTabBarController)
    open var parallaxHeaderPageTabBarController: ParallaxHeaderPageTabBarController? {
        var parentVC = parent
        while parentVC != nil {
            
            if let vc = parentVC as? ParallaxHeaderPageTabBarController {
                return vc
            }
            parentVC = parentVC?.parent
        }
        return nil
    }
}

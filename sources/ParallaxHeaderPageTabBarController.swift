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
    
    // MARK: - Position
    
    enum Position {
        case top
        case bottom
        case refresh
    }
        
    open weak var delegate: ParallaxHeaderPageTabBarControllerDelegate?
    
    open let pageTabBarController: PageTabBarController
    
    internal let parallaxHeaderContainerView = ParallaxHeaderContainerView()
    
    open let headerTransitionView: UIView = {
        let transitionView = UIView()
        transitionView.isUserInteractionEnabled = false
        transitionView.translatesAutoresizingMaskIntoConstraints = false
        transitionView.clipsToBounds = true
        return transitionView
    }()
    
    internal let supplementaryContainerView = SupplementaryView()
    
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
            setViewsToPosition(.refresh)
        }
    }
    
    open var minimumSafeAreaInsets: UIEdgeInsets {
        var safeAreaInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safeAreaInsets.top = max(minimumRevealHeight, view.safeAreaInsets.top) + pageTabBarController.pageTabBar.frame.height
        } else {
            safeAreaInsets.top = minimumRevealHeight + pageTabBarController.pageTabBar.frame.height
        }
        safeAreaInsets.left = 0
        safeAreaInsets.bottom = 0
        safeAreaInsets.right = 0
        return safeAreaInsets
    }
    
    private var minimumCollapseOffset: CGFloat {
        if #available(iOS 11.0, *) {
            return max(minimumRevealHeight, view.safeAreaInsets.top)
        } else {
            return minimumRevealHeight
        }
    }
    
    private weak var currentChildScrollViewWeakReference: UIScrollView?
    private var previousChildScrollViewOffset: CGPoint = .zero
    private var isLatestScrollingUp = false
    
    // Positions
    private var revealingGapHeight = CGFloat(0)
    
    private var parallaxHeaderViewMinY: CGFloat {
        return revealingGapHeight - parallaxHeaderHeight
    }
    
    private var pageTabBarViewMinY: CGFloat {
        return revealingGapHeight
    }
    
    private var pageTabBarViewHeight: CGFloat {
        return view.frame.height - revealingGapHeight
    }
    
    private var supplementaryViewOffsetY = CGFloat(0)
    
    private var supplementaryViewMinY: CGFloat {
        return pageTabBarViewMinY - supplementaryViewHeight + supplementaryViewOffsetY
    }
    
    // MARK: - Life Cycle
    
    public required init(viewControllers: [UIViewController],
                         items: [PageTabBarItem],
                         parallaxHeaderHeight: CGFloat) {
        
        pageTabBarController = PageTabBarController(viewControllers: viewControllers, items: items, tabBarPosition: .topInsetAttached)
        super.init(nibName: nil, bundle: nil)
        
        self.parallaxHeaderHeight = parallaxHeaderHeight
        revealingGapHeight = parallaxHeaderHeight
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
        view.addSubview(headerTransitionView)
        
        pageTabBarController.view.autoresizingMask = [.flexibleWidth]
        parallaxHeaderContainerView.autoresizingMask = [.flexibleWidth]
        supplementaryContainerView.autoresizingMask = [.flexibleWidth]
        
        parallaxHeaderContainerView.frame = CGRect(x: 0, y: parallaxHeaderViewMinY, width: view.frame.width, height: parallaxHeaderHeight)
        pageTabBarController.view.frame = CGRect(x: 0, y: pageTabBarViewMinY, width: view.frame.width, height: pageTabBarViewHeight)
        supplementaryContainerView.frame = CGRect(x: 0, y: supplementaryViewMinY, width: view.frame.width, height: supplementaryViewHeight)
        
        pageTabBarController.didMove(toParentViewController: self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func tabBarPositionYDidChange() {
        
        let revealPercentage = 1 - abs(parallaxHeaderViewMinY) / abs(minimumCollapseOffset)
        
        if #available(iOS 11.0, *) {
            let revealPercentageWithSafeAreaInset = 1 - abs(parallaxHeaderViewMinY) / (parallaxHeaderHeight - min(minimumRevealHeight, view.safeAreaInsets.top))
            delegate?.parallaxHeaderPageTabBarController?(self, revealPercentage: revealPercentage, revealPercentageIncludingTopSafeAreaInset: revealPercentageWithSafeAreaInset)
        } else {
            delegate?.parallaxHeaderPageTabBarController?(self, revealPercentage: revealPercentage, revealPercentageIncludingTopSafeAreaInset: revealPercentage)
        }
    }
}

// MARK: - Public Methods

extension ParallaxHeaderPageTabBarController {
    
    private func setViewsToPosition(_ pos: Position, resetContentOffset: Bool = false) {
        
        switch pos {
        case .top:
            revealingGapHeight = parallaxHeaderHeight
            break
        case .bottom:
            revealingGapHeight = minimumCollapseOffset
            break
        case .refresh:
            break
        }
        
        setParallaxHeaderContainerViewPosition()
        setPageTabBarViewPosition()
        setSupplementaryContainerViewPosition()
    }
    
    private func setParallaxHeaderContainerViewPosition() {
        parallaxHeaderContainerView.transform = .identity
        parallaxHeaderContainerView.frame = CGRect(x: 0,
                                                   y: parallaxHeaderViewMinY,
                                                   width: view.frame.width,
                                                   height: parallaxHeaderHeight)
    }
    
    private func setPageTabBarViewPosition() {
        pageTabBarController.view.frame = CGRect(x: 0,
                                                 y: pageTabBarViewMinY,
                                                 width: view.frame.width,
                                                 height: pageTabBarViewHeight)
    }
    
    private func setSupplementaryContainerViewPosition() {
        supplementaryContainerView.frame = CGRect(x: 0,
                                                  y: supplementaryViewMinY,
                                                  width: view.frame.width,
                                                  height: supplementaryViewHeight)
    }
    
    open func scrollToTop(_ toTop: Bool, animated: Bool = false) {

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.setViewsToPosition(toTop ? .top : .bottom)
                self.tabBarPositionYDidChange()
            }, completion: nil)
        } else {
            setViewsToPosition(toTop ? .top : .bottom)
            tabBarPositionYDidChange()
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
  
        parallaxHeaderContainerView.insertSubview(customView, at: 0)
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([customView.leadingAnchor.constraint(equalTo: parallaxHeaderContainerView.leadingAnchor),
                                     customView.trailingAnchor.constraint(equalTo: parallaxHeaderContainerView.trailingAnchor),
                                     customView.bottomAnchor.constraint(equalTo: parallaxHeaderContainerView.bottomAnchor),
                                     customView.heightAnchor.constraint(equalToConstant: height)])
        parallaxHeaderContainerView.setNeedsLayout()
        parallaxHeaderContainerView.layoutIfNeeded()
    }
    
    /* @param height - new height
     * @param animated - run default animation
     */
    open func setParallexHeaderHeight(_ newHeight: CGFloat, animated: Bool, scrollToTop: Bool = true) {
        
        guard parallaxHeaderHeight != newHeight else { return }
        parallaxHeaderHeight = newHeight
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.setViewsToPosition(.refresh, resetContentOffset: scrollToTop)
                self.tabBarPositionYDidChange()
            }, completion: nil)
        } else {
            setViewsToPosition(.refresh, resetContentOffset: scrollToTop)
            tabBarPositionYDidChange()
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
        
        var contentInset = scrollView.contentInset
        if #available(iOS 11.0, *) {
            
            contentInset = scrollView.adjustedContentInset
            
            // Hotfixes: jumping scrollView contentInsets
            if let superview = scrollView.superview, superview.safeAreaInsets.top > contentInset.top {
                contentInset = superview.safeAreaInsets
            }
        } else {
            contentInset.top = max(contentInset.top, topLayoutGuide.length)
        }

        if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y > 0 {
            isLatestScrollingUp = true // finger moving down
        } else if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y < 0 {
            isLatestScrollingUp = false // finger moving up
        }
        
        let diff = scrollView.contentOffset.y - previousChildScrollViewOffset.y
        
        let shouldCollapse = revealingGapHeight > minimumCollapseOffset && revealingGapHeight <= parallaxHeaderHeight && scrollView.contentOffset.y > -contentInset.top && !isLatestScrollingUp
        let shouldExpand = revealingGapHeight >= minimumCollapseOffset && revealingGapHeight < parallaxHeaderHeight && isLatestScrollingUp && scrollView.contentOffset.y < -contentInset.top
        
        if shouldCollapse || shouldExpand {
            revealingGapHeight = min(parallaxHeaderHeight, max(minimumCollapseOffset, revealingGapHeight - diff))
        }
        
        if case .topInsetAttached = pageTabBarController.tabBarPosition {
            
            pageTabBarController.transformTabBarWithScrollViewBounces(scrollView)

            let gap = pageTabBarController.pageTabBar.frame.minY
            supplementaryViewOffsetY = gap
            setSupplementaryContainerViewPosition()
            
            let scale = 1 + (gap * 2)/parallaxHeaderHeight
            
            parallaxHeaderContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            parallaxHeaderContainerView.center = CGPoint(x: parallaxHeaderContainerView.frame.midX, y: revealingGapHeight + gap - parallaxHeaderContainerView.frame.height / 2)
            
            setPageTabBarViewPosition()
            
        } else {
            setViewsToPosition(.refresh)
        }

        tabBarPositionYDidChange()
        
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

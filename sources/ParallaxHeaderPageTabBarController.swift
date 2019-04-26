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
    
    // MARK: - Transition Spacing
    
    public enum TransitionContextPosition {
        case automatic
        case custom(position: CGRect)
    }
    
    // MARK: - Transition Spacing
    
    public enum TransitionSpacing {
        case maximumSpace
        case customHeight(height: CGFloat)
    }
    
    // MARK: - Properties
    
    open weak var delegate: ParallaxHeaderPageTabBarControllerDelegate?
    
    public let pageTabBarController: PageTabBarController
    
    internal let parallaxHeaderContainerView = ParallaxHeaderContainerView()
    
    public let headerTransitionView: UIView = {
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
    
    private var isTransitioning = false
    
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
        
        addChild(pageTabBarController)
        
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

        headerTransitionView.isHidden = true
        
        pageTabBarController.didMove(toParent: self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func tabBarPositionYDidChange() {
        
        let revealPercentage = 1 - abs(parallaxHeaderViewMinY) / (parallaxHeaderHeight - minimumRevealHeight)
        
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
            if resetContentOffset {
                revealingGapHeight = parallaxHeaderHeight
            }
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
    
    open func scrollToTop(_ toTop: Bool, animated: Bool = false, completion: ((Bool) -> ())? = nil) {

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.setViewsToPosition(toTop ? .top : .bottom)
                self.tabBarPositionYDidChange()
            }, completion: completion)
        } else {
            setViewsToPosition(toTop ? .top : .bottom)
            tabBarPositionYDidChange()
            completion?(true)
        }
    }
    
    open func setSupplementaryView(_ supplementaryView: UIView?, height: CGFloat) {
        supplementaryViewHeight = height
        supplementaryContainerView.configureWithContentView(supplementaryView)
    }
    
    open func setParallexHeaderView(_ view: UIView?, height: CGFloat) {
        
        parallaxHeaderContainerView.removeContentView()
        
        setParallexHeaderHeight(height, animated: false)
        
        parallaxHeaderContainerView.setContentView(view)
    }
    
    /* @param height - new height
     * @param animated - run default animation
     */
    open func setParallexHeaderHeight(_ newHeight: CGFloat, animated: Bool, completion: ((Bool) -> ())? = nil) {
        
        guard parallaxHeaderHeight != newHeight else { return }
        parallaxHeaderHeight = newHeight
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.setViewsToPosition(.refresh, resetContentOffset: true)
                self.tabBarPositionYDidChange()
            }, completion: completion)
        } else {
            setViewsToPosition(.refresh, resetContentOffset: true)
            tabBarPositionYDidChange()
            completion?(true)
        }
    }
    
    // MARK: - Header Transitioning
    
    open func prepareTransition(transitionContextPosition position: TransitionContextPosition, animated: Bool, completion: ((Bool) -> ())? = nil) {
        
        isTransitioning = true
        
        if revealingGapHeight != parallaxHeaderHeight {
            scrollToTop(animated) { _ in
                self.prepareTransition(transitionContextPosition: position, animated: animated, completion: completion)
            }
            
            return
        }
        
        switch position {
        case .automatic:
            headerTransitionView.frame = parallaxHeaderContainerView.frame
            break
        case let .custom(position):
            headerTransitionView.frame = position
            break
        }
        
        headerTransitionView.isHidden = false
        completion?(true)
    }

    open func finalizeTransition() {
        headerTransitionView.isHidden = true
        isTransitioning = false
    }
    
    open func startTransition(spacing: TransitionSpacing, duration: TimeInterval, animated: Bool, completion: ((Bool) -> ())? = nil) {
        
        var spacingHeight = CGFloat(0)
        
        switch spacing {
        case .maximumSpace:
            if #available(iOS 11.0, *) {
                spacingHeight = view.frame.height - parallaxHeaderHeight - view.safeAreaInsets.bottom - pageTabBarController.pageTabBar.frame.height
            } else {
                spacingHeight = view.frame.height - parallaxHeaderHeight - bottomLayoutGuide.length - pageTabBarController.pageTabBar.frame.height
            }
            break
        case let .customHeight(height):
            
            guard height != parallaxHeaderHeight else {
                completion?(true)
                return
            }
            
            spacingHeight = height
            break
        }
        
        if animated {
            UIView.animate(withDuration: duration, animations: {
                self.pageTabBarController.view.transform = CGAffineTransform(translationX: 0, y: spacingHeight)
            }) { finished in
                completion?(finished)
            }
        } else {
            pageTabBarController.view.transform = CGAffineTransform(translationX: 0, y: spacingHeight)
            completion?(true)
        }
    }
    
    open func endTransition(headerHeight: CGFloat, duration: TimeInterval, animated: Bool, completion: ((Bool) -> ())? = nil) {
        parallaxHeaderHeight = headerHeight
        
        if revealingGapHeight > parallaxHeaderHeight {
            revealingGapHeight = parallaxHeaderHeight
        }
        
        if animated {
            UIView.animate(withDuration: duration, animations: {
                self.pageTabBarController.view.transform = .identity
                self.setViewsToPosition(.refresh)
                self.tabBarPositionYDidChange()
            }) { finished in
                completion?(finished)
            }
        } else {
            pageTabBarController.view.transform = .identity
            setViewsToPosition(.refresh)
            tabBarPositionYDidChange()
            completion?(true)
        }
    }
    
    // MARK: - Scroll View Monitoring
    
    open func childScrollViewDidScroll(_ scrollView: UIScrollView) {

        guard !isTransitioning else { return }
        
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

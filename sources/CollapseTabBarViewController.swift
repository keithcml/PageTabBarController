//
//  CollapseTabBarViewController.swift
//  PageTabBarControllerExample
//
//  Created by Mingloan Chan on 9/5/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit

@objc public protocol CollapseTabBarViewControllerDelegate: class {
    @objc optional func collapseTabBarController(_ controller: CollapseTabBarViewController, tabBarDidReach position: CollapseTabBarPosition)
    //@objc optional func shouldNavigateToItem(at index: Int)
}

@objc public enum CollapseTabBarPosition: Int {
    case top = 0
    case bottom
}

@objc public final class CollapseTabBarViewController: UIViewController {
    
    public weak var delegate: CollapseTabBarViewControllerDelegate?
    
    // MARK: - PageTabBarController Properties
    public fileprivate(set) var pageTabBarController: PageTabBarController?
    
    // MARK: - Scroll Control
    public var autoCollapse = false
    public var alwaysBouncesAtTop = false
    public var alwaysBouncesAtBottom = true
    public var minimumHeaderViewHeight: CGFloat = 100
    public var maximumHeaderViewHeight: CGFloat = 300 {
        didSet {
            if maximumHeaderViewHeight > self.view.frame.height - 100 {
                _maximumHeaderViewHeight = self.view.frame.height - 100
            }
            else {
                _maximumHeaderViewHeight = maximumHeaderViewHeight
            }
        }
    }
    public fileprivate(set) var defaultHeaderHeight: CGFloat = 200
    
    fileprivate var tabBarItems = [PageTabBarItem]()
    
    // tabbar positioning
    fileprivate var _maximumHeaderViewHeight: CGFloat = 300
    
    fileprivate var headerViewPanGesture: UIPanGestureRecognizer!
    fileprivate var pageTabBarPanGesture: UIPanGestureRecognizer!
    fileprivate var isPageTabBarPanning = false
    fileprivate var currentScrollDirection = Direction.notMoving
    
    fileprivate var initialY: CGFloat = 200
    fileprivate var initialHeight: CGFloat = 300
    fileprivate var innerScrollViewContentOffset = CGPoint.zero
    
    fileprivate var viewControllers = [UIViewController]()
    fileprivate var headerView = UIView(frame: CGRect.zero)
    
    @objc public init(viewControllers: [UIViewController],
                tabBarItems: [PageTabBarItem],
                headerView: UIView = UIView(frame: CGRect.zero),
                maximumHeaderHeight: CGFloat = 200) {
        
        super.init(nibName: nil, bundle: nil)
        
        assert(viewControllers.count > 0, "view controllers count == 0")
        assert(viewControllers.count == tabBarItems.count, "view controllers count != tabBarItems.count")
        
        self.viewControllers = viewControllers
        self.tabBarItems = tabBarItems
        self.headerView = headerView
        self.defaultHeaderHeight = maximumHeaderHeight
        
        pageTabBarController =
            PageTabBarController(
                viewControllers: viewControllers,
                items: tabBarItems,
                estimatedFrame: UIScreen.main.bounds)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        _maximumHeaderViewHeight = view.frame.height - 100
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: defaultHeaderHeight)
        view.addSubview(headerView)
        
        guard let pageTabBarController = pageTabBarController else { fatalError("pagetabbar controller = nil") }
        pageTabBarController.updateIndex = { _, index in
            if index == 0 {
                
            }
            else {
                
            }
        }
        
        addChildViewController(pageTabBarController)
        
        pageTabBarController.view.frame = CGRect(x: 0, y: defaultHeaderHeight, width: view.frame.width, height: view.frame.height - defaultHeaderHeight)
        view.addSubview(pageTabBarController.view)
        pageTabBarController.didMove(toParentViewController: self)
        
        pageTabBarPanGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        pageTabBarPanGesture.delegate = self
        pageTabBarController.view.addGestureRecognizer(pageTabBarPanGesture)
        
        headerView.isUserInteractionEnabled = true
        headerViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        headerViewPanGesture.delegate = self
        headerView.addGestureRecognizer(headerViewPanGesture)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public static func attachCollapseTabBarController(_ collapseTabBarViewController: CollapseTabBarViewController, into parentViewController: UIViewController, layoutClosure: (CollapseTabBarViewController, UIViewController) -> ()) {
        parentViewController.addChildViewController(collapseTabBarViewController)
        collapseTabBarViewController.view.frame = CGRect(x: 0, y: 0, width: parentViewController.view.frame.width, height: parentViewController.view.frame.height)
        parentViewController.view.addSubview(collapseTabBarViewController.view)
        layoutClosure(collapseTabBarViewController, parentViewController)
        collapseTabBarViewController.didMove(toParentViewController: parentViewController)
    }
    
    // MARK: - Select Tab
    @objc public func selectTabAtIndex(_ index: Int, scrollToPosition: CollapseTabBarPosition) {
        pageTabBarController?.setPageIndex(index, animated: true)
        scrollTabBar(to: .top)
    }
    
    // MARK: - Control Scroll
    @objc public func scrollTabBar(to position: CollapseTabBarPosition, springAnimation: Bool = false) {
        guard let pageView = pageTabBarController?.view else { return }
        var headerViewOrigin = CGPoint.zero
        var pageViewOrigin = pageView.frame.origin
        var pageViewSize = pageView.frame.size
        
        switch position {
        case .top:
            pageViewOrigin = CGPoint(x: 0, y: minimumHeaderViewHeight)
            pageViewSize = CGSize(width: pageView.frame.width, height: view.frame.height - minimumHeaderViewHeight)
            headerViewOrigin = CGPoint(x: 0, y: minimumHeaderViewHeight - defaultHeaderHeight)
            break
        case .bottom:
            pageViewOrigin = CGPoint(x: 0, y: defaultHeaderHeight)
            pageViewSize = CGSize(width: pageView.frame.width, height: defaultHeaderHeight)
            break
        }
        
        if springAnimation {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                animations: {
                    pageView.frame = CGRect(origin: pageViewOrigin, size: pageViewSize)
                    self.headerView.transform = .identity
                    self.headerView.frame.origin = headerViewOrigin
                }) { _ in
                    self.delegate?.collapseTabBarController?(self, tabBarDidReach: position)
                }
        }
        else {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                animations: {
                    pageView.frame = CGRect(origin: pageViewOrigin, size: pageViewSize)
                    self.headerView.transform = .identity
                    self.headerView.frame.origin = headerViewOrigin
                }) { _ in
                    self.delegate?.collapseTabBarController?(self, tabBarDidReach: position)
                }
        }
    }
    
    // MARK: - Gesture Handling
    @objc private func pan(_ sender: UIPanGestureRecognizer?) {
        guard let gesture = sender else { return }
        guard let gView = pageTabBarController?.view else { return }
        guard let touchView = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            guard abs(gesture.velocity(in: gView).y) >= abs(gesture.velocity(in: gView).x) else { return }
            
            initialY = gView.frame.minY
            initialHeight = gView.frame.height
            
            if touchView == headerView {
                isPageTabBarPanning = true
            }
            else {
                isPageTabBarPanning = pageTabBarCanScroll(direction: gesture.direction)
            }
            if let pageTabBarController = pageTabBarController,
                let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) {
                innerScrollViewContentOffset = scrollView.contentOffset
            }
            
            if case .notMoving = gesture.direction {} else {
                currentScrollDirection = gesture.direction
            }
            
            break
        case .changed:
            guard isPageTabBarPanning else { return }
            
            if case .notMoving = gesture.verticalDirection {} else {
                currentScrollDirection = gesture.verticalDirection
            }
            
            let translateY = gesture.translation(in: view).y
            
            let minimumY = alwaysBouncesAtTop ? 0 : minimumHeaderViewHeight
            var newY = alwaysBouncesAtBottom ? max(minimumY, translateY + initialY) : max(minimumY, min(translateY + initialY, defaultHeaderHeight))
            if newY > _maximumHeaderViewHeight {
                newY = _maximumHeaderViewHeight
            }
            let newHeight = initialHeight + (initialY - newY)
            
            gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
            gView.frame.origin = CGPoint(x: 0, y: newY)
            
            if alwaysBouncesAtBottom && gView.frame.minY >= defaultHeaderHeight {
                let gap = gView.frame.minY - defaultHeaderHeight
                let newHeight = ceil(defaultHeaderHeight + gap)
                let scale = newHeight/defaultHeaderHeight
                headerView.transform = CGAffineTransform(scaleX: scale, y: scale)
                headerView.frame = CGRect(x: headerView.frame.minX, y: newY - newHeight, width: headerView.frame.width, height: headerView.frame.height)
            }
            else {
                headerView.transform = CGAffineTransform.identity
                headerView.frame = CGRect(x: 0, y: newY - defaultHeaderHeight, width: headerView.frame.width, height: headerView.frame.height)
            }
            
            guard let pageTabBarController = pageTabBarController,
                let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) else { return }
            
            switch gesture.direction {
            case .up:
                if newY > 0 {
                    scrollView.contentOffset = innerScrollViewContentOffset
                }
                break
            case .down:
                if newY < defaultHeaderHeight {
                    scrollView.contentOffset = innerScrollViewContentOffset
                }
                break
            default:
                break
            }
            break
        default:
            guard isPageTabBarPanning else { return }
            if case .notMoving = gesture.verticalDirection {} else {
                currentScrollDirection = gesture.verticalDirection
            }

            // bouncing control
            if gView.frame.minY > defaultHeaderHeight {
                scrollTabBar(to: .bottom)
                return
            }
            else if gView.frame.minY < minimumHeaderViewHeight && alwaysBouncesAtTop {
                scrollTabBar(to: .top)
                return
            }
            
            isPageTabBarPanning = false
            
            if autoCollapse {
                guard gView.frame.minY > minimumHeaderViewHeight, gView.frame.minY < defaultHeaderHeight else { return }
                switch currentScrollDirection {
                case .up:
                    scrollTabBar(to: .top)
                    break
                case .down:
                    scrollTabBar(to: .bottom)
                    break
                default:
                    break
                }
            }
            else {
                guard abs(gesture.velocity(in: gView).y) > 500 else { return }
                // spring effect
                var distance = (gesture.velocity(in: gView).y * gesture.velocity(in: gView).y) / (2 * UIScrollViewDecelerationRateNormal)
                var position = CollapseTabBarPosition.bottom
                if case .up = currentScrollDirection {
                    distance = distance * -1
                    position = .top
                }
                let time = 0.2
                let translateY = gesture.translation(in: view).y + distance
                let minimumY = alwaysBouncesAtTop ? 0 : minimumHeaderViewHeight
                let newY = max(minimumY, min(translateY + initialY, defaultHeaderHeight))
                
                let newHeight = initialHeight + (initialY - newY)
                
                UIView.animate(withDuration: TimeInterval(time),
                               delay: 0,
                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                               animations: {
                                    gView.frame = CGRect(x: 0, y: newY, width: gView.frame.width, height: newHeight)
                                    self.headerView.frame = CGRect(origin: CGPoint(x: 0, y: newY - self.defaultHeaderHeight), size: self.headerView.frame.size)
                                }) { _ in
                                    self.delegate?.collapseTabBarController?(self, tabBarDidReach: position)
                                }
            }
            break
        }
    }
    
    fileprivate func pageTabBarCanScroll(direction: Direction?) -> Bool {
        
        if let pageTabBarController = pageTabBarController {
            guard let dir = direction else { return true }
            switch dir {
            case .up:
                let threshold = alwaysBouncesAtTop ? 0 : minimumHeaderViewHeight
                return pageTabBarController.view.frame.minY > threshold
            case .down:
                guard let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) else { return true }
                if !alwaysBouncesAtBottom && pageTabBarController.view.frame.minY == defaultHeaderHeight { return false }
                return scrollView.contentOffset.y <= scrollView.contentInset.top
            default:
                break
            }
        }
        return true
    }
}

extension CollapseTabBarViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = otherGestureRecognizer as? UIPanGestureRecognizer {
            if panGesture.direction.isX {
                return false
            }
        }
        return true
    }
}

// Pan Gesture Helpers
@objc public enum Direction: Int {
    case up
    case down
    case left
    case right
    case notMoving
    
    public var isX: Bool { return self == .left || self == .right }
    public var isY: Bool { return !isX }
}

public extension UIPanGestureRecognizer {
    
    @objc public var direction: Direction {
        let panVelocity = velocity(in: view)
        let vertical = fabs(panVelocity.y) > fabs(panVelocity.x)
        switch (vertical, panVelocity.x, panVelocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return .notMoving
        }
    }
    
    @objc public var verticalDirection: Direction {
        let panVelocity = velocity(in: view)
        let vertical = fabs(panVelocity.y) > fabs(panVelocity.x)
        switch (vertical, panVelocity.x, panVelocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, _, let y) where y < 0: return .up
        case (false, _, let y) where y > 0: return .down
        default: return .notMoving
        }
    }
}

//extension UIScrollView {
//    
//    var isAtTop: Bool {
//        return contentOffset.y <= verticalOffsetForTop
//    }
//    
//    var isAtBottom: Bool {
//        return contentOffset.y >= verticalOffsetForBottom
//    }
//    
//    var verticalOffsetForTop: CGFloat {
//        let topInset = contentInset.top
//        return -topInset
//    }
//    
//    var verticalOffsetForBottom: CGFloat {
//        let scrollViewHeight = bounds.height
//        let scrollContentSizeHeight = contentSize.height
//        let bottomInset = contentInset.bottom
//        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
//        return scrollViewBottomOffset
//    }
//    
//}

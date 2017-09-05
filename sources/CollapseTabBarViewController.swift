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

public enum CollapseTabBarHeaderType {
    case fixedHeight
    case sticky
    //case scrollAway
}

public final class CollapseTabBarViewController: UIViewController {
    
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
    
    fileprivate var pageTabBarController: PageTabBarController?
    fileprivate var tabBarItems = [PageTabBarItem]()
    
    // tabbar positioning
    fileprivate var _maximumHeaderViewHeight: CGFloat = 300
    
    fileprivate var headerViewPanGesture: UIPanGestureRecognizer!
    fileprivate var pageTabBarPanGesture: UIPanGestureRecognizer!
    fileprivate var isPageTabBarPanning = false
    
    fileprivate var initialY: CGFloat = 200
    fileprivate var initialHeight: CGFloat = 300
    fileprivate var innerScrollViewContentOffset = CGPoint.zero
    
    fileprivate var viewControllers = [UIViewController]()
    fileprivate var headerView = UIView(frame: CGRect.zero)
    
    public init(viewControllers: [UIViewController],
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
        
        pageTabBarController =
            PageTabBarController(
                viewControllers: viewControllers,
                items: tabBarItems,
                estimatedFrame: view.bounds)
        
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
    
    // MARK: - Gesture Handling
    @objc private func pan(_ sender: UIPanGestureRecognizer?) {
        guard let gesture = sender else { return }
        guard let gView = pageTabBarController?.view else { return }
        guard let touchView = gesture.view else { return }
        guard abs(gesture.velocity(in: gView).y) > abs(gesture.velocity(in: gView).x) else { return }
        
        switch gesture.state {
        case .began:
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
            break
        case .changed:
            guard isPageTabBarPanning else { return }
            
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
            
            guard let direction = gesture.direction,
                let pageTabBarController = pageTabBarController,
                let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) else { return }
            
            switch direction {
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
            
            if gView.frame.minY > defaultHeaderHeight {
                let newHeight = initialHeight + (initialY - defaultHeaderHeight)
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                               animations: {
                                    gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
                                    gView.frame.origin = CGPoint(x: 0, y: self.defaultHeaderHeight)
                                
                                    self.headerView.transform = .identity
                                    self.headerView.frame = CGRect(origin: CGPoint.zero, size: self.headerView.frame.size)
                                },
                               completion: nil)
                return
            }
            else if gView.frame.minY < minimumHeaderViewHeight && alwaysBouncesAtTop {
                let newHeight = initialHeight + (initialY - minimumHeaderViewHeight)
                let headerViewOrigin = CGPoint(x: 0, y: minimumHeaderViewHeight - defaultHeaderHeight)
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                               animations: {
                                    gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
                                    gView.frame.origin = CGPoint(x: 0, y: self.minimumHeaderViewHeight)
                                
                                    self.headerView.frame = CGRect(origin: headerViewOrigin, size: self.headerView.frame.size)
                                },
                               completion: nil)
            }
            
            isPageTabBarPanning = false
            
            if autoCollapse {
                guard let direction = gesture.direction,
                    gView.frame.minY > 0,
                    gView.frame.minY < defaultHeaderHeight else { return }
                switch direction {
                case .up:
                    let newHeight = initialHeight + initialY
                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                   animations: {
                                    gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
                                    gView.frame.origin = CGPoint(x: 0, y: 0)
                                    
                                    self.headerView.frame = CGRect(x: 0,
                                                                   y: -self.defaultHeaderHeight,
                                                                   width: self.headerView.frame.width,
                                                                   height: self.headerView.frame.height)
                    },
                                   completion: nil)
                    break
                case .down:
                    let newHeight = initialHeight + (initialY - defaultHeaderHeight)
                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                   animations: {
                                    gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
                                    gView.frame.origin = CGPoint(x: 0, y: self.defaultHeaderHeight)
                                    
                                    self.headerView.frame = CGRect(origin: CGPoint.zero, size: self.headerView.frame.size)
                    },
                                   completion: nil)
                    break
                default:
                    break
                }
            }
            else {
                guard let direction = gesture.direction, abs(gesture.velocity(in: gView).y) > 500 else { return }
                // spring effect
                var distance = (gesture.velocity(in: gView).y * gesture.velocity(in: gView).y) / (2 * UIScrollViewDecelerationRateNormal)
                if case .up = direction {
                    distance = distance * -1
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
                                },
                               completion: nil)
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
        return true
    }
}

// Pan Gesture Helpers
public enum Direction: Int {
    case up
    case down
    case left
    case right
    
    public var isX: Bool { return self == .left || self == .right }
    public var isY: Bool { return !isX }
}

public extension UIPanGestureRecognizer {
    
    public var direction: Direction? {
        let panVelocity = velocity(in: view)
        let vertical = fabs(panVelocity.y) > fabs(panVelocity.x)
        switch (vertical, panVelocity.x, panVelocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return nil
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

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
    @objc optional func collapseTabBarController(_ controller: CollapseTabBarViewController,
                                                 panGestureRecognizer: UIPanGestureRecognizer,
                                                 shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

@objc public enum CollapseTabBarPosition: Int {
    case top = 0
    case bottom
}

@objc public enum CollapseTabBarAnimationType: Int {
    case easeInOut = 0
    case spring
}

public typealias CollapseTabBarLayoutSettings = CollapseCollectionViewLayoutSettings

@objc open class CollapseTabBarViewController: UIViewController {
    
    override open var childViewControllerForStatusBarHidden: UIViewController? {
        return pageTabBarController
    }
    
    override open var childViewControllerForStatusBarStyle: UIViewController? {
        return pageTabBarController
    }
    
    override open var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    
    open weak var delegate: CollapseTabBarViewControllerDelegate?
    
    // MARK: - PageTabBarController Properties
    open fileprivate(set) var pageTabBarController: PageTabBarController?
    open var visibleViewController: UIViewController? {
        return pageTabBarController?.selectedViewController
    }
    
    // MARK: - Scroll Control
    open var pageIndex: Int {
        get {
            guard let pageTabBarController = pageTabBarController else { return 0 }
            return pageTabBarController.pageIndex
        }
        set {
            guard let pageTabBarController = pageTabBarController, pageTabBarController.pageIndex != newValue else { return }
            pageTabBarController.setPageIndex(newValue, animated: false)
        }
    }
    open var autoCollapse = false
    open var alwaysBouncesAtTop = false
    open var alwaysBouncesAtBottom = true
    open var minimumHeaderViewHeight: CGFloat = 100
    open var maximumHeaderViewHeight: CGFloat = 300 {
        didSet {
            if maximumHeaderViewHeight > self.view.frame.height - 100 {
                _maximumHeaderViewHeight = self.view.frame.height - 100
            }
            else {
                _maximumHeaderViewHeight = maximumHeaderViewHeight
            }
        }
    }
    open fileprivate(set) var defaultHeaderHeight: CGFloat = 200 {
        didSet {
            _maximumHeaderViewHeight = defaultHeaderHeight + 64
        }
    }
    
    /**
     LayoutGuide for attaching views to top of page view
     */
    open fileprivate(set) var topPageTabBarLayoutGuide: UILayoutGuide?
    
    fileprivate var tabBarItems = [PageTabBarItem]()
    
    // tabbar positioning
    fileprivate var _maximumHeaderViewHeight: CGFloat = 300
    
    fileprivate var headerViewPanGesture: UIPanGestureRecognizer!
    fileprivate var pageTabBarPanGesture: UIPanGestureRecognizer!
    fileprivate var isPageTabBarPanning = false
    // fileprivate var currentScrollDirection = Direction.notMoving
    
    fileprivate var initialY: CGFloat = 200
    fileprivate var initialHeight: CGFloat = 300
    fileprivate var innerScrollViewContentOffset = CGPoint.zero
    
    fileprivate var viewControllers = [UIViewController]()
    fileprivate var headerView = UIView(frame: CGRect.zero)
    
    fileprivate var collpaseCollectionView: CollapseCollectionView!
    
    @objc public init(viewControllers: [UIViewController],
                      tabBarItems: [PageTabBarItem],
                      headerView: UIView = UIView(frame: CGRect.zero),
                      headerHeight: CGFloat = 200) {
        
        super.init(nibName: nil, bundle: nil)
        
        assert(viewControllers.count > 0, "view controllers count == 0")
        assert(viewControllers.count == tabBarItems.count, "view controllers count != tabBarItems.count")
        
        self.viewControllers = viewControllers
        self.tabBarItems = tabBarItems
        self.headerView = headerView
        self.defaultHeaderHeight = headerHeight
        
        pageTabBarController =
            PageTabBarController(
                viewControllers: viewControllers,
                items: tabBarItems)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let settings = CollapseCollectionViewLayoutSettings(headerSize: CGSize(width: view.frame.width, height: defaultHeaderHeight),
                                                            isHeaderStretchy: true,
                                                            headerStretchHeight: 64,
                                                            headerMinimumHeight: 64)
        let layout = CollapseCollectionViewLayout(settings: settings)
        layout.delegate = self
        
        collpaseCollectionView = CollapseCollectionView(frame: view.bounds, collectionViewLayout: layout)
        collpaseCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Content")
        collpaseCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: CollapseCollectionViewLayout.Element.header.kind, withReuseIdentifier: "Header")
        collpaseCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: CollapseCollectionViewLayout.Element.footer.kind, withReuseIdentifier: "Footer")
        collpaseCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collpaseCollectionView.dataSource = self
        collpaseCollectionView.delegate = self
        view.addSubview(collpaseCollectionView)
        
        //headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: defaultHeaderHeight)
        //view.addSubview(headerView)
        
        guard let pageTabBarController = pageTabBarController else { fatalError("pagetabbar controller = nil") }
        pageTabBarController.updateIndex = { _, index in
            if index == 0 {
            }
        }
        
        pageTabBarController.setPageIndex(pageIndex, animated: false)
        
        addChildViewController(pageTabBarController)
        pageTabBarController.view.frame = CGRect(x: 0, y: defaultHeaderHeight, width: view.frame.width, height: view.frame.height - defaultHeaderHeight)
        view.addSubview(pageTabBarController.view)
        pageTabBarController.didMove(toParentViewController: self)
        
        /*
        pageTabBarController.setPageIndex(pageIndex, animated: false)
        
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
        headerView.addGestureRecognizer(headerViewPanGesture)*/
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public static func attachCollapseTabBarController(_ collapseTabBarViewController: CollapseTabBarViewController, into parentViewController: UIViewController, layoutClosure: (CollapseTabBarViewController, UIViewController) -> ()) {
        parentViewController.addChildViewController(collapseTabBarViewController)
        collapseTabBarViewController.view.frame = CGRect(x: 0, y: 0, width: parentViewController.view.frame.width, height: parentViewController.view.frame.height)
        parentViewController.view.addSubview(collapseTabBarViewController.view)
        layoutClosure(collapseTabBarViewController, parentViewController)
        collapseTabBarViewController.didMove(toParentViewController: parentViewController)
    }
    
    // MARK: - Adjust HeaderViewHeight
    @objc open func setHeaderHeight(_ height: CGFloat) {
        defaultHeaderHeight = height
        scrollTabBar(to: .bottom, animated: false)
    }
    
    // MARK: - Select Tab
    @objc open func selectTabAtIndex(_ index: Int, scrollToPosition: CollapseTabBarPosition) {
        pageTabBarController?.setPageIndex(index, animated: true)
        scrollTabBar(to: .top)
    }
    
    // MARK: - Control Scroll
    @objc open func scrollTabBar(to position: CollapseTabBarPosition, animated: Bool = false) {
        
        switch position {
        case .top:
            collpaseCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: animated)
            break
        case .bottom:
            collpaseCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: animated)
            break
        }
//
//        guard let pageView = pageTabBarController?.view else { return }
//        var headerViewOrigin = CGPoint.zero
//        var pageViewOrigin = pageView.frame.origin
//        var pageViewSize = pageView.frame.size
//
//        switch position {
//        case .top:
//            pageViewOrigin = CGPoint(x: 0, y: minimumHeaderViewHeight)
//            pageViewSize = CGSize(width: pageView.frame.width, height: view.frame.height - minimumHeaderViewHeight)
//            headerViewOrigin = CGPoint(x: 0, y: minimumHeaderViewHeight - defaultHeaderHeight)
//            break
//        case .bottom:
//            pageViewOrigin = CGPoint(x: 0, y: defaultHeaderHeight)
//            pageViewSize = CGSize(width: pageView.frame.width, height: view.frame.height - defaultHeaderHeight)
//            break
//        }
//
//        if springAnimation {
//            UIView.animate(
//                withDuration: 0.3,
//                delay: 0,
//                options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
//                animations: {
//                    pageView.frame = CGRect(origin: pageViewOrigin, size: pageViewSize)
//                    self.headerView.transform = .identity
//                    self.headerView.frame.origin = headerViewOrigin
//                }) { _ in
//                    self.delegate?.collapseTabBarController?(self, tabBarDidReach: position)
//                }
//        }
//        else {
//            UIView.animate(
//                withDuration: 0.3,
//                delay: 0,
//                options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
//                animations: {
//                    pageView.frame = CGRect(origin: pageViewOrigin, size: pageViewSize)
//                    self.headerView.transform = .identity
//                    self.headerView.frame.origin = headerViewOrigin
//                }) { _ in
//                    self.delegate?.collapseTabBarController?(self, tabBarDidReach: position)
//                }
//        }
    }
    
//    // MARK: - Gesture Handling
//    @objc private func pan(_ sender: UIPanGestureRecognizer?) {
//        guard let gesture = sender else { return }
//        guard let gView = pageTabBarController?.view else { return }
//        guard let touchView = gesture.view else { return }
//
//        switch gesture.state {
//        case .began:
//            guard abs(gesture.velocity(in: gView).y) >= abs(gesture.velocity(in: gView).x) else { return }
//
//            initialY = gView.frame.minY
//            initialHeight = gView.frame.height
//
//            if touchView == headerView {
//                isPageTabBarPanning = true
//            }
//            else {
//                isPageTabBarPanning = pageTabBarCanScroll(direction: gesture.direction)
//            }
//            if let pageTabBarController = pageTabBarController,
//                let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) {
//                innerScrollViewContentOffset = scrollView.contentOffset
//            }
//
//            if case .notMoving = gesture.direction {} else {
//                currentScrollDirection = gesture.direction
//            }
//
//            break
//        case .changed:
//            guard isPageTabBarPanning else { return }
//
//            if case .notMoving = gesture.verticalDirection {} else {
//                currentScrollDirection = gesture.verticalDirection
//            }
//
//            let translateY = gesture.translation(in: view).y
//
//            let minimumY = alwaysBouncesAtTop ? 0 : minimumHeaderViewHeight
//            var newY = alwaysBouncesAtBottom ? max(minimumY, translateY + initialY) : max(minimumY, min(translateY + initialY, defaultHeaderHeight))
//            if newY > _maximumHeaderViewHeight {
//                newY = _maximumHeaderViewHeight
//            }
//            let newHeight = initialHeight + (initialY - newY)
//
//            gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
//            gView.frame.origin = CGPoint(x: 0, y: newY)
//
//            if alwaysBouncesAtBottom && gView.frame.minY >= defaultHeaderHeight {
//                let gap = gView.frame.minY - defaultHeaderHeight
//                let newHeight = ceil(defaultHeaderHeight + gap)
//                let scaleFactor = newHeight/defaultHeaderHeight
//                let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
//                let translation = CGAffineTransform(translationX: 0, y: -scaleFactor)
//
//                headerView.transform = scale.concatenating(translation)//CGAffineTransform(scaleX: scale, y: scale)
//                headerView.frame = CGRect(x: headerView.frame.minX, y: newY - newHeight, width: headerView.frame.width, height: headerView.frame.height)
//            }
//            else {
//                headerView.transform = CGAffineTransform.identity
//                headerView.frame = CGRect(x: 0, y: newY - defaultHeaderHeight, width: headerView.frame.width, height: headerView.frame.height)
//            }
//
//            guard let pageTabBarController = pageTabBarController,
//                let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) else { return }
//
//            switch gesture.direction {
//            case .up:
//                if newY > 0 {
//                    scrollView.contentOffset = innerScrollViewContentOffset
//                }
//                break
//            case .down:
//                if newY < defaultHeaderHeight {
//                    scrollView.contentOffset = innerScrollViewContentOffset
//                }
//                break
//            default:
//                break
//            }
//            break
//        default:
//            guard isPageTabBarPanning else { return }
//            if case .notMoving = gesture.verticalDirection {} else {
//                currentScrollDirection = gesture.verticalDirection
//            }
//
//            // bouncing control
//            if gView.frame.minY > defaultHeaderHeight {
//                scrollTabBar(to: .bottom)
//                return
//            }
//            else if gView.frame.minY < minimumHeaderViewHeight && alwaysBouncesAtTop {
//                scrollTabBar(to: .top)
//                return
//            }
//
//            isPageTabBarPanning = false
//
//            if autoCollapse {
//                guard gView.frame.minY > minimumHeaderViewHeight, gView.frame.minY < defaultHeaderHeight else { return }
//                switch currentScrollDirection {
//                case .up:
//                    scrollTabBar(to: .top)
//                    break
//                case .down:
//                    scrollTabBar(to: .bottom)
//                    break
//                default:
//                    break
//                }
//            }
//            else {
//                guard abs(gesture.velocity(in: gView).y) > 500 else { return }
//                // spring effect
//                var distance = (gesture.velocity(in: gView).y * gesture.velocity(in: gView).y) / (2 * UIScrollViewDecelerationRateNormal)
//                var position = CollapseTabBarPosition.bottom
//                if case .up = currentScrollDirection {
//                    distance = distance * -1
//                    position = .top
//                }
//                let time = 0.2
//                let translateY = gesture.translation(in: view).y + distance
//                let minimumY = alwaysBouncesAtTop ? 0 : minimumHeaderViewHeight
//                let newY = max(minimumY, min(translateY + initialY, defaultHeaderHeight))
//
//                let newHeight = initialHeight + (initialY - newY)
//
//                UIView.animate(withDuration: TimeInterval(time),
//                               delay: 0,
//                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
//                               animations: {
//                                    gView.frame = CGRect(x: 0, y: newY, width: gView.frame.width, height: newHeight)
//                                    self.headerView.frame = CGRect(origin: CGPoint(x: 0, y: newY - self.defaultHeaderHeight), size: self.headerView.frame.size)
//                                }) { _ in
//                                    self.delegate?.collapseTabBarController?(self, tabBarDidReach: position)
//                                }
//            }
//            break
//        }
//    }
//
//    fileprivate func pageTabBarCanScroll(direction: Direction?) -> Bool {
//
//        if let pageTabBarController = pageTabBarController {
//            guard let dir = direction else { return true }
//            switch dir {
//            case .up:
//                let threshold = alwaysBouncesAtTop ? 0 : minimumHeaderViewHeight
//                return pageTabBarController.view.frame.minY > threshold
//            case .down:
//                guard let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) else { return true }
//                if !alwaysBouncesAtBottom && pageTabBarController.view.frame.minY == defaultHeaderHeight { return false }
//                return scrollView.contentOffset.y <= scrollView.contentInset.top
//            default:
//                break
//            }
//        }
//        return true
//    }
}

extension CollapseTabBarViewController: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
            let shouldRecognizeSimultaneously = delegate?.collapseTabBarController?(self,
                                                                                    panGestureRecognizer: panGestureRecognizer,
                                                                                    shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
                return shouldRecognizeSimultaneously
        }

        if let gestureView = otherGestureRecognizer.view, gestureView.isKind(of: UIScrollView.self) {
            return true
        }
        
        return false
    }
}

extension CollapseTabBarViewController: CollapseCollectionViewDelegate {
    func collapseCollectionView(_ collapseCollectionView: CollapseCollectionView,
                                panGestureRecognizer: UIPanGestureRecognizer,
                                shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CollapseTabBarViewController: CollapseCollectionViewLayoutDelegate {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Content", for: indexPath)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let vc = pageTabBarController else { fatalError("pagetabbar controller = nil") }
        
        if vc.parent == nil {
            addChildViewController(vc)
            cell.contentView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            vc.didMove(toParentViewController: self)
        }
        else {
            cell.contentView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = viewControllers[indexPath.row]
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case CollapseCollectionViewLayout.Element.header.kind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: defaultHeaderHeight)
            cell.addSubview(headerView)
            return cell
        case CollapseCollectionViewLayout.Element.footer.kind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            
            return cell
        default:
            break
        }
        
        return UICollectionReusableView()
    }
    
    // Disable bottom bounces
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        let bottomOffsetY = scrollView.contentSize.height - scrollView.bounds.height
//
//        if scrollView.contentOffset.y == 0 {
//            self.delegate?.collapseTabBarController?(self, tabBarDidReach: .bottom)
//        }
//
//        if scrollView.contentOffset.y == bottomOffsetY {
//            self.delegate?.collapseTabBarController?(self, tabBarDidReach: .top)
//        }
//
//        // Disable Bottom Bounces
//        if scrollView.contentOffset.y > bottomOffsetY {
//            scrollView.contentOffset.y = bottomOffsetY
//        }
//
//        // Inner Scroll View Handling
//        guard let innerScrollView = pageTabBarController?.currentBaseScrollView else { return }
//
//        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < bottomOffsetY {
//            // disable inner scroll view scroll
//            innerScrollView.panGestureRecognizer.isEnabled = false
//        }
//        else if scrollView.contentOffset.y == 0 {
//            // at bottom
//            if innerScrollView.contentOffset.y + innerScrollView.contentInset.top == 0 {
//                innerScrollView.panGestureRecognizer.isEnabled = false
//            }
//            else {
//                innerScrollView.panGestureRecognizer.isEnabled = true
//            }
//        }
//        else if scrollView.contentOffset.y == bottomOffsetY {
//            // at top
//            if innerScrollView.contentOffset.y + innerScrollView.contentInset.top == 0 {
//                innerScrollView.panGestureRecognizer.isEnabled = false
//            }
//            else {
//                innerScrollView.panGestureRecognizer.isEnabled = true
//            }
//        }
        
    }
    
}

// Pan Gesture Helpers
//@objc public enum Direction: Int {
//    case up
//    case down
//    case left
//    case right
//    case notMoving
//
//    public var isX: Bool { return self == .left || self == .right }
//    public var isY: Bool { return !isX }
//}
//
//extension UIPanGestureRecognizer {
//
//    @objc open var direction: Direction {
//        let panVelocity = velocity(in: view)
//        let vertical = fabs(panVelocity.y) > fabs(panVelocity.x)
//        switch (vertical, panVelocity.x, panVelocity.y) {
//        case (true, _, let y) where y < 0: return .up
//        case (true, _, let y) where y > 0: return .down
//        case (false, let x, _) where x > 0: return .right
//        case (false, let x, _) where x < 0: return .left
//        default: return .notMoving
//        }
//    }
//
//    @objc open var verticalDirection: Direction {
//        let panVelocity = velocity(in: view)
//        let vertical = fabs(panVelocity.y) > fabs(panVelocity.x)
//        switch (vertical, panVelocity.x, panVelocity.y) {
//        case (true, _, let y) where y < 0: return .up
//        case (true, _, let y) where y > 0: return .down
//        case (false, _, let y) where y < 0: return .up
//        case (false, _, let y) where y > 0: return .down
//        default: return .notMoving
//        }
//    }
//}


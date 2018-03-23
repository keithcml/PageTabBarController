//
//  PageTabBarController.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
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

public enum PageTabBarTransitionAnimation {
    case none
    case scroll
}

@objc
public protocol PageTabBarControllerDelegate: NSObjectProtocol {
    @objc optional func pageTabBarController(_ controller: PageTabBarController, tabBarHeaderView: PageTabBarSupplementaryView)
    @objc optional func pageTabBarController(_ controller: PageTabBarController, bannerView: PageTabBarSupplementaryView)
    @objc optional func pageTabBarController(_ controller: PageTabBarController, didChangeContentViewController vc: UIViewController, atIndex index: Int)
}

protocol PageTabBarControllerParallaxDelegate: NSObjectProtocol {
    func pageTabBarController(_ controller: PageTabBarController, childScrollViewDidChange scrollView: UIScrollView)
}

@objcMembers
open class PageTabBarController: UIViewController, UIScrollViewDelegate {
        
    override open var childViewControllerForStatusBarHidden: UIViewController? {
        return selectedViewController
    }
    
    override open var childViewControllerForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
    
    override open var shouldAutomaticallyForwardAppearanceMethods: Bool {
        if case .scroll = transitionAnimation {
            return false
        }
        else {
           return true
        }
    }
    
    open weak var delegate: PageTabBarControllerDelegate?
    open weak var touchDelegate: PageTabBarCollectionViewTouchDelegate? {
        didSet {
            pageTabBarCollectionView.touchDelegate = touchDelegate
        }
    }
    weak var parallaxDelegate: PageTabBarControllerParallaxDelegate?
    
    open var transitionAnimation = PageTabBarTransitionAnimation.scroll {
        didSet {
            if case .scroll = transitionAnimation {
                isScrollEnabled = true
            }
            else {
                isScrollEnabled = false
            }
        }
    }
    
    open private(set) var pageIndex: Int = 0
    
    open var selectedViewController: UIViewController? {
        if viewControllers.count > pageIndex {
            return viewControllers[pageIndex]
        }
        return nil
    }
    
    open internal(set) var pageTabBar: PageTabBar
    
    // horizontal paging scrolling
    open var isScrollEnabled = true {
        didSet {
            pageTabBarCollectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    // paging horizontal bounces
    open var bounces = true {
        didSet {
            pageTabBarCollectionView.bounces = bounces
        }
    }
    
    open private(set) lazy var pageTabBarSupplementaryView = PageTabBarSupplementaryView(frame: CGRect.zero)
    
    open let pageTabBarCollectionView: PageTabBarCollectionView = {
        let layout = PageTabBarCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        
        let collectionView = PageTabBarCollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.register(PageTabBarCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.isPagingEnabled = true
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .clear
        collectionView.isDirectionalLockEnabled = true
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }()
    
    internal(set) var viewControllers = [UIViewController]()
    private(set) var tabBarPosition: PageTabBarPosition = .topAttached
    
    var pageTabBarItems: [PageTabBarItem] = []
    
    // States
    private var viewDidLayoutSubviewsForTheFirstTime = true
    
    // Layout Guide
//    open private(set) var tabBarLayoutGuide = UILayoutGuide()
//    open private(set) var bannerViewLayoutGuide = UILayoutGuide()
    
    // Constraints
    private var tabBarTopConstraint: NSLayoutConstraint?
    private var supplementaryViewHeightConstraint: NSLayoutConstraint?
    
    // Child Scroll View
    open private(set) var currentScrollView: UIScrollView?
    
    public required init(viewControllers: [UIViewController],
                         items: [PageTabBarItem],
                         tabBarPosition: PageTabBarPosition = .topAttached) {
        
        self.pageTabBar = PageTabBar(tabBarItems: items)
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewControllers = viewControllers
        self.tabBarPosition = tabBarPosition
        pageTabBarItems = items
        
        automaticallyAdjustsScrollViewInsets = false
        viewControllers.forEach { $0.automaticallyAdjustsScrollViewInsets = false }
        
        for vc in viewControllers {
            addChildViewController(vc)
            vc.didMove(toParentViewController: self)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(pageTabBarCollectionView)
        pageTabBarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pageTabBarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageTabBarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pageTabBarCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pageTabBarCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        pageTabBar.delegate = self
        view.addSubview(pageTabBar)
        pageTabBar.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            pageTabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            pageTabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            pageTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            pageTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        switch tabBarPosition {
        case .topAttached:
            view.addSubview(pageTabBarSupplementaryView)
            pageTabBarSupplementaryView.translatesAutoresizingMaskIntoConstraints = false
            pageTabBarSupplementaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            pageTabBarSupplementaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            supplementaryViewHeightConstraint = pageTabBarSupplementaryView.heightAnchor.constraint(equalToConstant: 0)
            supplementaryViewHeightConstraint?.isActive = true
            break
        default:
            break
        }
        
        pageTabBarCollectionView.dataSource = self
        pageTabBarCollectionView.delegate = self
        
        var topAnchor = view.topAnchor
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11.0, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        
        switch tabBarPosition {
        case .topAttached:
            pageTabBarSupplementaryView.topAnchor.constraint(equalTo: pageTabBar.bottomAnchor).isActive = true
            tabBarTopConstraint = pageTabBar.topAnchor.constraint(equalTo: topAnchor)
            tabBarTopConstraint?.isActive = true
            break
        case .topInsetAttached:
            tabBarTopConstraint = pageTabBar.topAnchor.constraint(equalTo: topAnchor)
            tabBarTopConstraint?.isActive = true
            break
        case .bottom:
            pageTabBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            break
        }
        
        if viewControllers.count > 0 {
            didChangeContentViewController(viewControllers[0], at: 0)
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !shouldAutomaticallyForwardAppearanceMethods {
            selectedViewController?.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !shouldAutomaticallyForwardAppearanceMethods {
            selectedViewController?.endAppearanceTransition()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !shouldAutomaticallyForwardAppearanceMethods {
            selectedViewController?.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !shouldAutomaticallyForwardAppearanceMethods {
            selectedViewController?.endAppearanceTransition()
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if viewDidLayoutSubviewsForTheFirstTime {
            viewDidLayoutSubviewsForTheFirstTime = false
            
            if case .scroll = transitionAnimation {
                isScrollEnabled = true
            }
            else {
                isScrollEnabled = false
            }
            
            pageTabBarCollectionView.scrollToItem(at: IndexPath(item: pageIndex, section: 0), at: .centeredHorizontally, animated: false)

            setNeedsStatusBarAppearanceUpdate()
            
            if #available(iOS 11.0, *) { /* do nothing */ } else {
                if let constant = tabBarTopConstraint?.constant, constant != topLayoutGuide.length {
                    tabBarTopConstraint?.constant = topLayoutGuide.length
                    adjustsContentInsets()
                }
            }
        }
    }
    
    private func adjustsContentInsets() {
        if #available(iOS 11.0, *) {
            var newSafeArea = UIEdgeInsets()
            switch tabBarPosition {
            case .topAttached, .topInsetAttached:
                newSafeArea.top += pageTabBar.frame.height
                break
            case .bottom:
                newSafeArea.bottom += pageTabBar.frame.height
                break
            }
            
            if let bannerHeight = supplementaryViewHeightConstraint?.constant {
                newSafeArea.top += bannerHeight
            }
            for child in viewControllers {
                child.additionalSafeAreaInsets = newSafeArea
            }
        } else {
            
            for vc in viewControllers {
                if let scrollView = theMostBelowScrollViewInView(vc.view) {
                    var inset = scrollView.contentInset
                    switch tabBarPosition {
                    case .topAttached, .topInsetAttached:
                        inset.top = pageTabBar.frame.maxY + (supplementaryViewHeightConstraint?.constant ?? 0)
                        break
                    case .bottom:
                        inset.bottom = pageTabBar.frame.height
                        break
                    }
                    scrollView.contentInset = inset
                    scrollView.scrollIndicatorInsets = inset
                    
                    scrollView.setContentOffset(CGPoint(x: 0, y: -inset.top), animated: false)
                }
            }
        }
    }
    
    private func theMostBelowScrollViewInView(_ view: UIView) -> UIScrollView? {
        
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        
        for subview in view.subviews {
            // if the real keyboard-view is found, remember it.
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
            
            let itsSubview = theMostBelowScrollViewInView(subview)
            if itsSubview != nil {
                return itsSubview
            }
        }
        return nil
    }
}

// MARK: - Public Methods
extension PageTabBarController {
    
    // MARK: - Badge
    open func setBadge(_ value: Int, forItemAt index: Int) {
        guard pageTabBarItems.count > index else { return }
        pageTabBarItems[index].badgeCount = value
    }
    
    open func clearAllBadges() {
        for item in pageTabBarItems {
            item.badgeCount = 0
        }
    }
    
    // MARK: - PageIndex
    open func setPageIndex(_ index: Int, animated: Bool) {
        guard pageTabBarItems.count > index else { return }
        
        var shouldAnimate = animated
        if case .scroll = transitionAnimation {
            shouldAnimate = animated
        }
        else {
            shouldAnimate = false
        }
        
        if !isViewLoaded {
            shouldAnimate = false
        }
        
        // delay set pageIndex until animation ended
        let indexPath = IndexPath(item: index, section: 0)
        if !viewDidLayoutSubviewsForTheFirstTime {
            pageTabBarCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: shouldAnimate)
        }
        
        if !shouldAnimate {
            guard index != pageIndex else { return }
            pageIndex = index
            
            didChangeContentViewController(viewControllers[pageIndex], at: pageIndex)
            delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[pageIndex], atIndex: pageIndex)
        }
    }
    
    // MARK: - Supplementary Views
    open func setPageTabBarSupplementaryViewWithCustomView(_ customView: UIView?, animated: Bool) {
        
        guard case .topAttached = tabBarPosition else {
            fatalError("position top not supporting banner view")
        }
        
        pageTabBarSupplementaryView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let customView = customView else {
            
            UIView.animate(withDuration: 0.3) {
                self.supplementaryViewHeightConstraint?.constant = 0
                self.view.layoutIfNeeded()
            }
            
            return
        }
        
        let height = ceil(customView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        
        pageTabBarSupplementaryView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.topAnchor.constraint(equalTo: pageTabBarSupplementaryView.topAnchor).isActive = true
        customView.leadingAnchor.constraint(equalTo: pageTabBarSupplementaryView.leadingAnchor).isActive = true
        customView.trailingAnchor.constraint(equalTo: pageTabBarSupplementaryView.trailingAnchor).isActive = true
        customView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        if view.window == nil {
            supplementaryViewHeightConstraint?.constant = height
            adjustsContentInsets()
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.supplementaryViewHeightConstraint?.constant = height
            self.adjustsContentInsets()
            self.view.layoutIfNeeded()
        }
    }
    
    open func setPageTabBarController(_ viewControllers: [UIViewController], items: [PageTabBarItem], newPageIndex: Int, animated: Bool) {

        pageTabBarItems = items
        pageTabBar.replaceTabBarItems(items)
        
        self.viewControllers.forEach { vc in
            if vc.parent != nil {
                vc.willMove(toParentViewController: nil)
                vc.removeFromParentViewController()
            }
        }
        self.viewControllers = viewControllers
        
        for vc in viewControllers {
            addChildViewController(vc)
            vc.didMove(toParentViewController: self)
        }

        // visual update if view on screen
        if !viewDidLayoutSubviewsForTheFirstTime {
            pageTabBarCollectionView.reloadData()
            
            pageTabBarCollectionView.performBatchUpdates(nil) { [weak self] (_) in
                self?.setPageIndex(newPageIndex, animated: animated)
            }
        }
        
//        if view.window != nil {
//            pageTabBarCollectionView.reloadData()
//            pageTabBarCollectionView.performBatchUpdates(nil) { (_) in
//                self.pageTabBarCollectionView.scrollToItem(at: IndexPath(item: newPageIndex, section: 0), at: .centeredHorizontally, animated: animated)
//                self.didChangeContentViewController(viewControllers[newPageIndex], at: newPageIndex)
//            }
//        }
    }
    
    open func setTabBarTopPosition(_ position: PageTabBarPosition) {
        if case .bottom = position {
            fatalError("message: bottom position is forbidden")
        }
        
        guard position != tabBarPosition else { return }
        tabBarPosition = position
    }
}

extension PageTabBarController: PageTabBarDelegate {
    
    func pageTabBarCurrentIndex(_ tabBar: PageTabBar) -> Int {
        return pageIndex
    }
    
    // call back from item tapped
    func pageTabBar(_ tabBar: PageTabBar, indexDidChanged index: Int) {
        setPageIndex(index, animated: true)
    }
}

extension PageTabBarController: UICollectionViewDataSource {
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PageTabBarCollectionViewCell
        cell.viewController = viewControllers[indexPath.row]
        return cell
    }
}

extension PageTabBarController: UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        guard let cell = cell as? PageTabBarCollectionViewCell, let vc = cell.viewController else { return }
        
        if !shouldAutomaticallyForwardAppearanceMethods {
            vc.beginAppearanceTransition(true, animated: false)
        }
        
        cell.contentView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        
        adjustsContentInsets()

        if !shouldAutomaticallyForwardAppearanceMethods {
            vc.endAppearanceTransition()
        }
        
        UIView.animate(withDuration: 0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? PageTabBarCollectionViewCell, let vc = cell.viewController else { return }
        
        for view in vc.view.subviews {
            if let scrollView =  view as? UIScrollView {
                let offset = scrollView.contentOffset
                scrollView.setContentOffset(offset, animated: false)
                break
            }
        }
        
        if !shouldAutomaticallyForwardAppearanceMethods {
            vc.beginAppearanceTransition(false, animated: false)
        }
        
        vc.view.removeFromSuperview()
        
        if !shouldAutomaticallyForwardAppearanceMethods {
            vc.endAppearanceTransition()
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pageTabBar.isInteracting = true
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentSize = pageTabBarCollectionView.collectionViewLayout.collectionViewContentSize
        guard contentSize.width > 0 else { return }
        let diff = scrollView.contentOffset.x * pageTabBar.frame.width/contentSize.width
        pageTabBar.setIndicatorPosition(diff)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && !scrollView.isDragging {
            didDragAndEnd(scrollView)
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDragging {
            didDragAndEnd(scrollView)
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        guard let indexPath = pageTabBarCollectionView.indexPathForItem(at: center) else { return }
        if indexPath.item != pageIndex {
            delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[indexPath.item], atIndex: indexPath.item)
        }
        pageIndex = indexPath.item
        didChangeContentViewController(viewControllers[indexPath.item], at: indexPath.item)
    }
    
    private func didDragAndEnd(_ scrollView: UIScrollView) {
        pageTabBar.isInteracting = false
        
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        guard let indexPath = pageTabBarCollectionView.indexPathForItem(at: center) else { return }
        if indexPath.item != pageIndex {
            delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[indexPath.item], atIndex: indexPath.item)
        }
        pageIndex = indexPath.item
        didChangeContentViewController(viewControllers[indexPath.item], at: indexPath.item)
    }
    
    private func didChangeContentViewController(_ vc: UIViewController, at index: Int) {
        for view in vc.view.subviews {
            if view.isKind(of: UIScrollView.self) {
                currentScrollView = view as? UIScrollView
                if let scrollView = currentScrollView {
                    parallaxDelegate?.pageTabBarController(self, childScrollViewDidChange: scrollView)
                }
                break
            }
        }
        
    }
}

extension PageTabBarController: UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var contentInsets = collectionView.contentInset
        if #available(iOS 11.0, *) {
            contentInsets = collectionView.adjustedContentInset
        }
        
        return CGSize(width: collectionView.frame.width - contentInsets.left - contentInsets.right,
                      height: collectionView.frame.height - contentInsets.top - contentInsets.bottom)
    }
}

// MARK: - TabBar Transform

extension PageTabBarController {

    func transformTabBarWithScrollViewBounces(_ scrollView: UIScrollView) {
        
        var contentInset = scrollView.contentInset
        var minimumThreshold = self.topLayoutGuide.length
        if #available(iOS 11.0, *) {
            minimumThreshold = 0
            contentInset = scrollView.adjustedContentInset
        }
        
        let offset = min(0, scrollView.contentOffset.y + contentInset.top)
        
        pageTabBar.transform = CGAffineTransform(translationX: 0, y: max(minimumThreshold, minimumThreshold - offset))
    }
}


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

@objc public protocol PageTabBarControllerDelegate: class {
    @objc optional func pageTabBarController(_ controller: PageTabBarController, didSelectItem item: PageTabBarItem, atIndex index: Int, previousIndex: Int)
    @objc optional func pageTabBarController(_ controller: PageTabBarController, didChangeContentViewController vc: UIViewController, atIndex index: Int)
}

internal final class PageTabBarCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        let oldBounds = cv.bounds
        if newBounds.height != oldBounds.height {
            cv.collectionViewLayout.invalidateLayout()
            return false
        }
        return false
    }
}

@objc open class PageTabBarController: UIViewController, UIScrollViewDelegate {
        
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
    
    open var updateIndex: (Bool, Int) -> () = { _ in }
    
    open internal(set) var pageIndex: Int = 0 {
        didSet {
            // print("change from \(oldValue) to \(pageIndex)")
            UIView.animate(withDuration: 0.2) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    open var selectedViewController: UIViewController? {
        if viewControllers.count > pageIndex {
            return viewControllers[pageIndex]
        }
        return nil
    }
    
    open fileprivate(set) var pageTabBar: PageTabBar!
    open var isScrollEnabled = true {
        didSet {
            guard let cv = collectionView else { return }
            cv.isScrollEnabled = isScrollEnabled
        }
    }
    
    fileprivate var collectionView: UICollectionView!
    fileprivate(set) var viewControllers = [UIViewController]()
    fileprivate var tabBarPosition: PageTabBarPosition = .top
    
    internal var pageTabBarItems: [PageTabBarItem] = []
    internal var internalScrollViewPanGestureRecognizer: UIPanGestureRecognizer? {
        return collectionView.panGestureRecognizer
    }
    
    @objc public convenience init(viewControllers: [UIViewController],
                                  items: [PageTabBarItem],
                                  estimatedFrame: CGRect,
                                  initialPageIndex: Int = 0,
                                  tabBarPosition: PageTabBarPosition = .top) {
        
        self.init(nibName: nil, bundle: nil)
        
        self.viewControllers = viewControllers
        self.tabBarPosition = tabBarPosition
        for item in items {
            item.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width/CGFloat(pageTabBarItems.count), height: 44)
            pageTabBarItems.append(item)
        }
        self.pageIndex = initialPageIndex
        
        pageTabBar = PageTabBar(frame: CGRect(x: 0, y: 0, width: estimatedFrame.width, height: 44), tabBarItems: pageTabBarItems, initialIndex: pageIndex)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        pageTabBar.toIndex = { [unowned self] index in
            self.setPageIndex(index, animated: true)
        }
        
        view.addSubview(pageTabBar)
        pageTabBar.translatesAutoresizingMaskIntoConstraints = false
        pageTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pageTabBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let layout: UICollectionViewFlowLayout = PageTabBarCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        setPageIndex(pageIndex, animated: false)
        
        if case .scroll = transitionAnimation {
            isScrollEnabled = true
        }
        else {
            isScrollEnabled = false
        }
        
        if case .top = tabBarPosition {
            pageTabBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            collectionView.topAnchor.constraint(equalTo: pageTabBar.bottomAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        else {
            pageTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: pageTabBar.topAnchor).isActive = true
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
    
    @available(*, deprecated, message: "deprecated")
    override open func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        UIView.animate(withDuration: 0, animations: {
            self.collectionView.reloadData()
            self.collectionView?.scrollToItem(at: IndexPath(row: self.pageIndex, section: 0),
                                              at: .top,
                                              animated: true)
            self.view.layoutIfNeeded()
        }, completion: { _ in
            let diff = self.collectionView.contentOffset.x * self.pageTabBar.frame.width / self.collectionView.contentSize.width
            self.pageTabBar.setIndicatorPosition(diff)
        })
    }
    
    open func setPageIndex(_ index: Int, animated: Bool) {
        guard pageTabBarItems.count > index else { return }
        
        delegate?.pageTabBarController?(self, didSelectItem: pageTabBarItems[index], atIndex: index, previousIndex: pageIndex)
        
        guard index != pageIndex else { return }
        
        if !shouldAutomaticallyForwardAppearanceMethods {
            viewControllers[pageIndex].beginAppearanceTransition(false, animated: false)
            viewControllers[pageIndex].endAppearanceTransition()
        }
        
        pageIndex = index
        
        if !shouldAutomaticallyForwardAppearanceMethods {
            viewControllers[pageIndex].beginAppearanceTransition(true, animated: false)
            viewControllers[pageIndex].endAppearanceTransition()
        }
        
        var shouldAnimate = animated
        if case .scroll = transitionAnimation {
            shouldAnimate = animated
        }
        else {
            shouldAnimate = false
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: shouldAnimate)
        
        if !shouldAnimate {
            delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[pageIndex], atIndex: pageIndex)
        }
    }
    
    open func setBadge(_ value: Int, forItemAt index: Int) {
        guard pageTabBarItems.count > index else { return }
        pageTabBarItems[index].badgeCount = value
    }
    
    open func clearAllBadges() {
        for item in pageTabBarItems {
            item.badgeCount = 0
        }
    }
    
    func theMostBelowScrollViewInView(_ view: UIView) -> UIScrollView? {
        
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

extension PageTabBarController: UICollectionViewDataSource {
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
}

extension PageTabBarController: UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let vc = viewControllers[indexPath.row]
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
        updateIndex(false, indexPath.row)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = viewControllers[indexPath.row]
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pageTabBar.isInteracting = true
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let diff = scrollView.contentOffset.x * pageTabBar.frame.width/scrollView.contentSize.width
        pageTabBar.setIndicatorPosition(diff)
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && !scrollView.isDragging {
            didDragAndEnd()
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDragging {
            didDragAndEnd()
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[pageIndex], atIndex: pageIndex)
    }
    
    fileprivate func didDragAndEnd() {
        pageTabBar.isInteracting = false
        let index = pageTabBar.getCurrentIndex()
        setPageIndex(index, animated: true)
        delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[pageIndex], atIndex: pageIndex)
    }
    
}

extension PageTabBarController: UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

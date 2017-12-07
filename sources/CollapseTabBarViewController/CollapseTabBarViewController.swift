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

@objc
public protocol CollapseTabBarViewControllerDelegate: PageTabBarControllerDelegate {
    
    // Don't do heavy task in this delegate
    @objc optional func collapseTabBarController(_ controller: CollapseTabBarViewController, tabBarRect rect: CGRect, position: CollapseTabBarPosition, revealPercentage: CGFloat)
    @objc optional func collapseTabBarController(_ controller: CollapseTabBarViewController, scrollViewsForScrollingWithTabBarMoveAtIndex pageIndex: Int) -> [UIScrollView]
}

@objc
public enum CollapseTabBarPosition: Int {
    case top = 0
    case bottom
    case inBetween
}

@objc
public enum CollapseTabBarAnimationType: Int {
    case easeInOut = 0
    case spring
}

public typealias CollapseTabBarLayoutSettings = CollapseCollectionViewLayoutSettings

@objcMembers
open class CollapseTabBarViewController: UIViewController {
    
    override open var childViewControllerForStatusBarHidden: UIViewController? {
        return pageTabBarController
    }
    
    override open var childViewControllerForStatusBarStyle: UIViewController? {
        return pageTabBarController
    }
    
    override open var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    open weak var delegate: CollapseTabBarViewControllerDelegate? {
        didSet {
            pageTabBarController.delegate = delegate
        }
    }
    
    // MARK: - PageTabBarController Properties
    open fileprivate(set) var pageTabBarController: PageTabBarController
    
    open var visibleViewController: UIViewController? {
        return pageTabBarController.selectedViewController
    }
    
    // MARK: - Scroll Control
    open var pageIndex: Int {
        get {
            return pageTabBarController.pageIndex
        }
        set {
            guard pageTabBarController.pageIndex != newValue else { return }
            pageTabBarController.setPageIndex(newValue, animated: false)
        }
    }
    
    open var autoCollapse = false
    
    open var alwaysBouncesAtBottom = true
    
    open var minimumHeaderViewHeight: CGFloat = 0
    
    open var defaultHeaderHeight: CGFloat = 200
    
    open var headerViewStretchyHeight: CGFloat = 64
    
    open var staticHeaderView: UIView? {
        didSet {
            collpaseCollectionView.staticHeaderView = staticHeaderView
        }
    }
    
    open var isScrollEnabled = true {
        didSet {
            collpaseCollectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    private var tabBarItems = [PageTabBarItem]()
    
    private var viewControllers = [UIViewController]()
    private var headerView = UIView(frame: CGRect.zero)
    
    private var collpaseCollectionView: CollapseCollectionView
    
    public init(viewControllers: [UIViewController],
                tabBarItems: [PageTabBarItem],
                headerView: UIView = UIView(frame: CGRect.zero),
                headerHeight: CGFloat = 200) {
        
        pageTabBarController =
            PageTabBarController(
                viewControllers: viewControllers,
                items: tabBarItems)
        
        let layout = CollapseCollectionViewLayout(settings: CollapseCollectionViewLayoutSettings.defaultSettings())
        collpaseCollectionView = CollapseCollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        assert(viewControllers.count > 0, "view controllers count == 0")
        assert(viewControllers.count == tabBarItems.count, "view controllers count != tabBarItems.count")
        
        self.viewControllers = viewControllers
        self.tabBarItems = tabBarItems
        self.headerView = headerView
        self.defaultHeaderHeight = headerHeight
        
        collpaseCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Content")
        collpaseCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: CollapseCollectionViewLayout.Element.header.kind, withReuseIdentifier: "Header")
        collpaseCollectionView.register(CollapseStaticHeaderView.self, forSupplementaryViewOfKind: CollapseCollectionViewLayout.Element.staticHeader.kind, withReuseIdentifier: "StaticHeader")
        collpaseCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        automaticallyAdjustsScrollViewInsets = false
        
        if #available(iOS 11.0, *) {
            collpaseCollectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let settings = CollapseCollectionViewLayoutSettings(headerSize: CGSize(width: view.frame.width, height: defaultHeaderHeight),
                                                            isHeaderStretchy: true,
                                                            headerStretchHeight: headerViewStretchyHeight,
                                                            headerMinimumHeight: minimumHeaderViewHeight)
        setLayoutSettings(settings, animated: false)

        collpaseCollectionView.collapseDelegate = self
        
        view.addSubview(collpaseCollectionView)
        
        pageTabBarController.updateIndex = { _, index in
            if index == 0 {
            }
        }
        
        pageTabBarController.setPageIndex(pageIndex, animated: false)
        
        // add child view controller
        addChildViewController(pageTabBarController)
        pageTabBarController.didMove(toParentViewController: self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pageTabBarController.parent != nil {
            pageTabBarController.beginAppearanceTransition(true, animated: animated)
        }
        
        if #available(iOS 11.0, *) { /* do nothing */ } else {
            collpaseCollectionView.registerMultiScrollViewsHandling()
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if pageTabBarController.parent != nil {
            pageTabBarController.endAppearanceTransition()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pageTabBarController.beginAppearanceTransition(false, animated: animated)
        
        if #available(iOS 11.0, *) { /* do nothing */ } else {
            collpaseCollectionView.unregisterMultiScrollViewsHandling()
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageTabBarController.endAppearanceTransition()
    }
    
    public static func attachCollapseTabBarController(_ collapseTabBarViewController: CollapseTabBarViewController, into parentViewController: UIViewController, layoutClosure: (CollapseTabBarViewController, UIViewController) -> ()) {
        parentViewController.addChildViewController(collapseTabBarViewController)
        collapseTabBarViewController.view.frame = CGRect(x: 0, y: 0, width: parentViewController.view.frame.width, height: parentViewController.view.frame.height)
        parentViewController.view.addSubview(collapseTabBarViewController.view)
        layoutClosure(collapseTabBarViewController, parentViewController)
        collapseTabBarViewController.didMove(toParentViewController: parentViewController)
    }
    
    // MARK: - Adjust Layout
    open func setLayoutSettings(_ settings: CollapseTabBarLayoutSettings, animated: Bool) {
        minimumHeaderViewHeight = settings.headerMinimumHeight
        defaultHeaderHeight = settings.headerSize.height
        headerViewStretchyHeight = settings.headerStretchHeight
        let newLayout = CollapseCollectionViewLayout(settings: settings)
        newLayout.delegate = collpaseCollectionView
        collpaseCollectionView.setCollectionViewLayout(newLayout, animated: animated)
    }
    
    // MARK: - Select Tab
    open func selectTabAtIndex(_ index: Int, scrollToPosition: CollapseTabBarPosition) {
        pageTabBarController.setPageIndex(index, animated: true)
        scrollTabBar(to: .top, animated: true)
    }
    
    // MARK: - Control Scroll
    open func scrollTabBar(to position: CollapseTabBarPosition, animated: Bool = false) {
        
        switch position {
        case .top:
            collpaseCollectionView.setContentOffset(CGPoint(x: 0, y: defaultHeaderHeight - minimumHeaderViewHeight), animated: animated)
            break
        case .bottom:
            collpaseCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: animated)
            break
        case .inBetween:
            break
        }
    }
    
    private func constructScrollViewsToIgnoreTouches() -> [UIScrollView] {
        var scrollViews = pageTabBarController.interceptTouchesScrollViews()

        if let fromDelegate = delegate?.collapseTabBarController?(self, scrollViewsForScrollingWithTabBarMoveAtIndex: pageIndex) {
            
            fromDelegate.forEach { additionalScrollView in
                if !scrollViews.contains( where: { $0 === additionalScrollView } ) {
                    scrollViews.append(additionalScrollView)
                }
            }
        }
        return scrollViews
    }
}

extension CollapseTabBarViewController: CollapseCollectionViewDelegate {
    func getCollapseTabBarViewController() -> CollapseTabBarViewController? {
        return self
    }
    
    func getPageTabBarController() -> PageTabBarController? {
        return pageTabBarController
    }
    
    func getHeaderView() -> UIView? {
        return headerView
    }
    
    func getContentViewControllers() -> [UIViewController] {
        return viewControllers
    }
    
    func collapseCollectionViewDidScroll(_ collapseCollectionView: CollapseCollectionView) {
        
        guard let cell = collapseCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
        let rect = collapseCollectionView.convert(cell.frame, to: view)
        
        if collapseCollectionView.contentOffset.y >= defaultHeaderHeight - minimumHeaderViewHeight {
            let adjustedRect = CGRect(x: rect.minX, y: minimumHeaderViewHeight, width: rect.width, height: rect.height)
            delegate?.collapseTabBarController?(self, tabBarRect: adjustedRect, position: .top, revealPercentage: CGFloat(0))
        }
        else if collapseCollectionView.contentOffset.y <= 0 {
            let adjustedRect = CGRect(x: rect.minX,
                                      y: defaultHeaderHeight + min(abs(collapseCollectionView.contentOffset.y), headerViewStretchyHeight),
                                      width: rect.width,
                                      height: rect.height)
            delegate?.collapseTabBarController?(self, tabBarRect: adjustedRect, position: .bottom, revealPercentage: CGFloat(1))
        }
        else {
            let percentage = (rect.minY - minimumHeaderViewHeight) / (defaultHeaderHeight - minimumHeaderViewHeight)
            delegate?.collapseTabBarController?(self, tabBarRect: rect, position: .inBetween, revealPercentage: percentage)
        }
        
    }
}


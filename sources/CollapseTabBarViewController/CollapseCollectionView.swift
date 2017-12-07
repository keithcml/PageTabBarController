//
//  CollapseCollectionView.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 22/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objc
protocol CollapseCollectionViewExtendedDelegate: class {
    @objc optional func scrollView(_ scrollView: CollapseCollectionView, shouldScrollWithSubView subView: UIScrollView) -> Bool
}

@objc
protocol CollapseCollectionViewDelegate {
    @objc func getCollapseTabBarViewController() -> CollapseTabBarViewController?
    @objc func getPageTabBarController() -> PageTabBarController?
    @objc func getHeaderView() -> UIView?
    @objc func getContentViewControllers() -> [UIViewController]
    @objc optional func collapseCollectionViewDidScroll(_ collapseCollectionView: CollapseCollectionView)
}

@objcMembers
final class CollapseCollectionView: UICollectionView {
    
    let proxy = CollapseCollectionViewProxy()
    
    var headerMinimumHeight: CGFloat {
        if let layout = collectionViewLayout as? CollapseCollectionViewLayout {
            return layout.settings.headerMinimumHeight
        }
        return 0
    }
    var headerHeight: CGFloat {
        if let layout = collectionViewLayout as? CollapseCollectionViewLayout {
            return layout.settings.headerSize.height
        }
        return 0
    }
    var stretchyHeight: CGFloat {
        if let layout = collectionViewLayout as? CollapseCollectionViewLayout {
            return layout.settings.headerStretchHeight
        }
        return 0
    }
    private lazy var minimumOffsetY = headerHeight - headerMinimumHeight
    private var maximumContentOffsetY: CGFloat {
        return headerHeight - headerMinimumHeight
    }
    
    var staticHeaderView: UIView?

    private var observedScrollViews = [UIScrollView]()
    private var isObserving = false
    private var otherScrollViewLocked = false
    private var contentOffsetObservation: NSKeyValueObservation?
    private var observations = [NSKeyValueObservation]()
    
    weak var collapseDelegate: CollapseCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        dataSource = self
        proxy.extendedDelegateObject = self
        proxy.extendedDelegate = self
        delegate = proxy
        backgroundColor = .white
        bounces = true
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        panGestureRecognizer.delegate = self
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        
        if let layout = layout as? CollapseCollectionViewLayout {
            layout.delegate = self
        }
        
        if #available(iOS 11.0, *) {
            observeMySelf()
            isObserving = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObservingViews()
    }
    
    // iOS 10 Crahses Fixes - https://bugs.swift.org/browse/SR-5816
    func registerMultiScrollViewsHandling() {
        observeMySelf()
        isObserving = true
    }
    
    func unregisterMultiScrollViewsHandling() {
        unObserveMySelf()
    }
    
    // Methods Forwarding
    override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector)
    }
    
    // MARK: - Multi Scroll Handling
    private func handleMultiScroll(oldOffset: CGPoint, newOffset: CGPoint, scrollView: UIScrollView) {
        
        let diff = oldOffset.y - newOffset.y
        
        if scrollView == self {
            
            if diff > 0 {
                
                if oldOffset.y >= maximumContentOffsetY && newOffset.y < maximumContentOffsetY {
                    
                    if let observed = observedScrollViews.first {
                        if observed.contentOffset.y - observed.contentInset.top > 0 {
                            setContentOffset(CGPoint(x: oldOffset.x, y: maximumContentOffsetY), for: scrollView)
                        }
                    }
                }
            }
            
            
        } else {
            //Adjust the observed scrollview's content offset
            otherScrollViewLocked = scrollView.contentOffset.y > -scrollView.contentInset.top

            //Manage scroll up
            if contentOffset.y < -headerMinimumHeight + headerHeight && otherScrollViewLocked && diff < 0 {
                setContentOffset(oldOffset, for: scrollView)
            }
            //Disable bouncing when scroll down
            if !otherScrollViewLocked && ((contentOffset.y > -contentInset.top) || bounces) {
                setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -scrollView.contentInset.top), for: scrollView)
            }
        }
        
    }
    
    
    // MARK: - Scrolling handler
    private func observeMySelf() {
        
        guard contentOffsetObservation == nil else { return }
        
        contentOffsetObservation = observe(\.contentOffset, options: [.new, .old]) { myself, change in
            
            guard myself.isObserving else { return }
            
            guard let oldValue = change.oldValue, let newValue = change.newValue else {
                return
            }
            
            // diff < 0 => scroll up, diff > 0 => scroll down
            let diff = oldValue.y - newValue.y
            
            guard diff != 0 else { return }
            
            myself.handleMultiScroll(oldOffset: oldValue, newOffset: newValue, scrollView: myself)
        }
    }
    
    private func unObserveMySelf() {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }
    
    private func addObserverFor(scrollView: UIScrollView) {
        guard !observedScrollViews.contains(scrollView) else { return }
        
        observedScrollViews.append(scrollView)
        
        otherScrollViewLocked = scrollView.contentOffset.y > -scrollView.contentInset.top
        
        let observation = scrollView.observe(\.contentOffset, options: [.new, .old]) { [unowned self] observed, change in
            
            guard self.isObserving else { return }
            
            guard let oldValue = change.oldValue, let newValue = change.newValue else {
                return
            }
            
            // diff < 0 => scroll up, diff > 0 => scroll down
            let diff = oldValue.y - newValue.y
            
            guard diff != 0 else {
                return
            }
            
            self.handleMultiScroll(oldOffset: oldValue, newOffset: newValue, scrollView: observed)
        }
        
        observations.append(observation)
    }
    
    private func removeObservingViews() {
        observations.forEach {
            $0.invalidate()
        }
        observations.removeAll()
        observedScrollViews.removeAll()
    }
    
    private func setContentOffset(_ contentOffset: CGPoint, for scrollView: UIScrollView) {
        isObserving = false
        scrollView.contentOffset = contentOffset
        DispatchQueue.main.async {
            self.isObserving = true
        }
    }
}

extension CollapseCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        
        guard let vc = collapseDelegate?.getPageTabBarController() else { fatalError("pagetabbar controller = nil") }
        
        cell.contentView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let vc = collapseDelegate?.getPageTabBarController() else { return }
        vc.view.removeFromSuperview()
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case CollapseCollectionViewLayout.Element.header.kind:
            if let headerView = collapseDelegate?.getHeaderView(), let collapseVC = collapseDelegate?.getCollapseTabBarViewController() {
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
                headerView.frame = CGRect(x: 0, y: 0, width: collapseVC.view.frame.width, height: collapseVC.defaultHeaderHeight)
                cell.addSubview(headerView)
                headerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([headerView.topAnchor.constraint(equalTo: cell.topAnchor),
                                             headerView.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
                                             headerView.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                                             headerView.trailingAnchor.constraint(equalTo: cell.trailingAnchor)])
                return cell
            }
            break
        case CollapseCollectionViewLayout.Element.staticHeader.kind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StaticHeader", for: indexPath) as! CollapseStaticHeaderView
            cell.configureWithContentView(staticHeaderView)
            return cell
        default:
            break
        }
        
        return UICollectionReusableView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
        collapseDelegate?.collapseCollectionViewDidScroll?(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        otherScrollViewLocked = false
        removeObservingViews()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            otherScrollViewLocked = false
            removeObservingViews()
        }
    }
}

extension CollapseCollectionView: CollapseCollectionViewLayoutDelegate {
    func collapseCollectionView(_ collapseCollectionView: CollapseCollectionView, layout: CollapseCollectionViewLayout, sizeForStaticHeaderAt indexPath: IndexPath) -> CGSize {
        guard let staticHeaderView = staticHeaderView else { return CGSize(width: collapseCollectionView.bounds.width, height: 0) }
        
        let size = staticHeaderView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return CGSize(width: collapseCollectionView.bounds.width, height: ceil(size.height))
    }
}

extension CollapseCollectionView: UIGestureRecognizerDelegate {
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
            let translation = panGestureRecognizer.translation(in: gestureRecognizer.view)
            return abs(velocity.y) > abs(velocity.x) && abs(translation.y) > abs(translation.x)
        }
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer.view == self {
            return false
        }
        
        guard let _ = gestureRecognizer as? UIPanGestureRecognizer,
             let scrollView = otherGestureRecognizer.view as? UIScrollView else {
            return false
        }
        
        // Tricky case: UITableViewWrapperView
        if let _ = scrollView.superview as? UITableView {
            return false
        }
        
        var shouldScroll = true
        
        if let extendedDelegate = proxy.extendedDelegate,
            let delegateShouldScroll = extendedDelegate.scrollView?(self, shouldScrollWithSubView: scrollView) {
            shouldScroll = delegateShouldScroll
        }
        
        if shouldScroll {
            
            if let pageScrollView = collapseDelegate?.getPageTabBarController()?.pageTabBarCollectionView, scrollView == pageScrollView {
                // skip
            } else {
                observeMySelf()
                addObserverFor(scrollView: scrollView)
            }
        }
        
        return shouldScroll
    }
}

extension CollapseCollectionView: CollapseCollectionViewExtendedDelegate {
    func scrollView(_ scrollView: CollapseCollectionView, shouldScrollWithSubView subView: UIScrollView) -> Bool {
        return true
    }
}

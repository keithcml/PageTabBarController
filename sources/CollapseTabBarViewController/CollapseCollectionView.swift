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
    
    var extendedDelegate: CollapseCollectionViewExtendedDelegate?
    
    var revealedHeight: CGFloat {
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
    
    var staticHeaderView: UIView?
    var preferredRecognizingScrollViews = [UIScrollView]()
    
    var observedScrollViews = [UIScrollView]()
    var otherScrollViews = [UIScrollView]() {
        didSet {
            otherScrollViewsContentOffset = otherScrollViews.map { $0.contentOffset }
        }
    }
    fileprivate var otherScrollViewsContentOffset = [CGPoint]()
    
    fileprivate var lastContentOffset = CGPoint.zero
    fileprivate var ignoringScroll = false
    
    private var isObserving = false
    private var isLocked = false
    private var contentOffsetObservation: NSKeyValueObservation?
    private var observations = [NSKeyValueObservation]()
    
    weak var collapseDelegate: CollapseCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        extendedDelegate = self
        dataSource = self
        delegate = self
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
        
        contentOffsetObservation = observe(\.contentOffset, options: [.new, .old]) { collapseCollectionView, change in
            
            guard collapseCollectionView.isObserving else { return }
            
            guard let oldValue = change.oldValue, let newValue = change.newValue else {
                return
            }
            
            let diff = oldValue.y - newValue.y
            
            guard diff > 0 else { return }
            
            //Adjust self scroll offset when scroll down
            if collapseCollectionView.isLocked {
                collapseCollectionView.setContentOffset(oldValue, for: collapseCollectionView)
                
            } else if collapseCollectionView.contentOffset.y < -collapseCollectionView.contentInset.top && !collapseCollectionView.bounces {
                
                collapseCollectionView.setContentOffset(CGPoint(x: collapseCollectionView.contentOffset.x, y: -collapseCollectionView.contentInset.top),
                                                        for: collapseCollectionView)
                
            }
//            else if collapseCollectionView.contentOffset.y > -collapseCollectionView.parallaxHeader.minimumHeight {
//                [self scrollView:self setContentOffset:CGPointMake(self.contentOffset.x, -self.parallaxHeader.minimumHeight)];
//                collapseCollectionView.setContentOffset(CGPoint(x: collapseCollectionView.contentOffset.x, y: -collapseCollectionView.contentInset.top),
//                                                        for: collapseCollectionView)
//            }
        }
        
        isObserving = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        contentOffsetObservation?.invalidate()
        observations.forEach { $0.invalidate() }
    }
    
    // MARK: - Scrolling handler
    func addObserverFor(scrollView: UIScrollView) {
        guard !observedScrollViews.contains(scrollView) else { return }
        
        observedScrollViews.append(scrollView)
        
        let observation = scrollView.observe(\.contentOffset, options: [.new, .old]) { [unowned self] scrollView, change in
            
            guard self.isObserving else { return }
            
            guard let oldValue = change.oldValue, let newValue = change.newValue else {
                return
            }
            
            let diff = oldValue.y - newValue.y
            
            guard diff > 0 else { return }
            
            //Adjust the observed scrollview's content offset
            self.isLocked = scrollView.contentOffset.y > -scrollView.contentInset.top
            
            //Manage scroll up
            if self.contentOffset.y < 0 && self.isLocked && diff < 0 {
                self.setContentOffset(oldValue, for: scrollView)
            }
            //Disable bouncing when scroll down
            if !self.isLocked && ((self.contentOffset.y > -self.contentInset.top) || self.bounces) {
                self.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -scrollView.contentInset.top),
                                      for: scrollView)
            }
        }
        
        observations.append(observation)
    }
    
    func setContentOffset(_ contentOffset: CGPoint, for scrollView: UIScrollView) {
        isObserving = false
        scrollView.contentOffset = contentOffset
        isObserving = true
    }
}

extension CollapseCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, CollapseCollectionViewLayoutDelegate {
    
    private func shouldIgoreScrolling(at point: CGPoint, on scrollView: UIScrollView) -> Bool {
        for otherScrollView in otherScrollViews {
            let rect = otherScrollView.superview!.convert(otherScrollView.frame, to: scrollView)
            if rect.contains(point) && otherScrollView.contentOffset.y > -otherScrollView.contentInset.top {
                return true
            }
        }
        return false
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let touchLocation = scrollView.panGestureRecognizer.location(in: scrollView)
        ignoringScroll = shouldIgoreScrolling(at: touchLocation, on: scrollView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // print(scrollView.contentOffset)
        if ignoringScroll {
            scrollView.contentOffset = lastContentOffset
        } else {
            if lastContentOffset.y < scrollView.contentOffset.y && stretchyHeight > 0 {
                let scrollableOffsetY = headerHeight - revealedHeight
                for (otherScrollView, initialContentOffset) in zip(otherScrollViews, otherScrollViewsContentOffset) {
                    if contentOffset.y < scrollableOffsetY {
                        otherScrollView.contentOffset = initialContentOffset
                    }
                }
            }
        }
        
        lastContentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y)
        
        collapseDelegate?.collapseCollectionViewDidScroll?(self)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(velocity)
        print(targetContentOffset.pointee)
    }
    
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
        
        guard let collapseVC = collapseDelegate?.getCollapseTabBarViewController(), let vc = collapseDelegate?.getPageTabBarController() else { fatalError("pagetabbar controller = nil") }
        
        if vc.parent == nil {
            collapseVC.addChildViewController(vc)
            cell.contentView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            vc.didMove(toParentViewController: collapseVC)
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
        guard let viewControllers = collapseDelegate?.getContentViewControllers() else { return }
        let vc = viewControllers[indexPath.row]
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
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
            return abs(velocity.y) >= abs(velocity.x) && abs(translation.y) >= abs(translation.x)
        }
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let cv = collapseDelegate?.getPageTabBarController()?.collectionView, let gestureView = otherGestureRecognizer.view, gestureView == cv {
            return false
        }
        
        for scrollView in preferredRecognizingScrollViews {
            if let gestureView = otherGestureRecognizer.view as? UIScrollView, gestureView === scrollView {
                return false
            }
        }
        
        guard let _ = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        
        return true
    }
}

extension CollapseCollectionView: CollapseCollectionViewExtendedDelegate {
    func scrollView(_ scrollView: CollapseCollectionView, shouldScrollWithSubView subView: UIScrollView) -> Bool {
        return true
    }
}

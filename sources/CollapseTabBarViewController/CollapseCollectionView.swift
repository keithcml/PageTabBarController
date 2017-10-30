//
//  CollapseCollectionView.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 22/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CollapseCollectionViewDelegate {
    @objc func getCollapseTabBarViewController() -> CollapseTabBarViewController?
    @objc func getPageTabBarController() -> PageTabBarController?
    @objc func getHeaderView() -> UIView?
    @objc func getContentViewControllers() -> [UIViewController]
    @objc optional func collapseCollectionViewDidScroll(_ collapseCollectionView: CollapseCollectionView)
}

final class CollapseCollectionView: UICollectionView {
    
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
    
    var otherScrollViews = [UIScrollView]() {
        didSet {
            otherScrollViewsContentOffset = otherScrollViews.map { $0.contentOffset }
        }
    }
    fileprivate var otherScrollViewsContentOffset = [CGPoint]()
    
    fileprivate var lastContentOffset = CGPoint.zero
    fileprivate var ignoringScroll = false
    
    weak var collapseDelegate: CollapseCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        return true
    }
}


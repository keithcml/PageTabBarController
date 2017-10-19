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
}

final class CollapseCollectionView: UICollectionView {
    
    var revealedHeight: CGFloat = 0
    var headerHeight: CGFloat = 320
    var stretchyHeight: CGFloat = 64
    
    fileprivate var uncommitedOtherScrollViews = [UIScrollView]()
    fileprivate var otherScrollViews = [UIScrollView]()
    fileprivate var otherScrollViewsContentOffset = [CGPoint]()
    fileprivate var initialCollectionViewContentOffset = CGPoint.zero
    
    fileprivate var gestureDirection = Direction.notMoving
    fileprivate var isScrolling = false
    
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
        panGestureRecognizer.addTarget(self, action: #selector(pan(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func pan(_ sender: UIPanGestureRecognizer?) {
        guard let gesture = sender else { return }

        switch gesture.state {
        case .began:
            initialCollectionViewContentOffset = contentOffset
            otherScrollViewsContentOffset = otherScrollViews.map { $0.contentOffset }
            gestureDirection = gesture.verticalDirection
            break
        case .changed:
            break
        default:
            break
        }
    }
}

extension CollapseCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        otherScrollViews.forEach({ $0.setContentOffset(scrollView.contentOffset, animated: false) })
        otherScrollViews = uncommitedOtherScrollViews
        uncommitedOtherScrollViews = []
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let scrollableOffsetY = headerHeight - revealedHeight
        
        defer {
            if contentOffset.y > scrollableOffsetY {
                contentOffset.y = scrollableOffsetY
            }
        }

        if case .up = gestureDirection {
            
            for (scrollView, initialContentOffset) in zip(otherScrollViews, otherScrollViewsContentOffset) {
                if contentOffset.y < scrollableOffsetY {
                    scrollView.contentOffset = initialContentOffset
                } else {
                    contentOffset.y = scrollableOffsetY
                    contentOffset.y = max(scrollableOffsetY, revealedHeight)
                }
            }
            
            return
        }
        
        if case .down = gestureDirection {
            for (scrollView, initialContentOffset) in zip(otherScrollViews, otherScrollViewsContentOffset) {
                
                if initialContentOffset.y > -scrollView.contentInset.top && scrollView.contentOffset.y <= -scrollView.contentInset.top {
                    scrollView.contentOffset.y = -scrollView.contentInset.top
                }
                else if scrollView.contentOffset.y > -scrollView.contentInset.top {
                    contentOffset.y = initialCollectionViewContentOffset.y
                }
                else {
                    scrollView.contentOffset = initialContentOffset
                }
            }
            return
        }
        
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
                return cell
            }
            break
        case CollapseCollectionViewLayout.Element.footer.kind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            
            return cell
        default:
            break
        }
        
        return UICollectionReusableView()
    }
}

extension CollapseCollectionView: UIGestureRecognizerDelegate {
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        if case .notMoving = panGesture.verticalDirection {
            return false
        }
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        
        if let _ = gestureRecognizer as? UIPanGestureRecognizer,
            let otherPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer,
            let otherScrollView = otherPanGestureRecognizer.view as? UIScrollView,
            otherPanGestureRecognizer != panGestureRecognizer {

            if let _ = otherScrollView as? PageTabBarCollectionView {} else {
                
                if !uncommitedOtherScrollViews.contains( where: { $0 === otherScrollView } ) && !otherScrollView.description.hasPrefix("<UITableViewWrapperView") {
                    uncommitedOtherScrollViews.append(otherScrollView)
                }
                
            }
        }
        
        return true
    }

    
}

// MARK: - Pan Gesture Helpers
@objc public enum Direction: Int {
    case up
    case down
    case left
    case right
    case notMoving
    
    public var isX: Bool { return self == .left || self == .right }
    public var isY: Bool { return !isX }
}

extension UIPanGestureRecognizer {
    
    @objc open var direction: Direction {
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
    
    @objc open var verticalDirection: Direction {
        let panVelocity = velocity(in: view)
        let vertical = fabs(panVelocity.y) > fabs(panVelocity.x)
        switch (vertical, panVelocity.x, panVelocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, _, let y) where y < 0: return .notMoving
        case (false, _, let y) where y > 0: return .notMoving
        default: return .notMoving
        }
    }
}


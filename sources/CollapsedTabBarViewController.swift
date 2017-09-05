//
//  CollapsedTabBarViewController.swift
//  PageTabBarControllerExample
//
//  Created by Mingloan Chan on 9/5/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

final class CollapsedTabBarViewController: UIViewController {
    
    fileprivate var pageTabBarController: PageTabBarViewController?
    fileprivate let hottestOffersViewController = HottestOffersViewController(nibName: nil, bundle: nil)
    fileprivate let popularStoresViewController = PopularStoresViewController(nibName: nil, bundle: nil)
    
    // tabbar positioning
    fileprivate let maximumTopGap: CGFloat = 133
    fileprivate var pageTabBarPanGesture: UIPanGestureRecognizer!
    fileprivate var isPageTabBarPanning = false {
        didSet {
            if let pageTabBarController = pageTabBarController {
                pageTabBarController.isScrollEnabled = !isPageTabBarPanning
            }
        }
    }
    
    fileprivate var initialY: CGFloat = 133
    fileprivate var initialHeight: CGFloat = 300
    fileprivate var innerScrollViewContentOffset = CGPoint.zero
    
    fileprivate let coverPhotoView: CouponCoverView = {
        let view = CouponCoverView()
        return view
    }()
    
    // place under nav bar
    fileprivate let topWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.autoresizingMask = [.flexibleWidth]
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = UIColor.white
        let height = view.frame.height - maximumTopGap
        
        
        view.addSubview(coverPhotoView)
        coverPhotoView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: maximumTopGap)
        
        pageTabBarController =
            PageTabBarViewController(
                viewControllers: [hottestOffersViewController, popularStoresViewController],
                titles: ["Hottest Offers", "Top Stores"],
                estimatedFrame: view.bounds)
        
        guard let pageTabBarController = pageTabBarController else { fatalError("pagetabbar controller = nil") }
        pageTabBarController.updateIndex = { _, index in
            if index == 0 {
                self.searchPresenter.offerListClick()
            }
            else {
                self.searchPresenter.storeLinkClick()
            }
        }
        addChildViewController(pageTabBarController)
        
        pageTabBarController.view.frame = CGRect(x: 0, y: maximumTopGap, width: view.frame.width, height: height)
        pageTabBarController.view.backgroundColor = UIColor.munsell()
        view.addSubview(pageTabBarController.view)
        pageTabBarController.didMove(toParentViewController: self)
        
        pageTabBarPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panPageTabBar(_:)))
        pageTabBarPanGesture.delegate = self
        pageTabBarController.view.addGestureRecognizer(pageTabBarPanGesture)
        
        view.addSubview(topWhiteView)
        topWhiteView.frame = CGRect(x: 0, y: 0 - 64, width: view.frame.width, height: 64)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let bar = navigationController?.navigationBar as? CouponNavigationBar {
            searchPresenter.searchTextField = bar.searchTextField
            searchPresenter.delegate = self
            bar.rightBarButtonItems = []
            bar.changeCouponMode(.search(keyword: ""), animated: true)
        }
        
        
        if !isSearching {
            appDelegate?.mainTabBarController?.showTabbar()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isMovingFromParentViewController {
            if let vcs = navigationController?.viewControllers {
                if vcs.count > 1 && vcs[vcs.count-2] == self {
                    appDelegate?.mainTabBarController?.hidesTabbar()
                }
            }
        }
    }
    
    @objc private func panPageTabBar(_ sender: UIPanGestureRecognizer?) {
        guard let gesture = sender else { return }
        guard let gView = gesture.view else { return }
        switch gesture.state {
        case .began:
            guard gView.frame.minY <= maximumTopGap else { return }
            initialY = gView.frame.minY
            initialHeight = gView.frame.height
            guard abs(gesture.velocity(in: gView).y) > abs(gesture.velocity(in: gView).x) else { return }
            isPageTabBarPanning = pageTabBarCanScroll(direction: gesture.direction)
            if let pageTabBarController = pageTabBarController,
                let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) {
                innerScrollViewContentOffset = scrollView.contentOffset
            }
            break
        case .changed:
            guard isPageTabBarPanning else { return }
            let translateY = gesture.translation(in: view).y
            let newY = max(0, min(translateY + initialY, maximumTopGap))
            let newHeight = initialHeight + (initialY - newY)
            gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
            gView.frame.origin = CGPoint(x: 0, y: newY)
            coverPhotoView.frame = CGRect(x: 0, y: newY - maximumTopGap, width: coverPhotoView.frame.width, height: coverPhotoView.frame.height)
            
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
                if newY < maximumTopGap {
                    scrollView.contentOffset = innerScrollViewContentOffset
                }
                break
            default:
                break
            }
            
            break
        case .ended, .cancelled:
            guard isPageTabBarPanning else { return }
            isPageTabBarPanning = false
            guard let direction = gesture.direction,
                gView.frame.minY > 0,
                gView.frame.minY < maximumTopGap else { return }
            switch direction {
            case .up:
                let newHeight = initialHeight + initialY
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                               animations: {
                                gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
                                gView.frame.origin = CGPoint(x: 0, y: 0)
                                self.coverPhotoView.frame = CGRect(x: 0,
                                                                   y: -self.maximumTopGap,
                                                                   width: self.coverPhotoView.frame.width,
                                                                   height: self.coverPhotoView.frame.height)
                },
                               completion: nil)
                break
            case .down:
                let newHeight = initialHeight + (initialY - maximumTopGap)
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                               animations: {
                                gView.bounds = CGRect(x: 0, y: 0, width: gView.frame.width, height: newHeight)
                                gView.frame.origin = CGPoint(x: 0, y: self.maximumTopGap)
                                self.coverPhotoView.frame = CGRect(x: 0,
                                                                   y: 0,
                                                                   width: self.coverPhotoView.frame.width,
                                                                   height: self.coverPhotoView.frame.height)
                },
                               completion: nil)
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    private func pageTabBarCanScroll(direction: Direction?) -> Bool {
        
        if let pageTabBarController = pageTabBarController,
            let scrollView = pageTabBarController.theMostBelowScrollViewInView(pageTabBarController.viewControllers[pageTabBarController.pageIndex].view) {
            guard let dir = direction else { return true }
            switch dir {
            case .up:
                return pageTabBarController.view.frame.minY > 0
            case .down:
                if pageTabBarController.view.frame.minY == maximumTopGap { return false }
                return scrollView.contentOffset.y <= scrollView.contentInset.top
            default:
                break
            }
        }
        return true
    }
}

extension CollapsedTabBarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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

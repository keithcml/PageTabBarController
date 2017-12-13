//
//  ParallaxHeaderPageTabBarController.swift
//  PageTabBarController
//
//  Created by Mingloan Chan on 12/11/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol ParallaxHeaderPageTabBarControllerDelegate: NSObjectProtocol {
    @objc optional func parallaxHeaderPageTabBarController(_ controller: ParallaxHeaderPageTabBarController, revealPercentage: CGFloat)
}

@objcMembers
open class ParallaxHeaderPageTabBarController: UIViewController {
    
    open weak var delegate: ParallaxHeaderPageTabBarControllerDelegate?
    
    open let pageTabBarController: PageTabBarController
    open let parallaxHeaderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    let supplementaryContainerView: SupplementaryView = {
        let view = SupplementaryView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    open var isStretchy = true {
        didSet {
            if isStretchy {
                pageTabBarController.setTabBarTopPosition(.topInsetAttached)
            } else {
                pageTabBarController.setTabBarTopPosition(.topAttached)
            }
        }
    }
    open var parallaxOffset = CGFloat(1)
    open var minimumRevealHeight = CGFloat(0)
    open var parallaxHeaderHeight = CGFloat(200)
    open var supplementaryViewHeight = CGFloat(60) {
        didSet {
            supplementaryViewHeightConstraint?.constant = supplementaryViewHeight
            view.setNeedsLayout()
        }
    }
    
    private var minimumCollapseOffset: CGFloat {
        if #available(iOS 11.0, *) {
            // print(max(minimumRevealHeight - parallaxHeaderHeight, -view.safeAreaInsets.top))
            return max(minimumRevealHeight, view.safeAreaInsets.top) - parallaxHeaderHeight
        } else {
            return minimumRevealHeight - parallaxHeaderHeight
        }
    }
    private var parallaxHeaderViewTopConstraint: NSLayoutConstraint?
    private var parallaxHeaderViewHeightConstraint: NSLayoutConstraint?
    private var supplementaryViewBottomConstraint: NSLayoutConstraint?
    private var supplementaryViewHeightConstraint: NSLayoutConstraint?
    
    private weak var currentChildScrollViewWeakReference: UIScrollView?
    private var previousChildScrollViewOffset: CGPoint = .zero
        
    private var isPanning = false
    private var initialOffset = CGFloat(0)
    
    public required init(viewControllers: [UIViewController],
                         items: [PageTabBarItem],
                         parallaxHeaderHeight: CGFloat) {
        
        pageTabBarController = PageTabBarController(viewControllers: viewControllers, items: items, tabBarPosition: .topInsetAttached)
        super.init(nibName: nil, bundle: nil)
        
        self.parallaxHeaderHeight = parallaxHeaderHeight
        pageTabBarController.parallaxDelegate = self
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addChildViewController(pageTabBarController)
        
        view.addSubview(pageTabBarController.view)
        view.addSubview(parallaxHeaderContainerView)
        view.addSubview(supplementaryContainerView)

        parallaxHeaderContainerView.translatesAutoresizingMaskIntoConstraints = false
        pageTabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        supplementaryContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // var topAnchor = view.topAnchor
        // var bottomAnchor = view.bottomAnchor
        var leadingAnchor = view.leadingAnchor
        var trailingAnchor = view.trailingAnchor
        if #available(iOS 11.0, *) {
            //topAnchor = view.safeAreaLayoutGuide.topAnchor
            //bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
            leadingAnchor = view.safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = view.safeAreaLayoutGuide.trailingAnchor
        }
        
        NSLayoutConstraint.activate([parallaxHeaderContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     parallaxHeaderContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        parallaxHeaderViewTopConstraint = parallaxHeaderContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        parallaxHeaderViewTopConstraint?.isActive = true
        parallaxHeaderViewHeightConstraint = parallaxHeaderContainerView.heightAnchor.constraint(equalToConstant: parallaxHeaderHeight)
        parallaxHeaderViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([supplementaryContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     supplementaryContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        supplementaryViewBottomConstraint = supplementaryContainerView.bottomAnchor.constraint(equalTo: parallaxHeaderContainerView.bottomAnchor)
        supplementaryViewBottomConstraint?.isActive = true
        supplementaryViewHeightConstraint = supplementaryContainerView.heightAnchor.constraint(equalToConstant: supplementaryViewHeight)
        supplementaryViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([pageTabBarController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     pageTabBarController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     pageTabBarController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     pageTabBarController.view.topAnchor.constraint(equalTo: parallaxHeaderContainerView.bottomAnchor)])
        /*
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        */
        pageTabBarController.didMove(toParentViewController: self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc private func pan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state{
        case .began:
            let velocity = gesture.velocity(in: gesture.view)
            guard abs(velocity.y) > abs(velocity.x) else { return }
            guard let topContraint = parallaxHeaderViewTopConstraint else { return }
            isPanning = true
            initialOffset = topContraint.constant
            break
        case .changed:
            guard isPanning else { return }
            let translate = gesture.translation(in: gesture.view)
            
            let newConstant = max(minimumCollapseOffset, min(0, initialOffset + translate.y))
            parallaxHeaderViewTopConstraint?.constant = newConstant
//            if newConstant > parallaxHeaderHeight {
//                let gap = newConstant - parallaxHeaderHeight
//                let scale = 1 + (gap * 2)/parallaxHeaderHeight
//                parallaxHeaderContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
//                supplementaryViewBottomConstraint?.constant = gap
//            }
            view.layoutIfNeeded()
            break
        case .ended, .cancelled:
            guard isPanning else { return }
            isPanning = false
            break
        default:
            isPanning = false
            break
        }
    }
}

// MARK: - Public Methods

extension ParallaxHeaderPageTabBarController {
    
    open func scrollTabBar(to top: Bool, animated: Bool = false) {
        
        if top {
            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    self.parallaxHeaderViewTopConstraint?.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                parallaxHeaderViewTopConstraint?.constant = 0
                view.layoutIfNeeded()
            }
        }
        else {
            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    self.parallaxHeaderViewTopConstraint?.constant = self.minimumRevealHeight - self.parallaxHeaderHeight
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                parallaxHeaderViewTopConstraint?.constant = self.minimumRevealHeight - self.parallaxHeaderHeight
                view.layoutIfNeeded()
            }
        }
    }
    
    open func setSelfSizingParallexHeaderView(_ view: UIView?) {
        
        parallaxHeaderContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let customView = view else {
            // setParallexHeaderHeight(height, animated: false)
            return
        }
        
        parallaxHeaderContainerView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([customView.leadingAnchor.constraint(equalTo: parallaxHeaderContainerView.leadingAnchor),
                                     customView.trailingAnchor.constraint(equalTo: parallaxHeaderContainerView.trailingAnchor),
                                     customView.topAnchor.constraint(equalTo: parallaxHeaderContainerView.topAnchor),
                                     customView.bottomAnchor.constraint(equalTo: parallaxHeaderContainerView.bottomAnchor)])
        let size = parallaxHeaderContainerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        setParallexHeaderHeight(size.height, animated: false)
    }
    
    open func setParallexHeaderView(_ view: UIView?, height: CGFloat) {
        
        parallaxHeaderContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let customView = view else {
            setParallexHeaderHeight(height, animated: false)
            return
        }
        
        parallaxHeaderContainerView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([customView.leadingAnchor.constraint(equalTo: parallaxHeaderContainerView.leadingAnchor),
                                     customView.trailingAnchor.constraint(equalTo: parallaxHeaderContainerView.trailingAnchor),
                                     customView.topAnchor.constraint(equalTo: parallaxHeaderContainerView.topAnchor)])
        
        setParallexHeaderHeight(height, animated: false)
    }
    
    open func setSupplementaryView(_ view: UIView?) {
        supplementaryContainerView.configureWithContentView(view)
    }
    
    /* @param height - new height
     * @param animated - run default animation
     */
    open func setParallexHeaderHeight(_ newHeight: CGFloat, animated: Bool) {
        
        guard parallaxHeaderHeight != newHeight else { return }
        parallaxHeaderHeight = newHeight
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.parallaxHeaderViewTopConstraint?.constant = 0
                self.parallaxHeaderViewHeightConstraint?.constant = newHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            parallaxHeaderViewTopConstraint?.constant = 0
            parallaxHeaderViewHeightConstraint?.constant = newHeight
            view.layoutIfNeeded()
        }
    }
    
    open func childScrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let currentScrollView = currentChildScrollViewWeakReference, currentScrollView == scrollView else { return }
        
        guard let topConstraint = parallaxHeaderViewTopConstraint else { return }
        
        var contentInset = scrollView.contentInset
        if #available(iOS 11.0, *) {
            contentInset = scrollView.adjustedContentInset
        }
        
        let diff = scrollView.contentOffset.y - previousChildScrollViewOffset.y
        let shouldCollapse = topConstraint.constant > minimumCollapseOffset && scrollView.contentOffset.y > -contentInset.top && diff > 0
        let shouldExpand = topConstraint.constant < 0 && scrollView.contentOffset.y < -contentInset.top && diff < 0
        
        if shouldCollapse || shouldExpand {
            
            let newConstant = max(minimumCollapseOffset, min(0, topConstraint.constant - diff))
            parallaxHeaderViewTopConstraint?.constant = newConstant
            //view.layoutIfNeeded()
            
            if shouldCollapse {
                print("Collapsing... \(newConstant)")
            }
            
            if shouldExpand {
                print("Expanding... \(newConstant)")
            }
            
            scrollView.contentOffset = previousChildScrollViewOffset
        }
        else {
            previousChildScrollViewOffset = scrollView.contentOffset
        }
        
        // transformations
        if case .topAttached = pageTabBarController.tabBarPosition {
            parallaxHeaderContainerView.transform = .identity
            supplementaryViewBottomConstraint?.constant = 0
            //view.setNeedsLayout()
        } else {
            
            pageTabBarController.transformTabBarWithScrollViewBounces(scrollView)
            
            if scrollView.contentOffset.y < -contentInset.top {
                let gap = -contentInset.top - scrollView.contentOffset.y
                let scale = 1 + (gap * 2)/parallaxHeaderHeight
                parallaxHeaderContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)

                supplementaryViewBottomConstraint?.constant = gap
            } else {
                parallaxHeaderContainerView.transform = .identity
                supplementaryViewBottomConstraint?.constant = 0
                //view.setNeedsLayout()
            }
        }

        
    }
}

extension ParallaxHeaderPageTabBarController: PageTabBarControllerParallaxDelegate {
    
    func pageTabBarController(_ controller: PageTabBarController, childScrollViewDidChange scrollView: UIScrollView) {
        currentChildScrollViewWeakReference = scrollView
        previousChildScrollViewOffset = scrollView.contentOffset
    }
}

extension ParallaxHeaderPageTabBarController: UIGestureRecognizerDelegate {
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
            let translation = panGestureRecognizer.translation(in: gestureRecognizer.view)
            return abs(velocity.y) > abs(velocity.x) && abs(translation.y) > abs(translation.x)
        }
        return true
    }
    
}

extension UIViewController {
    
    @objc(ml_parallaxHeaderPageTabBarController)
    open var parallaxHeaderPageTabBarController: ParallaxHeaderPageTabBarController? {
        var parentVC = parent
        while parentVC != nil {
            
            if let vc = parentVC as? ParallaxHeaderPageTabBarController {
                return vc
            }
            parentVC = parentVC?.parent
        }
        return nil
    }
}

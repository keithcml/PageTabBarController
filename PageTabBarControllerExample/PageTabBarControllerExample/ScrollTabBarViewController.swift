//
//  ScrollTabBarViewController.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 11/12/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit
import PageTabBarController

class ScrollTabBarViewController: UIViewController {
    
    private var pageTabBarController: PageTabBarController
    
    private var pageTabBarTopConstraint: NSLayoutConstraint?
    
    private var isObservingContentOffset = true
    private var currentScrollView: UIScrollView?
    private var contentOffsetObservation: NSKeyValueObservation?
    
    required init?(coder aDecoder: NSCoder) {
        
        // set styles
        let tabColor = UIColor(red: 215/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1)
        let tabSelectedColor = UIColor(red: 35/255.0, green: 171/255.0, blue: 232/255.0, alpha: 1)
        
        let tab01 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab01.color = tabColor
        tab01.selectedColor = tabSelectedColor
        let tab02 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab02.color = tabColor
        tab02.selectedColor = tabSelectedColor
        let tab03 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab03.color = tabColor
        tab03.selectedColor = tabSelectedColor
        
        let vc01 = TableViewController(nibName: nil, bundle: nil)
        let vc02 = TableViewController(nibName: nil, bundle: nil)
        let vc03 = TableViewController(nibName: nil, bundle: nil)
        
        pageTabBarController = PageTabBarController(viewControllers: [vc01, vc02, vc03], items: [tab01, tab02, tab03], tabBarPosition: .top)
        pageTabBarController.pageTabBar.barHeight = 60
        pageTabBarController.pageTabBar.indicatorLineColor = tabSelectedColor
        pageTabBarController.pageTabBar.indicatorLineHeight = 2
        pageTabBarController.pageTabBar.bottomLineHidden = true
        pageTabBarController.pageTabBar.topLineColor = tabSelectedColor
        pageTabBarController.pageTabBar.barTintColor = UIColor(white: 0.95, alpha: 1)
        
        super.init(coder: aDecoder)
        
        vc01.view.tag = 1
        vc02.view.tag = 2
        vc03.view.tag = 3
    }
    
    deinit {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(pageTabBarController)
        view.addSubview(pageTabBarController.view)
        pageTabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        
        pageTabBarTopConstraint = pageTabBarController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.width)
        pageTabBarTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([pageTabBarController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     pageTabBarController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     pageTabBarController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        pageTabBarController.didMove(toParentViewController: self)
        
        pageTabBarController.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let vc = pageTabBarController.selectedViewController {
            for view in vc.view.subviews {
                if view.isKind(of: UIScrollView.self) {
                    currentScrollView = view as? UIScrollView
                    
                    print("currentScrollView: \(view)")
                    break
                }
            }
        }
        addContentOffsetObserve()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeContentOffsetObserver()
    }
    
    // MARK: - Scrolling handler
    private func addContentOffsetObserve() {
        
        if contentOffsetObservation != nil {
            removeContentOffsetObserver()
        }
        
        guard let scrollView = currentScrollView else { return }
        
        contentOffsetObservation = scrollView.observe(\.contentOffset, options: [.new, .old]) { [unowned self] observed, change in
            
            guard self.isObservingContentOffset else { return }
            
            guard let oldValue = change.oldValue, let newValue = change.newValue else {
                return
            }
            
            guard let currentSpacing = self.pageTabBarTopConstraint?.constant else {
                return
            }
            
            // diff < 0 => scroll up, diff > 0 => scroll down
            let diff = oldValue.y - newValue.y
            
            guard diff != 0 else { return }
            
            if newValue.y < -observed.contentInset.top {
                
                if currentSpacing < self.view.frame.width {
                    self.setContentOffset(oldValue, forScrollView: observed)
                    self.pageTabBarTopConstraint?.constant = min(self.view.frame.width, max(150, currentSpacing + diff))
                    self.view.layoutIfNeeded()
                }
                
            } else if newValue.y > -observed.contentInset.top {
                
                if currentSpacing > 150 {
                    self.setContentOffset(oldValue, forScrollView: observed)
                    
                    self.pageTabBarTopConstraint?.constant = min(self.view.frame.width, max(150, currentSpacing + diff))
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func removeContentOffsetObserver() {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }
    
    private func setContentOffset(_ offset: CGPoint, forScrollView scrollView: UIScrollView) {
        isObservingContentOffset = false
        scrollView.contentOffset = offset
        isObservingContentOffset = true
    }
    
}

extension ScrollTabBarViewController: PageTabBarControllerDelegate {
    func pageTabBarController(_ controller: PageTabBarController, didSelectItem item: PageTabBarItem, atIndex index: Int, previousIndex: Int) {
        
        //        if index == 0 {
        //            let banner = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        //            banner.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        //            collapseTabBarViewController.pageTabBarController.setBannerViewWithCustomView(banner, animated: true)
        //        } else {
        //            let banner = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        //            banner.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        //            collapseTabBarViewController.pageTabBarController.setBannerViewWithCustomView(banner, animated: true)
        //        }
        // print("previousIndex: \(previousIndex)")
        // print("currentIndex: \(index)")
        
        if index == 0 {
            //collapseTabBarViewController.scrollTabBar(to: .top, animated: true)
        }
        
        if index == 1 {
            //collapseTabBarViewController.scrollTabBar(to: .bottom, animated: true)
        }
        
        if index == 2 {
            controller.setBadge(200, forItemAt: index)
        }
        
        if index == 1 {
            controller.clearAllBadges()
        }
    }
    
    func pageTabBarController(_ controller: PageTabBarController, didChangeContentViewController vc: UIViewController, atIndex index: Int) {

        //print("didChangeContentViewController: \(vc)")
        //print("index: \(index)")
        
        for view in vc.view.subviews {
            if view.isKind(of: UIScrollView.self) {
                currentScrollView = view as? UIScrollView
                addContentOffsetObserve()
                //print("currentScrollView: \(view)")
                break
            }
        }
        
    }
    
    func pageTabBarController(_ controller: PageTabBarController, transit fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        // print("from index: \(fromIndex), to index: \(toIndex), progress: \(progress)")
    }
    
    func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool {
        if collectionView.bounces == false && collectionView.contentOffset.x == 0 {
            
            if let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
                abs(panGesture.velocity(in: panGesture.view).x) > abs(panGesture.velocity(in: panGesture.view).y),
                panGesture.velocity(in: panGesture.view).x > 0 {
                return false
            }
            
        }
        return true
    }
}





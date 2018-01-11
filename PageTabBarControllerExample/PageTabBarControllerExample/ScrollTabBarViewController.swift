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
    
    private lazy var parallaxController: ParallaxHeaderPageTabBarController = {
        return initParallaxHeaderPageTabBarController()
    }()
    
    private var pageTabBarTopConstraint: NSLayoutConstraint?
    
    private var isObservingContentOffset = true
    private var currentScrollView: UIScrollView?
    private var contentOffsetObservation: NSKeyValueObservation?
    
    private func initParallaxHeaderPageTabBarController() -> ParallaxHeaderPageTabBarController {
        
        // set default appearance settings
        var appearance = PageTabBarItem.defaultAppearanceSettings
        //appearance.contentHeight = 30
        PageTabBarItem.defaultAppearanceSettings = appearance

        let tab01 = PageTabBarItem(unselectedImage: UIImage(named: "img01"), selectedImage: UIImage(named: "img01"))
        let tab02 = PageTabBarItem(unselectedImage: UIImage(named: "img01"), selectedImage: UIImage(named: "img01"))
        let tab03 = PageTabBarItem(unselectedImage: UIImage(named: "img01"), selectedImage: UIImage(named: "img01"))
        
        let vc01 = TableViewController(nibName: nil, bundle: nil)
        let vc02 = TableViewController(nibName: nil, bundle: nil)
        let vc03 = TableViewController(nibName: nil, bundle: nil)
        vc01.view.tag = 1
        vc02.view.tag = 2
        vc03.view.tag = 3
        
        // set default appearance settings
        var barAppearance = PageTabBar.defaultBarAppearanceSettings
        barAppearance.topLineColor = UIColor(white: 0.95, alpha: 1)
        barAppearance.bottomLineColor = UIColor(white: 0.95, alpha: 1)
        barAppearance.barTintColor = .white
        barAppearance.topLineHidden = true
        PageTabBar.defaultBarAppearanceSettings = barAppearance
        
        var lineAppearance = PageTabBar.defaultIndicatorLineAppearanceSettings
        lineAppearance.lineHeight = 2
        lineAppearance.lineColor = view.tintColor
        PageTabBar.defaultIndicatorLineAppearanceSettings = lineAppearance
        
        let parallaxController = ParallaxHeaderPageTabBarController(viewControllers: [], items: [], parallaxHeaderHeight: 300)
        parallaxController.pageTabBarController.pageTabBar.barHeight = 60

        parallaxController.pageTabBarController.setPageTabBarController([vc01, vc02, vc03], items: [tab01, tab02, tab03], newPageIndex: 1, animated: false)
        return parallaxController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(parallaxController)
        
        parallaxController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(parallaxController.view)
        parallaxController.view.translatesAutoresizingMaskIntoConstraints = false
        
        if let _ = parent as? UINavigationController {
            if #available(iOS 11.0, *) {
                parallaxController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            } else {
                parallaxController.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            }
        } else {
            parallaxController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        parallaxController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        parallaxController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        parallaxController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        parallaxController.didMove(toParentViewController: self)
        
        
        parallaxController.pageTabBarController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0)
        } else {
            // Fallback on earlier versions
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
//        if let vc = pageTabBarController.selectedViewController {
//            for view in vc.view.subviews {
//                if view.isKind(of: UIScrollView.self) {
//                    currentScrollView = view as? UIScrollView
//
//                    print("currentScrollView: \(view)")
//                    break
//                }
//            }
//        }
//        addContentOffsetObserve()
        
       // print(parallaxController.minimumSafeAreaInsets)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    //    print(parallaxController.minimumSafeAreaInsets)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
}

extension ScrollTabBarViewController: PageTabBarControllerDelegate {

    func pageTabBarController(_ controller: PageTabBarController, didChangeContentViewController vc: UIViewController, atIndex index: Int) {
        print("didChangeContentViewController: \(vc)")
        print("index: \(index)")
    }
  
}





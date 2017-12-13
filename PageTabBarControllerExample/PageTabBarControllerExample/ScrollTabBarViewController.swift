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
    
    private var parallaxController: ParallaxHeaderPageTabBarController
    
    private var pageTabBarTopConstraint: NSLayoutConstraint?
    
    private var isObservingContentOffset = true
    private var currentScrollView: UIScrollView?
    private var contentOffsetObservation: NSKeyValueObservation?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
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
        vc01.view.tag = 1
        vc02.view.tag = 2
        vc03.view.tag = 3
        
        parallaxController = ParallaxHeaderPageTabBarController(viewControllers: [vc01, vc02, vc03], items: [tab01, tab02, tab03], parallaxHeaderHeight: 300)
        parallaxController.pageTabBarController.pageTabBar.barHeight = 60
        parallaxController.pageTabBarController.pageTabBar.indicatorLineColor = tabSelectedColor
        parallaxController.pageTabBarController.pageTabBar.indicatorLineHeight = 2
        parallaxController.pageTabBarController.pageTabBar.bottomLineHidden = true
        parallaxController.pageTabBarController.pageTabBar.topLineColor = tabSelectedColor
        parallaxController.pageTabBarController.pageTabBar.barTintColor = UIColor(white: 0.95, alpha: 1)
        parallaxController.minimumRevealHeight = 0
        super.init(nibName: nil, bundle: nil)
        
        
        parallaxController.pageTabBarController.resetPageTabBarController([vc01, vc02, vc03], items: [tab01, tab02, tab03], newPageIndex: 1, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0)
        } else {
            // Fallback on earlier versions
        }
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
}

extension ScrollTabBarViewController: PageTabBarControllerDelegate {
    func pageTabBarController(_ controller: PageTabBarController, didSelectItem item: PageTabBarItem, atIndex index: Int, previousIndex: Int) {
       
    }
    
    func pageTabBarController(_ controller: PageTabBarController, didChangeContentViewController vc: UIViewController, atIndex index: Int) {

    }
    
    func pageTabBarController(_ controller: PageTabBarController, transit fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        // print("from index: \(fromIndex), to index: \(toIndex), progress: \(progress)")
    }
}





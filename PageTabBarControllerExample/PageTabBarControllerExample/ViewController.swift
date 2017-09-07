//
//  ViewController.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 4/9/2017.
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

import UIKit
import PageTabBarController

class ViewController: UIViewController, CollapseTabBarViewControllerDelegate, PageTabBarControllerDelegate {

    //var tabBarController: PageTabBarController!
    var collapseTabBarViewController: CollapseTabBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        
        let vc01 = TableViewController(nibName: nil, bundle: nil)
        let vc02 = TableViewController(nibName: nil, bundle: nil)
        let vc03 = TableViewController(nibName: nil, bundle: nil)
        let vc04 = TableViewController(nibName: nil, bundle: nil)
        let vc05 = TableViewController(nibName: nil, bundle: nil)
        let vc06 = TableViewController(nibName: nil, bundle: nil)
        
        let headerView = UIImageView(image: UIImage(named: "cover"))
        
        let tab01 = PageTabBarItem(icon: UIImage(named: "img01"))
        let tab02 = PageTabBarItem(icon: UIImage(named: "img01"))
        let tab03 = PageTabBarItem(icon: UIImage(named: "img01"))
        let tab04 = PageTabBarItem(icon: UIImage(named: "img01"))
        let tab05 = PageTabBarItem(icon: UIImage(named: "img01"))
        let tab06 = PageTabBarItem(icon: UIImage(named: "img01"))
        
        collapseTabBarViewController = CollapseTabBarViewController(viewControllers: [vc01, vc02, vc03, vc04, vc05, vc06],
                                                                    tabBarItems: [tab01, tab02, tab03, tab04, tab05, tab06],
                                                                    headerView: headerView,
                                                                    maximumHeaderHeight: view.frame.width)
        collapseTabBarViewController.pageTabBarController?.pageTabBar.indicatorLineColor = .blue
        collapseTabBarViewController.pageTabBarController?.pageTabBar.indicatorLineHeight = 2
        collapseTabBarViewController.pageTabBarController?.pageTabBar.bottomLineHidden = true
        collapseTabBarViewController.pageTabBarController?.pageTabBar.topLineColor = .black
        collapseTabBarViewController.pageTabBarController?.pageTabBar.barTintColor = UIColor(white: 0.9, alpha: 1)
        
        collapseTabBarViewController.pageTabBarController?.transitionAnimation = .scroll
        collapseTabBarViewController.pageTabBarController?.delegate = self
        collapseTabBarViewController.delegate = self
        CollapseTabBarViewController.attachCollapseTabBarController(collapseTabBarViewController,
                                                                    into: self) { (collapseVC, _) in
                                                                        collapseVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                                                    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collapseTabBarController(_ controller: CollapseTabBarViewController, tabBarDidReach position: CollapseTabBarPosition) {
        // print("\(position.rawValue)")
    }
    
    func pageTabBarController(_ controller: PageTabBarController, didSelectItem item: PageTabBarItem, atIndex index: Int, previousIndex: Int) {
        
        print("previousIndex: \(previousIndex)")
        print("currentIndex: \(index)")
        
        if index == 3 {
            collapseTabBarViewController?.scrollTabBar(to: .top)
        }
        
        if index == 2 {
            controller.setBadge(200, forItemAt: index)
        }
        
        if index == 5 {
            controller.clearAllBadges()
        }
    }
    
    func pageTabBarController(_ controller: PageTabBarController, didChangeContentViewController vc: UIViewController, atIndex index: Int) {
        print("didChangeContentViewController: \(vc)")
        print("index: \(index)")
    }

}


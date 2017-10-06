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

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override open var childViewControllerForStatusBarHidden: UIViewController? {
        return collapseTabBarViewController
    }
    
    override open var childViewControllerForStatusBarStyle: UIViewController? {
        return collapseTabBarViewController
    }
    
    //var tabBarController: PageTabBarController!
    var collapseTabBarViewController: CollapseTabBarViewController!
    
    let vc01 = TableViewController(nibName: nil, bundle: nil)
    let vc02 = TableViewController(nibName: nil, bundle: nil)
    let vc03 = TableViewController(nibName: nil, bundle: nil)
    let vc04 = TableViewController(nibName: nil, bundle: nil)
    let vc05 = TableViewController(nibName: nil, bundle: nil)
    let vc06 = TableViewController(nibName: nil, bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set styles
        let tabColor = UIColor(red: 215/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1)
        let tabSelectedColor = UIColor(red: 35/255.0, green: 171/255.0, blue: 232/255.0, alpha: 1)
        
        vc01.view.tag = 1
        vc02.view.tag = 2
        vc03.view.tag = 3
        vc04.view.tag = 4
        vc05.view.tag = 5
        vc06.view.tag = 6
        
        let headerView = UIImageView(image: UIImage(named: "cover"))
        
        let tab01 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab01.color = tabColor
        tab01.selectedColor = tabSelectedColor
        let tab02 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab02.color = tabColor
        tab02.selectedColor = tabSelectedColor
        let tab03 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab03.color = tabColor
        tab03.selectedColor = tabSelectedColor
        let tab04 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab04.color = tabColor
        tab04.selectedColor = tabSelectedColor
        let tab05 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab05.color = tabColor
        tab05.selectedColor = tabSelectedColor
        let tab06 = PageTabBarItem(icon: UIImage(named: "img01"))
        tab06.color = tabColor
        tab06.selectedColor = tabSelectedColor
        let tabA = PageTabBarItem(title: "Tab Title A")
        tabA.color = tabColor
        tabA.selectedColor = tabSelectedColor
        
        collapseTabBarViewController = CollapseTabBarViewController(viewControllers: [vc01, vc02, vc03],
                                                                    tabBarItems: [tab01, tab02, tabA],
                                                                    headerView: headerView,
                                                                    headerHeight: view.frame.width)
        collapseTabBarViewController.pageIndex = 1
        collapseTabBarViewController.minimumHeaderViewHeight = 0
        collapseTabBarViewController.maximumHeaderViewHeight = view.frame.height - 150
        collapseTabBarViewController.pageTabBarController?.pageTabBar.barHeight = 40
        collapseTabBarViewController.pageTabBarController?.pageTabBar.indicatorLineColor = tabSelectedColor
        collapseTabBarViewController.pageTabBarController?.pageTabBar.indicatorLineHeight = 2
        collapseTabBarViewController.pageTabBarController?.pageTabBar.bottomLineHidden = true
        collapseTabBarViewController.pageTabBarController?.pageTabBar.topLineColor = tabSelectedColor
        collapseTabBarViewController.pageTabBarController?.pageTabBar.barTintColor = UIColor(white: 0.95, alpha: 1)
        
        collapseTabBarViewController.pageTabBarController?.transitionAnimation = .scroll
        collapseTabBarViewController.pageTabBarController?.delegate = self
        collapseTabBarViewController.delegate = self
        CollapseTabBarViewController.attachCollapseTabBarController(
            collapseTabBarViewController,
            into: self) { (collapseVC, parentVC) in
                collapseVC.view.translatesAutoresizingMaskIntoConstraints = false
                collapseVC.view.topAnchor.constraint(equalTo: parentVC.view.topAnchor, constant: 64).isActive = true
                collapseVC.view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor).isActive = true
                collapseVC.view.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor).isActive = true
                collapseVC.view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor).isActive = true
        }
        
        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        topBar.backgroundColor = tabSelectedColor
        view.addSubview(topBar)
    }

    func collapseTabBarController(_ controller: CollapseTabBarViewController, tabBarDidReach position: CollapseTabBarPosition) {
        // print("\(position.rawValue)")
    }
    
    func collapseTabBarController(_ controller: CollapseTabBarViewController, panGestureRecognizer: UIPanGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let tableViewController = collapseTabBarViewController.pageTabBarController?.selectedViewController as? TableViewController {
            return otherGestureRecognizer == tableViewController.tableView.panGestureRecognizer
        }
        return false
    }
    
    func pageTabBarController(_ controller: PageTabBarController, didSelectItem item: PageTabBarItem, atIndex index: Int, previousIndex: Int) {
        
        // print("previousIndex: \(previousIndex)")
        // print("currentIndex: \(index)")
        
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
        // print("didChangeContentViewController: \(vc)")
        // print("index: \(index)")
    }

}


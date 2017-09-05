//
//  ViewController.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 4/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import UIKit
import PageTabBarController

class ViewController: UIViewController {

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
        
        let collapseTabBarViewController = CollapseTabBarViewController(viewControllers: [vc01, vc02, vc03, vc04, vc05, vc06],
                                                                        tabBarItems: [tab01, tab02, tab03, tab04, tab05, tab06],
                                                                        headerView: headerView,
                                                                        maximumHeaderHeight: view.frame.width)
        CollapseTabBarViewController.attachCollapseTabBarController(collapseTabBarViewController,
                                                                    into: self) { (collapseVC, _) in
                                                                        collapseVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                                                    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


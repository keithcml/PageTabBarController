//
//  MainViewController.swift
//  PageTabBarControllerExample
//
//  Created by Mingloan Chan on 12/6/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit
import PageTabBarController

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Collapse Tab Bar"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Scroll Tab Bar"
        } else {
            cell.textLabel?.text = "Page Tab Bar subclass"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScrollTabBarViewController")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            
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
            
            let parallaxVC = ParallaxHeaderPageTabBarController(viewControllers: [vc01, vc02, vc03], items: [tab01, tab02, tab03], parallaxHeaderHeight: view.frame.width)
            parallaxVC.pageTabBarController.pageTabBar.barHeight = 60
            parallaxVC.pageTabBarController.pageTabBar.indicatorLineColor = tabSelectedColor
            parallaxVC.pageTabBarController.pageTabBar.indicatorLineHeight = 2
            parallaxVC.pageTabBarController.pageTabBar.bottomLineHidden = true
            parallaxVC.pageTabBarController.pageTabBar.topLineColor = tabSelectedColor
            parallaxVC.pageTabBarController.pageTabBar.barTintColor = UIColor(white: 0.95, alpha: 1)
            parallaxVC.minimumRevealHeight = 200
            navigationController?.pushViewController(parallaxVC, animated: true)
        }
    }
}

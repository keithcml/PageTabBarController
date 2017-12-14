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

    var parallaxVC: ParallaxHeaderPageTabBarController!
    
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
            cell.textLabel?.text = "Top Tab Bar"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Embeded Parallax Page Tab Bar"
        } else {
            cell.textLabel?.text = "Parallax Page Tab Bar"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
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
            
            let vc = PlainPageTabBarController(viewControllers: [vc01, vc02, vc03], items: [tab01, tab02, tab03], tabBarPosition: .topAttached)
            vc.pageTabBar.barHeight = 60
            vc.pageTabBar.indicatorLineColor = tabSelectedColor
            vc.pageTabBar.indicatorLineHeight = 2
            vc.pageTabBar.bottomLineHidden = true
            vc.pageTabBar.topLineColor = tabSelectedColor
            vc.pageTabBar.barTintColor = UIColor(white: 0.95, alpha: 1)
            vc.delegate = self
            
            let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            let button = UIButton(type: .custom)
            button.setTitle("A Button", for: .normal)
            button.backgroundColor = .red
            tempView.backgroundColor = .white
            tempView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: tempView.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: tempView.bottomAnchor).isActive = true
            button.trailingAnchor.constraint(equalTo: tempView.trailingAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 100).isActive = true
            button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            
            vc.setBannerViewWithCustomView(tempView, animated: false)
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 1 {
            let vc = ScrollTabBarViewController(nibName: nil, bundle: nil)
            //present(vc, animated: true, completion: nil)
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
            
            
            let galleryView = GalleryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
            galleryView.images = [GalleryImage.image(image: UIImage(named: "cover")!),
                                  GalleryImage.image(image: UIImage(named: "cover")!),
                                  GalleryImage.image(image: UIImage(named: "cover")!)]
            
            parallaxVC = ParallaxHeaderPageTabBarController(viewControllers: [vc01, vc02, vc03], items: [tab01, tab02, tab03], parallaxHeaderHeight: view.frame.width)
            parallaxVC.pageTabBarController.pageTabBar.barHeight = 60
            parallaxVC.pageTabBarController.transitionAnimation = .scroll
            parallaxVC.pageTabBarController.pageTabBar.indicatorLineColor = tabSelectedColor
            parallaxVC.pageTabBarController.pageTabBar.indicatorLineHeight = 2
            parallaxVC.pageTabBarController.pageTabBar.bottomLineHidden = true
            parallaxVC.pageTabBarController.pageTabBar.topLineColor = tabSelectedColor
            parallaxVC.pageTabBarController.delegate = self
            
            parallaxVC.setParallexHeaderView(galleryView, height: 200)
            //parallaxVC.setSelfSizingParallexHeaderView(galleryView)
            parallaxVC.delegate = self
            
            let button = UIButton(type: .custom)
            button.setTitle("A Button", for: .normal)
            button.backgroundColor = .red
            button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            parallaxVC.setSupplementaryView(button)
            
            navigationController?.pushViewController(parallaxVC, animated: true)
        }
    }
    
    @objc private func tap(_ sender: Any) {
        
        parallaxVC.setParallexHeaderHeight(view.frame.width, animated: true)
        
        /*
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: {
            self.parallaxVC.setParallexHeaderView(nil, height: 500)
        }) { (_) in
            
            
            let tabColor = UIColor(red: 0/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1)
            let tabSelectedColor = UIColor(red: 35/255.0, green: 171/255.0, blue: 232/255.0, alpha: 1)
            
            let tab01 = PageTabBarItem(icon: UIImage(named: "img01"))
            tab01.color = tabColor
            tab01.selectedColor = tabSelectedColor
            let tab02 = PageTabBarItem(icon: UIImage(named: "img01"))
            tab02.color = tabColor
            tab02.selectedColor = tabSelectedColor
            
            let vc01 = TableViewController(nibName: nil, bundle: nil)
            let vc02 = TableViewController(nibName: nil, bundle: nil)
            vc01.view.tag = 1
            vc02.view.tag = 2
            
            self.parallaxVC.pageTabBarController.setPageTabBarController([vc01, vc02], items: [tab01, tab02], newPageIndex: 0, animated: false)
            
            let galleryView = GalleryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
            galleryView.images = [GalleryImage.image(image: UIImage(named: "cover")!),
                                  GalleryImage.image(image: UIImage(named: "cover")!)]
            
            UIView.animate(withDuration: 0.4, delay: 1.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: {
                self.parallaxVC.setParallexHeaderView(galleryView, height: 300)
            }) { (_) in
                
            }
        }
        */
        
    }
}

extension MainViewController: PageTabBarControllerDelegate, ParallaxHeaderPageTabBarControllerDelegate {
    
    func parallaxHeaderPageTabBarController(_ controller: ParallaxHeaderPageTabBarController, revealPercentage: CGFloat, revealPercentageIncludingTopSafeAreaInset: CGFloat) {
        //print("revealPercentage \(revealPercentage)")
        //print("revealPercentageIncludingTopSafeAreaInset \(revealPercentageIncludingTopSafeAreaInset)")
    }
    
    func pageTabBarController(_ controller: PageTabBarController, didSelectItem item: PageTabBarItem, atIndex index: Int, previousIndex: Int) {

        if index == 0 {
        }

        if index == 1 {
            controller.clearAllBadges()
        }
    }
    
    func pageTabBarController(_ controller: PageTabBarController, didChangeContentViewController vc: UIViewController, atIndex index: Int) {
        print("didChangeContentViewController: \(vc)")
        print("index: \(index)")
        
        if index == 1 {
            
            if let _ = parallaxVC {
                
            }
//
            //parallaxVC.isStretchy = false
            //parallaxVC.setParallexHeaderHeight(300, animated: true)
        } else {
            //parallaxVC.isStretchy = true
        }
        
        if index == 2 {
            //parallaxVC.setParallexHeaderHeight(view.frame.width, animated: true)
            controller.setBadge(200, forItemAt: index)
            
            if let _ = parallaxVC {
                parallaxVC.scrollTabBar(to: true, animated: true)
            }
        }
    }
}

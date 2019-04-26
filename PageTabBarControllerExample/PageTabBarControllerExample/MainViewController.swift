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
        
        title = "Main"
        
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
            
            // set default appearance settings
            let appearance = PageTabBarItem.defaultAppearanceSettings
            //appearance.contentHeight = 20
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
            
            var barAppearance = PageTabBar.defaultBarAppearanceSettings
            //barAppearance.isTranslucent = true
            //barAppearance.topLineColor = view.tintColor
            barAppearance.bottomLineColor = UIColor(white: 0.95, alpha: 1)
            barAppearance.barTintColor = .white
            barAppearance.bottomLineHidden = true
            PageTabBar.defaultBarAppearanceSettings = barAppearance
            
            var lineAppearance = PageTabBar.defaultIndicatorLineAppearanceSettings
            lineAppearance.lineHeight = 2
            lineAppearance.lineColor = view.tintColor
            PageTabBar.defaultIndicatorLineAppearanceSettings = lineAppearance
            
            let vc = PlainPageTabBarController(viewControllers: [vc01, vc02, vc03], items: [tab01, tab02, tab03], tabBarPosition: .topAttached)
            vc.pageTabBar.barHeight = 60
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
            
            vc.setPageTabBarSupplementaryViewWithCustomView(tempView, animated: false)
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 1 {
            let vc = ScrollTabBarViewController(nibName: nil, bundle: nil)
            //present(vc, animated: true, completion: nil)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            
            // set default appearance settings
            var appearance = PageTabBarItem.defaultAppearanceSettings
            appearance.font = UIFont.boldSystemFont(ofSize: 16)
            appearance.selectedColor = view.tintColor
            appearance.contentHeight = PageTabBarItem.AppearanceSettings.automaticDimemsion
            appearance.offset = CGSize(width: 0, height: -5)
            PageTabBarItem.defaultAppearanceSettings = appearance
            
            let tab01 = PageTabBarItem(title: "London")
            let tab02 = PageTabBarItem(title: "Paris")
            let tab03 = PageTabBarItem(title: "Singapore")
            
            let vc01 = TableViewController(nibName: nil, bundle: nil)
            let vc02 = TableViewController(nibName: nil, bundle: nil)
            let vc03 = TableViewController(nibName: nil, bundle: nil)
            vc01.view.tag = 1
            vc02.view.tag = 2
            vc03.view.tag = 3
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
            headerView.backgroundColor = .lightGray
//            let galleryView = GalleryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
//            galleryView.images = [GalleryImage.image(image: UIImage(named: "cover")!),
//                                  GalleryImage.image(image: UIImage(named: "cover")!),
//                                  GalleryImage.image(image: UIImage(named: "cover")!)]
            
            var barAppearance = PageTabBar.defaultBarAppearanceSettings
            barAppearance.topLineColor = view.tintColor
            barAppearance.bottomLineColor = UIColor(white: 0.95, alpha: 1)
            barAppearance.barTintColor = .white
            barAppearance.bottomLineHidden = true
            PageTabBar.defaultBarAppearanceSettings = barAppearance
            
            var lineAppearance = PageTabBar.defaultIndicatorLineAppearanceSettings
            lineAppearance.lineHeight = 3
            lineAppearance.lineWidth = .contentWidth
            lineAppearance.lineColor = view.tintColor
            lineAppearance.position = .bottom(offset: 15)
            PageTabBar.defaultIndicatorLineAppearanceSettings = lineAppearance
            
            parallaxVC = ParallaxHeaderPageTabBarController(viewControllers: [vc01, vc02, vc03], items: [tab01, tab02, tab03], parallaxHeaderHeight: view.frame.width)
            parallaxVC.pageTabBarController.pageTabBar.barHeight = 60
            // parallaxVC.isStretchy = false
            parallaxVC.pageTabBarController.transitionAnimation = .scroll
            parallaxVC.pageTabBarController.delegate = self
            parallaxVC.minimumRevealHeight = 40
            parallaxVC.setParallexHeaderView(headerView, height: view.frame.width)
            parallaxVC.delegate = self
            
        
            let button = UIButton(type: .custom)
            button.setTitle("A Button", for: .normal)
            button.backgroundColor = .red
            button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            let contentView = UIView()
            contentView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            button.widthAnchor.constraint(equalToConstant: 100).isActive = true
            
            parallaxVC.setSupplementaryView(contentView, height: 40)
            setPageVC02()
            navigationController?.pushViewController(parallaxVC, animated: true)
        }
    }
    
    @objc private func tap(_ sender: Any) {
        
        // parallaxVC.scrollToTop(true, animated: true)
        
        // parallaxVC.pageTabBarController.setPageIndex(1, animated: true)
        setPageVC02()
        // parallaxVC.setParallexHeaderHeight(view.frame.width, animated: true)
        /*
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: {
            self.parallaxVC.minimizesTabsContent(animated: false)
            // self.parallaxVC.setParallexHeaderView(nil, height: 500, sizeToFitHeader:  true)
        }) { (_) in
            
            
            self.setPageVC02()
            
            let galleryView = GalleryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
            galleryView.images = [GalleryImage.image(image: UIImage(named: "cover")!),
                                  GalleryImage.image(image: UIImage(named: "cover")!)]
            
            self.parallaxVC.setParallexHeaderView(galleryView, height: 300)
            
            UIView.animate(withDuration: 0.4, delay: 2.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: {
                self.parallaxVC.setParallexHeaderHeight(300, animated: false)
                //self.parallaxVC.setParallexHeaderView(galleryView, height: 300)
            }) { (_) in
                // self.parallaxVC.setParallexHeaderView(galleryView, height: 300)
            }
        }*/
        
        
    }
    
    private func setPageVC02() {
        let tab01 = PageTabBarItem(unselectedImage: UIImage(named: "img01"), selectedImage: UIImage(named: "img01"))
        let tab02 = PageTabBarItem(unselectedImage: UIImage(named: "img01"), selectedImage: UIImage(named: "img01"))
        let tab03 = PageTabBarItem(unselectedImage: UIImage(named: "img01"), selectedImage: UIImage(named: "img01"))
        let tab04 = PageTabBarItem(unselectedImage: UIImage(named: "img01"), selectedImage: UIImage(named: "img01"))
        let tab05 = PageTabBarItem(unselectedImage: UIImage(named: "img01"), selectedImage: UIImage(named: "img01"))
        
        let vc01 = TableViewController(nibName: nil, bundle: nil)
        let vc02 = TableViewController(nibName: nil, bundle: nil)
        let vc03 = TableViewController(nibName: nil, bundle: nil)
        let vc04 = TableViewController(nibName: nil, bundle: nil)
        let vc05 = TableViewController(nibName: nil, bundle: nil)
        vc01.view.tag = 1
        vc02.view.tag = 2
        vc03.view.tag = 3
        vc04.view.tag = 3
        vc05.view.tag = 3
        
        self.parallaxVC.pageTabBarController.setPageTabBarController([vc01, vc02, vc03, vc04, vc05],
                                                                     items: [tab01, tab02, tab03, tab04, tab05],
                                                                     newPageIndex: 4, animated: false)
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
        print("didChangeContentViewController: \(vc) at index: \(index)")
        
        
        if index == 1 {
            parallaxVC.scrollToTop(false, animated: true)
        }
        
        if index == 2 {
            controller.setBadge(20, forItemAt: index)
            
            if let _ = parallaxVC {
                parallaxVC.scrollToTop(true, animated: true)
            }
        }
    }
}

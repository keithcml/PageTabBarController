//
//  PageTabBarController.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

internal final class PageTabBarCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        let oldBounds = cv.bounds
        if newBounds.height != oldBounds.height {
            cv.collectionViewLayout.invalidateLayout()
            return false
        }
        return false
    }
}

@objc public final class PageTabBarController: UIViewController, UIScrollViewDelegate {
    
    var updateIndex: (Bool, Int) -> () = { _ in }
    fileprivate var pageTabBar: PageTabBar!

    fileprivate var collectionView: UICollectionView!
    fileprivate(set) var viewControllers = [UIViewController]()
    
    var pageIndex: Int = 0
    var pageTabBarItems: [PageTabBarItem] = []
    var isScrollEnabled = true {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    @objc public convenience init(viewControllers: [UIViewController],
                                  items: [PageTabBarItem],
                                  estimatedFrame: CGRect,
                                  tabBarPosition: PageTabBarPosition = .top) {
        
        self.init(nibName: nil, bundle: nil)
        
        self.viewControllers = viewControllers
        
        for item in items {
            item.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width/CGFloat(items.count), height: 44)
            pageTabBarItems.append(item)
        }
        
        pageTabBar = PageTabBar(frame: CGRect(x: 0, y: 0, width: estimatedFrame.width, height: 44), tabBarItems: pageTabBarItems)
        
        pageTabBar.toIndex = { [unowned self] index in
            
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            self.pageIndex = index
        }
        
        view.addSubview(pageTabBar)
        pageTabBar.translatesAutoresizingMaskIntoConstraints = false
        pageTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pageTabBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let layout: UICollectionViewFlowLayout = PageTabBarCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
        if case .top = tabBarPosition {
            pageTabBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            collectionView.topAnchor.constraint(equalTo: pageTabBar.bottomAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        else {
            pageTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: pageTabBar.topAnchor).isActive = true
        }
    }
    
    @available(*, deprecated, message: "deprecated")
    override public func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        UIView.animate(withDuration: 0, animations: {
            self.collectionView.reloadData()
            self.collectionView?.scrollToItem(at: IndexPath(row: self.pageIndex, section: 0),
                                              at: .top,
                                              animated: true)
            self.view.layoutIfNeeded()
        }, completion: { _ in
            let diff = self.collectionView.contentOffset.x * self.pageTabBar.frame.width / self.collectionView.contentSize.width
            self.pageTabBar.setIndicatorPosition(diff)
        })
    }
    
    func theMostBelowScrollViewInView(_ view: UIView) -> UIScrollView? {
        
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        
        for subview in view.subviews {
            // if the real keyboard-view is found, remember it.
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
            
            let itsSubview = theMostBelowScrollViewInView(subview)
            if itsSubview != nil {
                return itsSubview
            }
        }
        return nil
    }
}

extension PageTabBarController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        return cell
    }
}

extension PageTabBarController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = viewControllers[indexPath.row]
        if vc.parent == nil {
            addChildViewController(vc)
            cell.contentView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            vc.didMove(toParentViewController: self)
        }
        else {
            cell.contentView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        }
        updateIndex(false, indexPath.row)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pageTabBar.isInteracting = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let diff = scrollView.contentOffset.x * pageTabBar.frame.width/scrollView.contentSize.width
        pageTabBar.setIndicatorPosition(diff)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if !scrollView.isDragging {
                pageTabBar.isInteracting = false
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if !scrollView.isDragging {
            pageTabBar.isInteracting = false
        }
    }
    
}

extension PageTabBarController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

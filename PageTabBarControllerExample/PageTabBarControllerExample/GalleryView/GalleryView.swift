//
//  GalleryView.swift
//  real-v2-ios
//
//  Created by Mingloan Chan on 9/23/17.
//  Copyright © 2017 Real. All rights reserved.
//

import PageTabBarController
import Foundation
import UIKit

enum GalleryImage {
    case image(image: UIImage)
    case url(url: URL)
}

final class GalleryView: UIView {
    
    var images = [GalleryImage]() {
        didSet {
            pageNumberView.totalNumberOfPage = images.count
            pageNumberView.currentPage = 1
            collectionView.isScrollEnabled = images.count > 1
            collectionView.alwaysBounceHorizontal = images.count > 1
            collectionView.contentOffset = CGPoint.zero
            collectionView.reloadData()
        }
    }
    
    internal(set) var collectionView: GalleryCollectionView
    
    fileprivate let pageNumberView = PageNumberView(frame: CGRect(x: 0, y: 0, width: 36, height: 18))
    
    override init(frame: CGRect) {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        layout.itemSize = frame.size
        layout.scrollDirection = .horizontal
        
        collectionView = GalleryCollectionView(frame: frame, collectionViewLayout: layout)
        
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        
        collectionView.backgroundColor = .white
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(collectionView)
        
        pageNumberView.totalNumberOfPage = images.count
        addSubview(pageNumberView)
        pageNumberView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageNumberView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            pageNumberView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            ])
    }
}

extension GalleryView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? GalleryCell else { return }
        if case let .url(imgURL) = images[indexPath.row] {
            // cell.imageView.sd_setImage(with: imgURL, placeholderImage: nil)
        }
        else if case let .image(img) = images[indexPath.row] {
            cell.imageView.image = img
        }
        pageNumberView.currentPage = indexPath.row + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageNumberView.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width) + 1
    }
}

final class GalleryCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        panGestureRecognizer.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GalleryCollectionView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
//            if let _ = parentViewController?.mm_drawerController, panGesture.direction == .right && contentOffset.x == 0 {
//                return false
//            }
//        }

        return true
    }
}

private class PageNumberView: UIView {
    
    var totalNumberOfPage = 1 {
        didSet {
            pageNumberLabel.text = "\(currentPage)/\(totalNumberOfPage)"
        }
    }
    var currentPage = 1 {
        didSet {
            pageNumberLabel.text = "\(currentPage)/\(totalNumberOfPage)"
        }
    }
    
    private let pageNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = UIColor.lightText
        return label
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 36, height: 18)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        layer.cornerRadius = 4
        layer.masksToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        addSubview(pageNumberLabel)
        pageNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageNumberLabel.topAnchor.constraint(equalTo: topAnchor),
            pageNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageNumberLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
    }
}



//
//  CollapseCollectionView.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 22/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CollapseCollectionViewDelegate: UICollectionViewDelegate {
    @objc optional func collapseCollectionView(_ collapseCollectionView: CollapseCollectionView,
                                               panGestureRecognizer: UIPanGestureRecognizer,
                                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

final class CollapseCollectionView: UICollectionView {
    
    fileprivate weak var collapseCollectionViewDelegate: CollapseCollectionViewDelegate?
    
    override weak var delegate: UICollectionViewDelegate? {
        didSet {
            collapseCollectionViewDelegate = delegate as? CollapseCollectionViewDelegate
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .white
        bounces = true
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        panGestureRecognizer.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CollapseCollectionView: UIGestureRecognizerDelegate {
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
            let delegate = delegate as? CollapseCollectionViewDelegate,
            let shouldRecognizeSimultaneously = delegate.collapseCollectionView?(self,
                                                                                 panGestureRecognizer: panGestureRecognizer,
                                                                                 shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return shouldRecognizeSimultaneously
        }
        
        if let gestureView = otherGestureRecognizer.view, gestureView.isKind(of: UIScrollView.self) {
            return true
        }
        
        return true
    }

}


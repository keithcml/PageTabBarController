//
//  CollapseCollectionViewLayout.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 22/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

public struct CollapseCollectionViewLayoutSettings {
    var isHeaderStretchy = true
    var headerSize = CGSize.zero
    var headerStretchHeight: CGFloat = 64
    var headerMinimumHeight: CGFloat = 0
    
    public static func defaultSettings() -> CollapseCollectionViewLayoutSettings {
        return CollapseCollectionViewLayoutSettings(headerSize: CGSize.zero, isHeaderStretchy: true, headerStretchHeight: 64, headerMinimumHeight: 0)
    }
    
    public init(headerSize: CGSize, isHeaderStretchy: Bool, headerStretchHeight: CGFloat, headerMinimumHeight: CGFloat) {
        self.isHeaderStretchy = isHeaderStretchy
        self.headerSize = headerSize
        self.headerStretchHeight = headerStretchHeight
        self.headerMinimumHeight = headerMinimumHeight
    }
}

@objc protocol CollapseCollectionViewLayoutDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    
}

final class CollapseCollectionViewLayout: UICollectionViewLayout {
    
    weak var delegate: CollapseCollectionViewLayoutDelegate?

    enum Element: String {
        case header
        case footer
        case cell
        
        var id: String {
            return self.rawValue
        }
        
        var kind: String {
            return "Kind\(self.rawValue.capitalized)"
        }
    }
    
    fileprivate var contentSize = CGSize.zero
    fileprivate var settings = CollapseCollectionViewLayoutSettings.defaultSettings()
    fileprivate var oldBounds = CGRect.zero
    fileprivate var cache = [Element: [IndexPath: UICollectionViewLayoutAttributes]]()
    fileprivate var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    convenience init(settings: CollapseCollectionViewLayoutSettings) {
        self.init()
        self.settings = settings
    }
    
    override public class var layoutAttributesClass: AnyClass {
        return UICollectionViewLayoutAttributes.self
    }
    
    override public var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case Element.header.kind:
            return cache[.header]?[indexPath]
            
        default:
            return cache[.footer]?[indexPath]
        }
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[.cell]?[indexPath]
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let collectionView = collectionView else {
            return nil
        }
        
        visibleLayoutAttributes.removeAll(keepingCapacity: true)
        
        for (type, elementInfos) in cache {
            for (indexPath, attributes) in elementInfos {
                
                updateSupplementaryViews(type,
                                         attributes: attributes,
                                         collectionView: collectionView,
                                         indexPath: indexPath)
                visibleLayoutAttributes.append(attributes)

            }
        }
        return visibleLayoutAttributes
    }
    
    //MARK: - Preparation
    
    private func prepareCache() {
        cache.removeAll(keepingCapacity: true)
        cache[.header] = [IndexPath: UICollectionViewLayoutAttributes]()
        cache[.footer] = [IndexPath: UICollectionViewLayoutAttributes]()
        cache[.cell] = [IndexPath: UICollectionViewLayoutAttributes]()
    }
    
    private func prepareElement(size: CGSize, type: Element, attributes: UICollectionViewLayoutAttributes) {

        guard size != .zero else {
            return
        }
        
        attributes.frame = CGRect(origin: CGPoint.zero, size: size)
        
        cache[type]?[attributes.indexPath] = attributes
    }
    
    private func updateSupplementaryViews(_ type: Element, attributes: UICollectionViewLayoutAttributes, collectionView: UICollectionView, indexPath: IndexPath) {

        let headerHeight = settings.headerSize.height
        
        if collectionView.contentOffset.y < 0 {
            
            switch type {
            case .header:
                if settings.isHeaderStretchy {
                    
                    let updatedHeight = min(headerHeight + settings.headerStretchHeight,
                                            max(headerHeight, headerHeight - collectionView.contentOffset.y))
                    
                    let scaleFactor = updatedHeight / headerHeight
                    let delta = (updatedHeight - headerHeight) / 2
                    
                    let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                    let translation = CGAffineTransform(translationX: 0,
                                                        y: min(collectionView.contentOffset.y, headerHeight) + delta)
                    
                    attributes.transform = scale.concatenating(translation)
                }
                break
            case .footer:
                break
            case .cell:
                if settings.isHeaderStretchy {
                    let y = min(headerHeight + collectionView.contentOffset.y + settings.headerStretchHeight, headerHeight)
                    attributes.frame.origin = CGPoint(x: 0, y: y)
                }
                break
            }

        } else {
            
            switch type {
            case .header:
                attributes.transform = .identity
                break
            case .footer:
                break
            case .cell:
                attributes.frame.origin = CGPoint(x: 0, y: headerHeight)
                break
            }
            
        }
    }
    
    // MARK: - Layout Details
    override public func prepare() {
        
        guard let collectionView = collectionView, cache.isEmpty else {
            return
        }
        
        prepareCache()
        
        let maxHeight = ceil(collectionView.frame.height + settings.headerSize.height - settings.headerMinimumHeight)
        contentSize = CGSize(width: collectionView.frame.width, height: maxHeight)
        
        oldBounds = collectionView.bounds
        
        let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.header.kind,
                                                                with: IndexPath(item: 0, section: 0))
        
        prepareElement(size: settings.headerSize, type: .header, attributes: headerAttributes)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let cellIndexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
            
            attributes.frame = CGRect(
                x: 0,
                y: settings.headerSize.height,
                width: collectionView.bounds.width,
                height: collectionView.bounds.height - settings.headerMinimumHeight
            )
            
            cache[.cell]?[cellIndexPath] = attributes
        }
        
    }
    
    // MARK: - Invalidation
    override func shouldInvalidateLayout (forBoundsChange newBounds : CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            cache.removeAll(keepingCapacity: true)
        }
        return true
    }
    
}


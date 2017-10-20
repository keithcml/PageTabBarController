//
//  CollapseCollectionViewLayout.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 22/9/2017.
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

@objc protocol CollapseCollectionViewLayoutDelegate: class {
    @objc optional func collapseCollectionView(_ collapseCollectionView: CollapseCollectionView, layout: CollapseCollectionViewLayout, sizeForStaticHeaderAt indexPath: IndexPath) -> CGSize
}

final class CollapseCollectionViewLayout: UICollectionViewLayout {
    
    weak var delegate: CollapseCollectionViewLayoutDelegate?
    
    enum Element: String {
        case staticHeader
        case header
        case cell
        
        var id: String {
            return self.rawValue
        }
        
        var kind: String {
            return "Kind\(self.rawValue.capitalized)"
        }
    }
    
    var settings = CollapseCollectionViewLayoutSettings.defaultSettings()
    fileprivate var contentSize = CGSize.zero
    fileprivate var oldBounds = CGRect.zero
    fileprivate var cache = [Element: [IndexPath: UICollectionViewLayoutAttributes]]()
    fileprivate var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    convenience init(settings: CollapseCollectionViewLayoutSettings = CollapseCollectionViewLayoutSettings.defaultSettings()) {
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
        case Element.staticHeader.kind:
            return cache[.staticHeader]?[indexPath]
        case Element.header.kind:
            return cache[.header]?[indexPath]
        default:
            return nil
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
                
                updateViews(type,
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
        cache[.staticHeader] = [IndexPath: UICollectionViewLayoutAttributes]()
        cache[.cell] = [IndexPath: UICollectionViewLayoutAttributes]()
    }
    
    private func prepareElement(size: CGSize, type: Element, attributes: UICollectionViewLayoutAttributes) {

        guard size != .zero else {
            return
        }
        
        switch type {
        case .staticHeader:
            attributes.frame = CGRect(origin: CGPoint(x: 0, y: settings.headerSize.height - size.height), size: size)
            break
        case .header:
            attributes.frame = CGRect(origin: CGPoint.zero, size: size)
            break
        case .cell:
            attributes.frame = CGRect(origin: CGPoint(x: 0, y: settings.headerSize.height), size: size)
            break
        }
        
        cache[type]?[attributes.indexPath] = attributes
    }
    
    private func updateViews(_ type: Element, attributes: UICollectionViewLayoutAttributes, collectionView: UICollectionView, indexPath: IndexPath) {

        let headerHeight = settings.headerSize.height
        let strechyHeight = settings.isHeaderStretchy ? settings.headerStretchHeight : 0
        
        if collectionView.contentOffset.y < 0 {
            
            switch type {
            case .staticHeader:
                let y = min(headerHeight + collectionView.contentOffset.y + strechyHeight, headerHeight) - attributes.size.height
                attributes.frame = CGRect(origin: CGPoint(x: 0, y: y),
                                          size: attributes.size)
                break
            case .header:
                let updatedHeight = min(headerHeight + strechyHeight,
                                        max(headerHeight, headerHeight - collectionView.contentOffset.y))
                
                let scaleFactor = updatedHeight / headerHeight
                let delta = (updatedHeight - headerHeight) / 2
                
                let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                let translation = CGAffineTransform(translationX: 0,
                                                    y: min(collectionView.contentOffset.y, headerHeight) + delta)
                
                attributes.transform = scale.concatenating(translation)
                break
            case .cell:
                let y = min(headerHeight + collectionView.contentOffset.y + strechyHeight, headerHeight)
                let maxHeight = collectionView.frame.height - headerHeight - strechyHeight
                let height = collectionView.frame.height - headerHeight + collectionView.contentOffset.y
                attributes.frame = CGRect(origin: CGPoint(x: 0, y: y),
                                          size: CGSize(width: attributes.frame.width,
                                                       height: max(maxHeight, height)))
                break
            }

        } else {
            
            switch type {
            case .staticHeader:
                let originY = headerHeight - attributes.frame.height
                attributes.frame = CGRect(origin: CGPoint(x: 0, y: originY),
                                          size: attributes.size)
                break
            case .header:
                attributes.transform = .identity
                break
            case .cell:
                let originY = max(headerHeight, collectionView.contentOffset.y)
                attributes.frame = CGRect(origin: CGPoint(x: 0, y: originY),
                                          size: CGSize(width: attributes.frame.width,
                                                       height: collectionView.frame.height - originY + collectionView.contentOffset.y))
                break
            }
            
        }
    }
    
    // MARK: - Layout Details
    override public func prepare() {
        
        guard let collectionView = collectionView as? CollapseCollectionView, cache.isEmpty else {
            return
        }
        
        prepareCache()
        
        let maxHeight = ceil(collectionView.frame.height + settings.headerSize.height - settings.headerMinimumHeight)
        contentSize = CGSize(width: collectionView.frame.width, height: maxHeight)
        
        oldBounds = collectionView.bounds
        
        let staticHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.staticHeader.kind,
                                                                      with: IndexPath(item: 0, section: 0))
        if let staticHeaderSize = delegate?.collapseCollectionView?(collectionView, layout: self, sizeForStaticHeaderAt: IndexPath(item: 0, section: 0)) {
            prepareElement(size: staticHeaderSize, type: .staticHeader, attributes: staticHeaderAttributes)
        } else {
            prepareElement(size: CGSize(width: collectionView.bounds.width, height: 0), type: .staticHeader, attributes: staticHeaderAttributes)
        }
        
        let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.header.kind,
                                                                with: IndexPath(item: 0, section: 0))
        prepareElement(size: settings.headerSize, type: .header, attributes: headerAttributes)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let cellIndexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
            let size = CGSize(width: collectionView.bounds.width,
                              height: collectionView.bounds.height - settings.headerMinimumHeight)
            prepareElement(size: size, type: .cell, attributes: attributes)
        }
        
    }
    
    // MARK: - Invalidation
    override func shouldInvalidateLayout (forBoundsChange newBounds : CGRect) -> Bool {
//        if oldBounds.size != newBounds.size {
//            cache.removeAll(keepingCapacity: true)
//        }
        return true
    }
    
}


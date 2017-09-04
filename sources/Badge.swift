//
//  Badge.swift
//  PageTabBarControllerExample
//
//  Created by Mingloan Chan on 9/5/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

//
//  Badge.swift
//  chaatz
//
//  Created by Mingloan Chan on 1/4/2016.
//  Copyright © 2016 Chaatz. All rights reserved.
//

import Foundation
import UIKit

final class Badge: UIView {
    
    enum BadgeType {
        case number
    }
    
    var badgeBorderWidth: CGFloat = 0 {
        didSet {
            guard oldValue != badgeBorderWidth else { return }
            layer.borderWidth = badgeBorderWidth
            setNeedsDisplay()
        }
    }
    
    var badgeBorderColor: UIColor = UIColor.white {
        didSet {
            guard oldValue != badgeBorderColor else { return }
            layer.borderColor = badgeBorderColor.cgColor
            setNeedsDisplay()
        }
    }
    
    var badgeFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            guard oldValue != badgeFont else { return }
            innerLabel.font = badgeFont
            adjustCornerRadius()
            setNeedsDisplay()
        }
    }
    
    var badgeTintColor: UIColor = UIColor.red {
        didSet {
            guard oldValue != badgeTintColor else { return }
            layer.backgroundColor = badgeTintColor.cgColor
            setNeedsDisplay()
        }
    }
    
    var badgeTextColor: UIColor = UIColor.white {
        didSet {
            guard oldValue != badgeTextColor else { return }
            innerLabel.textColor = badgeTextColor
            setNeedsDisplay()
        }
    }
    
    var badgeValue: Int = 0 {
        didSet {
            guard oldValue != badgeValue else { return }
            switch badgeType {
            case .number:
                innerLabel.text = String(badgeValue)
                isHidden = badgeValue == 0
                adjustCornerRadius()
                setNeedsDisplay()
                break
            }
        }
    }
    
    var insets: UIEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5) {
        didSet {
            guard oldValue != insets else { return }
            
            insetTopConstaint?.constant = insets.top
            insetLeftConstaint?.constant = insets.left
            insetBottomConstaint?.constant = -insets.bottom
            insetRIghtConstaint?.constant = -insets.right
            
            setNeedsUpdateConstraints()
            layoutIfNeeded()
            adjustCornerRadius()
        }
    }
    
    var badgeType: BadgeType = .number
    
    fileprivate let innerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    init(type: BadgeType) {
        badgeType = type
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override var intrinsicContentSize : CGSize {
        return bounds.size
    }
    
    override func forBaselineLayout() -> UIView {
        return innerLabel
    }
    
    override var forFirstBaselineLayout: UIView {
        return innerLabel
    }
    
    override var forLastBaselineLayout: UIView {
        return innerLabel
    }
    
    fileprivate var insetTopConstaint: NSLayoutConstraint?
    fileprivate var insetLeftConstaint: NSLayoutConstraint?
    fileprivate var insetBottomConstaint: NSLayoutConstraint?
    fileprivate var insetRIghtConstaint: NSLayoutConstraint?
    
    fileprivate func commonInit() {
        layer.backgroundColor = badgeTintColor.cgColor
        innerLabel.textColor = badgeTextColor
        innerLabel.font = badgeFont
        layer.masksToBounds = true
        layer.borderWidth = badgeBorderWidth
        layer.borderColor = badgeBorderColor.cgColor
        isHidden = true
        
        bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        addSubview(innerLabel)
        innerLabel.translatesAutoresizingMaskIntoConstraints = false
        innerLabel.widthAnchor.constraint(greaterThanOrEqualTo: innerLabel.heightAnchor, multiplier: 1.0)
        
        insetTopConstaint = innerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3)
        insetLeftConstaint = innerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5)
        insetBottomConstaint = innerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
        insetRIghtConstaint = innerLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5)
        
        insetTopConstaint?.isActive = true
        insetLeftConstaint?.isActive = true
        insetBottomConstaint?.isActive = true
        insetRIghtConstaint?.isActive = true
        
        switch badgeType {
        case .number:
            innerLabel.text = String(0)
            adjustCornerRadius()
            break
        }
    }
    
    fileprivate func adjustCornerRadius() {
        let attriStr = NSAttributedString(string: innerLabel.text ?? "0", attributes: [NSFontAttributeName: innerLabel.font])
        let size = attriStr.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
        var viewSize = CGSize(width: ceil(size.width) + insets.left + insets.right, height: ceil(size.height) + insets.top + insets.bottom)
        
        if viewSize.width < viewSize.height {
            viewSize = CGSize(width: viewSize.height, height: viewSize.height)
        }
        
        layer.cornerRadius = viewSize.height/2
        bounds = CGRect(origin: CGPoint.zero, size: viewSize)
    }
    
}


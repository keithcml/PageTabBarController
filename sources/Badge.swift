//
//  Badge.swift
//  PageTabBarControllerExample
//
//  Created by Mingloan Chan on 9/5/17.
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

//
//  Badge.swift
//  chaatz
//
//  Created by Mingloan Chan on 1/4/2016.
//  Copyright © 2016 Chaatz. All rights reserved.
//

import Foundation
import UIKit

open class Badge: UIView {
    
    public enum BadgeType {
        case number
    }
    
    open var badgeBorderWidth: CGFloat = 0 {
        didSet {
            guard oldValue != badgeBorderWidth else { return }
            layer.borderWidth = badgeBorderWidth
            setNeedsDisplay()
        }
    }
    
    open var badgeBorderColor: UIColor = UIColor.white {
        didSet {
            guard oldValue != badgeBorderColor else { return }
            layer.borderColor = badgeBorderColor.cgColor
            setNeedsDisplay()
        }
    }
    
    open var badgeFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            guard oldValue != badgeFont else { return }
            innerLabel.font = badgeFont
            adjustCornerRadius()
            setNeedsDisplay()
        }
    }
    
    open var badgeTintColor: UIColor = UIColor.red {
        didSet {
            guard oldValue != badgeTintColor else { return }
            layer.backgroundColor = badgeTintColor.cgColor
            setNeedsDisplay()
        }
    }
    
    open var badgeTextColor: UIColor = UIColor.white {
        didSet {
            guard oldValue != badgeTextColor else { return }
            innerLabel.textColor = badgeTextColor
            setNeedsDisplay()
        }
    }
    
    open var badgeValue: Int = 0 {
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
    
    open var insets: UIEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5) {
        didSet {
            guard oldValue != insets else { return }
            
            insetTopConstaint?.constant = insets.top
            insetLeftConstaint?.constant = insets.left
            insetBottomConstaint?.constant = -insets.bottom
            insetRightConstaint?.constant = -insets.right
            
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
    
    public init(type: BadgeType) {
        badgeType = type
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override open var intrinsicContentSize : CGSize {
        return bounds.size
    }
    
    override open func forBaselineLayout() -> UIView {
        return innerLabel
    }
    
    override open var forFirstBaselineLayout: UIView {
        return innerLabel
    }
    
    override open var forLastBaselineLayout: UIView {
        return innerLabel
    }
    
    fileprivate var insetTopConstaint: NSLayoutConstraint?
    fileprivate var insetLeftConstaint: NSLayoutConstraint?
    fileprivate var insetBottomConstaint: NSLayoutConstraint?
    fileprivate var insetRightConstaint: NSLayoutConstraint?
    
    fileprivate func commonInit() {
        
        isUserInteractionEnabled = false
        
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
        insetRightConstaint = innerLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5)
        
        insetTopConstaint?.isActive = true
        insetLeftConstaint?.isActive = true
        insetBottomConstaint?.isActive = true
        insetRightConstaint?.isActive = true
        
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


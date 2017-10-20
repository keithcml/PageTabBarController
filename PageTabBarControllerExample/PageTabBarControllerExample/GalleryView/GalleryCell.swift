//
//  GalleryCell.swift
//  real-v2-ios
//
//  Created by Mingloan Chan on 9/23/17.
//  Copyright © 2017 Real. All rights reserved.
//

import Foundation
import UIKit

final class GalleryCell: UICollectionViewCell {
    
    private(set) var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        imageView.frame = contentView.bounds
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
}

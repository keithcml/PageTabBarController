//
//  PresentedViewController.swift
//  PageTabBarControllerExample
//
//  Created by Mingloan Chan on 9/8/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

class PresentedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
}

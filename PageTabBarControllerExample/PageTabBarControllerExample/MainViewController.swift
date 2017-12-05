//
//  MainViewController.swift
//  PageTabBarControllerExample
//
//  Created by Mingloan Chan on 12/6/17.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    
    @IBAction func tap(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

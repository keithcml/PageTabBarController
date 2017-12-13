//
//  TableViewController.swift
//  PageTabBarControllerExample
//
//  Created by Keith Chan on 5/9/2017.
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
import PageTabBarController

final class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override var prefersStatusBarHidden: Bool {
        if view.tag == 5 {
            return true
        }
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if view.tag % 2 == 0 {
            return .lightContent
        }
        return .default
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: view.frame, style: .plain)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("viewWillAppear \(view.tag)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("viewDidAppear \(view.tag)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //print("viewWillDisappear \(view.tag)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //print("viewDidDisappear \(view.tag)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = "Cell"
        cell?.contentView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let presentedViewController = PresentedViewController(nibName: nil, bundle: nil)
        present(presentedViewController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if #available(iOS 11.0, *) {
//            print(view.safeAreaInsets)
//            print(scrollView.safeAreaInsets)
//            print(scrollView.adjustedContentInset)
//        }
        parallaxHeaderPageTabBarController?.childScrollViewDidScroll(scrollView)
    }
}

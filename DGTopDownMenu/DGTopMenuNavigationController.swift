//
//  DGTopMenuNavigationController.swift
//  DGTopDownMenu
//
//  Created by Diwakar Garg on 24/08/17.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//


import UIKit

open class DGTopMenuNavigationController: UINavigationController, DGTopMenuProtocol {
    
    open var topMenu : DGTopMenu?
    open var topMenuAnimationType : DGTopMenuAnimation = .default
    
    
    // MARK: - Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public init( menuViewController: UIViewController, contentViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        
        if (contentViewController != nil) {
            self.viewControllers = [contentViewController!]
        }
        
        topMenu = DGTopMenu(sourceView: self.view, menuViewController: menuViewController, menuPosition:.top)
        view.bringSubview(toFront: navigationBar)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    open func setContentViewController(_ contentViewController: UIViewController) {
        self.topMenu?.toggleMenu()
        switch topMenuAnimationType {
        case .none:
            self.viewControllers = [contentViewController]
            break
        default:
            contentViewController.navigationItem.hidesBackButton = true
            self.setViewControllers([contentViewController], animated: true)
            break
        }
        
    }
    
}

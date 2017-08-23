//
//  ViewController.swift
//  DGTopDownMenu
//
//  Created by Diwakar Garg on 24/08/17.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DGTopMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topMenuController()?.topMenu?.delegate = self
        self.loadNavBar()
        // Do any additional setup after loading the view.
    }
    func loadNavBar()
    {
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 60))
        let menuButton = UIButton.init(type: .custom)
        menuButton.setBackgroundImage(UIImage(named: "Menu-w"), for: .normal)
        menuButton.frame = CGRect(x: 0.0, y: 5.0, width: 30.0, height: 30.0)
        menuButton.center.y = customView.center.y
        menuButton.addTarget(self, action: #selector(menuButtonAction), for: .touchUpInside)
        customView.addSubview(menuButton)
        
        let marginX = CGFloat(menuButton.frame.origin.x + menuButton.frame.size.width + 15)
        let label = UILabel(frame: CGRect(x: marginX, y: 0.0, width: self.view.frame.width - marginX, height: customView.frame.height))
        label.text = "BaseView"
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.left
        label.center.y = customView.center.y
        //label.backgroundColor = UIColor.red
        customView.addSubview(label)
        let leftButton = UIBarButtonItem(customView: customView)
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    //Navigation Button Click function
    func menuButtonAction()
    {
        //Toggel of View
        toggleTopMenuView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleSideMenuBtn(_ sender: UIBarButtonItem) {
        toggleTopMenuView()
    }
    
    // MARK: - DGTopMenu Delegate
    func topMenuWillOpen() {
        print("topMenuWillOpen")
    }
    
    func topMenuWillClose() {
        print("topMenuWillClose")
    }
    
    func topMenuShouldOpenTopDownMenu() -> Bool {
        print("topMenuShouldOpenTopDownMenu")
        return true
    }
    
    func topMenuDidClose() {
        print("topMenuDidClose")
    }
    
    func topMenuDidOpen() {
        print("topMenuDidOpen")
    }

}

//
//  CustomNavigationViewController.swift
//  DGTopDownMenu
//
//  Created by Diwakar Garg on 24/08/17.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit

class CustomNavigationViewController: DGTopMenuNavigationController,DGTopMenuDelegate
{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topMenu = DGTopMenu(sourceView: self.view, menuViewController:TopMenuTableViewController(), menuPosition: .top)
        //topMenu?.delegate = self //optional
        topMenu?.menuWidth = self.view.frame.width// optional, default is 160
        topMenu?.menuHight = 220 // optional, default is 160
        //topMenu?.bouncingEnabled = false
        //topMenu?.bouncingEnabled = false
        //topMenu?.allowPanGesture = false
        // make navigation bar showing over top menu
        view.bringSubview(toFront: navigationBar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func topMenuWillOpen() {
        print("topNaviagtionMenuWillOpen")
    }
    
    func topMenuWillClose() {
        print("topNaviagtionMenuWillClose")
    }
    
    func topMenuDidClose() {
        print("topNaviagtionMenuDidClose")
    }
    
    func topMenuDidOpen() {
        print("topNaviagtionMenuDidOpen")
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

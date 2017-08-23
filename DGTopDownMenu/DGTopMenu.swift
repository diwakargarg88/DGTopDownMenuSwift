//
//  DGTopMenu.swift
//  DGTopDownMenu
//
//  Created by Diwakar Garg on 24/08/17.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit

@objc public protocol DGTopMenuDelegate {
    @objc optional func topMenuWillOpen()
    @objc optional func topMenuWillClose()
    @objc optional func topMenuDidOpen()
    @objc optional func topMenuDidClose()
    @objc optional func topMenuShouldOpenTopDownMenu () -> Bool
}

@objc public protocol DGTopMenuProtocol {
    var topMenu : DGTopMenu? { get }
    func setContentViewController(_ contentViewController: UIViewController)
}

public enum DGTopMenuAnimation : Int {
    case none
    case `default`
}
/**
 The position of the top slide view on the screen.
 
 - Top:  Top side of the screen
 */
public enum DGTopMenuPosition : Int {
    case top
}

public extension UIViewController {
    /**
     Changes current state of top menu view.
     */
    public func toggleTopMenuView () {
        topMenuController()?.topMenu?.toggleMenu()
    }
    /**
     Hides the top menu view.
     */
    public func hideTopMenuView () {
        topMenuController()?.topMenu?.hideTopMenu()
    }
    /**
     Shows the top menu view.
     */
    public func showSideMenuView () {
        
        topMenuController()?.topMenu?.showTopMenu()
    }
    
    /**
     Returns a Boolean value indicating whether the top menu is showed.
     
     :returns: BOOL value
     */
    public func isTopMenuOpen () -> Bool {
        let topMenuOpen = self.topMenuController()?.topMenu?.isMenuOpen
        return topMenuOpen!
    }
    
    /**
     * You must call this method from viewDidLayoutSubviews in your content view controlers so it fixes size and position of the top menu when the screen
     * rotates.
     * A convenient way to do it might be creating a subclass of UIViewController that does precisely that and then subclassing your view controllers from it.
     */
    func fixTopMenuSize() {
        if let navController = self.navigationController as? DGTopMenuNavigationController {
            navController.topMenu?.updateFrame()
        }
    }
    /**
     Returns a view controller containing a top menu
     
     :returns: A `UIViewController`responding to `DGTopMenuProtocol` protocol
     */
    public func topMenuController () -> DGTopMenuProtocol? {
        var iteration : UIViewController? = self.parent
        if (iteration == nil) {
            return topMostController()
        }
        repeat {
            if (iteration is DGTopMenuProtocol) {
                return iteration as? DGTopMenuProtocol
            } else if (iteration?.parent != nil && iteration?.parent != iteration) {
                iteration = iteration!.parent
            } else {
                iteration = nil
            }
        } while (iteration != nil)
        
        return iteration as? DGTopMenuProtocol
    }
    
    internal func topMostController () -> DGTopMenuProtocol? {
        var topController : UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        if (topController is UITabBarController) {
            topController = (topController as! UITabBarController).selectedViewController
        }
        var lastMenuProtocol : DGTopMenuProtocol?
        while (topController?.presentedViewController != nil) {
            if(topController?.presentedViewController is DGTopMenuProtocol) {
                lastMenuProtocol = topController?.presentedViewController as? DGTopMenuProtocol
            }
            topController = topController?.presentedViewController
        }
        
        if (lastMenuProtocol != nil) {
            return lastMenuProtocol
        }
        else {
            return topController as? DGTopMenuProtocol
        }
    }
}

open class DGTopMenu : NSObject, UIGestureRecognizerDelegate {
    /// The width of the top menu view. The default value is 160.
    open var menuWidth : CGFloat = 160.0 {
        didSet {
            needUpdateApperance = true
            updateTopMenuApperanceIfNeeded()
            updateFrame()
        }
    }
    /// The height of the top menu view. The default value is 160.
    open var menuHight : CGFloat = 160.0 {
        didSet {
            needUpdateApperance = true
            updateTopMenuApperanceIfNeeded()
            updateFrame()
        }
    }
    fileprivate var menuPosition:DGTopMenuPosition = .top
    fileprivate var blurStyle: UIBlurEffectStyle = .light
    ///  A Boolean value indicating whether the bouncing effect is enabled. The default value is TRUE.
    open var bouncingEnabled :Bool = true
    /// The duration of the top slide animation. Used only when `bouncingEnabled` is FALSE.
    open var animationDuration = 0.7
    fileprivate let topMenuContainerView =  UIView()
    fileprivate(set) var menuViewController : UIViewController!
    fileprivate var animator : UIDynamicAnimator!
    fileprivate var sourceView : UIView!
    fileprivate var needUpdateApperance : Bool = false
    /// The delegate of the top menu
    open weak var delegate : DGTopMenuDelegate?
    fileprivate(set) var isMenuOpen : Bool = false
    /// A Boolean value indicating whether the up swipe is enabled.
    open var allowUpSwipe : Bool = true
    /// A Boolean value indicating whether the down swipe is enabled.
    open var allowDownSwipe : Bool = true
    // A Boolean value indicating whether the pan gesture is enabled.
    open var allowPanGesture : Bool = true
    fileprivate var panRecognizer : UIPanGestureRecognizer?
    
    /**
     Initializes an instance of a `DGTopMenu` object.
     
     :param: sourceView   The parent view of the side menu view.
     :param: menuPosition The position of the side menu view.
     
     :returns: An initialized `DGTopMenu` object, added to the specified view.
     */
    public init(sourceView: UIView, menuPosition: DGTopMenuPosition, blurStyle: UIBlurEffectStyle = .light) {
        super.init()
        self.sourceView = sourceView
        self.menuPosition = menuPosition
        self.blurStyle = blurStyle
        self.setupMenuView()
        
        animator = UIDynamicAnimator(referenceView:sourceView)
        animator.delegate = self
        
        self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DGTopMenu.handlePan(_:)))
        panRecognizer!.delegate = self
        sourceView.addGestureRecognizer(panRecognizer!)
        
        // Add down swipe gesture recognizer
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DGTopMenu.handleGesture(_:)))
        downSwipeGestureRecognizer.delegate = self
        downSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.down
        // Add up swipe gesture recognizer
        let upSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DGTopMenu.handleGesture(_:)))
        upSwipeGestureRecognizer.delegate = self
        upSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.up

        sourceView.addGestureRecognizer(downSwipeGestureRecognizer)
        sourceView.addGestureRecognizer(upSwipeGestureRecognizer)
        
        
    }
    /**
     Initializes an instance of a `DGTopMenu` object.
     
     :param: sourceView         The parent view of the top menu view.
     :param: menuViewController A menu view controller object which will be placed in the top menu view.
     :param: menuPosition       The position of the top menu view.
     
     :returns: An initialized `DGTopMenu` object, added to the specified view, containing the specified menu view controller.
     */
    public convenience init(sourceView: UIView, menuViewController: UIViewController, menuPosition: DGTopMenuPosition, blurStyle: UIBlurEffectStyle = .light) {
        self.init(sourceView: sourceView, menuPosition: menuPosition, blurStyle: blurStyle)
        self.menuViewController = menuViewController
        self.menuViewController.view.frame = topMenuContainerView.bounds
        self.menuViewController.view.autoresizingMask =  [.flexibleHeight, .flexibleWidth]
        topMenuContainerView.addSubview(self.menuViewController.view)
    }
    /*
     public convenience init(sourceView: UIView, view: UIView, menuPosition: DGTopMenuPosition) {
     self.init(sourceView: sourceView, menuPosition: menuPosition)
     view.frame = topMenuContainerView.bounds
     view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
     topMenuContainerView.addSubview(view)
     }
     */
    /**
     Updates the frame of the top menu view.
     */
    func updateFrame() {
        var width:CGFloat
        var height:CGFloat
        (width, height) = adjustFrameDimensions( sourceView.frame.size.width, height: sourceView.frame.size.height)
        let menuFrame = CGRect(
            x:sourceView.frame.origin.x ,
            y:(menuPosition == .top) ?
                isMenuOpen ? 0 : -menuHight-1.0 :
                isMenuOpen ? height - menuHight : height+1.0 ,
            width: menuWidth,
            height: menuHight
        )
        topMenuContainerView.frame = menuFrame
    }
    
    fileprivate func adjustFrameDimensions( _ width: CGFloat, height: CGFloat ) -> (CGFloat,CGFloat) {
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 &&
            (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight ||
                UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft) {
            // iOS 7.1 or lower and landscape mode -> interchange width and height
            return (height, width)
        }
        else {
            return (width, height)
        }
        
    }
    
    fileprivate func setupMenuView() {
        
        // Configure top menu container
        updateFrame()
        
        topMenuContainerView.backgroundColor = UIColor.clear
        topMenuContainerView.clipsToBounds = false
        topMenuContainerView.layer.masksToBounds = false
        topMenuContainerView.layer.shadowOffset = (menuPosition == .top) ? CGSize(width: 1.0, height: 1.0) : CGSize(width: -1.0, height: -1.0)
        topMenuContainerView.layer.shadowRadius = 1.0
        topMenuContainerView.layer.shadowOpacity = 0.125
        topMenuContainerView.layer.shadowPath = UIBezierPath(rect: topMenuContainerView.bounds).cgPath
        
        sourceView.addSubview(topMenuContainerView)
        
        if (NSClassFromString("UIVisualEffectView") != nil) {
            // Add blur view
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle)) as UIVisualEffectView
            visualEffectView.frame = topMenuContainerView.bounds
            visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            topMenuContainerView.addSubview(visualEffectView)
        }
        else {
            // TODO: add blur for ios 7
        }
    }
    
    fileprivate func toggleMenu (_ shouldOpen: Bool) {
        //If you want to disable the toggle effect on topMenuShouldOpenTopDownMenu just un comment below code and send the return false from delegate method topMenuShouldOpenTopDownMenu from view controller.
        //Also connected with swipe gesture so comment out the same code below in gesture handling method so both are stop working.
//        if (shouldOpen && delegate?.topMenuShouldOpenTopDownMenu?() == false) {
//            return
//        }
        updateTopMenuApperanceIfNeeded()
        isMenuOpen = shouldOpen
        var width:CGFloat
        var height:CGFloat
        (width, height) = adjustFrameDimensions( sourceView.frame.size.width, height: sourceView.frame.size.height)
        if (bouncingEnabled) {
            
            var destFrame :CGRect
            
                destFrame = CGRect(x:0, y:  (shouldOpen) ? -2.0 : -menuHight, width: menuWidth, height: menuHight)
            
            UIView.animate(withDuration: animationDuration, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 15, options: .curveEaseInOut, animations: {
                self.topMenuContainerView.frame = destFrame
            },
                           completion: { (Bool) -> Void in
                            if (self.isMenuOpen) {
                                self.delegate?.topMenuDidOpen?()
                            } else {
                                self.delegate?.topMenuDidClose?()
                            }
            })
            
        }
        else {
            var destFrame :CGRect
           
                destFrame = CGRect(x:0, y:  (shouldOpen) ? -2.0 : -menuHight, width: menuWidth, height: menuHight)
            
            UIView.animate(
                withDuration: animationDuration,
                animations: { () -> Void in
                    self.topMenuContainerView.frame = destFrame
            },
                completion: { (Bool) -> Void in
                    if (self.isMenuOpen) {
                        self.delegate?.topMenuDidOpen?()
                    } else {
                        self.delegate?.topMenuDidClose?()
                    }
            })
        }
        
        if (shouldOpen) {
            delegate?.topMenuWillOpen?()
        } else {
            delegate?.topMenuWillClose?()
        }
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
       
        
        if gestureRecognizer is UISwipeGestureRecognizer {
            //By pass the gesture Action by sending false value of topMenuShouldOpenTopDownMenu from view controller or if you want to remove just comment out below three lines.
            if delegate?.topMenuShouldOpenTopDownMenu?() == false {
                return false
            }
            
            let swipeGestureRecognizer = gestureRecognizer as! UISwipeGestureRecognizer
            if !self.allowUpSwipe {
                if swipeGestureRecognizer.direction == .up {
                    return false
                }
            }
            
            if !self.allowDownSwipe {
                if swipeGestureRecognizer.direction == .down {
                    return false
                }
            }
        }
        else if gestureRecognizer.isEqual(panRecognizer) {
            if allowPanGesture == false {
                return false
            }
            animator.removeAllBehaviors()
            let touchPosition = gestureRecognizer.location(ofTouch: 0, in: sourceView)
            if menuPosition == .top {
                if isMenuOpen {
                    if touchPosition.y < menuHight {
                        return true
                    }
                }
                else {
                    if touchPosition.y < 25 {
                        return true
                    }
                }
            }
            
            return false
        }
        return true
    }
    
    internal func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        toggleMenu(self.menuPosition == .top && gesture.direction == .down)
    }
    
    internal func handlePan(_ recognizer : UIPanGestureRecognizer){
        
        let topToBottom = recognizer.velocity(in: recognizer.view).x > 0
        
        switch recognizer.state {
        case .began:
            
            break
            
        case .changed:
            
            let translation = recognizer.translation(in: sourceView).x
            let xPoint : CGFloat = topMenuContainerView.center.y + translation + (menuPosition == .top ? 1 : -1) * menuHight / 2
            
            if menuPosition == .top {
                if xPoint <= 0 || xPoint > self.topMenuContainerView.frame.height {
                    return
                }
            }
            
            topMenuContainerView.center.y = topMenuContainerView.center.y + translation
            recognizer.setTranslation(CGPoint.zero, in: sourceView)
            
        default:
            
            let shouldClose = menuPosition == .top ? !topToBottom && topMenuContainerView.frame.maxY < menuHight : topToBottom && topMenuContainerView.frame.minY >  (sourceView.frame.size.height - menuHight)
            
            toggleMenu(!shouldClose)
            
        }
    }
    
    fileprivate func updateTopMenuApperanceIfNeeded () {
        if (needUpdateApperance) {
            var frame = topMenuContainerView.frame
            frame.size.width = menuWidth
            frame.size.height = menuHight
            topMenuContainerView.frame = frame
            topMenuContainerView.layer.shadowPath = UIBezierPath(rect: topMenuContainerView.bounds).cgPath
            
            needUpdateApperance = false
        }
    }
    
    /**
     Toggles the state of the top menu.
     */
    open func toggleMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
        else {
            updateTopMenuApperanceIfNeeded()
            toggleMenu(true)
        }
    }
    /**
     Shows the top menu if the menu is hidden.
     */
    open func showTopMenu () {
        if (!isMenuOpen) {
            toggleMenu(true)
        }
    }
    /**
     Hides the top menu if the menu is showed.
     */
    open func hideTopMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
    }
}

extension DGTopMenu: UIDynamicAnimatorDelegate {
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if (self.isMenuOpen) {
            self.delegate?.topMenuDidOpen?()
        } else {
            self.delegate?.topMenuDidClose?()
        }
    }
}

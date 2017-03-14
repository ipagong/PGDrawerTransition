//
//  DrawerTransition.swift
//  PGDrawerExample
//
//  Created by ipagong on 2017. 3. 13..
//  Copyright © 2017년 suwan. All rights reserved.
//

import UIKit

public typealias DrawerVoidBlock = () -> ()

@objc
public protocol DrawerTransitionDelegate:NSObjectProtocol {
    @objc optional func canPresentWith(transition:DrawerTransition) -> Bool
    @objc optional func canDismissWith(transition:DrawerTransition) -> Bool
}

@objc
public class DrawerTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    
    public var enablePresent:Bool = true
    public var enableDismiss:Bool = true
    
    public var hasDismissView:Bool = true
    
    public var dismissViewAlpha:CGFloat = 0.6
    public var drawerWidth:CGFloat = 0
    
    public var presentDuration:TimeInterval = 0.3
    public var dismissDuration:TimeInterval = 0.3
    
    public weak var drawerDelegate:DrawerTransitionDelegate?
    
    public weak var drawer:UIViewController? {
        willSet {
            guard self.isPresentedDrawer == false else { return }
            guard self.drawer?.view.gestureRecognizers?.contains(self.drawerViewGesture) == true else { return }
            self.drawer?.view.removeGestureRecognizer(self.drawerViewGesture)
        }
        
        didSet {
            guard self.isPresentedDrawer == false else {
                self.drawer = oldValue
                return
            }
            self.drawer?.view.addGestureRecognizer(self.drawerViewGesture)
        }
    }
    
    public weak var target:UIViewController!
    
    private var presentBlock:DrawerVoidBlock?
    private var dismissBlock:DrawerVoidBlock?
    
    private var current:UIViewController?
    private var isAnimated:Bool = false
    private var hasInteraction:Bool = false
    private var beganPanPoint:CGPoint = .zero
    private var isPresentedDrawer:Bool {
        guard let currentVc = self.current, currentVc != target else { return false }
        return true
    }
    
    private var drawerPresentationStyle:UIModalPresentationStyle { return .custom }
    
    private var canPresent:Bool { return self.drawerDelegate?.canPresentWith?(transition: self) ?? true }
    private var canDismiss:Bool { return self.drawerDelegate?.canDismissWith?(transition: self) ?? true }
    
    private var dismissRect:CGRect {
        guard let window = self.target.view.window else { return .zero }
        return CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
    }
    
    @objc
    init(target:UIViewController!) {
        super.init()
        
        self.target = target
        target.view.addGestureRecognizer(self.mainViewGesutre)
    }
    
    @objc
    init(target:UIViewController!, drawer:UIViewController!) {
        super.init()
        
        self.target = target
        target.view.addGestureRecognizer(self.mainViewGesutre)
        
        self.drawer = drawer
        drawer.view.addGestureRecognizer(self.drawerViewGesture)
    }
    
    //MARK: - lazy properties
    
    lazy public var innerButton:UIButton = {
        let innerButton = UIButton(type: .custom)
        innerButton.backgroundColor = .clear
        innerButton.addTarget(self, action: #selector(onClickDismiss), for: .touchUpInside)
        innerButton.frame = self.dismissRect
        return innerButton
    }()
    
    lazy public var dismissButton:UIButton = {
        let dismissButton = UIButton(type: .custom)
        dismissButton.backgroundColor = .clear
        dismissButton.addTarget(self, action: #selector(onClickDismiss), for: .touchUpInside)
        dismissButton.frame = self.dismissRect
        return dismissButton
    }()
    
    lazy public var dismissBg:UIView = {
        let dismissBg = UIView(frame: .zero)
        dismissBg.backgroundColor = .black
        dismissBg.alpha = 0
        return dismissBg
    }()
    
    lazy private var mainViewGesutre:UIScreenEdgePanGestureRecognizer = {
        let gesutre = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(onMainGesture(_:)))
        gesutre.edges = .left
        return gesutre
    }()
    
    lazy private var drawerViewGesture:UIPanGestureRecognizer = {
        let gesutre = UIPanGestureRecognizer(target: self, action: #selector(onDrawerGesture(_:)))
        gesutre.delegate = self
        return gesutre
    }()
    
    
    //MARK: - action methods
    
    func onMainGesture(_ recognizer:UIPanGestureRecognizer) {
        guard let drawer = self.drawer else   { return }
        guard isAnimated == false else        { return }
        guard canPresent == true else         { return }
        guard enablePresent     == true  else { return }
        guard isPresentedDrawer == false else { return }
        
        guard let window = self.target.view.window else { return }
        
        let location = recognizer.location(in: window)
        let velocity = recognizer.velocity(in: self.target.view.window)
        
        switch recognizer.state {
        case .began:
            self.hasInteraction = true
            self.presentDrawerAction()
            
        case .changed:
            self.update(location.x / window.bounds.width)
            
        case .ended:
            guard self.hasInteraction == true else {
                self.isAnimated = false
                return
            }
            
            self.isAnimated = true
            
            if (velocity.x > 0) {
                self.finish()
                self.current = self.target
            } else {
                self.cancel()
                self.current = drawer
            }
            
            self.hasInteraction = false
            
        default:
            break
        }
        
    }
    
    func onDrawerGesture(_ recognizer:UIScreenEdgePanGestureRecognizer) {
        guard let drawer = self.drawer  else { return }
        guard isAnimated == false       else { return }
        guard canPresent == true        else { return }
        guard enablePresent == true     else { return }
        guard isPresentedDrawer == true else { return }
        
        guard let window = drawer.view.window else { return }
        
        let location = recognizer.location(in: window)
        let velocity = recognizer.velocity(in: window)
        
        switch recognizer.state {
        case .began:
            self.beganPanPoint = location
            self.hasInteraction = true
            self.dismissDrawerAction()
            
        case .changed:
            self.update(max(0, beganPanPoint.x - location.x)/drawer.view.bounds.width)
            
        case .ended:
            guard hasInteraction == true else {
                self.isAnimated = false
                return
            }
            
            self.isAnimated = true
            
            if (velocity.x < 0) {
                self.finish()
                self.current = self.target
            } else {
                self.cancel()
                self.current = self.drawer
            }
            
            self.hasInteraction = false
            
        default:
            break
        }
    }
    
    func onClickDismiss() {
        guard hasDismissView == true    else { return }
        guard isPresentedDrawer == true else { return }
        
        dismissDrawerViewController(animated: true)
    }
    
    //MARK: - private methods
    
    private func addDismissView(target:UIViewController, drawer:UIViewController, container:UIView) {
        guard hasDismissView == true else { return }
        guard self.target != nil     else { return }
        
        self.removeDismissView()
        
        dismissButton.frame = CGRect(x: 0, y: 0, width: target.view.frame.width, height: target.view.frame.height)
        dismissBg.frame     = CGRect(x: 0, y: 0, width: target.view.frame.width, height: target.view.frame.height)
        innerButton.frame   = CGRect(x: drawer.view.frame.width,
                                     y: 0,
                                     width:  target.view.frame.width - drawer.view.frame.width,
                                     height: target.view.frame.height)
        
        container.addSubview(self.dismissBg)
        container.addSubview(self.dismissButton)
        target.view.addSubview(self.innerButton)
        
        container.bringSubview(toFront: drawer.view)
    }
    
    private func removeDismissView() {
        guard self.dismissButton.superview != nil else { return }
        
        self.dismissButton.removeFromSuperview()
        self.dismissBg.removeFromSuperview()
        self.innerButton.removeFromSuperview()
    }
    
    private func presentDrawerAction() {
        guard let drawer = self.drawer else { return }
        guard canPresent == true       else { return }
        guard enablePresent == true    else { return }
        guard percentComplete == 0     else { return }
        
        drawer.modalPresentationStyle = self.drawerPresentationStyle
        drawer.transitioningDelegate  = self
        
        self.target.present(drawer, animated: true, completion: nil)
    }
    
    private func dismissDrawerAction() {
        guard let drawer = self.drawer else { return }
        guard canDismiss == true       else { return }
        guard enableDismiss == true    else { return }
        guard percentComplete == 0     else { return }
        
        drawer.dismiss(animated: true, completion: nil)
    }
    
    private func presentAnimation(from:UIViewController, to:UIViewController, container:UIView, context: UIViewControllerContextTransitioning) {
        container.addSubview(to.view)
        container.frame = from.view.frame
        
        var sourceRect = from.view.window?.bounds ?? from.view.bounds
        sourceRect.size.width = (self.drawerWidth == 0 ? sourceRect.size.width * 0.8 : self.drawerWidth)
        sourceRect.origin.x = -sourceRect.width
        sourceRect.origin.y = 0
        to.view.frame = sourceRect
        
        self.addDismissView(target: from, drawer: to, container: container)
        
        UIView.animate(withDuration: self.transitionDuration(using: context), animations: {
            
            self.dismissBg.alpha = self.dismissViewAlpha
            var toRect = to.view.frame
            toRect.origin.x = 0
            to.view.frame = toRect
            
        }, completion: { _ in
            
            let canceled = context.transitionWasCancelled
            self.isAnimated = false
            to.modalPresentationStyle = self.drawerPresentationStyle
            
            if canceled == true {
                self.current = self.target
                context.completeTransition(false)
                self.removeDismissView()
            } else {
                self.current = self.drawer
                context.completeTransition(true)
                self.presentBlock?()
            }
            
        })
    }
    
    private func dismissAnimation(from:UIViewController, to:UIViewController, container:UIView, context: UIViewControllerContextTransitioning) {
        self.dismissBg.alpha = self.dismissViewAlpha
        
        UIView.animate(withDuration: self.transitionDuration(using: context), animations: {
            
            var rect = from.view.frame
            rect.origin.x = -rect.width
            from.view.frame = rect
            self.dismissBg.alpha = 0
            
        }, completion: { _ in
            
            let canceled = context.transitionWasCancelled
            self.isAnimated = false
            to.modalPresentationStyle = self.drawerPresentationStyle
            
            if canceled == true {
                self.current = self.drawer
                context.completeTransition(false)
                self.addDismissView(target: to, drawer: from, container: container)
            } else {
                self.current = self.target
                context.completeTransition(true)
                self.removeDismissView()
                self.dismissBlock?()
            }
            
        })
        
    }
    
    //MARK: - UIVieControllerTransitioningDelegate methods
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard self.hasInteraction == true else { return nil }
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard self.hasInteraction == true else { return nil }
        return self
    }
    
    //MARK: - UIViewControllerAnimatedTransitioning methods
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresentedDrawer ? dismissDuration : presentDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVc = transitionContext.viewController(forKey: .from) else { return }
        guard let toVc = transitionContext.viewController(forKey: .to)     else { return }
        
        if (toVc === self.drawer) {
            self.presentAnimation(from: fromVc, to: toVc, container: transitionContext.containerView, context: transitionContext)
        } else {
            self.dismissAnimation(from: fromVc, to: toVc, container: transitionContext.containerView, context: transitionContext)
        }
    }
    
    //MARK - gesture delegate methods
    
    private func gestureRecognizerShouldBegin(_ panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard let drawer = self.drawer else { return false }
        let velocity = panGestureRecognizer.velocity(in: drawer.view)
        return fabs(velocity.x) > fabs(velocity.y)
    }
    
    //MARK: - public methods

    @objc
    public func presentDrawerViewController() {
        self.presentDrawerViewController(animated: true, completion: nil)
    }
    
    @objc
    public func presentDrawerViewController(animated:Bool) {
        self.presentDrawerViewController(animated: animated, completion: nil)
    }
    
    @objc
    public func presentDrawerViewController(animated:Bool, completion:DrawerVoidBlock?) {
        guard let drawer = self.drawer   else { return }
        guard canPresent == true         else { return }
        guard isAnimated == false        else { return }
        guard enablePresent == true      else { return }
        guard isPresentedDrawer == false else { return }
        guard percentComplete == 0       else { return }
        
        self.isAnimated = true
        
        drawer.modalPresentationStyle = self.drawerPresentationStyle
        drawer.transitioningDelegate  = self
        
        self.target.present(drawer, animated: animated) { completion?() }
    }
    
    @objc
    public func dismissDrawerViewController() {
        self.presentDrawerViewController(animated: true, completion: nil)
    }
    
    @objc
    public func dismissDrawerViewController(animated:Bool) {
        self.presentDrawerViewController(animated: animated, completion: nil)
    }
    
    @objc
    public func dismissDrawerViewController(animated:Bool, completion:DrawerVoidBlock?) {
        guard let drawer = self.drawer  else { return }
        guard canDismiss == true        else { return }
        guard isAnimated == false       else { return }
        guard enableDismiss == true     else { return }
        guard isPresentedDrawer == true else { return }
        guard percentComplete == 0      else { return }
        
        drawer.modalPresentationStyle = self.drawerPresentationStyle
        drawer.transitioningDelegate  = self
        
        self.isAnimated = true
        
        drawer.dismiss(animated: animated) { completion?() }
    }
    
    @objc public func setPresentCompletion(block:DrawerVoidBlock?) { self.presentBlock = block }
    @objc public func setDismissCompletion(block:DrawerVoidBlock?) { self.dismissBlock = block }
}

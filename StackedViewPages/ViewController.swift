//
//  ViewController.swift
//  StackViewMenuAnimation
//
//  Created by Prateek Sharma on 02/01/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UICollisionBehaviorDelegate{

    let data = ["View Controller : 1","View Controller : 2","View Controller : 3","View Controller : 4","View Controller : 5"]
    
    var views = [UIView]()
    
    var animator : UIDynamicAnimator!
    var gravityAnimator : UIGravityBehavior!
    var snapBehaviour : UISnapBehavior!
    var lastTouchedPoint : CGPoint!
    var isDragging = false
    var isPinned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        animator = UIDynamicAnimator(referenceView: view)
        gravityAnimator = UIGravityBehavior()
        gravityAnimator.magnitude = 4
        animator.addBehavior(gravityAnimator)
        
        var offset : CGFloat = 350
        
        for i in 0..<data.count {
            if let stackedElementView = addViewControllers(atOffset: offset, dataForVC: data[i]){
                views.append(stackedElementView)
                offset = offset - 45
            }
        }
    }
    
    func addViewControllers(atOffset offset: CGFloat, dataForVC : Any?) -> UIView?{
        
        let frameForView = view.bounds.offsetBy(dx: 0, dy: view.bounds.height - offset)
        
//        let frameForView = CGRect(x: 0, y: 100, width: view.frame.width, height: self.view.frame.height)
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let stackElementVC = sb.instantiateViewController(withIdentifier: "stackElementVC") as! StackedElementViewController
        
        if let vcView = stackElementVC.view {
            
            vcView.frame = frameForView
            
            vcView.layer.cornerRadius = 5
            vcView.layer.shadowOffset = CGSize(width: 2, height: 2)
            vcView.layer.shadowColor = UIColor.black.cgColor
            vcView.layer.shadowRadius = 3
            vcView.layer.shadowOpacity = 0.5
            
            if let heading = dataForVC as? String {
                stackElementVC.headerString = heading
            }
        
            self.addChildViewController(stackElementVC)
            self.view.addSubview(vcView)
            stackElementVC.didMove(toParentViewController: self)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            vcView.addGestureRecognizer(panGesture)
            
            let collisionBehaviour = UICollisionBehavior(items: [vcView])
            collisionBehaviour.collisionDelegate = self
            animator.addBehavior(collisionBehaviour)
            collisionBehaviour.addBoundary(withIdentifier: 1 as NSCopying, from: CGPoint(x: 0, y: vcView.frame.maxY), to: CGPoint(x: self.view.frame.width, y: vcView.frame.maxY))
            collisionBehaviour.addBoundary(withIdentifier: 2 as NSCopying, from: CGPoint(x: 0, y: 0), to: CGPoint(x: self.view.frame.width, y: 0))
            
            gravityAnimator.addItem(vcView)
            
            let itemBehaviour = UIDynamicItemBehavior(items: [vcView])
            animator.addBehavior(itemBehaviour)
            
            return vcView
        }
        
        return nil
    }
    
    @objc func handlePan(_ gesture : UIPanGestureRecognizer){
        
        let touchPoint = gesture.location(in: self.view)
        let draggedView = gesture.view
        
        if gesture.state == .began {

            let draggedPoint = gesture.location(in: draggedView)

            if draggedPoint.y < 200 {
                isDragging = true
                lastTouchedPoint = touchPoint
            }
        }
        else if gesture.state == .changed && isDragging{
            let yOffset = lastTouchedPoint.y - touchPoint.y
            draggedView?.center = CGPoint(x: (draggedView?.center.x)!, y: (draggedView?.center.y)! - yOffset)
            lastTouchedPoint = touchPoint
        }
        else if gesture.state == .ended && isDragging {
            
            pin(stackedView: draggedView!)
            setVelocity(draggedView: draggedView!, panVelocity: gesture.velocity(in: self.view))
            
            animator.updateItem(usingCurrentState: draggedView!)
            isDragging = false
        }

    }
    
    func setVelocity(draggedView : UIView , panVelocity : CGPoint) {
        var panVelocity = panVelocity
        
        panVelocity.x = 0
        
        if let behaviour = itemBehaviour(forGesturedView: draggedView) {
            behaviour.addLinearVelocity(panVelocity, for: draggedView)
        }
        
    }
    
    func itemBehaviour(forGesturedView draggedView : UIView) -> UIDynamicItemBehavior?{
        for itemBehaviour in animator.behaviors {
            if let behaviour = itemBehaviour as? UIDynamicItemBehavior {
                if let possibleView = behaviour.items.first as? UIView , possibleView == draggedView {
                    return behaviour
                }
            }
        }
        return nil
    }
    
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        
        if NSNumber(integerLiteral: 2).isEqual(identifier) {
            let view = item as! UIView
            pin(stackedView: view)
        }
    }
    
    
    func pin(stackedView : UIView){
        let viewviewHasReachedPinLocation = stackedView.frame.origin.y < 100
        
        if viewviewHasReachedPinLocation {
            if !isPinned {
                var snapPosition = self.view.center
                snapPosition.y = snapPosition.y + 20
                
                snapBehaviour = UISnapBehavior(item: stackedView, snapTo: snapPosition)
                animator.addBehavior(snapBehaviour)
                
                setVisibility(draggedView: stackedView, alpha: 0)
                
                isPinned = true
            }
        }
        else {
            if isPinned {
                animator.removeBehavior(snapBehaviour)
                isPinned = false
                
                setVisibility(draggedView: stackedView, alpha: 1)
            }
        }
    }
    
    func setVisibility(draggedView : UIView ,alpha : CGFloat) {
        for view in self.views {
            if view != draggedView {
                view.alpha = alpha
            }
        }
    }
}


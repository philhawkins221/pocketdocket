//
//  TransitionManager.swift
//  Docket
//
//  Created by Phil Hawkins on 7/10/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit

enum direction {
    case left
    case right
}

var swipe: direction!


class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    //MARK - UIViewControllerAnimatedTransitioning protocol methods
    
    //animate a change from one viewcontroller to another
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let offScreenRight = CGAffineTransformMakeTranslation(container!.frame.width, 0)
        let offScreenLeft = CGAffineTransformMakeTranslation(-container!.frame.width, 0)
        
        if swipe == direction.left {
            toView.transform = offScreenRight
        } else {
            toView.transform = offScreenLeft
        }
        
        container!.addSubview(toView)
        container!.addSubview(fromView)
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations:  {
                if swipe == direction.left {
                    fromView.transform = offScreenLeft
                } else {
                    fromView.transform = offScreenRight
                }
                toView.transform = CGAffineTransformIdentity
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
        })
        
    }
    
    //return how many seconds the animation will take
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }
    
    //MARK - UIViewControllerTransitioningDelegate protocol methods
    
    //return the animator when presenting a viewcontroller
    //an animator is any object that adheres to the first protocol
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    //return the animator when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
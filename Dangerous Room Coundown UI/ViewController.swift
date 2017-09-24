//
//  ViewController.swift
//  Dangerous Room Coundown UI
//
//  Created by Konstantin on 04/09/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit

fileprivate var circleView: UIView = {
    let gradient = CAGradientLayer()
    let circleDiameter = sqrt(UIScreen.main.bounds.size.height*UIScreen.main.bounds.size.height + UIScreen.main.bounds.size.width*UIScreen.main.bounds.size.width) / 2.0 // 765
    let circleView = UIView(frame: CGRect(origin: UIScreen.main.bounds.origin, size: CGSize(width: circleDiameter * 2, height: circleDiameter * 2)))
    gradient.colors = [UIColor(red:1.00, green:0.78, blue:0.52, alpha:1.0).cgColor, UIColor(red:0.95, green:0.53, blue:0.63, alpha:1.0).cgColor]
    gradient.frame = circleView.bounds
    circleView.layer.insertSublayer(gradient, at: 0)
    circleView.layer.cornerRadius = circleView.bounds.size.height / 2
    gradient.cornerRadius = circleView.layer.cornerRadius
    
    return circleView
}()

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.cornerRadius = startButton.frame.size.width / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: Transitioning
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionForward(fromPoint: startButton.center, andFrame: startButton.frame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionDismiss(toPoint: startButton.center, andFrame: startButton.frame)
    }
}

fileprivate class TransitionForward: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.5
    var startPoint = CGPoint.zero
    var startFrame = CGRect.zero
    
    init(fromPoint startPoint: CGPoint, andFrame startFrame: CGRect) {
        self.startPoint = startPoint
        self.startFrame = startFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toView = transitionContext.view(forKey: .to) {
            let scaleTo = startFrame.size.height / (1.4142 * toView.frame.size.height)

            toView.alpha = 0.0
            toView.transform = CGAffineTransform(scaleX: scaleTo, y: scaleTo)
            toView.center = startPoint
         
            let scaleCircleTo = startFrame.size.height / circleView.frame.size.height
            circleView.alpha = 0.0
            circleView.transform = CGAffineTransform(scaleX: scaleCircleTo, y: scaleCircleTo)
            circleView.center = startPoint
            
            transitionContext.containerView.addSubview(circleView)
            transitionContext.containerView.addSubview(toView)
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
                toView.alpha = 1.0
                toView.transform = CGAffineTransform.identity
                toView.center = transitionContext.containerView.center
                circleView.alpha = 1.0
                circleView.transform = CGAffineTransform.identity
                circleView.center = transitionContext.containerView.center
            }, completion: {(success:Bool) in
                transitionContext.completeTransition(success)
            })
        }
    }
}

fileprivate class TransitionDismiss: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.5
    var endPoint = CGPoint.zero
    var endFrame = CGRect.zero
    
    init(toPoint endPoint: CGPoint, andFrame endFrame: CGRect) {
        self.endPoint = endPoint
        self.endFrame = endFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: .from) {
            transitionContext.containerView.addSubview(fromView)
            let scaleTo = endFrame.size.height / (1.4142 * fromView.frame.size.height)
            let scaleCircleTo = endFrame.size.height / circleView.frame.size.height
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
                fromView.alpha = 0.0
                fromView.transform = CGAffineTransform(scaleX: scaleTo, y: scaleTo)
                fromView.center = self.endPoint

                circleView.alpha = 0.0
                circleView.transform = CGAffineTransform(scaleX: scaleCircleTo, y: scaleCircleTo)
                circleView.center = self.endPoint
}, completion: {(success:Bool) in
                fromView.removeFromSuperview()
                circleView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }
}


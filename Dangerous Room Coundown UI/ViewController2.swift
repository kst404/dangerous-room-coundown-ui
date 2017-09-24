//
//  ViewController.swift
//  Dangerous Room Coundown UI
//
//  Created by Konstantin on 04/09/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit

fileprivate let maxMainTime: TimeInterval = 3  * 60 * 60

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

class ViewController2: UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var mainCountdown: UILabel!
    @IBOutlet var infoView: UIView!
    @IBOutlet var allInfoView: UIView!
    
    let mainCountdownTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: 260).scaledBy(x: 0.5, y: 0.5)
    let startButtonTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: -150).scaledBy(x: 0.001, y: 0.001)
    let stopButtonTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: 150).scaledBy(x: 0.001, y: 0.001)
    let allInfoViewTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: -48)

    var mainTime: TimeInterval = maxMainTime {
        didSet {
            let interval = Int(mainTime)
            let seconds = interval % 60
            let minutes = (interval / 60) % 60
            let hours = (interval / 3600)
            mainCountdown.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    var mainTimer: Timer?
    var aliveSetupTimer: Timer?
    var isAliveTimerStarted = false {
        didSet {
            if isAliveTimerStarted {
                self.performSegue(withIdentifier: "aliveCounterSegue", sender: self)
            } else {
                self.aliveSetupTimer?.invalidate()
                self.aliveSetupTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(setupAliveCountdown), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc(proccessMainTick)
    func proccessMainTick() {
        if self.mainTime == 0 {
            
        }
        
        self.mainTime -= 1
    }

    @objc(setupAliveCountdown)
    func setupAliveCountdown() {
        self.isAliveTimerStarted = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainCountdown.font = UIFont.monospacedDigitSystemFont(ofSize: 49, weight: UIFontWeightLight)
        mainCountdown.transform = mainCountdownTransform
        mainCountdown.alpha = 0.0

        startButton.layer.cornerRadius = startButton.frame.size.width / 2
//        startButton.layer.masksToBounds = true
//        startButton.layer.borderWidth = 1.0
//        startButton.layer.borderColor = startButton.titleLabel?.textColor.cgColor

        stopButton.layer.cornerRadius = stopButton.frame.size.width / 2
        stopButton.layer.masksToBounds = true
        stopButton.layer.borderWidth = 1.0
        stopButton.layer.borderColor = stopButton.titleLabel?.textColor.cgColor
        
        stopButton.transform = stopButtonTransform
        stopButton.alpha = 0.0
        
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mainTimer?.invalidate()
    }

    // MARK: Tap handlers
    @IBAction func tapStart(_ sender: Any) {
        mainTime = 3 * 60 * 60
        mainTimer?.invalidate()
        mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(proccessMainTick), userInfo: nil, repeats: true)
        aliveSetupTimer?.invalidate()
        aliveSetupTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(setupAliveCountdown), userInfo: nil, repeats: false)

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4.0, options: [], animations: {
            self.infoView.alpha = 0.0
            
            self.allInfoView.transform = self.allInfoViewTransform
            
            self.mainCountdown.alpha = 1.0
            self.mainCountdown.transform = CGAffineTransform.identity
            
            self.startButton.alpha = 0.0
            self.startButton.transform = self.startButtonTransform
            
            self.stopButton.alpha = 1.0
            self.stopButton.transform = CGAffineTransform.identity
        }, completion: { success in
            
        })
    }
    
    @IBAction func tapStop(_ sender: Any) {
        mainTimer?.invalidate()
        aliveSetupTimer?.invalidate()

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4.0, options: [], animations: {
            self.infoView.alpha = 1.0

            self.allInfoView.transform = CGAffineTransform.identity

            self.mainCountdown.alpha = 0.0
            self.mainCountdown.transform = self.mainCountdownTransform
            
            self.startButton.alpha = 1.0
            self.startButton.transform = CGAffineTransform.identity
            
            self.stopButton.alpha = 0.0
            self.stopButton.transform = self.stopButtonTransform
        }, completion: { success in
            
        })
    }

    // MARK: Transitioning
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = self
        
        segue.destination.modalPresentationStyle = .overFullScreen
//        segue.destination.modalTransitionStyle = .crossDissolve
        let destinationVC = segue.destination as? TimerViewController2
        destinationVC?.parentController = self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionForward()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionDismiss()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AliveTimerPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

fileprivate class TransitionForward: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.4

//    init() {
//    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toView = transitionContext.view(forKey: .to) { //, let fromView = transitionContext.view(forKey: .from)
//            toView.alpha = 0.0
            toView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            transitionContext.containerView.addSubview(toView)
//            transitionContext.containerView.addSubview(fromView)
            
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
//                toView.alpha = 1.0
                toView.transform = CGAffineTransform.identity
            }, completion: {(success:Bool) in
                transitionContext.completeTransition(success)
            })
        }
    }
}

fileprivate class TransitionDismiss: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.4
    
//    init() {
//    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: .from) { //, let toView = transitionContext.view(forKey: .to)
//            transitionContext.containerView.addSubview(toView)
            transitionContext.containerView.addSubview(fromView)
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
//                fromView.alpha = 0.0
                fromView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
}, completion: {(success:Bool) in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }
}

fileprivate class AliveTimerPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false
    }
}

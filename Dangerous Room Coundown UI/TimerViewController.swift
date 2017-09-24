//
//  TimerViewController.swift
//  Dangerous Room Coundown UI
//
//  Created by Konstantin on 05/09/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit
import Foundation

fileprivate let maxAliveTime: TimeInterval = 2 * 60
fileprivate let maxMainTime: TimeInterval = 3  * 60 * 60

class TimerViewController: UIViewController {
    @IBOutlet var aliveTimerView: UIView!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var infoView: UIView!
    @IBOutlet var mainCountdown: UILabel!
    @IBOutlet var aliveCountdown: UILabel!
    
    let gradient = CAGradientLayer()
    var mainTime: TimeInterval = maxMainTime {
        didSet {
            let interval = Int(mainTime)
            let seconds = interval % 60
            let minutes = (interval / 60) % 60
            let hours = (interval / 3600)
            mainCountdown.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    var aliveTime: TimeInterval = maxAliveTime {
        didSet {
            let interval = Int(aliveTime)
            let seconds = interval % 60
            let minutes = (interval / 60) % 60
            aliveCountdown.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    
    lazy var aliveCircleLayer:CAShapeLayer = {
        return CAShapeLayer(withCircleInRect: self.aliveTimerView.bounds)
    }()
    
    lazy var aliveWhiteDisk: CAShapeLayer = {
        let disk = CAShapeLayer()
        disk.frame = self.aliveTimerView.bounds

        let circlePath = CGPath(ellipseIn: self.aliveTimerView.bounds, transform: nil)
        
        disk.path = circlePath
        disk.strokeColor = nil
        disk.fillColor = UIColor.white.cgColor
        
        return disk
    }()
    
    var mainTimer: Timer?
    var aliveSetupTimer: Timer?
    var aliveTimer: Timer?
    var isAliveTimerStarted = false {
        didSet {
            if isAliveTimerStarted {
                self.aliveTime = maxAliveTime
                self.aliveTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(proccessAliveTick), userInfo: nil, repeats: true)

                self.showAliveTimer()

                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = self.aliveTime / maxAliveTime
                animation.toValue = 0.0
                animation.duration = maxAliveTime
                
                self.aliveCircleLayer.removeAnimation(forKey: "countdownAnimation")
                self.aliveCircleLayer.add(animation, forKey: "countdownAnimation")
                
                let pulse = CAKeyframeAnimation(keyPath: "transform")
                pulse.values = [
                    CATransform3DMakeScale(1.0, 1.0, 0.0),
                    CATransform3DMakeScale(1.08, 1.08, 0.0),
                    CATransform3DMakeScale(1.0, 1.0, 0.0),
                ]
                pulse.keyTimes = [0.001, 0.1, 0.3]
                pulse.duration = 1.0
                pulse.repeatDuration = maxAliveTime
                
                self.aliveCircleLayer.removeAnimation(forKey: "pulseAnimation")
                self.aliveWhiteDisk.removeAnimation(forKey: "pulseAnimation")
                self.aliveCircleLayer.add(pulse, forKey: "pulseAnimation")
                self.aliveWhiteDisk.add(pulse, forKey: "pulseAnimation")

            } else {
                self.hideAliveTimer()
                self.aliveTimer?.invalidate()
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
    
    @objc(proccessAliveTick)
    func proccessAliveTick() {
        if self.aliveTime == 0 {
            self.isAliveTimerStarted = false
            return
        }
        
        self.aliveTime -= 1
    }
    
    @objc(setupAliveCountdown)
    func setupAliveCountdown() {
        self.isAliveTimerStarted = true
    }
    
    func showAliveTimer() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4.0, options: [], animations: {
            self.aliveTimerView.alpha = 1.0
            self.aliveTimerView.transform = CGAffineTransform.identity
            
            self.infoView.alpha = 0.0
            self.infoView.transform = CGAffineTransform(translationX: 0, y: -50)
            
            self.stopButton.alpha = 0.0
            self.stopButton.transform = CGAffineTransform(translationX: 0, y: 50)
        }, completion: nil)
    }
    
    func hideAliveTimer() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4.0, options: [], animations: {
            self.aliveTimerView.alpha = 0.0
            self.aliveTimerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
            self.infoView.alpha = 1.0
            self.infoView.transform = CGAffineTransform.identity
        
            self.stopButton.alpha = 1.0
            self.stopButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mainTime = 3 * 60 * 60
        mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(proccessMainTick), userInfo: nil, repeats: true)
        aliveSetupTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(setupAliveCountdown), userInfo: nil, repeats: false)

//        gradient.colors = [UIColor(red:1.00, green:0.78, blue:0.52, alpha:1.0).cgColor, UIColor(red:0.95, green:0.53, blue:0.63, alpha:1.0).cgColor]
//        gradient.frame = view.bounds
//
//        view.layer.insertSublayer(gradient, at: 0)
        
        view.backgroundColor = UIColor.clear
        
        aliveTimerView.backgroundColor = UIColor.clear
        aliveTimerView.alpha = 0.0
        aliveTimerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        aliveTimerView.layer.insertSublayer(aliveCircleLayer, at: 0)
        aliveTimerView.layer.insertSublayer(aliveWhiteDisk, at: 0)
        
        aliveCountdown.font = UIFont.monospacedDigitSystemFont(ofSize: 69, weight: UIFontWeightThin)
        mainCountdown.font = UIFont.monospacedDigitSystemFont(ofSize: 49, weight: UIFontWeightLight)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mainTimer?.invalidate()
        aliveTimer?.invalidate()
        aliveSetupTimer?.invalidate()
    }
    
    @IBAction func stopTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stopAliveTap(_ sender: Any) {
        self.isAliveTimerStarted = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

fileprivate extension CAShapeLayer {
    convenience init(withCircleInRect rect: CGRect) {
        self.init()
        
        self.frame = rect
        
        var transform = CGAffineTransform(rotationAngle: CGFloat.pi / -2.0).translatedBy(x: -rect.size.height, y: 0)
        
        let circlePath = CGPath(ellipseIn: rect.insetBy(dx: 4, dy: 4), transform: &transform)
        
        self.path = circlePath
        self.strokeColor = UIColor(red:0.95, green:0.53, blue:0.63, alpha:1.0).cgColor
        self.lineWidth = 2
        self.fillColor = nil
        
    }
}

//
//  EGAnimator.swift
//  EGPieChart
//
//  Created by EthanGuan on 2021/11/18.
//

import Foundation

public protocol EGAnimatorDelegate: AnyObject {
    /// Called when the Animator has began.
    func animatorBegan(_ animator: EGAnimator)
    
    /// Called when the Animator has stepped.
    func animatorUpdated(_ animator: EGAnimator)
    
    /// Called when the Animator has stopped.
    func animatorStopped(_ animator: EGAnimator)
}

open class EGAnimator {
    open weak var delegate: EGAnimatorDelegate?
    
    var animationDisplayLink: CADisplayLink?
    var animationDuration: TimeInterval = 0.0
    var animationProgress: CGFloat = 0.0
    var animationStartTime: TimeInterval = 0.0
    
    @objc func animationLink() {
        animationProgress = CGFloat((CACurrentMediaTime() - animationStartTime)/animationDuration)
        delegate?.animatorUpdated(self)
        if (animationProgress > 1) {
            animationDisplayLink?.remove(from: RunLoop.main, forMode: .common)
            animationProgress = 1
            animationDisplayLink = nil
            delegate?.animatorStopped(self)
        }
    }
    
    open func animate(duration: TimeInterval) {
        animationStartTime = CACurrentMediaTime()
        animationDuration = duration
        if animationDisplayLink == nil {
            animationDisplayLink = CADisplayLink(target: self, selector: #selector(animationLink))
            animationDisplayLink?.add(to: .main, forMode: RunLoop.Mode.common)
            delegate?.animatorBegan(self)
        }
    }
}

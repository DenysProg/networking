//
//  UIView+shakeAnimation.swift
//  networking
//
//  Created by Denys Nikolaichuk on 17.08.2021.
//

import UIKit

extension UIView {
    func shake(duration: TimeInterval = 0.5, values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.values = values
        self.layer.add(animation, forKey: "shake")
    }
}

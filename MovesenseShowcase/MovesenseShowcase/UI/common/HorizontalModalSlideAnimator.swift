//
// HorizontalModalSlideAnimator.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class HorizontalModalSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private enum Constants {
        static let transitionDuration: Double = 0.35
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }

        let containerView = transitionContext.containerView

        toView.transform = CGAffineTransform.identity
        toView.clipsToBounds = true

        toView.center = CGPoint(
            x: containerView.frame.maxX + toView.frame.midX,
            y: containerView.frame.midY)

        containerView.addSubview(toView)

        UIView.animate(withDuration: Constants.transitionDuration,
                       delay: 0.0,
                       options: [],
                       animations: {
                           toView.transform = CGAffineTransform.identity
                           toView.center = CGPoint(x: containerView.frame.midX,
                                                   y: containerView.frame.midY)
                       }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}

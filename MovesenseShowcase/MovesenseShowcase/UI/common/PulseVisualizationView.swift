//
// PulseVisualizationView.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class PulseVisualizationView: UIView {

    private let innerRingView: UIView
    private let middleRingView: UIView
    private let outerRingView: UIView

    private var pulseStarted: Bool = false

    init(strokeColor: UIColor, fillColor: UIColor) {
        self.innerRingView = PulseRingView(strokeColor: strokeColor.cgColor,
                                           fillColor: fillColor.withAlphaComponent(0.10).cgColor)
        self.middleRingView = PulseRingView(strokeColor: strokeColor.cgColor,
                                            fillColor: fillColor.withAlphaComponent(0.08).cgColor)
        self.outerRingView = PulseRingView(strokeColor: strokeColor.cgColor,
                                           fillColor: fillColor.withAlphaComponent(0.06).cgColor)
        super.init(frame: CGRect.zero)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        stopPulseAnimation()

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startPulseAnimation() {
        stopPulseAnimation()

        innerRingView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        middleRingView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        outerRingView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        alpha = 1.0

        UIView.animate(withDuration: 2.0, delay: 0, options: .repeat, animations: {
            self.innerRingView.transform = CGAffineTransform.identity
            self.middleRingView.transform = CGAffineTransform.identity
            self.outerRingView.transform = CGAffineTransform.identity
        })

        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .curveEaseIn], animations: {
            self.alpha = 0.0
        })

        pulseStarted = true
    }

    func stopPulseAnimation() {
        alpha = 0.0
        layer.removeAllAnimations()
        innerRingView.layer.removeAllAnimations()
        middleRingView.layer.removeAllAnimations()
        outerRingView.layer.removeAllAnimations()

        pulseStarted = false
    }

    @objc private func applicationDidBecomeActive() {
        pulseStarted ? startPulseAnimation() : stopPulseAnimation()
    }

    private func layoutView() {
        addSubview(outerRingView)
        addSubview(middleRingView)
        addSubview(innerRingView)

        outerRingView.translatesAutoresizingMaskIntoConstraints = false
        middleRingView.translatesAutoresizingMaskIntoConstraints = false
        innerRingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [innerRingView.centerXAnchor.constraint(equalTo: centerXAnchor),
             innerRingView.centerYAnchor.constraint(equalTo: centerYAnchor),
             innerRingView.widthAnchor.constraint(equalTo: widthAnchor),
             innerRingView.heightAnchor.constraint(equalTo: heightAnchor)])

        NSLayoutConstraint.activate(
            [middleRingView.centerXAnchor.constraint(equalTo: centerXAnchor),
             middleRingView.centerYAnchor.constraint(equalTo: centerYAnchor),
             middleRingView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.33),
             middleRingView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.33)])

        NSLayoutConstraint.activate(
            [outerRingView.centerXAnchor.constraint(equalTo: centerXAnchor),
             outerRingView.centerYAnchor.constraint(equalTo: centerYAnchor),
             outerRingView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.66),
             outerRingView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.66)])
    }
}

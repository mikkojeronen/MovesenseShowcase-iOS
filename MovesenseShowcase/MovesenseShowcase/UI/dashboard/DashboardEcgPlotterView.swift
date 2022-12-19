//
// DashboardEcgPlotterView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class DashboardEcgPlotterView: UIView {

    private let secondsToPlot: UInt32

    private let plotContainer: UIView = UIView(frame: CGRect.zero)
    private let plotView: UIView = UIView(frame: CGRect.zero)

    private let plotFadeLayer: CAGradientLayer = CAGradientLayer()
    private let plotScaleLayer: CAShapeLayer = CAShapeLayer()
    private let plotLayers: [CAShapeLayer] = [CAShapeLayer(), CAShapeLayer()]
    private let plotDots: [CAShapeLayer] = [CAShapeLayer(), CAShapeLayer()]
    private let plotPath: UIBezierPath = UIBezierPath()

    private var currentPlotLayer: Int = 0
    private var plotRect: CGRect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)

    private(set) var isDirty: Bool = false

    var isEmpty: Bool { return plotPath.isEmpty }

    var fadePosition: CGFloat = 0.0 {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)

            plotFadeLayer.frame.origin.x = fadePosition - plotFadeLayer.frame.width +
                                           plotRect.width / CGFloat(secondsToPlot)
            CATransaction.commit()
        }
    }

    init(secondsToPlot: UInt32) {
        self.secondsToPlot = secondsToPlot
        super.init(frame: CGRect.zero)

        clipsToBounds = true
        backgroundColor = UIColor.black

        plotLayers.forEach { plotLayer in
            plotLayer.strokeColor = UIColor.red.cgColor
            plotLayer.fillColor = nil
            plotLayer.lineWidth = 1.0
            plotLayer.zPosition = 3

            plotView.layer.addSublayer(plotLayer)
        }

        plotDots.enumerated().forEach { (index, plotDot) in
            plotDot.strokeColor = UIColor.white.cgColor
            plotDot.fillColor = UIColor.red.cgColor
            plotDot.lineWidth = 5.0

            let dotPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: CGFloat(4), startAngle: CGFloat(0),
                                       endAngle: CGFloat(Double.pi * 2), clockwise: true)
            plotDot.path = dotPath.cgPath
            plotDot.frame = CGRect(x: -10, y: 0, width: 8, height: 8)

            plotLayers[safe: index]?.addSublayer(plotDot)
        }

        plotFadeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        plotFadeLayer.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.0).cgColor]
        plotFadeLayer.zPosition = 1

        plotView.layer.addSublayer(plotFadeLayer)

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        plotRect = plotView.bounds

        let fadeSize = CGSize(width: plotRect.width + (plotRect.width / CGFloat(secondsToPlot)),
                              height: plotRect.height)

        plotFadeLayer.frame = CGRect(origin: CGPoint(x: -fadeSize.width, y: 0.0),
                                     size: fadeSize)

        plotFadeLayer.locations = [NSNumber(value: Double(plotRect.width / fadeSize.width)), 1.0]

        plotLayers.forEach { plotLayer in
            plotLayer.frame = plotRect
        }

        createScale(width: plotView.frame.width, height: plotView.frame.height, scaleStep: 10.0)
    }

    func addPlot(toPoint: CGPoint) {

        let centeredY = (plotRect.size.height / 2.0) - toPoint.y
        let plotPoint = CGPoint(x: toPoint.x, y: centeredY)

        if plotPath.isEmpty {
            plotPath.move(to: plotPoint)
        } else if distanceBetween(plotPoint, plotPath.currentPoint) >= 1.0 {
            plotPath.addLine(to: plotPoint)
            isDirty = true
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.066666)

        plotDots[safe: currentPlotLayer]?.frame.origin = plotPoint

        CATransaction.commit()
    }

    // Only call from main thread
    func drawPlot() {
        guard let plotLayer = plotLayers[safe: currentPlotLayer],
              plotPath.isEmpty == false else { return }

        plotLayer.path = plotPath.cgPath

        isDirty = false
    }

    // Only call from main thread
    func restartPlot() {
        resetPlot()
        resetPlot()
    }

    // Only call from main thread
    func resetPlot() {
        plotLayers[safe: currentPlotLayer]?.zPosition = 0

        currentPlotLayer = currentPlotLayer >= (plotLayers.count - 1) ? 0 : (currentPlotLayer + 1)

        plotLayers[safe: currentPlotLayer]?.zPosition = 3

        plotPath.removeAllPoints()
        plotLayers[safe: currentPlotLayer]?.path = plotPath.cgPath
        isDirty = false

        plotDots[safe: currentPlotLayer]?.isHidden = false
    }

    // Only call from main thread
    func resetDot() {
        guard let plotDot = plotDots[safe: currentPlotLayer] else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        plotDot.isHidden = true

        CATransaction.setCompletionBlock({
            plotDot.frame.origin = CGPoint(x: -plotDot.frame.width,
                                           y: (self.plotRect.size.height / 2.0))
        })
        CATransaction.commit()
    }

    private func createScale(width: CGFloat, height: CGFloat, scaleStep: CGFloat) {
        guard width > 0.0,
              scaleStep > 0.0 else { return }

        let scalePath = UIBezierPath()

        scalePath.move(to: CGPoint(x: 0.0, y: 0.0))
        scalePath.addLine(to: CGPoint(x: 0.0, y: height))

        let verticalScaleCount: Int = Int((height / 2) / scaleStep)
        [-1, 1].forEach { direction in
            let startingPoint = direction > 0 ? 0 : 1
            (startingPoint...verticalScaleCount).forEach { scale in
                let scaleY = floor(CGFloat(direction * scale) * scaleStep * 3 + height / 2)
                scalePath.move(to: CGPoint(x: 0.0, y: scaleY))
                scalePath.addLine(to: CGPoint(x: width, y: scaleY))
            }
        }

        let horizontalScaleCount: Int = Int(width / scaleStep)
        [-1, 1].forEach { direction in
            let startingPoint = direction > 0 ? 0 : 1
            (startingPoint...horizontalScaleCount).forEach { scale in
                let scaleX = floor(CGFloat(direction * scale) * scaleStep + width / 2)
                scalePath.move(to: CGPoint(x: scaleX, y: 0.0))
                scalePath.addLine(to: CGPoint(x: scaleX, y: height))
            }
        }

        plotScaleLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        plotScaleLayer.lineWidth = 0.5
        plotScaleLayer.strokeColor = UIColor.white.withAlphaComponent(0.15).cgColor
        plotScaleLayer.path = scalePath.cgPath
        plotScaleLayer.zPosition = 2

        plotView.layer.addSublayer(plotScaleLayer)
    }

    private func layoutView() {
        addSubview(plotContainer)
        plotContainer.addSubview(plotView)

        plotContainer.translatesAutoresizingMaskIntoConstraints = false
        plotView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [plotContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
             plotContainer.topAnchor.constraint(equalTo: topAnchor),
             plotContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
             plotContainer.bottomAnchor.constraint(equalTo: bottomAnchor)])

        NSLayoutConstraint.activate(
            [plotView.leadingAnchor.constraint(equalTo: plotContainer.leadingAnchor),
             plotView.topAnchor.constraint(equalTo: plotContainer.topAnchor),
             plotView.trailingAnchor.constraint(equalTo: plotContainer.trailingAnchor),
             plotView.bottomAnchor.constraint(equalTo: plotContainer.bottomAnchor)])
    }
}

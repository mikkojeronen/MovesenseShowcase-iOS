//
// DashboardPlotterSlice.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class DashboardPlotterSlice: UIView {

    private let plotView: UIView = UIView(frame: CGRect.zero)
    private let plotContainer: UIView = UIView(frame: CGRect.zero)
    private let plotScaleView: UIView = UIView(frame: CGRect.zero)
    private let plotLabel: UILabel
    private let plotLayers: [UIColor: CAShapeLayer]
    private let plotPaths: [UIColor: UIBezierPath]

    private var plotRect: CGRect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)

    private(set) var isDirty: Bool = false

    var isEmpty: Bool {
        return plotPaths.allSatisfy { (_, path) in path.isEmpty }
    }

    var plotPoints: [UIColor: CGPoint] {
        return plotPaths.reduce(into: [UIColor: CGPoint]()) { (points, path) in
            points[path.key] = path.value.currentPoint
        }
    }

    var scrollOffset: CGFloat = 0.0 {
        didSet {
            plotContainer.frame.origin.x = scrollOffset
        }
    }

    var yTransform: CGFloat = 1.0 {
        didSet {
            guard self.yTransform > 0.0 else { return }
            self.isDirty = true
        }
    }

    private var currentPoints: [UIColor: CGPoint]
    private var _yMin: CGFloat = CGFloat.greatestFiniteMagnitude
    private var _yMax: CGFloat = -CGFloat.greatestFiniteMagnitude

    var yLimits: (CGFloat, CGFloat) {
        return (_yMin, _yMax)
    }

    init(_ colors: [UIColor] = [UIColor.black]) {
        self.plotLayers = colors.reduce(into: [UIColor: CAShapeLayer]()) { (layers, color) in
            layers[color] = CAShapeLayer()
        }

        self.plotPaths = colors.reduce(into: [UIColor: UIBezierPath]()) { (paths, color) in
            paths[color] = UIBezierPath()
        }

        self.currentPoints = colors.reduce(into: [UIColor: CGPoint]()) { (points, color) in
            points[color] = CGPoint.zero
        }

        self.plotLabel = UILabel(with: UIFont.systemFont(ofSize: 8), inColor: UIColor.black, lines: 1)
        self.plotLabel.textAlignment = .center

        super.init(frame: CGRect.zero)

        plotLayers.forEach { (color, layer) in
            layer.strokeColor = color.cgColor
            layer.fillColor = nil
            layer.lineWidth = 2.0
            layer.drawsAsynchronously = true
            plotView.layer.addSublayer(layer)
        }

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Position plotLabel manually to prevent it from triggering layout events when the text changes
        plotLabel.frame = CGRect(x: -plotContainer.frame.width / 2, y: 0, width: plotContainer.frame.width, height: 10.0)
        plotLabel.bounds = CGRect(x: 0, y: 0, width: plotContainer.frame.width, height: 10.0)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        plotRect = plotView.bounds
        plotLayers.forEach { $0.1.frame = plotRect }

        createScale(width: plotScaleView.frame.width,
                    height: plotScaleView.frame.height,
                    scaleStep: plotScaleView.frame.width)
    }

    // May be called from a background thread, may NOT access views
    func addPlot(xStep: CGFloat, y: CGFloat, color: UIColor, required: Bool = false) {

        if y > _yMax {
            _yMax = y
        } else if y < _yMin {
            _yMin = y
        }

        // These need to happen in sync
        DispatchQueue.main.sync {
            guard let plotPath = self.plotPaths[color],
                  let plotPoint = self.currentPoints[color] else { return }

            if plotPath.isEmpty {

                let newPoint = CGPoint(x: xStep, y: y)

                plotPath.move(to: newPoint)

                self.currentPoints[color] = newPoint
            } else {
                let newPoint = CGPoint(x: plotPoint.x + xStep, y: y)

                if required || distanceBetween(plotPath.currentPoint, newPoint) >= 1.0 {
                    plotPath.addLine(to: newPoint)
                    self.isDirty = true
                }

                self.currentPoints[color] = newPoint
            }
        }
    }

    // Only called from main thread
    func drawPlot() {
        plotLayers.forEach { (color, plotLayer) in
            guard let plotPath = plotPaths[color] else { return }

            var scaleTransform = CGAffineTransform(scaleX: 1.0, y: -yTransform)
            let scaledPath = plotPath.cgPath.copy(using: &scaleTransform)

            var centeringTransform = CGAffineTransform(translationX: 0.0,
                                                       y: plotRect.size.height / 2)

            plotLayer.path = scaledPath?.copy(using: &centeringTransform)
        }

        isDirty = false
    }

    // Only called from main thread
    func resetPlot(label: String = "") {
        plotPaths.forEach { (_, plotPath) in
            plotPath.removeAllPoints()
        }

        _yMin = CGFloat.greatestFiniteMagnitude
        _yMax = -CGFloat.greatestFiniteMagnitude

        plotLabel.text = label

        isDirty = true
    }

    private func createScale(width: CGFloat, height: CGFloat, scaleStep: CGFloat) {
        guard width > 0.0,
              scaleStep > 0.0 else { return }

        let scalePath = UIBezierPath()

        scalePath.move(to: CGPoint(x: 0.0, y: 0.0))
        scalePath.addLine(to: CGPoint(x: 0.0, y: height))

        let plotScaleLayer = CAShapeLayer()

        plotScaleLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        plotScaleLayer.lineWidth = 1.0
        plotScaleLayer.strokeColor = UIColor.lightGray.cgColor
        plotScaleLayer.path = scalePath.cgPath

        plotScaleView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        plotScaleView.layer.addSublayer(plotScaleLayer)
    }

    private func layoutView() {
        addSubview(plotContainer)
        plotContainer.addSubview(plotScaleView)
        plotContainer.addSubview(plotView)
        plotContainer.addSubview(plotLabel)

        plotView.translatesAutoresizingMaskIntoConstraints = false
        plotContainer.translatesAutoresizingMaskIntoConstraints = false
        plotScaleView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [plotContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
             plotContainer.topAnchor.constraint(equalTo: topAnchor),
             plotContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
             plotContainer.bottomAnchor.constraint(equalTo: bottomAnchor)])

        NSLayoutConstraint.activate(
            [plotScaleView.leadingAnchor.constraint(equalTo: plotContainer.leadingAnchor),
             plotScaleView.topAnchor.constraint(equalTo: plotContainer.topAnchor, constant: 20),
             plotScaleView.trailingAnchor.constraint(equalTo: plotContainer.trailingAnchor),
             plotScaleView.bottomAnchor.constraint(greaterThanOrEqualTo: plotContainer.bottomAnchor)])

        NSLayoutConstraint.activate(
            [plotView.leadingAnchor.constraint(equalTo: plotScaleView.leadingAnchor),
             plotView.topAnchor.constraint(equalTo: plotScaleView.topAnchor),
             plotView.trailingAnchor.constraint(equalTo: plotScaleView.trailingAnchor),
             plotView.bottomAnchor.constraint(equalTo: plotScaleView.bottomAnchor)])
    }
}

//
// DashboardOperationViewControllerGyro.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class DashboardOperationViewControllerGyro: UIViewController {

    private let viewModel: DashboardContainerViewModel

    private let secondsToPlot: Int = 5
    private let scaleView: DashboardPlotterScaleView = DashboardPlotterScaleView(scaleStep: 100, scaleRange: -2000...2000)
    private let scrollView: UIView = UIView(frame: CGRect.zero)
    private let plotColors: [UIColor]
    private let valuesView: DashboardValuesView

    private let selectorContainer: UIView = UIView(frame: CGRect.zero)
    private let sampleRateValueView: SelectorValueView
    private let sampleRateSelector: SelectorSlider
    private let dpsRateValueView: SelectorValueView
    private let dpsRateSelector: SelectorSlider

    private var plotValues: DashboardVector3 = DashboardVector3(x: 0.0, y: 0.0, z: 0.0)
    private var plotSlices: [DashboardPlotterSlice]
    private var displayLink: CADisplayLink?

    private var scrollSize: CGSize = CGSize.zero
    private var sliceSize: CGSize = CGSize.zero
    private var sliceCounter: UInt32 = 0

    private var hideConstraints: [NSLayoutConstraint] = []

    private var currentSlice: DashboardPlotterSlice? {
        return plotSlices.sorted { (lhs, rhs) in lhs.scrollOffset > rhs.scrollOffset }.first
    }

    private var previousSlice: DashboardPlotterSlice? {
        guard let currentSlice = currentSlice else { return nil }

        return plotSlices.sorted { (lhs, rhs) in lhs.scrollOffset > rhs.scrollOffset }.first { slice in
            slice.scrollOffset < currentSlice.scrollOffset
        }
    }

    init(viewModel: DashboardContainerViewModel) {
        let plotColors = [UIColor(red: 238 / 255, green: 38 / 255, blue: 170 / 255, alpha: 1.0),
                          UIColor(red: 109 / 255, green: 77 / 255, blue: 238 / 255, alpha: 1.0),
                          UIColor(red: 254 / 255, green: 194 / 255, blue: 57 / 255, alpha: 1.0)]
        self.plotSlices = (0...secondsToPlot).map { _ in DashboardPlotterSlice(plotColors) }
        self.plotColors = plotColors
        self.valuesView = DashboardValuesView(xColor: plotColors[0], yColor: plotColors[1], zColor: plotColors[2])

        // TODO: Get values from the viewmodel
        self.sampleRateSelector = SelectorSlider(values: [13, 26, 52, 104, 208, 416, 833, 1666])
        self.sampleRateValueView = SelectorValueView(name: NSLocalizedString("Rate", comment: ""),
                                                     unit: "Hz")
        // TODO: Get values from the viewmodel
        self.dpsRateSelector = SelectorSlider(values: [245, 500, 1000, 2000])
        self.dpsRateValueView = SelectorValueView(name: NSLocalizedString("DASHBOARD_SELECTOR_DPS_NAME", comment: ""),
                                                  unit: NSLocalizedString("DASHBOARD_SELECTOR_DPS_UNIT", comment: ""))
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        scrollView.clipsToBounds = true

        hideConstraints.append(selectorContainer.heightAnchor.constraint(equalToConstant: 0))

        sampleRateSelector.setMarkerImages(markedImage: UIImage(named: "image_slider_marker_marked.pdf"),
                                           unmarkedImage: UIImage(named: "image_slider_marker_unmarked.pdf"))
        sampleRateSelector.setMinimumTrackImage(UIImage(named: "image_slider_line_marked.pdf"), for: .normal)
        sampleRateSelector.setMaximumTrackImage(UIImage(named: "image_slider_line_unmarked.pdf"), for: .normal)
        sampleRateSelector.setThumbImage(UIImage(named: "icon_slider_knob.pdf"), for: .normal)
        sampleRateSelector.delegate = self

        dpsRateSelector.setMarkerImages(markedImage: UIImage(named: "image_slider_marker_marked.pdf"),
                                        unmarkedImage: UIImage(named: "image_slider_marker_unmarked.pdf"))
        dpsRateSelector.setMinimumTrackImage(UIImage(named: "image_slider_line_marked.pdf"), for: .normal)
        dpsRateSelector.setMaximumTrackImage(UIImage(named: "image_slider_line_unmarked.pdf"), for: .normal)
        dpsRateSelector.setThumbImage(UIImage(named: "icon_slider_knob.pdf"), for: .normal)
        dpsRateSelector.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(applicationWillResignActive),
                                       name: UIApplication.willResignActiveNotification, object: nil)

        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                       name: UIApplication.didBecomeActiveNotification, object: nil)

        if viewModel.isOperation == false {
            sampleRateSelector.selectValue(index: 2)
            dpsRateSelector.selectValue(index: 2)
        }

        viewModel.addObserver(self)

        layoutView()

        // Calculate initial slice positions & sizes
        scrollSize = scrollView.frame.size
        sliceSize = CGSize(width: scrollSize.width / CGFloat(secondsToPlot), height: scrollSize.height)

        // Set initial states for slices
        for index in plotSlices.indices {
            plotSlices[index].frame.size = CGSize(width: sliceSize.width, height: scrollSize.height)
            plotSlices[index].frame.origin = CGPoint(x: 0.0, y: 0.0)
            plotSlices[index].scrollOffset = CGFloat(index) * sliceSize.width
            plotSlices[index].resetPlot(label: "0")
            plotSlices[index].yTransform = 1.0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollSize = scrollView.frame.size
        sliceSize = CGSize(width: scrollSize.width / CGFloat(secondsToPlot), height: scrollSize.height)

        for index in plotSlices.indices {
            plotSlices[index].frame.size = CGSize(width: sliceSize.width, height: scrollSize.height)
        }
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        // Removed from the container view so stop scrolling
        if parent == nil {
            stopDisplayLink()
        } else {
            startDisplayLink()
        }
    }

    @objc private func applicationWillResignActive() {
        stopDisplayLink()
    }

    @objc private func applicationDidBecomeActive() {
        startDisplayLink()
    }

    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        guard let link = displayLink else { return }

        link.remove(from: .main, forMode: .common)
        link.invalidate()
        displayLink = nil
    }

    @objc private func displayLinkTick() {
        guard let displayLink = displayLink,
              displayLink.duration > 0.0 else {
            NSLog("DashboardOperationViewControllerGyro::scrollTick frame duration error.")
            return
        }

        let scrollUnit = (scrollSize.width) / (CGFloat(secondsToPlot) * CGFloat(1.0 / displayLink.duration))

        plotSlices.forEach { slice in
            let sliceOffset = slice.scrollOffset - scrollUnit
            if sliceOffset <= -sliceSize.width {
                sliceCounter += 1
                slice.resetPlot(label: "\(sliceCounter)")
                slice.scrollOffset = sliceOffset + scrollSize.width + sliceSize.width
            } else if slice.isDirty {
                slice.drawPlot()
                slice.scrollOffset = sliceOffset
            } else {
                slice.scrollOffset = sliceOffset
            }
        }

        if scaleView.isDirty {
            scaleView.refreshScale()
        }

        valuesView.xValue = plotValues.x
        valuesView.yValue = plotValues.y
        valuesView.zValue = plotValues.z
    }

    // May be called from a background thread, may NOT access views
    private func plotVector3D(x: Float, y: Float, z: Float, step: CGFloat) {
        guard displayLink != nil else { return }

        plotValues.x = CGFloat(x)
        plotValues.y = CGFloat(y)
        plotValues.z = CGFloat(z)

        let dimensions = [CGFloat(x), CGFloat(y), CGFloat(z)].enumerated().map { (index, dimension) in
            return (dimension, plotColors[safe: index] ?? UIColor.black)
        }

        plotDimensions(dimensions, step: step, scale: scaleView.pointsPerUnit)
    }

    private func plotDimensions(_ dimensions: [(CGFloat, UIColor)], step: CGFloat, scale: CGFloat) {
        guard let currentSlice = currentSlice,
              let previousSlice = previousSlice else {
            NSLog("DashboardOperationViewControllerGyro::plotVector integrity error.")
            return
        }

        let sliceStep = step * (sliceSize.width / 1000.0)

        if currentSlice.isEmpty && (previousSlice.isEmpty == false) {
            guard let previousX = previousSlice.plotPoints.first?.value.x else { return }

            let gapStep = sliceSize.width - previousX

            if gapStep > 0.0 {
                // Underflow, close the gap
                dimensions.forEach { (y, color) in
                    let maxStep = max(gapStep, sliceStep)
                    previousSlice.addPlot(xStep: maxStep, y: scale * y, color: color, required: true)
                    currentSlice.addPlot(xStep: (previousX + maxStep) - sliceSize.width,
                                         y: scale * y, color: color)
                }
            } else {
                // Overflow, continue from it
                dimensions.forEach { (y, color) in
                    guard let previousY = previousSlice.plotPoints[color]?.y else { return }

                    let absStep = abs(gapStep)
                    currentSlice.addPlot(xStep: absStep > 10.0 ? 0.0 : absStep, y: previousY, color: color)
                    currentSlice.addPlot(xStep: sliceStep, y: scale * y, color: color, required: true)
                }
            }

            scalePlotter()

        } else {
            dimensions.forEach { (y, color) in
                currentSlice.addPlot(xStep: sliceStep, y: scale * y, color: color)
            }
        }
    }

    private func scalePlotter() {
        let limitsStart = (CGFloat.greatestFiniteMagnitude, -CGFloat.greatestFiniteMagnitude)
        let yLimits: (min: CGFloat, max: CGFloat) = plotSlices.reduce(limitsStart) { (result, slice) in
            let limits = slice.yLimits
            return (min(result.0, floor(limits.0)), max(result.1, floor(limits.1)))
        }

        let minLimit: CGFloat = -10.0 * scaleView.pointsPerUnit
        let maxLimit: CGFloat = 10.0 * scaleView.pointsPerUnit
        let maxOriginDiff = max(abs(min(minLimit, yLimits.min)), abs(max(maxLimit, yLimits.max)))
        let roundedDiff = (ceil(maxOriginDiff / 10) * 10)
        let scaleFactor = ((scrollSize.height - 20.0) / 2) / roundedDiff
        let roundedScale = floor(scaleFactor * 10) / 10

        plotSlices.forEach { $0.yTransform = roundedScale }
        scaleView.yTransform = roundedScale
    }

    private func layoutView() {
        view.addSubview(scrollView)
        view.addSubview(scaleView)
        view.addSubview(valuesView)
        view.addSubview(selectorContainer)
        selectorContainer.addSubview(sampleRateValueView)
        selectorContainer.addSubview(sampleRateSelector)
        selectorContainer.addSubview(dpsRateValueView)
        selectorContainer.addSubview(dpsRateSelector)
        plotSlices.forEach(scrollView.addSubview)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scaleView.translatesAutoresizingMaskIntoConstraints = false
        valuesView.translatesAutoresizingMaskIntoConstraints = false
        selectorContainer.translatesAutoresizingMaskIntoConstraints = false
        sampleRateValueView.translatesAutoresizingMaskIntoConstraints = false
        sampleRateSelector.translatesAutoresizingMaskIntoConstraints = false
        dpsRateValueView.translatesAutoresizingMaskIntoConstraints = false
        dpsRateSelector.translatesAutoresizingMaskIntoConstraints = false
        plotSlices.forEach { $0.translatesAutoresizingMaskIntoConstraints = true }

        NSLayoutConstraint.activate(
            [scaleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6.0),
             scaleView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
             scaleView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 10.0),
             scaleView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -20.0)])

        NSLayoutConstraint.activate(
            [scrollView.leadingAnchor.constraint(equalTo: scaleView.leadingAnchor, constant: 31.0),
             scrollView.topAnchor.constraint(equalTo: view.topAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
             scrollView.heightAnchor.constraint(equalTo: scrollView.widthAnchor,
                                                multiplier: CGFloat(plotSlices.count) / CGFloat(secondsToPlot),
                                                constant: 20.0)])

        NSLayoutConstraint.activate(
            [valuesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             valuesView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor, constant: 16.0),
             valuesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [selectorContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             selectorContainer.topAnchor.constraint(equalTo: valuesView.bottomAnchor, constant: 16.0),
             selectorContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
             selectorContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [sampleRateValueView.leadingAnchor.constraint(equalTo: selectorContainer.leadingAnchor),
             sampleRateValueView.topAnchor.constraint(equalTo: selectorContainer.topAnchor),
             sampleRateValueView.trailingAnchor.constraint(equalTo: selectorContainer.trailingAnchor)])

        NSLayoutConstraint.activate(
            [sampleRateSelector.leadingAnchor.constraint(equalTo: selectorContainer.leadingAnchor),
             sampleRateSelector.trailingAnchor.constraint(equalTo: selectorContainer.trailingAnchor)])

        NSLayoutConstraint.activate(
            [dpsRateValueView.leadingAnchor.constraint(equalTo: selectorContainer.leadingAnchor),
             dpsRateValueView.trailingAnchor.constraint(equalTo: selectorContainer.trailingAnchor)])

        NSLayoutConstraint.activate(
            [dpsRateSelector.leadingAnchor.constraint(equalTo: selectorContainer.leadingAnchor),
             dpsRateSelector.trailingAnchor.constraint(equalTo: selectorContainer.trailingAnchor),
             dpsRateSelector.bottomAnchor.constraint(equalTo: selectorContainer.bottomAnchor)])

        // Lower priority constraints for smooth hiding of the selectors
        NSLayoutConstraint.activate(
            [sampleRateSelector.topAnchor.constraint(equalTo: sampleRateValueView.bottomAnchor, constant: 6.0).with(.defaultHigh),
             dpsRateValueView.topAnchor.constraint(equalTo: sampleRateSelector.bottomAnchor, constant: 16.0).with(.defaultHigh),
             dpsRateSelector.topAnchor.constraint(equalTo: dpsRateValueView.bottomAnchor, constant: 6.0).with(.defaultHigh)])

        view.layoutIfNeeded()
    }
}

extension DashboardOperationViewControllerGyro: SelectorSliderDelegate {

    func valueSelected(sender: UIControl, value: NSNumber) {
        switch sender {
        case sampleRateSelector:
            guard let row = (viewModel.parameters.enumerated().first { $0.element?.value == value.stringValue }) else {
                return
            }

            viewModel.requestMethod(DashboardMethod.subscribe, indices: [row.offset])
            viewModel.quantity = value.stringValue + " Hz"
            sampleRateValueView.value = value

        case dpsRateSelector:
            guard let (index, _) = (viewModel.resourceParameters(resource: .gyroConfig).enumerated()
                .first { $0.element.value == value.stringValue }) else { return }

            viewModel.requestSend(resource: .gyroConfig, method: .put, parameterIndices: [index])
            dpsRateValueView.value = value

        default: return
        }
    }
}

extension DashboardOperationViewControllerGyro: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let accEvent as DashboardObserverEventVector: handleAccEvent(accEvent)
        case let containerEvent as DashboardObserverEventContainer: handleContainerEvent(containerEvent)
        default: return
        }
    }

    func handleAccEvent(_ event: DashboardObserverEventVector) {
        switch event {
        case .receivedVector(let x, let y, let z, let step): plotVector3D(x: x, y: y, z: z, step: CGFloat(step))
        case .onError(let error): onError(error)
        }
    }

    func handleContainerEvent(_ event: DashboardObserverEventContainer) {
        switch event {
        case .editModeUpdate(let update): editModeUpdate(update)
        case .selectModeUpdate(let update, let enabled): selectModeUpdate(update, enabled: enabled)
        case .quantityUpdate: return
        case .onError(let error): onError(error)
        }
    }

    func editModeUpdate(_ update: Bool) {
        DispatchQueue.main.async {
            if update {
                self.selectorContainer.isHidden = false
                self.hideConstraints.forEach { $0.isActive = false }
            } else {
                self.selectorContainer.isHidden = true
                self.hideConstraints.forEach { $0.isActive = true }
            }
        }
    }

    func selectModeUpdate(_ update: Bool, enabled: Bool) {}

    func onError(_ error: String) {}
}

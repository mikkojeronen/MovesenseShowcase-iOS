//
// DashboardOperationViewControllerEcg.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class DashboardOperationViewControllerEcg: UIViewController {

    private enum Constants {
        static let secondsToPlot: UInt32 = 5
    }

    private let viewModel: DashboardContainerViewModel

    private let scaleFactor: Int = 15
    private let plotLevels: Int = 2
    private let plotContainer: UIView = UIView(frame: CGRect.zero)
    private let plotViews: [DashboardEcgPlotterView]

    private let selectorContainer: UIView = UIView(frame: CGRect.zero)
    private let sampleRateValueView: SelectorValueView
    private let sampleRateSelector: SelectorSlider

    private var displayLink: CADisplayLink?
    private var timeOrigin: UInt32 = 0

    private var hideConstraints: [NSLayoutConstraint] = []
    private var plotSize: CGSize = CGSize.zero

    private var currentPlotter: Int = 0

    init(viewModel: DashboardContainerViewModel) {
        self.plotViews = (0..<plotLevels).map { _ in DashboardEcgPlotterView(secondsToPlot: Constants.secondsToPlot) }
        self.viewModel = viewModel
        self.sampleRateSelector = SelectorSlider(values: [128, 256, 512])
        self.sampleRateValueView = SelectorValueView(name: NSLocalizedString("Rate", comment: ""), unit: "Hz")
        super.init(nibName: nil, bundle: nil)

        hideConstraints.append(selectorContainer.heightAnchor.constraint(equalToConstant: 0))

        sampleRateSelector.setMarkerImages(markedImage: UIImage(named: "image_slider_marker_marked.pdf"),
                                           unmarkedImage: UIImage(named: "image_slider_marker_unmarked.pdf"))
        sampleRateSelector.setMinimumTrackImage(UIImage(named: "image_slider_line_marked.pdf"), for: .normal)
        sampleRateSelector.setMaximumTrackImage(UIImage(named: "image_slider_line_unmarked.pdf"), for: .normal)
        sampleRateSelector.setThumbImage(UIImage(named: "icon_slider_knob.pdf"), for: .normal)
        sampleRateSelector.delegate = self
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

        viewModel.addObserver(self)

        layoutView()

        if viewModel.isOperation == false {
            sampleRateSelector.selectValue(index: 0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        plotSize = plotContainer.frame.size
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
        plotViews[safe: currentPlotter]?.restartPlot()
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
        plotViews[safe: currentPlotter]?.drawPlot()
    }

    private func plotSample(_ sample: Int32, timestamp: UInt32) {
        guard displayLink != nil else {
            timeOrigin = timestamp
            return
        }

        guard timestamp >= timeOrigin else {
            NSLog("DashboardOperationViewControllerEcg::plotSample invalid timestamp: \(timestamp) - origo: \(timeOrigin).")
            timeOrigin = timestamp
            return
        }

        let timeDiff: UInt32
        if timeOrigin == 0 {
            timeDiff = 0
            timeOrigin = timestamp
        } else {
            timeDiff = timestamp - timeOrigin
        }

        let timeOffset: CGFloat
        if timeDiff >= Constants.secondsToPlot * 1000 {
            timeOrigin = 0
            timeOffset = 0
            plotViews[safe: currentPlotter]?.resetDot()
            currentPlotter = currentPlotter >= (plotViews.count - 1) ? 0 : (currentPlotter + 1)
        } else if timeDiff >= (Constants.secondsToPlot - 1) * 1000 {
            let nextPlotterIndex = currentPlotter >= (plotViews.count - 1) ? 0 : (currentPlotter + 1)
            guard let nextPlotter = plotViews[safe: nextPlotterIndex] else { return }

            timeOffset = CGFloat(timeDiff) * (plotSize.width / (CGFloat(Constants.secondsToPlot) * 1000.0))
            nextPlotter.fadePosition = timeOffset - plotSize.width

            if nextPlotter.isEmpty == false {
                nextPlotter.resetPlot()
            }
        } else {
            timeOffset = CGFloat(timeDiff) * (plotSize.width / (CGFloat(Constants.secondsToPlot) * 1000.0))
        }

        let scaledPoint = CGPoint(x: timeOffset, y: CGFloat(sample / Int32(plotViews.count * scaleFactor)))
        plotViews[safe: currentPlotter]?.addPlot(toPoint: scaledPoint)
        plotViews[safe: currentPlotter]?.fadePosition = timeOffset
    }

    private func layoutView() {
        view.addSubview(plotContainer)
        view.addSubview(selectorContainer)
        selectorContainer.addSubview(sampleRateValueView)
        selectorContainer.addSubview(sampleRateSelector)
        plotViews.forEach(plotContainer.addSubview)

        plotContainer.translatesAutoresizingMaskIntoConstraints = false
        selectorContainer.translatesAutoresizingMaskIntoConstraints = false
        sampleRateValueView.translatesAutoresizingMaskIntoConstraints = false
        sampleRateSelector.translatesAutoresizingMaskIntoConstraints = false
        plotViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate(
            [plotContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             plotContainer.topAnchor.constraint(equalTo: view.topAnchor),
             plotContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             plotContainer.heightAnchor.constraint(equalTo: plotContainer.widthAnchor)])

        plotViews.enumerated().forEach { (index, plotView) in
            NSLayoutConstraint.activate(
                [plotView.leadingAnchor.constraint(equalTo: plotContainer.leadingAnchor),
                 plotView.trailingAnchor.constraint(equalTo: plotContainer.trailingAnchor)])

            NSLayoutConstraint.activate(
                [plotView.topAnchor.constraint(equalTo: plotContainer.topAnchor, constant: CGFloat(index) * 187.5),
                 plotView.bottomAnchor.constraint(equalTo: plotContainer.bottomAnchor,
                                                  constant: CGFloat(plotViews.count - (index + 1)) * -187.5)])
        }

        NSLayoutConstraint.activate(
            [selectorContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             selectorContainer.topAnchor.constraint(equalTo: plotContainer.bottomAnchor, constant: 16.0),
             selectorContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
             selectorContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [sampleRateValueView.leadingAnchor.constraint(equalTo: selectorContainer.leadingAnchor),
             sampleRateValueView.topAnchor.constraint(equalTo: selectorContainer.topAnchor),
             sampleRateValueView.trailingAnchor.constraint(equalTo: selectorContainer.trailingAnchor)])

        NSLayoutConstraint.activate(
            [sampleRateSelector.leadingAnchor.constraint(equalTo: selectorContainer.leadingAnchor),
             sampleRateSelector.trailingAnchor.constraint(equalTo: selectorContainer.trailingAnchor),
             sampleRateSelector.bottomAnchor.constraint(equalTo: selectorContainer.bottomAnchor)])

        // Lower priority constraints for smooth hiding of the selectors
        NSLayoutConstraint.activate(
            [sampleRateSelector.topAnchor.constraint(equalTo: sampleRateValueView.bottomAnchor, constant: 6.0)]
                .map { $0.priority = .defaultHigh; return $0 })

        view.layoutIfNeeded()
    }
}

extension DashboardOperationViewControllerEcg: SelectorSliderDelegate {

    func valueSelected(sender: UIControl, value: NSNumber) {
        switch sender {
        case sampleRateSelector:
            guard let row = (viewModel.parameters.enumerated().first { $0.element?.value == value.stringValue }) else {
                return
            }

            viewModel.requestMethod(DashboardMethod.subscribe, indices: [row.offset])
            viewModel.quantity = value.stringValue + " Hz"
            sampleRateValueView.value = value

        default: return
        }
    }
}

extension DashboardOperationViewControllerEcg: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let ecgEvent as DashboardObserverEventEcg: handleEventEcg(ecgEvent)
        case let containerEvent as DashboardObserverEventContainer: handleEventContainer(containerEvent)
        default: return
        }
    }

    func handleEventEcg(_ event: DashboardObserverEventEcg) {
        switch event {
        case .receivedEcg(let sample, let timestamp):
            DispatchQueue.main.async { self.plotSample(sample, timestamp: timestamp) }
        case .onError(let error): onError(error)
        }
    }

    func handleEventContainer(_ event: DashboardObserverEventContainer) {
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

extension DashboardOperationViewControllerEcg: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.parameters.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.parameters[row]?.description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.requestMethod(DashboardMethod.subscribe, indices: [row])
    }
}

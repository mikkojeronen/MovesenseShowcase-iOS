//
// SelectorSlider.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

protocol SelectorSliderDelegate: AnyObject {

    func valueSelected(sender: UIControl, value: NSNumber)
}

class SelectorSlider: UISlider {

    private let markersStackView: UIStackView
    private let selectableValues: [NSNumber]

    private var markerSize: CGSize?

    weak var delegate: SelectorSliderDelegate?

    init(values: [NSNumber]) {
        self.markersStackView = UIStackView(frame: CGRect.zero)
        self.selectableValues = values
        super.init(frame: CGRect.zero)

        addTarget(self, action: #selector(sliderUpdate(sender:)), for: .touchUpInside)

        isContinuous = false

        markersStackView.axis = .horizontal
        markersStackView.distribution = .equalSpacing
        markersStackView.spacing = 0.0
        markersStackView.isUserInteractionEnabled = false

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.trackRect(forBounds: bounds)
        guard let markerHeight = markerSize?.height else {
            return superRect
        }

        let customY = bounds.height - superRect.height - markerHeight / 2.0

        return CGRect(x: superRect.origin.x, y: customY,
                      width: superRect.width, height: superRect.height)
    }

    override func thumbRect(forBounds bounds: CGRect,
                            trackRect rect: CGRect,
                            value: Float) -> CGRect {
        let superRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        guard let markerWidth = markerSize?.width else {
            return superRect
        }

        let customX: CGFloat = (0.0 - markerWidth / 4) +
                               CGFloat(value) * (rect.width - markerWidth)

        return CGRect(x: customX, y: superRect.origin.y,
                      width: superRect.width, height: superRect.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // UISlider sets a height constraint that messes up layout, remove it
        if let heightConstraint = (constraints.first { $0.firstAnchor == heightAnchor }),
           heightConstraint.constant != 0.0 { // Exception: Hiding the view with a constraint
            removeConstraint(heightConstraint)
            updateConstraints()
        }
    }

    func selectValue(index: Int) {
        guard selectableValues.count > 0 else { return }

        let normalizedValues = selectableValues.enumerated()
            .map { Float($0.offset) / Float(selectableValues.count - 1) }

        if let normalizedValue = normalizedValues[safe: index] {
            value = normalizedValue
            sliderUpdate(sender: self)
        }
    }

    func setMarkerImages(markedImage: UIImage?, unmarkedImage: UIImage?) {
        setupMarkers(markedImage: markedImage, unmarkedImage: unmarkedImage)
    }

    private func setupMarkers(markedImage: UIImage?, unmarkedImage: UIImage?) {
        markersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        markerSize = markedImage?.size

        selectableValues.forEach { value in
            let containerView: UIView = UIView(frame: CGRect.zero)
            let markerView = UIImageView(image: unmarkedImage,
                                         highlightedImage: markedImage)
            markerView.contentMode = .scaleAspectFit

            let valueLabel = UILabel(with: UIFont.systemFont(ofSize: 8), inColor: .gray, text: value.stringValue)

            containerView.addSubview(valueLabel)
            containerView.addSubview(markerView)

            markersStackView.addArrangedSubview(containerView)

            containerView.translatesAutoresizingMaskIntoConstraints = false
            markerView.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate(
                [valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
                 valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)])

            NSLayoutConstraint.activate(
                [markerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                 markerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                 markerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)])

            // Lower priority flexible constraint
            let flex = markerView.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 16.0)
            flex.priority = .defaultLow
            flex.isActive = true
        }

        layoutSubviews()
    }

    @objc private func sliderUpdate(sender: UIControl) {
        guard let sliderValue: Float = (sender as? SelectorSlider)?.value,
              selectableValues.count > 1,
              markersStackView.arrangedSubviews.count == selectableValues.count else { return }

        let normalizedValues: [Float] = selectableValues.enumerated()
            .map { Float($0.offset) / Float(selectableValues.count - 1) }

        value = normalizedValues.reduce(Float(0.0)) { (result: Float, element: Float) in
            abs(element - sliderValue) < abs(result - sliderValue) ? element : result
        }

        // Configure markers
        selectableValues.enumerated().forEach { (index, _) in
            guard let views = markersStackView.arrangedSubviews[safe: index]?.subviews,
                  let marker: UIImageView = (views.first { $0 is UIImageView }) as? UIImageView,
                  let label: UILabel = (views.first { $0 is UILabel }) as? UILabel else { return }

            let relativePosition = Float(index) / Float(selectableValues.count - 1)

            if value == relativePosition {
                label.textColor = .black
                marker.isHighlighted = true
            } else if value > relativePosition {
                label.textColor = .gray
                marker.isHighlighted = true
            } else {
                label.textColor = .gray
                marker.isHighlighted = false
            }
        }

        let divider = Float(selectableValues.count - 1)
        if let (_, selectedValue) = (selectableValues.enumerated().first { Float($0.offset) / divider >= value }) {
            delegate?.valueSelected(sender: self, value: selectedValue)
        }
    }

    private func layoutView() {
        addSubview(markersStackView)

        markersStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [markersStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
             markersStackView.topAnchor.constraint(equalTo: topAnchor),
             markersStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
             markersStackView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}

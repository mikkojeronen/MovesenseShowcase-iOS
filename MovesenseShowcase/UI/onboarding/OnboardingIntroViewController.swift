//
// OnboardingIntroViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class OnboardingIntroViewController: UIViewController {

    private let nextViewController: UIViewController?

    private let skipButton: UIButton = UIButton(type: .system)
    private let continueButton: UIButton = UIButton(type: .system)

    private let fgScrollView: UIScrollView = UIScrollView()
    private let bgScrollView: UIScrollView = UIScrollView()
    private let pageControl: UIPageControl = UIPageControl()

    private let fgStackView: UIStackView = UIStackView()
    private let bgStackView: UIStackView = UIStackView()

    private let gradientLayer: CAGradientLayer = CAGradientLayer()

    private let fgScrollViewPages: [UIView] = [
        OnboardingIntroPageView(image: "image_intro_page_1_layer_1",
                                title: NSLocalizedString("ONBOARDING_INTRO_1_TITLE", comment: ""),
                                description: NSLocalizedString("ONBOARDING_INTRO_1_DESC", comment: "")),
        OnboardingIntroPageView(image: "image_intro_page_2_layer_1",
                                title: NSLocalizedString("ONBOARDING_INTRO_2_TITLE", comment: ""),
                                description: NSLocalizedString("ONBOARDING_INTRO_2_DESC", comment: "")),
        OnboardingIntroPageView(image: "image_intro_page_3_layer_1",
                                title: NSLocalizedString("ONBOARDING_INTRO_3_TITLE", comment: ""),
                                description: NSLocalizedString("ONBOARDING_INTRO_3_DESC", comment: "")),
        OnboardingIntroPageView(image: "image_intro_page_4_layer_1",
                                title: NSLocalizedString("ONBOARDING_INTRO_4_TITLE", comment: ""),
                                description: NSLocalizedString("ONBOARDING_INTRO_4_DESC", comment: ""))
    ]

    private let bgScrollViewPages: [UIView] = [
        OnboardingIntroPageView(image: "image_intro_page_1_layer_2",
                                title: "",
                                description: ""),
        OnboardingIntroPageView(image: "image_intro_page_2_layer_2",
                                title: "",
                                description: ""),
        OnboardingIntroPageView(image: "image_intro_page_3_layer_2",
                                title: "",
                                description: ""),
        OnboardingIntroPageView(image: "image_intro_page_4_layer_2",
                                title: "",
                                description: "")
    ]

    override var prefersStatusBarHidden: Bool {
        return nextViewController != nil
    }

    init(nextViewController: UIViewController?) {
        self.nextViewController = nextViewController
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true

        fgScrollView.isPagingEnabled = true
        fgScrollView.showsHorizontalScrollIndicator = false
        fgScrollView.delaysContentTouches = false
        fgScrollView.delegate = self

        bgScrollView.isUserInteractionEnabled = false
        bgScrollView.showsHorizontalScrollIndicator = false

        fgStackView.axis = .horizontal
        fgStackView.alignment = .fill

        bgStackView.axis = .horizontal
        bgStackView.alignment = .fill

        pageControl.numberOfPages = fgScrollViewPages.count
        pageControl.defersCurrentPageDisplay = true
        pageControl.addTarget(self, action: #selector(pageControlTapHandler), for: .touchUpInside)

        skipButton.alpha = 1.0
        skipButton.setTitle(NSLocalizedString("ONBOARDING_BUTTON_SKIP", comment: ""), for: .normal)
        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        skipButton.addTarget(self, action: #selector(handleSkipTap), for: .touchUpInside)

        continueButton.alpha = 0.0
        continueButton.setImage(UIImage(named: "icon_forward"), for: .normal)
        continueButton.setTitle(NSLocalizedString("ONBOARDING_BUTTON_CONTINUE", comment: ""), for: .normal)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        continueButton.tintColor = UIColor.white
        continueButton.addTarget(self, action: #selector(handleSkipTap), for: .touchUpInside)

        gradientLayer.colors = [UIColor.gradientStart.cgColor, UIColor.gradientEnd.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientLayer.frame = view.bounds

        continueButton.sizeToFit()

        if let buttonImageWidth = continueButton.imageView?.frame.size.width,
           let buttonTitleWidth = continueButton.titleLabel?.frame.size.width {
            continueButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -buttonImageWidth,
                                                          bottom: 0, right: buttonImageWidth)
            continueButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: buttonTitleWidth + 6.0,
                                                          bottom: 0, right: -buttonTitleWidth)
        }
    }

    @objc private func handleSkipTap() {
        Settings.isFirstLaunch = false

        if let nextViewController = nextViewController {
            navigationController?.pushViewController(nextViewController, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func pageControlTapHandler(sender: UIPageControl) {
        let pageWidth = fgScrollView.frame.size.width
        let pageRect = CGRect(x: pageWidth * CGFloat(sender.currentPage), y: fgScrollView.frame.origin.y,
                              width: pageWidth, height: fgScrollView.frame.size.height)
        fgScrollView.scrollRectToVisible(pageRect, animated: true)
    }

    private func layoutView() {
        view.addSubview(bgScrollView)
        view.addSubview(fgScrollView)
        view.addSubview(skipButton)
        view.addSubview(continueButton)
        view.addSubview(pageControl)

        bgScrollView.addSubview(bgStackView)
        fgScrollView.addSubview(fgStackView)

        bgScrollView.translatesAutoresizingMaskIntoConstraints = false
        fgScrollView.translatesAutoresizingMaskIntoConstraints = false
        bgStackView.translatesAutoresizingMaskIntoConstraints = false
        fgStackView.translatesAutoresizingMaskIntoConstraints = false
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [bgScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             bgScrollView.topAnchor.constraint(equalTo: view.topAnchor),
             bgScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             bgScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [fgScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             fgScrollView.topAnchor.constraint(equalTo: view.topAnchor),
             fgScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             fgScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [skipButton.heightAnchor.constraint(equalToConstant: 44.0),
             skipButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36.0),
             skipButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32.0)])

        NSLayoutConstraint.activate(
            [bgStackView.leadingAnchor.constraint(equalTo: bgScrollView.leadingAnchor),
             bgStackView.topAnchor.constraint(equalTo: bgScrollView.topAnchor),
             bgStackView.trailingAnchor.constraint(equalTo: bgScrollView.trailingAnchor),
             bgStackView.bottomAnchor.constraint(equalTo: bgScrollView.bottomAnchor),
             bgStackView.heightAnchor.constraint(equalTo: bgScrollView.heightAnchor)])

        NSLayoutConstraint.activate(
            [fgStackView.leadingAnchor.constraint(equalTo: fgScrollView.leadingAnchor),
             fgStackView.topAnchor.constraint(equalTo: fgScrollView.topAnchor),
             fgStackView.trailingAnchor.constraint(equalTo: fgScrollView.trailingAnchor),
             fgStackView.bottomAnchor.constraint(equalTo: fgScrollView.bottomAnchor),
             fgStackView.heightAnchor.constraint(equalTo: fgScrollView.heightAnchor)])

        NSLayoutConstraint.activate(
            [continueButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -10.0),
             continueButton.centerXAnchor.constraint(equalTo: pageControl.centerXAnchor)])

        NSLayoutConstraint.activate(
            [pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60.0)])

        fgScrollViewPages.forEach {
            fgStackView.addArrangedSubview($0)
            NSLayoutConstraint.activate([$0.heightAnchor.constraint(equalTo: fgScrollView.heightAnchor),
                                         $0.widthAnchor.constraint(equalTo: fgScrollView.widthAnchor)])
        }

        bgScrollViewPages.forEach {
            bgStackView.addArrangedSubview($0)
            NSLayoutConstraint.activate([$0.heightAnchor.constraint(equalTo: bgScrollView.heightAnchor),
                                         $0.widthAnchor.constraint(equalTo: bgScrollView.widthAnchor)])
        }

        view.layoutIfNeeded()
    }
}

extension OnboardingIntroViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage: Int = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))

        if currentPage != pageControl.currentPage {
            UIView.animate(withDuration: 0.2) {
                self.skipButton.alpha = (currentPage + 1) >= self.pageControl.numberOfPages ? 0.0 : 1.0
                self.continueButton.alpha = (currentPage + 1) >= self.pageControl.numberOfPages ? 1.0 : 0.0
            }

            pageControl.currentPage = currentPage
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.bgScrollView.setContentOffset(scrollView.contentOffset, animated: false)
        }
    }
}

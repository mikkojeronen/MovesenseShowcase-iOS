//
// AboutViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {

    private let scrollView: UIScrollView
    private let stackView: UIStackView

    private let aboutVideo: WKWebView
    private let aboutImage: UIImageView = UIImageView(image: UIImage(named: "image_about_video_placeholder"))
    private let aboutHome: IconLabel = IconLabel(labelIcon: UIImage(named: "icon_home"),
                                                 labelText: "movesense.com")
    private let aboutFacebook: IconLabel = IconLabel(labelIcon: UIImage(named: "icon_facebook"),
                                                     labelText: "MovesenseOfficial")
    private let aboutTwitter: IconLabel = IconLabel(labelIcon: UIImage(named: "icon_twitter"),
                                                    labelText: "MovesenseSensor")
    private let aboutLinkedin: IconLabel = IconLabel(labelIcon: UIImage(named: "icon_linkedin"),
                                                     labelText: "movesense")
    private let aboutLocation: IconLabel = IconLabel(labelIcon: UIImage(named: "icon_location"),
                                                     labelText: "Tammiston Kauppatie 7A\nFIN-01510 Vantaa Finland")
    private let aboutTextView: UITextView = UITextView(frame: CGRect.zero)

    init() {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsAirPlayForMediaPlayback = false
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.allowsPictureInPictureMediaPlayback = false

        self.aboutVideo = WKWebView(frame: CGRect.zero, configuration: webViewConfig)
        self.scrollView = UIScrollView(frame: CGRect.zero)
        self.stackView = UIStackView(frame: CGRect.zero)

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 0

        scrollView.backgroundColor = UIColor.white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = true

        aboutImage.isUserInteractionEnabled = true
        aboutImage.contentMode = .scaleAspectFit

        aboutVideo.navigationDelegate = self
        aboutVideo.isUserInteractionEnabled = true
        aboutVideo.contentMode = .scaleAspectFit
        aboutVideo.alpha = 0.0

        aboutTextView.isEditable = false
        aboutTextView.isScrollEnabled = false
        aboutTextView.showsVerticalScrollIndicator = false

        aboutHome.addTapGesture(tapNumber: 1, target: self, action: #selector(homeAction))
        aboutFacebook.addTapGesture(tapNumber: 1, target: self, action: #selector(facebookAction))
        aboutTwitter.addTapGesture(tapNumber: 1, target: self, action: #selector(twitterAction))
        aboutLinkedin.addTapGesture(tapNumber: 1, target: self, action: #selector(linkedinAction))
        aboutLocation.addTapGesture(tapNumber: 1, target: self, action: #selector(locationAction))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("ABOUT_NAV_TITLE", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain,
                                                           target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        let attributedAbout = NSMutableAttributedString(withLocalizedHTMLString: NSLocalizedString("ABOUT_TEXT_HTML",
                                                                                                   comment: ""))
        aboutTextView.attributedText = attributedAbout

        stackView.addArrangedSubview(aboutHome)
        stackView.addArrangedSubview(UIView.separator())
        stackView.addArrangedSubview(aboutFacebook)
        stackView.addArrangedSubview(UIView.separator())
        stackView.addArrangedSubview(aboutTwitter)
        stackView.addArrangedSubview(UIView.separator())
        stackView.addArrangedSubview(aboutLinkedin)
        stackView.addArrangedSubview(UIView.separator())
        stackView.addArrangedSubview(aboutLocation)
        stackView.addArrangedSubview(UIView.separator())
        stackView.addArrangedSubview(aboutTextView)

        if let url = URL(string: "https://www.youtube.com/embed/pyZ9rFE_9A8") {
            aboutVideo.load(URLRequest(url: url))
        }

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        aboutTextView.setContentOffset(CGPoint.zero, animated: false)
    }

    @objc private func backAction(sender: Any) {
        aboutVideo.stopLoading()
        navigationController?.popViewController(animated: true)
    }

    @objc private func homeAction(sender: Any) {
        if let url = URL(string: "https://www.movesense.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }

    @objc private func facebookAction(sender: Any) {
        openAppOrWeb(appUrl: "fb://page?id=MovesenseOfficial",
                     webUrl: "https://www.facebook.com/MovesenseOfficial/")
    }

    @objc private func twitterAction(sender: Any) {
        openAppOrWeb(appUrl: "twitter://user?screen_name=MovesenseSensor",
                     webUrl: "https://twitter.com/MovesenseSensor")
    }

    @objc private func linkedinAction(sender: Any) {
        openAppOrWeb(appUrl: "linkedin://company?id=movesense",
                     webUrl: "https://www.linkedin.com/company/movesense/")
    }

    @objc private func locationAction(sender: Any) {
        let locationUrl = """
                          https://maps.apple.com/?address=Tammiston%20kauppatie%207%20A,%2001510%20Vantaa,%20Finland\
                          &auid=16774440882250129317&ll=60.271823,24.972214&lsp=9902&q=Suunto
                          """

        if let url = URL(string: locationUrl) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func openAppOrWeb(appUrl: String, webUrl: String) {
        if let url = URL(string: appUrl) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else if let url = URL(string: webUrl) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

    private func layoutView() {
        view.addSubview(aboutImage)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        aboutImage.addSubview(aboutVideo)

        aboutImage.translatesAutoresizingMaskIntoConstraints = false
        aboutVideo.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [aboutImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             aboutImage.topAnchor.constraint(equalTo: view.topAnchor),
             aboutImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)])

        NSLayoutConstraint.activate(
            [scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             scrollView.topAnchor.constraint(equalTo: aboutImage.bottomAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
             scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [aboutVideo.leadingAnchor.constraint(equalTo: aboutImage.leadingAnchor),
             aboutVideo.topAnchor.constraint(equalTo: aboutImage.topAnchor),
             aboutVideo.trailingAnchor.constraint(equalTo: aboutImage.trailingAnchor),
             aboutVideo.bottomAnchor.constraint(equalTo: aboutImage.bottomAnchor)])

        NSLayoutConstraint.activate(
            [stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
             stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
             stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
             stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
             stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)])

        view.layoutIfNeeded()
    }
}

extension AboutViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.35) {
                self.aboutVideo.alpha = 1.0
            }
        }
    }
}

//
// FaqViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class FaqViewController: UIViewController {

    private let faqTextView: UITextView = UITextView()

    init() {
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white

        faqTextView.dataDetectorTypes = .link
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("FAQ_NAV_TITLE", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain,
                                                           target: self, action: #selector(backButtonTap))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        let attributedFaq = NSMutableAttributedString(withLocalizedHTMLString: NSLocalizedString("FAQ_TEXT_HTML",
                                                                                                 comment: ""))

        faqTextView.isEditable = false
        faqTextView.showsVerticalScrollIndicator = false
        faqTextView.attributedText = attributedFaq
        faqTextView.delegate = self

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        faqTextView.setContentOffset(CGPoint.zero, animated: false)
    }

    @objc private func backButtonTap(sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    private func layoutView() {
        view.addSubview(faqTextView)

        faqTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [faqTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             faqTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             faqTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
             faqTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        view.layoutIfNeeded()
    }
}

extension FaqViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "applink" {
            navigationController?.pushViewController(DfuHowToViewController(),
                                                     animated: true)
            return false
        }

        return true
    }
}

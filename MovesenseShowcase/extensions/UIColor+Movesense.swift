//
//  UIColor+Movesense.swift
//  MovesenseShowcase
//
//  Copyright © 2018 Suunto. All rights reserved.
//

import UIKit

private let alphaGrayColor = UIColor(red: 84 / 255, green: 82 / 255, blue: 82 / 255, alpha: 61 / 255)
private let confirmationBackgroundColor = UIColor(red: 0 / 255, green: 7 / 255, blue: 22 / 255, alpha: 0.5)
private let confirmationCancelColor = UIColor(red: 238 / 255, green: 49 / 255, blue: 38 / 255, alpha: 1.0)
private let darkGrayColor = UIColor(red: 36 / 255, green: 33 / 255, blue: 42 / 255, alpha: 1.0)
private let gradientEndColor: UIColor = UIColor(red: 220.0 / 255.0, green: 0.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)
private let gradientStartColor: UIColor = UIColor(red: 238.0 / 255.0, green: 49.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
private let lightGrayColor = UIColor(red: 48 / 255, green: 46 / 255, blue: 60 / 255, alpha: 1.0)
private let mediumGrayColor = UIColor(red: 48 / 255, green: 46 / 255, blue: 60 / 255, alpha: 1.0)
private let navigationBarWhiteColor = UIColor(red: 232 / 255, green: 232 / 255, blue: 232 / 255, alpha: 1.0)
private let progressIndicatorColor = UIColor(red: 77 / 255, green: 104 / 255, blue: 236 / 255, alpha: 1.0)
private let selectedGrayColor = UIColor(red: 210 / 255, green: 210 / 255, blue: 210 / 255, alpha: 1.0)
private let separatorGrayColor = UIColor(red: 229 / 255, green: 229 / 255, blue: 229 / 255, alpha: 1.0)
private let tabBarTintColor = UIColor.white
private let tabPageBackgroundColor = UIColor.lightGray
private let tabTintRedColor = UIColor(red: 238 / 255, green: 49 / 255, blue: 38 / 255, alpha: 1.0)
private let titleTextBlackColor = UIColor(red: 9 / 255, green: 9 / 255, blue: 9 / 255, alpha: 1.0)
private let warningTextColor = UIColor(red: 255 / 255, green: 142 / 255, blue: 0 / 255, alpha: 1.0)

extension UIColor {

    class var confirmationBackground: UIColor {
        return confirmationBackgroundColor
    }

    class var confirmationCancel: UIColor {
        return confirmationCancelColor
    }

    class var gradientStart: UIColor {
        return gradientStartColor
    }

    class var gradientEnd: UIColor {
        return gradientEndColor
    }

    class var labelBackground: UIColor {
        return alphaGrayColor
    }

    class var mainViewBackground: UIColor {
        return darkGrayColor
    }

    class var mainViewCardBackground: UIColor {
        return mediumGrayColor
    }

    class var navigationBarTint: UIColor {
        return navigationBarWhiteColor
    }

    class var progressIndicator: UIColor {
        return progressIndicatorColor
    }

    class var selectedGray: UIColor {
        return selectedGrayColor
    }

    class var separatorGray: UIColor {
        return separatorGrayColor
    }

    class var tabPageBackground: UIColor {
        return tabPageBackgroundColor
    }

    class var tabBarTint: UIColor {
        return tabBarTintColor
    }

    class var tabTint: UIColor {
        return tabTintRedColor
    }

    class var titleTextBlack: UIColor {
        return titleTextBlackColor
    }

    class var warningText: UIColor {
        return warningTextColor
    }
}

extension UIColor {

    static func colorWithGradient(frame: CGRect, colors: [UIColor],
                                  startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
                                  endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) -> UIColor? {

        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame
        backgroundGradientLayer.colors = colors.map { $0.cgColor }
        backgroundGradientLayer.startPoint = startPoint
        backgroundGradientLayer.endPoint = endPoint

        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
        defer { UIGraphicsEndImageContext() }

        guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
        backgroundGradientLayer.render(in: currentContext)

        if let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext() {
            return UIColor(patternImage: backgroundColorImage)
        } else {
            return nil
        }
    }
}

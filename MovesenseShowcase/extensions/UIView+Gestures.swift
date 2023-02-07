//
//  UIView+Gestures.swift
//  MovesenseShowcase
//
//  Copyright © 2018 Suunto. All rights reserved.
//

import UIKit

extension UIView {

    func addTapGesture(tapNumber: Int, cancelTouches: Bool = true,
                       target: Any, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = tapNumber
        tap.cancelsTouchesInView = cancelTouches

        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
}

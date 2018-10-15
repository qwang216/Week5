//
//  Double+Extensions.swift
//  Week5
//
//  Created by Jason wang on 10/10/18.
//  Copyright © 2018 JasonWang. All rights reserved.
//

import Foundation

extension Double {
    func string(fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

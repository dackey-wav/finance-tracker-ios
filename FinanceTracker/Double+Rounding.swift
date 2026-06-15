//
//  Double+Rounding.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import SwiftUI

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

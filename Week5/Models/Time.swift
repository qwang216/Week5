//
//  Time.swift
//  Week5
//
//  Created by Jason wang on 10/10/18.
//  Copyright © 2018 JasonWang. All rights reserved.
//

import Foundation

class Time {
    var secondCounter: TimeInterval = 0

    var seconds: TimeInterval {
        return  secondCounter >= 60 ? secondCounter.truncatingRemainder(dividingBy: 60) : secondCounter
    }

    var minutes : TimeInterval {
        let seconds = secondCounter / 60
        let minutes = seconds / 60
        return minutes >= 60 ? minutes.truncatingRemainder(dividingBy: 60) : minutes
    }

}

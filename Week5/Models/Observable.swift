//
//  Observable.swift
//  Week5
//
//  Created by Jason wang on 10/10/18.
//  Copyright © 2018 JasonWang. All rights reserved.
//

import Foundation

class Observable<T> {
    typealias Listener = (T) -> Void
    var listeners = [Listener]()

    var value: T {
        didSet {
            for listener in listeners {
                listener(value)
            }
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(_ listener: @escaping Listener) {
        self.listeners.append(listener)
        listener(value)
    }

}

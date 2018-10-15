//
//  TimerViewModel.swift
//  Week5
//
//  Created by Jason wang on 10/9/18.
//  Copyright © 2018 JasonWang. All rights reserved.
//

import Foundation

enum TimeState {
    case stopped
    case paused
    case running
}

extension TimeInterval {

}

class MyTimer {

    private var timer: Timer?

    public var timerFinished: (() -> Void)?

    public var currentTime = Observable<TimeInterval>(0)


    public func start() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decrementTime), userInfo: nil, repeats: true)
    }
    public func resume() {
        print("resume called")
        start()
    }
    public func pause() {
        print("paused time")
        timer?.invalidate()
    }
    public func reset(to time: TimeInterval) {
        pause()
        print("reset time to \(time)")
        currentTime.value = time
    }

    @objc
    private func decrementTime() {
        guard currentTime.value > 0 else {
            timer?.invalidate()
            timerFinished?()
            return
        }
        currentTime.value -= 1
    }

}

import AVFoundation
class VoiceTimer {
    private var countDownTimer = MyTimer()
    private let timer = MyTimer()
    public var currentTime: Observable<TimeInterval>

    init(startTimer: TimeInterval) {
        self.timer.reset(to: startTimer)
        self.currentTime = Observable<TimeInterval>(startTimer)
        countDownTimer.timerFinished = {
            let utterance = AVSpeechUtterance(string: "Go!")
            let voice = AVSpeechSynthesisVoice(language: "en-AU")
            utterance.voice = voice
            utterance.rate = 0.7
            AVSpeechSynthesizer().speak(utterance)
        }

        countDownTimer.currentTime.bind {
            guard $0 > 0 else { return }
            let utterance = AVSpeechUtterance(string: "\(Int($0))")
            let voice = AVSpeechSynthesisVoice(language: "en-AU")
            utterance.voice = voice
            utterance.rate = 0.9
            AVSpeechSynthesizer().speak(utterance)
        }

        timer.currentTime.bind { [weak self] in
            self?.currentTime.value = $0
            guard $0 >= 0 && $0 <= 5 else { return }
            let utterance = AVSpeechUtterance(string: "\(Int($0))")
            let voice = AVSpeechSynthesisVoice(language: "en-AU")
            utterance.voice = voice
            utterance.rate = 0.76
            AVSpeechSynthesizer().speak(utterance)
        }
        timer.timerFinished = {
            let utterance = AVSpeechUtterance(string: "Times up")
            let voice = AVSpeechSynthesisVoice(language: "en-AU")
            utterance.voice = voice
            utterance.rate = 0.5
            AVSpeechSynthesizer().speak(utterance)
        }

    }

    func startTimer(with delay: TimeInterval) {
        countDownTimer.reset(to: delay)
        countDownTimer.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 1) {
            self.timer.reset(to: self.currentTime.value)
            self.timer.start()
        }
    }

    public func updateTimer(to time: TimeInterval) {
        timer.currentTime.value = time
    }

    public func reset(to time: TimeInterval) {
        
        timer.reset(to: time)
    }

    public func pause() {
        countDownTimer.pause()
        timer.pause()
    }

    public func resume() {
        countDownTimer.resume()
        timer.resume()
    }

}

class TimerViewModel {

    var setMin = Observable<TimeInterval>(0)
    var setSec = Observable<TimeInterval>(0)
    var timeState = Observable<TimeState>(.stopped)
    let voiceTimer: VoiceTimer

    init(countDownTime: TimeInterval) {
        self.voiceTimer = VoiceTimer(startTimer: countDownTime)

        setMin.bind { [weak self] in
            guard let strongSelf = self else { return }
            let seconds = strongSelf.setSec.value
            strongSelf.voiceTimer.updateTimer(to: ($0 * 60) + seconds)
        }
        setSec.bind { [weak self] in
            guard let strongSelf = self else { return }
            let min = strongSelf.setMin.value
            strongSelf.voiceTimer.updateTimer(to: $0 + (min * 60))
        }

        voiceTimer.currentTime.bind { [weak self] in
            guard let strongSelf = self else { return }
            if $0 == 0 && strongSelf.timeState.value == .running {
                strongSelf.timeState.value = .stopped
                strongSelf.voiceTimer.currentTime.value = (strongSelf.setMin.value * 60) + strongSelf.setSec.value
            }
        }
    }

    func updateStarterTimer(to seconds: TimeInterval) {
        voiceTimer.reset(to: seconds)
    }

    func pause() {
        timeState.value = .paused
        voiceTimer.pause()
    }

    func resume() {
        timeState.value = .running
        voiceTimer.resume()
    }

    func start(with delayTime: TimeInterval = 3) {
        switch timeState.value {
        case .stopped, .paused:
            timeState.value = .running
            voiceTimer.startTimer(with: delayTime)
        case .running:
            timeState.value = .paused
            voiceTimer.pause()
        }
    }

    func reset() {
        timeState.value = .stopped
        voiceTimer.reset(to: (setMin.value * 60) + setSec.value)
    }

}

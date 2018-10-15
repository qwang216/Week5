//
//  TimerController.swift
//  Week5
//
//  Created by Jason wang on 10/9/18.
//  Copyright © 2018 JasonWang. All rights reserved.
//

import UIKit

extension TimeInterval {
    func formateTimeToString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: self) ?? "00:00"
    }
}

class TimerController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerPickerView: UIPickerView!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!

    var timerViewModel = TimerViewModel(countDownTime: 60)

    override func viewDidLoad() {
        super.viewDidLoad()

        startPauseButton.addTarget(self, action: #selector(handleStartPauseButtonTapped), for: .touchUpInside)
        startPauseButton.layer.cornerRadius = 50
        resetButton.addTarget(self, action: #selector(handleResetButtonTapped), for: .touchUpInside)
        resetButton.layer.cornerRadius = 50
        resumeButton.addTarget(self, action: #selector(handleResumeButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(handlePauseButtonTapped), for: .touchUpInside)


        timerViewModel.voiceTimer.currentTime.bind { [unowned self] in
            self.timerLabel.text = $0.formateTimeToString()
        }

        timerViewModel.timeState.bind { [unowned self] in

            switch $0 {
            case .stopped:
                self.startPauseButton.setTitle("Start", for: .normal)
                self.startPauseButton.isSelected = false
                self.resetButton.isEnabled = true
            case .running:
                self.startPauseButton.setTitle("Pause", for: .normal)
                self.startPauseButton.isSelected = false
                self.resetButton.isEnabled = false
            case .paused:
                self.startPauseButton.setTitle("Resume", for: .normal)
                self.startPauseButton.isSelected = true
                self.resetButton.isEnabled = true
            }

        }

        timerPickerView.delegate = self
    }

    @objc
    func handleResumeButtonTapped(button: UIButton) {
        timerViewModel.resume()
    }

    @objc
    func handlePauseButtonTapped(button: UIButton) {
        timerViewModel.pause()
    }

    @objc
    func handleStartPauseButtonTapped(button: UIButton) {

        timerViewModel.start()

    }

    @objc
    func handleResetButtonTapped(button: UIButton) {
        print("timer is is reset")
        timerViewModel.reset()
    }
}

extension TimerController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        let pluralUnit = row > 1 ? "s" : ""

        switch component {
        case 0:
            return "\(row) min\(pluralUnit)"
        default:
            return "\(row) sec\(pluralUnit)"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            timerViewModel.setMin.value = Double(row)
        case 1:
            timerViewModel.setSec.value = Double(row)
        default:
            print("pickview component not defined")
            break
        }
    }

}

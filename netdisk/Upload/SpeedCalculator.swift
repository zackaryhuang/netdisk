//
//  SpeedCalculator.swift
//  ABCloud
//
//  Created by Zackary on 2024/6/2.
//

import Cocoa

protocol SpeedCalculatorDelegate: NSObjectProtocol {
    func speedCalculator(speedDidUpdate speed: Int)
}

class SpeedCalculator: NSObject {
    var speedQueue = DispatchQueue(label: "com.bilibili.upos.speed")
    var timer: Timer?
    var lastCompletedUnitCount: Int64 = 0
    var currentCompletedUnitCount: Int64 = 0
    var preSpeed: Int = 0
    
    weak var delegate: SpeedCalculatorDelegate?
    
    private func startTimer() {
        stopTimer()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let timer = Timer(fire: Date.now, interval: 1, repeats: true, block: { [weak self] t in
                guard let self = self else { return }
                self.speedQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.onTimer()
                }
            })
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        }
    }
    
    private func stopTimer() {
        guard let timer = self.timer else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func start() {
        startTimer()
    }
    
    func stop() {
        stopTimer()
    }
    
    func updateCurrentCompletedUnitCount(count: Int64) {
        self.speedQueue.async { [weak self] in
            guard let self = self else { return }
            self.currentCompletedUnitCount = count
        }
    }
    
    private func onTimer() {
        if self.currentCompletedUnitCount > self.lastCompletedUnitCount {
            self.preSpeed = Int(self.currentCompletedUnitCount - self.lastCompletedUnitCount)
            self.lastCompletedUnitCount = self.currentCompletedUnitCount
            DispatchQueue.main.async {
                self.delegate?.speedCalculator(speedDidUpdate: self.preSpeed)
            }
        }
    }
}

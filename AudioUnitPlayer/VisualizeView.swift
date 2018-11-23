//
//  VisualizeView.swift
//  AudioUnitPlayer
//
//  Created by michal on 23/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

import UIKit

class VisualizeView: UIView {
    
    private let processQueue = DispatchQueue(label: "ProcessSamplesQueue")
    
    private var averages = [Float]()
    private var vertMiddle: CGFloat = 0
    override func draw(_ rect: CGRect) {
        showAverages()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        vertMiddle = self.frame.height / 2
    }
    
    func updateBuffer(_ samples: UnsafeBufferPointer<Float>) {
        processQueue.async {
            let count = Float(samples.count)
            let slices = 50
            let bucketSize = samples.count / slices
            
            var sum: Float = 0
            for i in 0..<slices {
                sum = 0
                for j in 0..<bucketSize {
                    sum += samples[i * j + j]
                }
                let average = sum / count
                self.averages.append(average)
            }
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }
    
    private func showAverages() {
        let path = UIBezierPath()
        
        let scale = Float(40000.0)
        path.move(to: CGPoint(x: 0, y: self.vertMiddle))
        for i in 0..<self.averages.count {
            path.addLine(to: CGPoint(x: CGFloat(i) * 0.3, y: vertMiddle - CGFloat(self.averages[i] * scale)))
        }
        UIColor.blue.setStroke()
        path.lineWidth = 2
        path.stroke()
    }
}

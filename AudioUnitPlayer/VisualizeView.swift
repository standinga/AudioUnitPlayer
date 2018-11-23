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
    private var lastXPosition: CGFloat = 0
    private var paths = [UIBezierPath]()
    
    override func draw(_ rect: CGRect) {
        clearsContextBeforeDrawing = false
        showAverages(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        vertMiddle = self.frame.height / 2
    }
    
    func updateBuffer(_ samples: UnsafeBufferPointer<Float>) {
        processQueue.sync {
            let count = Float(samples.count)
            let slices = 20
            let bucketSize = samples.count / slices
            
            var sum: Float = 0
            for i in 0..<slices {
                sum = 0
                for j in 0..<bucketSize {
                    sum += abs(samples[i * j + j])
                }
                let average = sum / count
                self.averages.append(average * 100)
            }
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }
    
    private func showAverages(_ rect: CGRect) {
        guard averages.count > 0 else {
            return
        }
        if lastXPosition > self.frame.width {
            lastXPosition = 0
            paths.removeAll()
        }
        let path = UIBezierPath(rect: rect)
        print(averages.count)
        let scale = Float(400.0)
        path.move(to: CGPoint(x: lastXPosition, y: vertMiddle - CGFloat(averages[0] * scale)))
        for i in 1..<averages.count {
            lastXPosition += CGFloat(i) * 0.1
            path.addLine(to: CGPoint(x: lastXPosition, y: vertMiddle - CGFloat(averages[i] * scale)))
        }
        UIColor.blue.setStroke()
        
        averages.removeAll()
        paths.append(path)
        paths.forEach {
            $0.lineWidth = 2
            $0.stroke()
        }
    }
}

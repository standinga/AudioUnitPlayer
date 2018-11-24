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
    private var paths = [UIBezierPath]()
    private var vertMiddle: CGFloat = 0
    private var lastXPosition: CGFloat = 0
    private var width: CGFloat = 0
    private var windowLength = 1.0
    
    override func draw(_ rect: CGRect) {
        clearsContextBeforeDrawing = false
        showAverages(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        vertMiddle = frame.height / 2
        width = frame.width
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
                self.averages.append(average * 10000)
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
        if lastXPosition > width {
            lastXPosition = 0
            paths.removeAll()
        }
        let path = UIBezierPath(rect: rect)
        print(averages.count)
        path.move(to: CGPoint(x: lastXPosition, y: vertMiddle - CGFloat(averages[0])))
        for i in 1..<averages.count {
            lastXPosition += CGFloat(i) * 0.1
            path.addLine(to: CGPoint(x: lastXPosition, y: vertMiddle - CGFloat(averages[i])))
        }
        UIColor.blue.setStroke()
        path.lineWidth = 2
        path.stroke()
        averages.removeAll()
//        paths.append(path)
//        paths.forEach {
//            $0.lineWidth = 2
//            $0.stroke()
//        }
    }
    
   
}

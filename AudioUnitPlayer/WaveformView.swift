//
//  WaveformView.swift
//  AudioUnitPlayer
//
//  Created by michal on 24/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

import Foundation
import GLKit

struct ColorGL {
    var r: GLfloat = 0.0
    var g: GLfloat = 0.0
    var b: GLfloat = 0.0
    var a: GLfloat = 0.0
}

struct Vertex {
    var x: GLfloat = 0.0
    var y: GLfloat = 0.0
    var z: GLfloat = 0.0
    var r: GLfloat = 0.0
    var g: GLfloat = 0.0
    var b: GLfloat = 0.0
    var a: GLfloat = 0.0
}

class WaveformView : GLKView {
    
    var samples = [Float]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
//        drawScatterPlot(samples)
    }
    
    private func drawPoint(_ v: Vertex, size: GLfloat) {
//        glPointSize(size)
//        glBegin(GLenum(GL_POINTS))
//        glColor4f(v.r, v.g, v.b, v.a)
//        glVertexAttrib3f(0, v.x, v.y, v.z   )
    }
    
    private func drawLineSegment(_ v1: Vertex, v2: Vertex, width: GLfloat) {
        glLineWidth(width)
        GL_LINES
    }
}

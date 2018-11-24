//
//  GLRenderer.swift
//  PrerecordCamera
//
//  Created by michal on 30/12/2017.
//  Copyright © 2017 borama. All rights reserved.
//

import Foundation
import GLKit
import OpenGLES

class GLView: GLKView {
    
    private var dataLength = 4096
    private var xPos: UnsafeMutableRawPointer!
    private var samplesData: UnsafeMutableRawPointer!
    private var glFloatStride = 0
    private var program: GLuint = 0
    private var vPositionHandle: GLuint = 0
    private var vValueHandle: GLuint = 0
    private var uFragColorHandle: GLuint = 0
    private var width: GLsizei = 0
    private var height: GLsizei = 0
    private var colorArray: [CGFloat] = [1,0,0,1]
    
    func setup() {
        if let currentContext = EAGLContext.init(api: .openGLES2) {
            
            let count = dataLength
            glFloatStride = MemoryLayout<GLfloat>.stride
            let alignment = MemoryLayout<GLfloat>.alignment
            let byteCount = glFloatStride * count
            
            xPos = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
            samplesData = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
            
            self.context = currentContext
            EAGLContext.setCurrent(currentContext)
            let loading = GLUtils.loadShaders(&program)
            if !loading {
                print("didn't load shaders")
                return
            }
            
            let handleValue = glGetAttribLocation(program, "vValue")
            guard handleValue != -1 else {
                fatalError("glGetAttribLocation vValue fail")
            }
            vValueHandle = GLuint(handleValue)
            let handlePosition =  glGetAttribLocation(program, "vPosition")
            guard handlePosition != -1 else {
                fatalError("glGetAttribLocation vPosition fail")
            }
            vPositionHandle = GLuint(handlePosition)
            let handleColor = glGetUniformLocation(program, "uFragColor")
            guard handleColor != -1 else {
                fatalError("glGetUniformLocation uFragColor fail")
            }
            uFragColorHandle = GLuint(handleColor)
            generateXPos()
        } else {
            print("failed to init opengl es2 context!")
        }
    }
    
    
    func updateBuffer(_ samples: UnsafeBufferPointer<Float>) {
        for i in 0..<dataLength {
            let val = GLfloat(samples[i])
            (samplesData + i * glFloatStride).storeBytes(of: val, as: GLfloat.self)
        }
        DispatchQueue.main.async {
            self.display()
        }
        
    }
    
    private func generateXPos() {
        for i in 0..<dataLength {
            let t: GLfloat = GLfloat(i) / GLfloat(dataLength - 1)
            let val = -1 * (1 - t) + 1 * t
            (xPos + i * glFloatStride).storeBytes(of: val, as: GLfloat.self)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        EAGLContext.setCurrent(context)
        glClearColor(1, 0.0, 0.0, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glUseProgram(program)
        
        glEnableVertexAttribArray(vPositionHandle)
        glVertexAttribPointer(vPositionHandle, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, xPos)
        
        glEnableVertexAttribArray(vValueHandle)
        glVertexAttribPointer(vValueHandle, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout.size(ofValue: GL_FLOAT)), samplesData)
        glVertexAttribPointer(vValueHandle, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout.size(ofValue: GL_FLOAT)), samplesData)
        
        glUniform4f(GLint(uFragColorHandle), 1,1,0,1)
        glDrawArrays(GLenum(GL_LINE_STRIP), 0, GLsizei(dataLength))
        
    }
}

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
import QuartzCore
import CoreMedia
import AVFoundation
import UIKit

let squareVertices0: [GLfloat] = [-1, -1, 1, -1, -1, 1, 1, 1]
let textureVertices:[GLfloat] = [1,1,1,0,0,1,0,0]
let squareVertices90:[GLfloat] = [-1,1,-1,-1,1,1,1,-1]
let squareVertices180:[GLfloat] = [1,1,-1,1,1,-1,-1,-1]
let squareVertices270:[GLfloat] = [1,-1,1,1,-1,-1,-1,1]

let ATTRIB_VERTEX: GLuint = 0
let ATTRIB_TEXCOORD: GLuint = 1

class GLUtils {
    
    static func tearDownGL(context: EAGLContext, program: inout GLuint, positionVBO: inout GLuint, texcoordVBO: inout GLuint, indexVBO: inout GLuint) {
        EAGLContext.setCurrent(context)
        glDeleteBuffers(1, &positionVBO)
        glDeleteBuffers(1, &texcoordVBO)
        glDeleteBuffers(1, &indexVBO)
        
        if program > 0 {
            glDeleteProgram(program)
            program = 0
        }
    }
    
    static func loadShaders(_ program: inout GLuint)->Bool {
        
        var vertexShader: GLuint = 0
        var fragShader: GLuint = 0
        
        // create shader program
        
        program = glCreateProgram()
        if let vertShaderPathname = Bundle.main.path(forResource: "Shader", ofType: "vsh") {
        
            vertexShader = compileShader(type: GLenum(GL_VERTEX_SHADER), fileName: vertShaderPathname)
            if vertexShader == 0 {
                print ("compile vertex shader failed")
                return false
            }
        }
        
        if let fragShaderPathName = Bundle.main.path(forResource: "Shader", ofType: "fsh") {
            
            fragShader = compileShader(type: GLenum(GL_FRAGMENT_SHADER), fileName: fragShaderPathName)
            if fragShader == 0 {
                print("compile fragment shader failed")
                return false
            }
        }
        
        // attach shaders to program:
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragShader)
        
        // bind attribute locations
//        glBindAttribLocation(program, ATTRIB_VERTEX, "vValue")
//        glBindAttribLocation(program, ATTRIB_VERTEX, "vPosition")
        

        
        // Link program:
        
        if !linkProgram(program) {
            glDeleteShader(vertexShader)
            vertexShader = 0
            
            glDeleteShader(fragShader)
            fragShader = 0
            
            glDeleteProgram(program)
            program = 0
            return false
        }
                
        // release vertex and fragment shaders
        
        glDetachShader(program, vertexShader)
        glDeleteShader(vertexShader)
        
        glDetachShader(program, fragShader)
        glDeleteShader(fragShader)
        return true
    }
    
    private static func compileShader(type: GLenum, fileName: String)->GLuint {
        var status: GLint = -1
        var shaderHandle: GLuint = 0
        do {
            var source = try NSString.init(contentsOfFile: fileName, encoding: String.Encoding.utf8.rawValue).utf8String
            
            shaderHandle = glCreateShader(type)
            
            glShaderSource(shaderHandle, 1, &source, nil)
            glCompileShader(shaderHandle)
            
            var logLength: GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(shaderHandle, logLength, &logLength, log)
                let logString = NSString.init(utf8String: log)
                print ("error compiling shader at \(#line): \(logString ?? "")")
                return 0
            }
            glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &status)
            if (status == 0) {
                glDeleteShader(shaderHandle)
                print("error compiling shader at: \(#line)")
                return 0
            }
        } catch {
            return 0
        }
        return shaderHandle
    }
    
    private static func linkProgram(_ prog: GLuint)->Bool {
        
        var logLength: GLint = 0
        
        glLinkProgram(prog)
        
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            let log:  UnsafeMutablePointer<GLchar> = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
            glGetProgramInfoLog(prog, logLength, &logLength, log)
            let logString = NSString.init(utf8String: log)
            print("error linking program at \(#line): \(logString ?? "")")
            return false
        }
        return true
    }
    
    private static func validateProgram(_ prog: GLuint)->Bool {
        var logLength: GLint = 0
        var status: GLint = 1

        glValidateProgram(prog)
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        
        if logLength > 0 {
            let log: UnsafeMutablePointer<GLchar> = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
            glGetProgramInfoLog(prog, logLength, &logLength, log)
            let logString = NSString.init(utf8String: log)
            print("error validating program at: \(#line): \(logString ?? "")")
            return false
        }
        glGetProgramiv(prog, GLenum(GL_VALIDATE_STATUS), &status)
        if status == 0 {
            return false
        }
        return true
    }
}

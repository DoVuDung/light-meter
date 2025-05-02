//
//  CameraManager.swift
//  Light Meter
//
//  Created by Dung Do on 2/5/25.
//

import Foundation
import AVFoundation

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var brightness: Float = 0.0
    let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private var currentInput: AVCaptureDeviceInput?

    func configureCamera(position: AVCaptureDevice.Position) {
        session.beginConfiguration()
        session.sessionPreset = .medium
        
        if let currentInput = currentInput {
            session.removeInput(currentInput)
        }
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Không tìm thấy camera")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    func switchCamera(to position: AVCaptureDevice.Position) {
        configureCamera(position: position)
    }

    // Lấy độ sáng
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let metadata = CMGetAttachment(sampleBuffer, key: kCGImagePropertyExifDictionary, attachmentModeOut: nil) as? NSDictionary,
              let brightnessValue = metadata[kCGImagePropertyExifBrightnessValue] as? Float else { return }
        
        DispatchQueue.main.async {
            // Convert brightness value sang lux (ước tính đơn giản)
            self.brightness = pow(2.0, brightnessValue + 3) * 2
        }
    }
}

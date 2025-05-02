//
//  LightMeter.swift
//  Light Meter
//
//  Created by Dung Do on 2/5/25.
//

import Foundation
import AVFoundation
import Combine

class LightMeter: NSObject, ObservableObject {
    @Published var luxValue: Double = 0.0

    private var captureSession: AVCaptureSession?
    private var videoDevice: AVCaptureDevice?
    private var cancellable: AnyCancellable?

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        if let device = AVCaptureDevice.default(for: .video) {
            videoDevice = device
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }

                let output = AVCaptureVideoDataOutput()
                if captureSession.canAddOutput(output) {
                    captureSession.addOutput(output)
                }

                captureSession.startRunning()

                // Observe brightness via exposureTargetOffset (approximation)
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    do {
                        try device.lockForConfiguration()
                        // ... your code ...
                        device.unlockForConfiguration()
                    } catch {
                        print("Failed to lock configuration: \(error)")
                    }

                    let iso = device.iso
                    let exposureDuration = device.exposureDuration.seconds
                    let brightness = (iso * Float(exposureDuration))
                    DispatchQueue.main.async {
                        self.luxValue = Double(brightness * 1000) // scale up to simulate lux
                    }
                    device.unlockForConfiguration()
                }

            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
}

//
//  test.swift
//  Light Meter
//
//  Created by Dung Do on 2/5/25.
//

import AVFoundation
import SwiftUI

class LightSensorManager: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var videoDevice: AVCaptureDevice?
    private var timer: Timer?

    @Published var luxValue: Double = 0.0

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(for: .video) else {
            print("Không tìm thấy camera")
            return
        }
        videoDevice = device

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if (captureSession?.canAddInput(input) == true) {
                captureSession?.addInput(input)
            }
        } catch {
            print("Lỗi setup camera: \(error)")
        }
    }

    func startMeasuring() {
        captureSession?.startRunning()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.readLightValue()
        }
    }

    func stopMeasuring() {
        captureSession?.stopRunning()		
        timer?.invalidate()
        timer = nil
    }

    private func readLightValue() {
        guard let device = videoDevice else { return }

        let iso = Double(device.iso)
        let exposureDuration = device.exposureDuration.seconds
        let aperture = Double(device.lensAperture)

        let ev = log2((aperture * aperture) / exposureDuration)
        let estimatedLux = (pow(2, ev) * 2.5) / iso * 100

        DispatchQueue.main.async {
            self.luxValue = max(estimatedLux, 0)
        }
    }

}

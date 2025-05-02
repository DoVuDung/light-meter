//
//  CameraPreview.swift
//  Light Meter
//
//  Created by Dung Do on 2/5/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    var selectedCamera: Int

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        context.coordinator.setupCamera(in: view, useFront: selectedCamera == 1)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.setupCamera(in: uiView, useFront: selectedCamera == 1)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator {
        var session: AVCaptureSession?

        func setupCamera(in view: UIView, useFront: Bool) {
            session?.stopRunning()

            let session = AVCaptureSession()
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: useFront ? .front : .back) else {
                print("Không tìm thấy camera")
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.frame = view.bounds
                previewLayer.videoGravity = .resizeAspectFill

                // Xoá layer cũ nếu có
                view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                view.layer.addSublayer(previewLayer)

                session.startRunning()
                self.session = session
            } catch {
                print("Lỗi camera: \(error)")
            }
        }
    }
}

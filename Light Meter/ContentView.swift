//
//  ContentView.swift
//  Light Meter
//
//  Created by Dung Do on 2/5/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var selectedCamera: AVCaptureDevice.Position = .back

    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
                .onAppear {
                    cameraManager.configureCamera(position: selectedCamera)
                }
            
            VStack {
                Spacer()
                
                // Hiển thị độ sáng
                VStack {
                    Text("Độ sáng hiện tại")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(String(format: "%.2f", cameraManager.brightness)) Lux")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(colorForBrightness(cameraManager.brightness))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.2))
                        )
                        .scaleEffect(1 + CGFloat(cameraManager.brightness / 500))
                        .animation(.easeInOut, value: cameraManager.brightness)
                    
                    // Tiêu chuẩn môi trường
                    Text(environmentDescription(for: cameraManager.brightness))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }
                .padding()
                .background(BlurView(style: .systemThinMaterialDark))
                .cornerRadius(20)
                .padding()
                
                // Nút đổi camera
                Picker("Camera", selection: $selectedCamera) {
                    Text("Camera Sau").tag(AVCaptureDevice.Position.back)
                    Text("Camera Trước").tag(AVCaptureDevice.Position.front)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedCamera) { newPosition in
                    cameraManager.switchCamera(to: newPosition)
                }
            }
        }
    }
    
    // Màu theo độ sáng
    func colorForBrightness(_ brightness: Float) -> Color {
        switch brightness {
        case 0..<100:
            return .blue
        case 100..<500:
            return .green
        case 500..<1000:
            return .orange
        default:
            return .red
        }
    }
    
    // Mô tả môi trường ánh sáng
    func environmentDescription(for brightness: Float) -> String {
        switch brightness {
        case 0..<50:
            return "Ánh sáng yếu (ban đêm, trong nhà tối)"
        case 50..<300:
            return "Ánh sáng trong nhà"
        case 300..<1000:
            return "Ánh sáng ngoài trời (trời râm)"
        default:
            return "Ánh sáng mạnh (trời nắng gắt)"
        }
    }
}


// Blur View
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

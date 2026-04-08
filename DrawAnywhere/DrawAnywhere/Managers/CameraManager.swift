//
//  CameraManager.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 28/03/2026.
//

import SwiftUI
internal import AVFoundation
import Combine
import CoreHaptics

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData)
        else {
            print("Failed to convert photo to image")
            return
        }
        
        
        Task { @MainActor in
            self.capturedImage = IdentifiableImage(image: uiImage)
        }
    }
}

class CameraManager: NSObject, ObservableObject {
    
    @Published var capturedImage: IdentifiableImage?
    @Published var isSessionRunning: Bool = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    // AVFoundation components
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    
    override init() {
        super.init()
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationStatus = .authorized
            setupSession()
        case .notDetermined:
            authorizationStatus = .notDetermined
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        case .denied, .restricted:
            authorizationStatus = .denied
            
        @unknown default:
        authorizationStatus = .denied
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: camera) else {
                print("Cannot access camera")
                self.session.commitConfiguration()
                return
            }
            if session.canAddInput(input) {
                self.session.addInput(input)
                self.currentInput = input
            }
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                
                self.photoOutput.maxPhotoQualityPrioritization =  .quality
            }
            
            self.session.commitConfiguration()
            if isSessionRunning {
                startSession()
            }
        }
        
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
                Task { @MainActor in
                    self.isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
    }
    
    func capturePhoto() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            

            self.photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
}

struct IdentifiableImage: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
}

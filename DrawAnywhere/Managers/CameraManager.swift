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
import Photos

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
            if saveCapturedPicturesToGallery {
                await save(photo: photo)
            }
            haptics?.playHeartbeat()
            self.capturedImage = IdentifiableImage(image: uiImage)
        }
    }
}

class CameraManager: NSObject, ObservableObject {
    
    @Published var capturedImage: IdentifiableImage?
    @Published var isSessionRunning: Bool = false
    @Published var saveCapturedPicturesToGallery: Bool = true
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    // AVFoundation components
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    private var haptics: HapticsManager?
    
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    
    override init() {
        super.init()
    }
    
    var isPhotoLibraryReadWriteAccessGranted: Bool {
        get async {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            
            // Determine if the user previously authorized read/write access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
            }
            
            return isAuthorized
        }
    }
    
    private func save(photo: AVCapturePhoto) async {
        // Confirm the user granted read/write access.
        guard await isPhotoLibraryReadWriteAccessGranted else { return }
        
        // Create a data representation of the photo and its attachments.
        if let photoData = photo.fileDataRepresentation() {
            PHPhotoLibrary.shared().performChanges {
                // Save the photo data.
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photoData, options: nil)
            } completionHandler: { success, error in
                if let error {
                    print("Error saving photo: \(error.localizedDescription)")
                    return
                }
            }
        }
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
        haptics = HapticsManager()
        
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

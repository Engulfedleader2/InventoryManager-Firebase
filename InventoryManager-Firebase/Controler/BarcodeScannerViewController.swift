//
//  BarcodeScannerViewController.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/5/24.
//

import AVFoundation
import SwiftUI

class BarcodeScannerViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var scannedCode: Binding<String?>?
    var selectedTab: Binding<Int>?
    var delegate: AVCaptureMetadataOutputObjectsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Only set up the camera if not running in a preview
        #if !targetEnvironment(simulator)
        if !isRunningInPreview {
            setupCamera()
        }
        #endif
    }

    func setupCamera() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Failed to add input to capture session")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.code39]
        } else {
            print("Failed to add output to capture session")
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets
        let availableHeight = view.bounds.height - safeAreaInsets.bottom - 100 // Adjust 100 for tab bar height and spacing
        previewLayer?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: availableHeight)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if !targetEnvironment(simulator)
        if !(captureSession?.isRunning ?? false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if !targetEnvironment(simulator)
        if captureSession?.isRunning ?? false {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.stopRunning()
            }
        }
        #endif
    }

    // Helper to detect if we're running in SwiftUI Preview mode
    var isRunningInPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }
}

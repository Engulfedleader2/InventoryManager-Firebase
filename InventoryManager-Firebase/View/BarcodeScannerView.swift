//
//  BarcodeScannerView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var selectedTab: Int // Binding to control which tab is selected
    @Environment(\.presentationMode) var presentationMode // Add this line to access presentation mode

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.scannedCode = $scannedCode
        viewController.selectedTab = $selectedTab

        // Set the coordinator as the delegate
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView

        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }

                // Move to the LogItemsView tab (tag 1) and dismiss the camera
                DispatchQueue.main.async {
                    print("Scanned code: \(stringValue)") // Print for debugging
                    self.parent.scannedCode = stringValue
                    self.parent.selectedTab = 1 // Automatically switch to LogItemsView tab
                    self.parent.presentationMode.wrappedValue.dismiss() // Dismiss camera view after scan
                }
            }
        }
    }
}

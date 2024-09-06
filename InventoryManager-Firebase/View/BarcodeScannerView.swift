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

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.delegate = context.coordinator  // Set the delegate to the coordinator
        viewController.scannedCode = $scannedCode
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
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // Optional vibration feedback

                // Print the type of barcode and its value
                print("Scanned Barcode Type: \(readableObject.type)")
                print("Scanned Barcode Value: \(stringValue)")

                // Update the scanned code and switch to the LogItemsView tab
                DispatchQueue.main.async {
                    self.parent.scannedCode = stringValue
                    self.parent.selectedTab = 1 // Automatically switch to the LogItemsView tab

                    // Reset the scanned code after switching tabs to prevent further automatic tab changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.parent.scannedCode = nil
                    }
                }
            }
        }
    }
}
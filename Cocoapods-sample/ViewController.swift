//
//  ViewController.swift
//  Cocoapods-sample
//
//  Created by Supawit Ruen on 22/11/2563 BE.
//

import UIKit
import LocalAuthentication
import AVFoundation

class ViewController: UIViewController {
    
    private let biometricButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Biometrics", for: .normal)
        return button
    }()
    
    private let openCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Camera", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        AF.request("https://httpbin.org/get").response { response in
        //            debugPrint(response)
        //        }
        
        biometricButton.frame = CGRect(x: 0, y: 200, width: 200, height: 200)
        openCameraButton.frame = CGRect(x: 0, y: 400, width: 200, height: 200)
        view.addSubview(biometricButton)
        view.addSubview(openCameraButton)
        
        biometricButton.addTarget(self, action: #selector(onBiometricButton), for: .touchUpInside)
        openCameraButton.addTarget(self, action: #selector(onOpenCameraButton), for: .touchUpInside)
    }
    
    @objc func onOpenCameraButton() {
        present(CameraPerviewViewController(), animated: true, completion: .none)
    }
    
    /// import LocalAuthentication
    @objc func onBiometricButton() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log In") { success, error in
                if success {
                    print("biometrics success")
                } else {
                    guard let _error = error else { return }
                    print("biometrics fail :: \(_error)")
                }
            }
        } else {
            print("biometrics not support")
        }
    }
    
}

import Photos
/// import AVFoundation

class CameraPerviewViewController: UIViewController {
    private var session: AVCaptureSession?
    private let photoOutput: AVCapturePhotoOutput = {
        let output = AVCapturePhotoOutput()
        output.isHighResolutionCaptureEnabled = true
        return output
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCamara()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session?.stopRunning()
    }
    
    private func startPreview() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInDualCamera, .builtInDualWideCamera, .builtInTripleCamera, .builtInTelephotoCamera, .builtInTrueDepthCamera,
                          .builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTripleCamera],
            mediaType: .video,
            position: .front
        )
        let devices = discoverySession.devices
        
//        guard let captureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else { return }
        guard let captureDevice = devices.first else { return }
        
        let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        
        self.session = AVCaptureSession()
        self.session?.sessionPreset = .hd1920x1080
        self.session?.addInput(deviceInput!)
        self.session?.commitConfiguration()
        
        DispatchQueue.main.async {
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.session!)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = self.view.frame
            
            self.view.layer.addSublayer(previewLayer)
            self.session?.startRunning()
        }
    }
    
    private func startCamara() {
        guard !(session?.isRunning ?? false) else { return }

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.startPreview()
            break
        case .notDetermined: // open permission dialog
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                guard granted else { return }
                self.startPreview()
                
            }
        
        default:
            break
        
        }
    }
}

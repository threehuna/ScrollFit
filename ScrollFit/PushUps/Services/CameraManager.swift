// CameraManager.swift
// ScrollFit

import AVFoundation

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer)
}

final class CameraManager: NSObject {

    // MARK: - Public

    weak var delegate: CameraManagerDelegate?

    private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - Private

    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()

    /// Serial queue for session configuration — must not block main thread.
    private let sessionQueue = DispatchQueue(
        label: "com.scrollfit.camera.session",
        qos: .userInitiated
    )

    /// Dedicated queue for sample buffer delivery.
    private let outputQueue = DispatchQueue(
        label: "com.scrollfit.camera.output",
        qos: .userInteractive
    )

    // MARK: - Setup

    func setupAndStart(completion: @escaping (Result<Void, CameraError>) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            do {
                try self.configure()
                self.session.startRunning()
                DispatchQueue.main.async { completion(.success(())) }
            } catch let error as CameraError {
                DispatchQueue.main.async { completion(.failure(error)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.unknown(error))) }
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    /// Creates a preview layer backed by this session. Call once before adding to view hierarchy.
    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.previewLayer = layer
        return layer
    }

    // MARK: - Configuration

    private func configure() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        // 640×480 даёт Vision в 4 раза меньше пикселей → значительно быстрее детекция
        session.sessionPreset = .vga640x480

        // Front camera input
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            throw CameraError.deviceUnavailable
        }
        session.addInput(input)

        // Video data output
        videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]

        guard session.canAddOutput(videoOutput) else {
            throw CameraError.outputUnavailable
        }
        session.addOutput(videoOutput)

        // Portrait orientation on both connections
        if let outputConn = videoOutput.connection(with: .video) {
            if outputConn.isVideoOrientationSupported {
                outputConn.videoOrientation = .portrait
            }
            // Mirror the pixel buffer so Vision coordinates match the (auto-mirrored) preview.
            if outputConn.isVideoMirroringSupported {
                outputConn.isVideoMirrored = true
            }
        }

        if let previewConn = previewLayer?.connection {
            if previewConn.isVideoOrientationSupported {
                previewConn.videoOrientation = .portrait
            }
        }
    }

    // MARK: - Errors

    enum CameraError: LocalizedError {
        case deviceUnavailable
        case outputUnavailable
        case unknown(Error)

        var errorDescription: String? {
            switch self {
            case .deviceUnavailable:  return "Камера недоступна на этом устройстве."
            case .outputUnavailable:  return "Не удалось настроить видеовыход камеры."
            case .unknown(let e):     return e.localizedDescription
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        delegate?.cameraManager(self, didOutput: sampleBuffer)
    }
}

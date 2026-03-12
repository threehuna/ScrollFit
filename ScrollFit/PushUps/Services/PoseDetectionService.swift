// PoseDetectionService.swift
// ScrollFit

import Vision
import CoreMedia

protocol PoseDetectionServiceDelegate: AnyObject {
    func poseDetectionService(
        _ service: PoseDetectionService,
        didDetect observation: VNHumanBodyPoseObservation?
    )
}

/// Wraps VNDetectHumanBodyPoseRequest and throttles processing to avoid queue saturation.
final class PoseDetectionService {

    // MARK: - Public

    weak var delegate: PoseDetectionServiceDelegate?

    // MARK: - Private

    private var request: VNDetectHumanBodyPoseRequest?

    /// Guards against processing the next frame before the previous result is dispatched.
    private var isProcessing = false

    // MARK: - Setup

    func setup() {
        request = VNDetectHumanBodyPoseRequest()
    }

    // MARK: - Processing

    /// Called on the camera output queue. Drops frames if still busy.
    func process(sampleBuffer: CMSampleBuffer) {
        guard !isProcessing, let request else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        isProcessing = true

        // The buffer is already portrait-oriented and mirrored by CameraManager.
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        do {
            try handler.perform([request])
            let observation = request.results?.first
            // Сбрасываем флаг немедленно на outputQueue (не ждём main thread),
            // чтобы следующий кадр начал обрабатываться как можно скорее.
            isProcessing = false
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.poseDetectionService(self, didDetect: observation)
            }
        } catch {
            isProcessing = false
        }
    }
}

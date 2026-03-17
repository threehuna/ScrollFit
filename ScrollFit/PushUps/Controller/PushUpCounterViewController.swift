// PushUpCounterViewController.swift
// ScrollFit

import UIKit
import AVFoundation
import Vision

final class PushUpCounterViewController: UIViewController {

    // MARK: - Coordinator callbacks

    /// Пользователь нажал «Отмена» (0 отжиманий).
    var onCancel: (() -> Void)?
    /// Пользователь нажал «Получить N мин.» — передаёт количество отжиманий.
    var onFinish: ((Int) -> Void)?

    // MARK: - Dependencies

    private let cameraManager         = CameraManager()
    private let poseDetectionService  = PoseDetectionService()
    private let poseSmoother          = PoseSmoother()
    private let pushUpAnalyzer        = PushUpAnalyzer()
    private let audioFeedbackService  = AudioFeedbackService()

    // MARK: - UI

    private let gradientLayer = CAGradientLayer()

    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let logoImageView: UIImageView = {
        let image  = UIImage(named: "scrollFitLogo")
        image?.withRenderingMode(.alwaysOriginal)
        let view   = UIImageView(image: image)
        view.tintColor = UIColor(.scrollFitGreen)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ScrollFit"
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cameraContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.1, alpha: 1)
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let instructionBarView = InstructionBarView()
    private let skeletonOverlayView = SkeletonOverlayView()
    private let repCounterView = RepCounterView()

    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Отмена", for: .normal)
        btn.setTitleColor(UIColor(.scrollFitWhite), for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        btn.backgroundColor = UIColor(.scrollFitGreen)
        btn.layer.cornerRadius = 31
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupHierarchy()
        setupLayout()
        setupActions()
        setupServices()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = cameraContainerView.bounds
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestCameraAccessAndStart()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraManager.stop()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup Hierarchy

    private func setupHierarchy() {
        view.layer.insertSublayer(gradientLayer, at: 0)

        view.addSubview(headerView)
        headerView.addSubview(logoImageView)
        headerView.addSubview(titleLabel)

        view.addSubview(cameraContainerView)
        cameraContainerView.addSubview(skeletonOverlayView)
        cameraContainerView.addSubview(instructionBarView)
        cameraContainerView.addSubview(repCounterView)

        view.addSubview(cancelButton)
    }

    // MARK: - Setup Layout

    private func setupLayout() {
        skeletonOverlayView.translatesAutoresizingMaskIntoConstraints = false
        instructionBarView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 68),

            // Logo + Title (centered together in headerView)
            logoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -8),
            logoImageView.widthAnchor.constraint(equalToConstant: 42),
            logoImageView.heightAnchor.constraint(equalToConstant: 42),

            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 20),

            // Camera container
            cameraContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            cameraContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),
            cameraContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2),
            cameraContainerView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -12),

            // Instruction bar inside camera container (top)
            instructionBarView.topAnchor.constraint(equalTo: cameraContainerView.topAnchor, constant: 16),
            instructionBarView.leadingAnchor.constraint(equalTo: cameraContainerView.leadingAnchor, constant: 16),
            instructionBarView.trailingAnchor.constraint(equalTo: cameraContainerView.trailingAnchor, constant: -16),
            instructionBarView.heightAnchor.constraint(equalToConstant: 58),

            // Skeleton overlay (full camera area)
            skeletonOverlayView.topAnchor.constraint(equalTo: cameraContainerView.topAnchor),
            skeletonOverlayView.leadingAnchor.constraint(equalTo: cameraContainerView.leadingAnchor),
            skeletonOverlayView.trailingAnchor.constraint(equalTo: cameraContainerView.trailingAnchor),
            skeletonOverlayView.bottomAnchor.constraint(equalTo: cameraContainerView.bottomAnchor),

            // Rep counter (bottom center of camera area)
            repCounterView.centerXAnchor.constraint(equalTo: cameraContainerView.centerXAnchor),
            repCounterView.bottomAnchor.constraint(equalTo: cameraContainerView.bottomAnchor, constant: -16),

            // Cancel button
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 39),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -39),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 62),
        ])
    }

    // MARK: - Setup Appearance

    private func setupGradient() {
        let darkTop  = UIColor(.scrollFitBlack).cgColor
        let grayBot  = UIColor(.scrollFitGray).cgColor  
        gradientLayer.colors     = [darkTop, grayBot]
        gradientLayer.locations  = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.2)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
    }

    // MARK: - Setup Actions

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
    }

    // MARK: - Setup Services

    private func setupServices() {
        audioFeedbackService.setup()
        poseDetectionService.setup()
        poseDetectionService.delegate = self
        cameraManager.delegate = self

        repCounterView.setCount(0)
        instructionBarView.setText("Расположи телефон на полу перед собой")
    }

    // MARK: - Camera

    private func requestCameraAccessAndStart() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            startCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.startCamera() }
                    else       { self?.showPermissionDenied() }
                }
            }
        case .denied, .restricted:
            showPermissionDenied()
        @unknown default:
            break
        }
    }

    private func startCamera() {
        // Attach preview layer before starting session
        let previewLayer = cameraManager.makePreviewLayer()
        previewLayer.frame = cameraContainerView.bounds
        cameraContainerView.layer.insertSublayer(previewLayer, at: 0)

        cameraManager.setupAndStart { [weak self] result in
            if case .failure(let error) = result {
                self?.showAlert(title: "Ошибка камеры", message: error.localizedDescription)
            }
        }
    }

    // MARK: - Actions

    @objc private func primaryButtonTapped() {
        let count = pushUpAnalyzer.repCount
        cameraManager.stop()
        pushUpAnalyzer.reset()
        poseSmoother.reset()
        if count == 0 {
            onCancel?()
        } else {
            onFinish?(count)
        }
    }

    // MARK: - UI Update

    private func apply(_ result: PushUpAnalysisResult) {
        repCounterView.setCount(result.repCount)
        instructionBarView.setText(result.instructionText)
        updatePrimaryButton(repCount: result.repCount)

        if result.didCompleteRep {
            repCounterView.animatePulse()
            audioFeedbackService.playRepCompleted()
        }
    }

    private func updatePrimaryButton(repCount: Int) {
        if repCount == 0 {
            cancelButton.setTitle("Отмена", for: .normal)
        } else {
            let minutes = repCount * ActivityRepository.shared.scrollMinutesPerPushUp
            cancelButton.setTitle("Получить \(minutes) мин.", for: .normal)
        }
    }

    // MARK: - Alerts

    private func showPermissionDenied() {
        let alert = UIAlertController(
            title: "Нет доступа к камере",
            message: "Разрешите доступ к камере в Настройках, чтобы считать отжимания.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CameraManagerDelegate

extension PushUpCounterViewController: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer) {
        poseDetectionService.process(sampleBuffer: sampleBuffer)
    }
}

// MARK: - PoseDetectionServiceDelegate

extension PushUpCounterViewController: PoseDetectionServiceDelegate {
    func poseDetectionService(
        _ service: PoseDetectionService,
        didDetect observation: VNHumanBodyPoseObservation?
    ) {
        guard let observation else {
            skeletonOverlayView.update(with: nil)
            return
        }

        let poseData = poseSmoother.smooth(observation: observation)
        let result   = pushUpAnalyzer.analyze(poseData: poseData)

        skeletonOverlayView.update(with: poseData)
        apply(result)
    }
}

// AudioFeedbackService.swift
// ScrollFit

import AudioToolbox
import AVFoundation

final class AudioFeedbackService {

    // MARK: - Setup

    func setup() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playAndRecord,
            options: [.defaultToSpeaker, .mixWithOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Feedback

    /// Short satisfying tap played on each counted rep.
    /// System sound 1057 = "key_press_click" — low latency, no AVAudioPlayer overhead.
    func playRepCompleted() {
        guard !UserDefaults.standard.bool(forKey: "scrollfit.sound.muted") else { return }
        AudioServicesPlaySystemSound(1057)
    }
}

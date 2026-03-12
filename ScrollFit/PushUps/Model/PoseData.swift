// PoseData.swift
// ScrollFit

import CoreGraphics

/// A single detected body joint with a smoothed position.
struct JointPoint {
    /// Normalized Vision coordinates: origin bottom-left, x ∈ [0,1], y ∈ [0,1].
    let position: CGPoint
    let confidence: Float
    /// True when confidence meets the threshold OR the joint is within the stale grace period.
    let isValid: Bool
    /// 0 = fresh detection, >0 = frames since last confident detection.
    let staleAge: Int
}

/// All tracked body joints for one processed frame.
struct PoseData {
    var leftShoulder:  JointPoint?
    var rightShoulder: JointPoint?
    var leftElbow:     JointPoint?
    var rightElbow:    JointPoint?
    var leftWrist:     JointPoint?
    var rightWrist:    JointPoint?
    var leftHip:       JointPoint?
    var rightHip:      JointPoint?
    var leftKnee:      JointPoint?
    var rightKnee:     JointPoint?
    var leftAnkle:     JointPoint?
    var rightAnkle:    JointPoint?
    var neck:          JointPoint?
    var root:          JointPoint?
}

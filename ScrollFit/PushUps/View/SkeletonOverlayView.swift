// SkeletonOverlayView.swift
// ScrollFit

import UIKit

/// Transparent UIView that draws the detected body skeleton over the camera preview.
/// Joints that are becoming stale fade out gradually instead of disappearing abruptly.
final class SkeletonOverlayView: UIView {

    // MARK: - Appearance

    var boneColor:   UIColor = UIColor(.scrollFitGreen) 
    var jointColor:  UIColor = UIColor(.scrollFitGreen)
    var lineWidth:   CGFloat = 3
    var jointRadius: CGFloat = 5

    /// Stale frame limit (must match PoseSmoother.staleFrameLimit for correct fade).
    var fadeOverFrames: Int = 8

    // MARK: - State

    private var poseData: PoseData?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Update

    func update(with pose: PoseData?) {
        poseData = pose
        setNeedsDisplay()
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), let pose = poseData else { return }
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        drawBones(pose: pose, ctx: ctx)
        drawJoints(pose: pose, ctx: ctx)
    }

    // MARK: - Private

    private func drawBones(pose: PoseData, ctx: CGContext) {
        let connections: [(JointPoint?, JointPoint?)] = [
            (pose.leftShoulder,  pose.leftElbow),
            (pose.leftElbow,     pose.leftWrist),
            (pose.rightShoulder, pose.rightElbow),
            (pose.rightElbow,    pose.rightWrist),
            (pose.leftShoulder,  pose.rightShoulder),
            (pose.leftShoulder,  pose.leftHip),
            (pose.rightShoulder, pose.rightHip),
            (pose.leftHip,       pose.rightHip),
            (pose.leftHip,       pose.leftKnee),
            (pose.leftKnee,      pose.leftAnkle),
            (pose.rightHip,      pose.rightKnee),
            (pose.rightKnee,     pose.rightAnkle),
        ]

        for (a, b) in connections {
            guard let a, let b, a.isValid, b.isValid else { continue }
            // Alpha based on the stalest of the two joints
            let alpha = fadeAlpha(maxStaleAge: max(a.staleAge, b.staleAge))
            boneColor.withAlphaComponent(alpha).setStroke()
            ctx.setLineWidth(lineWidth)
            ctx.move(to: screenPoint(a.position))
            ctx.addLine(to: screenPoint(b.position))
            ctx.strokePath()
        }
    }

    private func drawJoints(pose: PoseData, ctx: CGContext) {
        let joints: [JointPoint?] = [
            pose.leftShoulder,  pose.rightShoulder,
            pose.leftElbow,     pose.rightElbow,
            pose.leftWrist,     pose.rightWrist,
            pose.leftHip,       pose.rightHip,
            pose.leftKnee,      pose.rightKnee,
            pose.leftAnkle,     pose.rightAnkle,
        ]

        for joint in joints.compactMap({ $0 }) where joint.isValid {
            let pt = screenPoint(joint.position)
            let alpha = fadeAlpha(maxStaleAge: joint.staleAge)
            jointColor.withAlphaComponent(alpha).setFill()
            ctx.fillEllipse(in: CGRect(
                x: pt.x - jointRadius,
                y: pt.y - jointRadius,
                width:  jointRadius * 2,
                height: jointRadius * 2
            ))
        }
    }

    /// Returns opacity 1.0 for fresh joints, fading toward 0.2 as staleAge approaches fadeOverFrames.
    private func fadeAlpha(maxStaleAge: Int) -> CGFloat {
        guard maxStaleAge > 0, fadeOverFrames > 0 else { return 1.0 }
        let t = CGFloat(maxStaleAge) / CGFloat(fadeOverFrames)
        return max(0.15, 1.0 - t * 0.85)
    }

    private func screenPoint(_ normalized: CGPoint) -> CGPoint {
        CGPoint(
            x:  normalized.x * bounds.width,
            y: (1 - normalized.y) * bounds.height
        )
    }
}

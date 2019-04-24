//
//  StatusViewController.swift
//  ARKitSwiftDemo
//
//  Created by Andrew Shen on 2019/4/23.
//  Copyright © 2019 Andrew Shen. All rights reserved.
//

import ARKit

class StatusViewController: UIViewController {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /// Updates the UI to provide feedback on the state of the AR experience.
    func updateSessionInfoLabel(for trackingState: ARCamera.TrackingState) {
        let message: String?
        
        switch trackingState {
        case .notAvailable:
            message = "Tracking Unavailable"
        case .limited(.excessiveMotion):
            message = "Tracking Limited\nExcessive motion - Try slowing down your movement, or reset the session."
        case .limited(.insufficientFeatures):
            message = "Tracking Limited\nLow detail - Try pointing at a flat surface, or reset the session."
        case .limited(.initializing):
            message = "Initializing"
        case .limited(.relocalizing):
            message = "Recovering from interruption"
        case .normal:
            message = "Tap to place a mode"
        default:
            message = nil
        }
        
        // Show the message, or hide the label if there's no message.
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.statusLabel.text = message
                if message != nil {
                    self.visualEffectView.alpha = 1
                } else {
                    self.visualEffectView.alpha = 0
                }
            }
        }
    }

}

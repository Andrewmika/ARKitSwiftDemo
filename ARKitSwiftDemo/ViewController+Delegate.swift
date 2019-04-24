//
//  ViewController+Delegate.swift
//  ARKitSwiftDemo
//
//  Created by Andrew Shen on 2019/4/23.
//  Copyright © 2019 Andrew Shen. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = node.childNodes.first as? Plane {
            if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
                planeGeometry.update(from: planeAnchor.geometry)
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, self.objectType.selectedSegmentIndex == 0 {
                let plane = Plane(anchor: planeAnchor, in: self.sceneView)
                node .addChildNode(plane)
            } else if let imageAnchor = anchor as? ARImageAnchor {
                let object = self.newObject()
                let translation = imageAnchor.transform.translation
                object.simdPosition = translation
                object.simdScale = object.simdScale * 0.05
                node.addChildNode(object)
                self.playSound(newObject: object)
                self.selectedObject = object
            }
        }
        
    }
    
    // MARK: - Session Delegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.updateSessionInfoLabel(for: camera.trackingState)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


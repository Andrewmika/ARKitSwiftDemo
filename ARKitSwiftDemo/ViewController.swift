//
//  ViewController.swift
//  ARKitSwiftDemo
//
//  Created by Andrew Shen on 2019/2/26.
//  Copyright © 2019 Andrew Shen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    

    @IBOutlet weak var objectType: UISegmentedControl!
    var selectedObject: VirtualObject?
    var audioSource: SCNAudioSource = {
        // Instantiate the audio source
        let source = SCNAudioSource(fileNamed: "dance.mp3")!
        // As an environmental sound layer, audio should play indefinitely
        source.loops = true
        // Decode the audio from disk ahead of time to prevent a delay in playback
        source.load()
        
        return source
    }()

    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        resetSessionConfiguration(type: objectType.selectedSegmentIndex)
        // Create a session configuration

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }


    // MARK: Gesture Interaction
    
    @IBAction func didTap(_ gesture: UITapGestureRecognizer) {
        guard let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState else { return }
        let touchLocation = gesture.location(in: sceneView)
        if let virtualObject = virtualObject(at: touchLocation) {
            selectedObject = virtualObject
        }
        else if let hitTestResult = smartHitTest(touchLocation) {
            let object = newObject()
            sceneView.scene.rootNode.addChildNode(object)
            if objectType.selectedSegmentIndex == 1 {
                object.simdScale = object.simdScale * 0.05
                playSound(newObject: object)
            }
            
            let translation = hitTestResult.worldTransform.translation
            object.simdPosition = translation
            selectedObject = object
            
        }
    }
    
    @IBAction func didPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let object = selectedObject, gesture.state == .changed
            else { return }
        let newScale = object.simdScale * Float(gesture.scale)
        object.simdScale = newScale
        gesture.scale = 1.0
    }
    
    @IBAction func didPan(_ gesture: UIPanGestureRecognizer) {
        
        guard let object = selectedObject, gesture.state == .changed
            else { return }
        let translation = gesture.translation(in: sceneView)
        let pPoint = sceneView.projectPoint(object.position)
        let previousPosition = CGPoint(x: Double(pPoint.x), y: Double(pPoint.y))
        // Calculate the new touch position
        let currentPosition = CGPoint(x: previousPosition.x + translation.x, y: previousPosition.y + translation.y)
        if let hitTestResult = smartHitTest(currentPosition) {
            let translation = hitTestResult.worldTransform.translation
            object.simdPosition = translation                // Refresh the probe as the object keeps moving
        }
        gesture.setTranslation(.zero, in: sceneView)
    }
    
    
    // MARK: - Private
    
    func smartHitTest(_ point: CGPoint) -> ARHitTestResult? {
        
        // Perform the hit test.
        let results = sceneView.hitTest(point, types: [.existingPlaneUsingGeometry])
        
        // 1. Check for a result on an existing plane using geometry.
        if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry }) {
            return existingPlaneUsingGeometryResult
        }
        
        // 2. Check for a result on an existing plane, assuming its dimensions are infinite.
        let infinitePlaneResults = sceneView.hitTest(point, types: .existingPlane)
        
        if let infinitePlaneResult = infinitePlaneResults.first {
            return infinitePlaneResult
        }
        
        // 3. As a final fallback, check for a result on estimated planes.
        return results.first(where: { $0.type == .estimatedHorizontalPlane })
    }
    
    func virtualObject(at point: CGPoint) -> VirtualObject? {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = sceneView.hitTest(point, options: hitTestOptions)
        
        return hitTestResults.lazy.compactMap { result in
            return VirtualObject.existingObjectContainingNode(result.node)
            }.first
    }
    
    func newObject() -> VirtualObject {
        var sceneURL: URL!
        if self.objectType.selectedSegmentIndex == 0 {
            sceneURL = Bundle.main.url(forResource: "sphere", withExtension: "scn", subdirectory: "art.scnassets")

        }
        else {
            sceneURL = Bundle.main.url(forResource: "twist_danceFixed", withExtension: "dae", subdirectory: "art.scnassets")
        }
        let referenceNode = VirtualObject(url: sceneURL)
        
        referenceNode!.load()
        
        return referenceNode!
    }
    
    /// Plays a sound on the `objectNode` using SceneKit's positional audio
    /// - Tag: AddAudioPlayer
    func playSound(newObject: VirtualObject) {
        // Ensure there is only one audio player
        if let object = selectedObject {
            object.removeAllAudioPlayers()
        }
        newObject.addAudioPlayer(SCNAudioPlayer(source: audioSource))
    }
    
    func resetSessionConfiguration(type: Int) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal]

        if type == 1 {
            let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
            configuration.detectionImages = referenceImages
        }
        // Run the view's session
        sceneView.session.run(configuration, options: .removeExistingAnchors)
    }
    
    @IBAction func typeSwitch(_ sender: UISegmentedControl) {
        resetSessionConfiguration(type: sender.selectedSegmentIndex)
    }
    
}


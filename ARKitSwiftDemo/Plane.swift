//
//  Plane.swift
//  ARKitSwiftDemo
//
//  Created by Andrew Shen on 2019/2/26.
//  Copyright © 2019 Andrew Shen. All rights reserved.
//

import ARKit

class Plane: SCNNode {
    
    let meshNode: SCNNode
    
    init(anchor: ARPlaneAnchor, in sceneView: SCNView) {
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!) else { fatalError("Can't create plane geometry") }
        meshGeometry.update(from: anchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)

        super.init()
        
        meshNode.opacity = 0.5
        guard let meterial = meshNode.geometry?.firstMaterial else {
            fatalError("ARSCNPlaneGeometry always has one material")
        }
        let planeImage = #imageLiteral(resourceName: "plane1")
        meterial.diffuse.contents = planeImage
        
        addChildNode(meshNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
}

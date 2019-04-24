//
//  VirtualObject.swift
//  ARKitSwiftDemo
//
//  Created by Andrew Shen on 2019/3/31.
//  Copyright © 2019 Andrew Shen. All rights reserved.
//

import UIKit
import SceneKit

class VirtualObject: SCNReferenceNode {

}

extension VirtualObject {
    
    /// Returns a `VirtualObject` if one exists as an ancestor to the provided node.
    static func existingObjectContainingNode(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `VirtualObject`.
        return existingObjectContainingNode(parent)
    }
}

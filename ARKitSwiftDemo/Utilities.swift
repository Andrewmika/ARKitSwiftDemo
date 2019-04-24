//
//  Utilities.swift
//  ARKitSwiftDemo
//
//  Created by Andrew Shen on 2019/4/23.
//  Copyright © 2019 Andrew Shen. All rights reserved.
//

import ARKit

// MARK: - float4x4 extensions

extension float4x4 {
    init(translation vector: float3) {
        self.init(float4(1, 0, 0, 0),
                  float4(0, 1, 0, 0),
                  float4(0, 0, 1, 0),
                  float4(vector.x, vector.y, vector.z, 1))
    }
    
    var translation: float3 {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

//
//  VectorOperations.swift
//  wwdc2020
//
//  Created by Mariana Beilune Abad on 09/05/20.
//  Copyright © 2020 Mariana Beilune Abad. All rights reserved.
//

import Foundation
import SceneKit

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(x:left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}

func +=(left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

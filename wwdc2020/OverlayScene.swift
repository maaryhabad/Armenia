//
//  OverlayScene.swift
//  wwdc2020
//
//  Created by Mariana Beilune Abad on 12/05/20.
//  Copyright © 2020 Mariana Beilune Abad. All rights reserved.
//

import Foundation
import SpriteKit

class OverlayScene: SKScene {
    var runNode: SKSpriteNode!
    var waterNode: SKLabelNode!
    
    var score = 0 {
        didSet {
            self.waterNode.text = "Water: \(self.score)"
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clear
        
        let spriteSize = size.width/12
        self.runNode = SKSpriteNode(imageNamed: "runButton")
        self.runNode.size = CGSize(width: spriteSize, height: spriteSize)
        self.runNode.position = CGPoint(x: spriteSize + 8, y: spriteSize + 8)
        
        self.waterNode = SKLabelNode(text: "Score: 0")
        self.waterNode.fontSize = 24
        self.waterNode.position = CGPoint(x: size.width/2, y: self.runNode.position.y - 9)
        
        self.addChild(self.runNode)
        self.addChild(self.waterNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

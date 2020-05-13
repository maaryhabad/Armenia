//
//  GameViewController.swift
//  wwdc2020
//
//  Created by Mariana Beilune Abad on 07/05/20.
//  Copyright © 2020 Mariana Beilune Abad. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

class GameViewController: UIViewController {
    
    let CategoryTree = 2
    
    let waterCount = 100
    let shapeLayer = CAShapeLayer()
    
    var sceneView: SCNView!
    var scene: SCNScene!
    
    var playerNode: SCNNode!
    var selfieStick: SCNNode!
    var camera: SCNNode!
    var youngsHouse: SCNNode!
    
    var runButton = UIButton()
    
    var motion = MotionHelper()
    var motionForce = SCNVector3(0, 0, 0)
    
    var sounds: [String: SCNAudioSource] = [:]
    

    override func viewDidLoad() {
        setupScene()
        setupNodes()
        setupSounds()
        setupWaterCount()
        AnimateWaterCounter()
    }
    
    func setupScene() {
        sceneView = self.view as? SCNView
        sceneView.delegate = self
        
        scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene = scene
        
        scene.physicsWorld.contactDelegate = self
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.numberOfTapsRequired = 1
        
        tapRecognizer.addTarget(self, action: #selector(GameViewController.sceneViewTapped(recognizer:)))
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    func setupNodes() {
        playerNode = scene.rootNode.childNode(withName: "young", recursively: true)!
        playerNode.physicsBody?.contactTestBitMask = CategoryTree
        selfieStick = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
        camera = scene.rootNode.childNode(withName: "camera", recursively: true)!
        youngsHouse = scene.rootNode.childNode(withName: "youngsHouse", recursively: true)!
        
        runButton = UIButton(type: UIButton.ButtonType.custom)
        runButton.setImage(UIImage(named: "runButton.png"), for: .normal)
        runButton.frame = CGRect(x: self.sceneView.frame.width - 200, y: self.sceneView.frame.height - 200, width: 100, height: 100)
        sceneView.addSubview(runButton)
        runButton.addTarget(self, action: #selector(runButtonClicked), for: UIControl.Event.touchDownRepeat)
        
        
    }
    
    func setupSounds() {
        let houseSounds = SCNAudioSource(fileNamed: "Casa_mixagem.mp3")!
        let tutorialMusic = SCNAudioSource(fileNamed: "Tutorial_mixagem.mp3")!
        let runSound = SCNAudioSource(fileNamed: "Corrida_mixagem.mp3")!
        
        houseSounds.load()
        tutorialMusic.load()
        runSound.load()
        
        houseSounds.volume = 0.3
        tutorialMusic.volume = 0.2
        runSound.volume = 0.8
        
        sounds["house"] = houseSounds
        sounds["tutorialMusic"] = tutorialMusic
        sounds["runSound"] = runSound
        
        let soundPlayer = SCNAudioPlayer(source: houseSounds)
        youngsHouse.addAudioPlayer(soundPlayer)
        
    }
    
    func setupWaterCount() {
        
        let trackLayer = CAShapeLayer()

        shapeLayer.frame = CGRect(x: 140, y: self.sceneView.frame.height - 180, width: 50, height: 50)
        trackLayer.frame = CGRect(x: 140, y: self.sceneView.frame.height - 180, width: 50, height: 50)
        let centerOfLayer = CGPoint(x: shapeLayer.frame.size.width/2, y: shapeLayer.frame.size.height/2)
        let circularPath = UIBezierPath(arcCenter: centerOfLayer, radius: 45, startAngle: -CGFloat.pi/2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        
       //TRACK LAYER
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
       
        trackLayer.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.5)
        trackLayer.lineWidth = 10
       
        trackLayer.lineCap = .round
        sceneView.layer.addSublayer(trackLayer)
        
        //SHAPE LAYER
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        shapeLayer.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        shapeLayer.lineWidth = 10
        
        shapeLayer.lineCap = .round
        
        sceneView.layer.addSublayer(shapeLayer)
        
        
    }
    
    func AnimateWaterCounter() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 0
        basicAnimation.duration = 10
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "anim")
    }
    
    func setupAnimations() {
        
    }
    @objc func runButtonClicked() {
        print("clicou no botão")
        let velocityInLocalSpace = SCNVector3(0, 0, -0.15)
        let velocityinWorldSpace = playerNode.presentation.convertVector(velocityInLocalSpace, to: nil)
        playerNode.runAction(SCNAction.moveBy(x: 0, y: 0, z: -0.5, duration: 0.05))
    }
    
    @objc func sceneViewTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result = hitResults.first
            //FIX ME: pegar o clique na subview e andar pra sempre
            
            if let node = result?.node {
                if node.name == "jovem" {
                    let runSound = sounds["runSound"]!
                    let music = sounds["tutorialMusic"]!
                    playerNode.runAction(SCNAction.playAudio(runSound, waitForCompletion: true)) {
                        self.camera.runAction(SCNAction.playAudio(music, waitForCompletion: false))
                    }
                } else {
                    print("não achou o node.name: ", node.name!)
                }
            }
        }
    }
    
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension GameViewController : SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let player = playerNode.presentation
        let playerPosition = player.position
//        print("playerPosition")
        
        let targetPosition = SCNVector3(x: playerPosition.x, y: playerPosition.y + 5, z: playerPosition.z + 5)
        var cameraPosition = selfieStick.position
        
        let cameraDamping: Float = 0.3
        
        let xComponent = cameraPosition.x * (1 - cameraDamping) + targetPosition.x * cameraDamping
        let yComponent = cameraPosition.y * (1 - cameraDamping) + targetPosition.y * cameraDamping
        let zComponent = cameraPosition.z * (1 - cameraDamping) + targetPosition.z * cameraDamping
        
        cameraPosition = SCNVector3(xComponent, yComponent, zComponent)
        selfieStick.position = cameraPosition
        
        
        motion.getAccelerometerData { (x, y, z) in
            self.motionForce = SCNVector3(x: x * 0.5, y: 0, z: (y+0.08) * -0.5) //FIX ME: Alterar a velocidade do personagem
            
        }
//        playerNode.runAction(SCNAction.move(by: motionForce, duration: 0.01)) //FIX ME: Colocar um botão pra mexer o personagem, tentar com touch3d?
//        print("self motionForce: ", self.motionForce)
    }
}

extension GameViewController : SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode: SCNNode!
        
        if contact.nodeA.name == "jovem" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if contactNode.physicsBody?.categoryBitMask == CategoryTree {
        
            contactNode.isHidden = true
            
            let waitAction = SCNAction.wait(duration: 15)
            let unhideAction = SCNAction.run { (node) in
                node.isHidden = false
            }
            
            let actionSequence = SCNAction.sequence([waitAction, unhideAction])
            
            contactNode.runAction(actionSequence)
        }
    }
}



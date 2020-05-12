//
//  GameViewController.swift
//  wwdc2020
//
//  Created by Mariana Beilune Abad on 07/05/20.
//  Copyright © 2020 Mariana Beilune Abad. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    let CategoryTree = 2
    
    var sceneView: SCNView!
    var scene: SCNScene!
    
    var playerNode: SCNNode!
    var selfieStick: SCNNode!
    var camera: SCNNode!
    
    var motion = MotionHelper()
    var motionForce = SCNVector3(0, 0, 0)
    
    var sounds: [String: SCNAudioSource] = [:]

    override func viewDidLoad() {
        setupScene()
        setupNodes()
        setupSounds()
    }
    
    func setupScene() {
        sceneView = self.view as! SCNView
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
    }
    
    func setupSounds() {
        let houseSounds = SCNAudioSource(fileNamed: "Casa_mixagem.mp3")!
        let tutorialMusic = SCNAudioSource(fileNamed: "Tutorial_mixagem.mp3")!
        let runSound = SCNAudioSource(fileNamed: "Corrida_mixagem.mp3")!
        
        houseSounds.load()
        tutorialMusic.load()
        runSound.load()
        
        houseSounds.volume = 0.5
        tutorialMusic.volume = 0.2
        runSound.volume = 0.5
        
        sounds["house"] = houseSounds
        sounds["tutorialMusic"] = tutorialMusic
        sounds["runSound"] = runSound
        
        let soundPlayer = SCNAudioPlayer(source: houseSounds)
        camera.addAudioPlayer(soundPlayer)
        
    }
    
    func setupAnimations() {
        
    }
    
    @objc func sceneViewTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result = hitResults.first
            
            if let node = result?.node {
                if node.name == "jovem" {
                    let runSound = sounds["runSound"]!
                    playerNode.runAction(SCNAction.playAudio(runSound, waitForCompletion: false)) //FIX ME: quando termina esse som, começa a música.
//                    playerNode.physicsBody?.applyForce(SCNVector3(x: 0, y: 2, z: -2), asImpulse: true)
                } else {
                    print("não achou o node.name: ", node.name)
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
        print("playerPosition")
        
        let targetPosition = SCNVector3(x: playerPosition.x, y: playerPosition.y + 5, z: playerPosition.z + 5)
        var cameraPosition = selfieStick.position
        
        let cameraDamping: Float = 0.3
        
        let xComponent = cameraPosition.x * (1 - cameraDamping) + targetPosition.x * cameraDamping
        let yComponent = cameraPosition.y * (1 - cameraDamping) + targetPosition.y * cameraDamping
        let zComponent = cameraPosition.z * (1 - cameraDamping) + targetPosition.z * cameraDamping
        
        cameraPosition = SCNVector3(xComponent, yComponent, zComponent)
        selfieStick.position = cameraPosition
        
        
        motion.getAccelerometerData { (x, y, z) in
            self.motionForce = SCNVector3(x: x * 0.05, y: 0, z: (y+0.08) * -0.05)
            
        }
        playerNode.runAction(SCNAction.move(by: motionForce, duration: 0.1)) //FIX ME: Colocar um botão pra mexer o personagem, tentar com touch3d?
        print("self motionForce: ", self.motionForce)
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
            let music = sounds["tutorialMusic"]!
            camera.runAction(SCNAction.playAudio(music, waitForCompletion: false))
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

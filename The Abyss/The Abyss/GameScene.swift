//
//  GameScene.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 13/04/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private let submarine = SKSpriteNode(imageNamed: "submarine")
    private var invincible = false
    private var lives = 5
    private let livesLabel = SKLabelNode(fontNamed: "Glimstic")
    
    private var lastUpdateTime: TimeInterval = 0
    private var dt: TimeInterval = 0
    private let playableRect: CGRect
    private var lastTouchLocation: CGPoint?
    
    private let submarineMovePointsPerSec: CGFloat = 480.0
    private var velocity = CGPoint.zero
    
    private let cameraNode = SKCameraNode()
    private let cameraMovePointsPerSec: CGFloat = 200.0

//    MARK: - Override
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 2.16
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        
        super.init(size: size)
      }
      
      required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        move(sprite: submarine, velocity: velocity)
      
        boundsCheckSubmarine()
      // checkCollisions()

        moveCamera()
        livesLabel.text = "Lives: \(lives)"
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
    
        setupBackground()
        
        setupSubmarine()
        setupSpawnEnemyAction(spawnTimeInSecond: 2.0)
        
        setupCamera()
        
        setupLivesLabel()
      }

    override func didEvaluateActions() {
        checkCollisions()
    }

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      let touchLocation = touch.location(in: self)
      sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      let touchLocation = touch.location(in: self)
      sceneTouched(touchLocation: touchLocation)
    }

//    MARK: - Submarine
    
    private func setupSubmarine() {
        submarine.position = CGPoint(x: 400, y: 400)
        submarine.zPosition = 100
        addChild(submarine)
      }

    private func moveSubmarineToward(location: CGPoint) {
        let offset = location - submarine.position
        let direction = offset.normalized()
        velocity = direction * submarineMovePointsPerSec
    }

    private func boundsCheckSubmarine() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
      
        if submarine.position.x <= bottomLeft.x {
            submarine.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
        }
        if submarine.position.x >= topRight.x {
            submarine.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if submarine.position.y <= bottomLeft.y {
            submarine.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if submarine.position.y >= topRight.y {
            submarine.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
      
    private func setupLivesLabel() {
        livesLabel.text = "Lives: \(lives)"
        livesLabel.fontColor = SKColor.white
        livesLabel.fontSize = 100
        livesLabel.zPosition = 100
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(x: -playableRect.size.width/2 + CGFloat(20),
                                      y: -playableRect.size.height/2 + CGFloat(20))
        cameraNode.addChild(livesLabel)
      }

//    MARK: - Enemy

    private func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width/2, y: CGFloat.random(
            min: cameraRect.minY + enemy.size.height/2, max: cameraRect.maxY - enemy.size.height/2))
        enemy.zPosition = 50
        addChild(enemy)
      
        let actionMove = SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 6.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }

    private func setupSpawnEnemyAction(spawnTimeInSecond: TimeInterval) {
        let singleSpawnEnemyAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }

        let waitTwoSecondAction = SKAction.wait(forDuration: spawnTimeInSecond)
        let spawnEnemyActionSequence = SKAction.sequence([singleSpawnEnemyAction, waitTwoSecondAction])
        let spawnEnemiesActionForever = SKAction.repeatForever(spawnEnemyActionSequence)

        run(spawnEnemiesActionForever)
    }

    private func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }

    private func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveSubmarineToward(location: touchLocation)
    }

//    MARK: - Collision Handler

    func submarineHit(enemy: SKSpriteNode) {
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.submarine.isHidden = false
            self?.invincible = false
        }
        submarine.run(SKAction.sequence([blinkAction, setHidden]))
        lives -= 1
        livesLabel.text = "Lives: \(lives)"
      }
      
    func checkCollisions() {
        if invincible {
            return
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 10, dy: 10).intersects(self.submarine.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            submarineHit(enemy: enemy)
        }
      }

//    MARK: - Background

    private func setupBackground() {
        backgroundColor = SKColor.black
      
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
    }

    private func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"

        let background1 = SKSpriteNode(imageNamed: "background")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background")
        background2.anchorPoint = CGPoint.zero
        background2.position =
          CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(
          width: background1.size.width + background2.size.width,
          height: background1.size.height)
        return backgroundNode
    }

//    MARK: - Camera

    private var cameraRect : CGRect {
      let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width)/2
      let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height)/2
      return CGRect(x: x, y: y, width: playableRect.width, height: playableRect.height)
    }

    private func setupCamera() {
      addChild(cameraNode)
      camera = cameraNode
      cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
    }

    private func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width*2,
                                              y: background.position.y)
            }
        }
    }
      
}

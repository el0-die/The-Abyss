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
    let submarine = Submarine()

//    MARK: - Override
    
    override init(size: CGSize) {
        super.init(size: size)
    }
      
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            submarine.dt = currentTime - lastUpdateTime
        } else {
            submarine.dt = 0
        }
        lastUpdateTime = currentTime
        submarine.move(sprite: submarine.submarine, velocity: submarine.velocity)
      
        submarine.boundsCheckSubmarine(bottomLeft: (x: cameraRect.minX, y: cameraRect.minY), topRight: (x: cameraRect.maxX, y: cameraRect.maxY))

        moveCamera()
        livesLabel.text = "Lives: \(lives)"

        displayGameOverScene()
        displayWinGameScene()

    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        addChild(submarine.submarine)
        submarine.setupSubmarineAnimation()
        setupBackground()
        
        submarine.setupSubmarine()
        setupSpawnEnemyAction(spawnTimeInSecond: 2.0)
        setupSpawnProjectileAction(spawnTimeInSecond: 1.0)
        
        setupPlayableRectangle(size)
        setupCamera()
        
        setupLivesLabel()
        setupKillCounterLabel()
      }

    override func didEvaluateActions() {
        checkSubmarineAndEnemyCollisions()
        checkProjectileAndEnemyCollisions()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchesEvent(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchesEvent(touches: touches)
    }
    
    // MARK: - Private
    
    
    // MARK: Private - Properties

    private var lastUpdateTime: TimeInterval = 0
    
    private var playableRect: CGRect?
    private var lastTouchLocation: CGPoint?
    

    private var lives = 5
    private let livesLabel = SKLabelNode()

    private var killCounter = 0
    private let killCounterLabel = SKLabelNode()
    
    private let cameraNode = SKCameraNode()
    private let cameraMovePointsPerSec: CGFloat = 200.0
    
    
    // MARK: Private - Methods
    
    private func handleTouchesEvent(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }

    private func setupPlayableRectangle(_ size: CGSize) {
        let screenWidth  = UIScreen.main.fixedCoordinateSpace.bounds.width
        let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height
        
        let maxAspectRatio: CGFloat = screenHeight / screenWidth
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
    }

    private func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        submarine.moveSubmarineToward(location: touchLocation)
    }
    
    // MARK: Submarine

    

    // Lives
    
    private func setupLivesLabel() {
        guard let playableRect = playableRect else { return }
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

    private func displayGameOverScene() {
        if lives <= 0 {
            print("You lose!")
            
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }

    // Collision: Submarine & Enemy
    
    private func submarineHit(enemy: SKSpriteNode) {
        submarine.invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.submarine.submarine.isHidden = false
            self?.submarine.invincible = false
        }
        submarine.submarine.run(SKAction.sequence([blinkAction, setHidden]))
        lives -= 1
        livesLabel.text = "Lives: \(lives)"
      }
      
    private func checkSubmarineAndEnemyCollisions() {
        if submarine.invincible {
            return
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 10, dy: 10).intersects(self.submarine.submarine.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            submarineHit(enemy: enemy)
        }
      }

    // MARK: Projectile

    private func spawnProjectile() {
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.name = "projectile"
        projectile.position = submarine.submarine.position
        addChild(projectile)

        let actionMove = SKAction.moveBy(x: size.width + projectile.size.width, y: 0, duration: 3.0)
        let actionRemove = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionRemove]))
    }

    private func setupSpawnProjectileAction(spawnTimeInSecond: TimeInterval) {
        let singleSpawnProjectileAction = SKAction.run { [weak self] in
            self?.spawnProjectile()
        }

        let waitBeforeAction = SKAction.wait(forDuration: spawnTimeInSecond)
        let spawnProjectileActionSequence = SKAction.sequence([singleSpawnProjectileAction, waitBeforeAction])
        let spawnProjectilesActionForever = SKAction.repeatForever(spawnProjectileActionSequence)

        run(spawnProjectilesActionForever)
    }

    // Kill Counter
    
    private func setupKillCounterLabel() {
        guard let playableRect = playableRect else { return }
        killCounterLabel.text = "Kill: \(killCounter)"
        killCounterLabel.fontColor = SKColor.white
        killCounterLabel.fontSize = 100
        killCounterLabel.zPosition = 100
        killCounterLabel.horizontalAlignmentMode = .right
        killCounterLabel.verticalAlignmentMode = .bottom
        killCounterLabel.position = CGPoint(x: playableRect.size.width/2 + CGFloat(-20),
                                      y: -playableRect.size.height/2 + CGFloat(20))
        cameraNode.addChild(killCounterLabel)
    }

    private func displayWinGameScene() {
        if killCounter >= 10 {
            print("You Win!")
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }

    // Collision: Projectile & Enemy

    private func projectileHit(enemy: SKSpriteNode) {
        killCounter += 1
        killCounterLabel.text = "Kill: \(killCounter)"
        enemy.removeFromParent()
    }

    private func checkProjectileAndEnemyCollisions() {
        var hitProjectile: [SKSpriteNode] = []
        enumerateChildNodes(withName: "projectile") { node, _ in
            let projectile = node as! SKSpriteNode
                hitProjectile.append(projectile)
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            for projectile in hitProjectile {
                if node.frame.insetBy(dx: 10, dy: 10).intersects(projectile.frame) {
                    hitEnemies.append(enemy)
                }
            }
        }
        for enemy in hitEnemies {
            projectileHit(enemy: enemy)
        }
    }

    // MARK:  Enemy

    private func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "pulp1")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width/2, y: CGFloat.random(
            min: cameraRect.minY + enemy.size.height/2, max: cameraRect.maxY - enemy.size.height/2))
        enemy.zPosition = 50
        addChild(enemy)

        enemyAnimation(enemy: enemy)
      
        let actionMove = SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 6.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }

    private func setupSpawnEnemyAction(spawnTimeInSecond: TimeInterval) {
        let singleSpawnEnemyAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }

        let waitBeforeAction = SKAction.wait(forDuration: spawnTimeInSecond)
        let spawnEnemyActionSequence = SKAction.sequence([singleSpawnEnemyAction, waitBeforeAction])
        let spawnEnemiesActionForever = SKAction.repeatForever(spawnEnemyActionSequence)

        run(spawnEnemiesActionForever)
    }

    private func enemyAnimation(enemy: SKSpriteNode) {
        var enemyAnimations: SKAction?
        var enemyTextures: [SKTexture] = []
        let numberOfEnemyTexture = 3
        for textureIndex in 1...numberOfEnemyTexture {
            enemyTextures.append(SKTexture(imageNamed: "pulp\(textureIndex)"))
        }
        enemyTextures.append(enemyTextures[2])
        enemyTextures.append(enemyTextures[1])
        enemyAnimations = SKAction.animate(with: enemyTextures, timePerFrame: 0.1)

        guard let enemyAnimation = enemyAnimations else { return }
        enemy.run(SKAction.repeatForever(enemyAnimation))
    }

    //MARK:  Background

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
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width,
                                     height: background1.size.height)
        return backgroundNode
    }

    //MARK:  Camera

    private var cameraRect : CGRect {
        guard let playableRect = playableRect else { return CGRect()}
        let x = cameraNode.position.x - size.width / 2 + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height / 2 + (size.height - playableRect.height)/2
        return CGRect(x: x, y: y, width: playableRect.width, height: playableRect.height)
    }

    private func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
    }

    private func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(submarine.dt)
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



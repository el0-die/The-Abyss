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

    // MARK: - Override

    let difficultyLvl: DifficultyLevel
    init(size: CGSize, difficultyLvl: DifficultyLevel) {
        self.difficultyLvl = difficultyLvl
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
        submarine.move(sprite: submarine.spriteNode, velocity: submarine.velocity)

        submarine.boundsCheck(bottomLeft: (x: cameraRect.minX, y: cameraRect.minY),
                              topRight: (x: cameraRect.maxX, y: cameraRect.maxY))

        moveCamera()
        counter.livesLabel.text = "Lives: \(difficultyLvl.numberOfLives)"

        displayGameOverScene()
        displayWinGameScene()

    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addChild(submarine.spriteNode)
        setupBubbles()
        submarine.setup()
        submarine.setupAnimation()

        setupSpawnEnemyAction(spawnTimeInSecond: 2.0)
        setupSpawnProjectileAction(spawnTimeInSecond: 1.0)

        setupBackground()
        setupPlayableRectangle(size)
        setupCamera()

        counter.setupLivesLabel(playableRect, difficultyLvl)
        counter.setupKillLabel(playableRect)
        playBackgroundMusic(filename: "gameMusic.wav")
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

    // Properties
    private let submarine = Submarine()
    private let counter = Counter()

    private let cameraNode = SKCameraNode()
    private let cameraMovePointsPerSec: CGFloat = 200.0
    private var lastUpdateTime: TimeInterval = 0
    private var playableRect: CGRect?
    private var lastTouchLocation: CGPoint?
    private let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "pop.wav", waitForCompletion: false)
    private let projectileCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "pulpdeath.wav", waitForCompletion: false)

    // Methods
    private func handleTouchesEvent(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }

    private func sceneTouched(touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
        submarine.moveToward(location: touchLocation)
    }

    private func setupPlayableRectangle(_ size: CGSize) {
        let screenWidth  = UIScreen.main.fixedCoordinateSpace.bounds.width / 1.03
        let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height

        let maxAspectRatio: CGFloat = screenHeight / screenWidth
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
    }

    private func setupBubbles() {
        if let particles = SKEmitterNode(fileNamed: "Bubbles") {
            particles.advanceSimulationTime(10)
            particles.particlePositionRange.dx = 3000
            particles.position = CGPoint(x: 0, y: -size.height)
            particles.isPaused = false
            particles.zPosition = 10
            particles.particleZPosition = 10
            cameraNode.addChild(particles)
        }
    }

    // MARK: Projectile

    private func spawnProjectile() {
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.name = "projectile"
        projectile.position = submarine.spriteNode.position
        addChild(projectile)

        let actionMove = SKAction.moveBy(x: size.width + projectile.size.width + 500, y: 0, duration: 3.0)
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

    // MARK: Enemy

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

        let waitBeforeAction = SKAction.wait(forDuration: difficultyLvl.spawnTimeInSec)
        let spawnEnemyActionSequence = SKAction.sequence([singleSpawnEnemyAction, waitBeforeAction])
        let spawnEnemiesActionForever = SKAction.repeatForever(spawnEnemyActionSequence)

        run(spawnEnemiesActionForever)
    }

    private func enemyAnimation(enemy: SKSpriteNode) {
        var enemyAnimations: SKAction?
        var enemyTextures: [SKTexture] = []
        let numberOfEnemyTexture = 2
        for textureIndex in 1...numberOfEnemyTexture {
            enemyTextures.append(SKTexture(imageNamed: "pulp\(textureIndex)"))
        }
        enemyTextures.append(enemyTextures[1])
        enemyAnimations = SKAction.animate(with: enemyTextures, timePerFrame: 0.1)

        guard let enemyAnimation = enemyAnimations else { return }
        enemy.run(SKAction.repeatForever(enemyAnimation))
    }

    // MARK: Collisions
    // Submarine & Enemy
    private func submarineHit(enemy: SKSpriteNode) {
        submarine.manageInvincibility()
        difficultyLvl.numberOfLives -= 1
        counter.livesLabel.text = "Lives: \(difficultyLvl.numberOfLives)"
        run(enemyCollisionSound)
    }

    private func checkSubmarineAndEnemyCollisions() {
        if submarine.invincible { return }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 10, dy: 10).intersects(self.submarine.spriteNode.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
        submarineHit(enemy: enemy)
        }
    }

       // Projectile & Enemy
    private func projectileHit(enemy: SKSpriteNode) {
        counter.kill += 1
        counter.killLabel.text = "Kill: \(counter.kill)"
        enemy.removeFromParent()
        run(projectileCollisionSound)
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
                    projectile.removeFromParent()
                }
            }
        }
        for enemy in hitEnemies {
            projectileHit(enemy: enemy)
        }
    }
   
    // MARK: Display Game's End

    private func displayWinGameScene() {
        if counter.kill >= difficultyLvl.numberOfKillToWin {
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }

    private func displayGameOverScene() {
        if difficultyLvl.numberOfLives <= 0 {
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }

    // MARK: Utilities

    // Background
    private func setupBackground() {
        for i in 0...5 {
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

        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)

        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width,
                                     height: background1.size.height)
        let background3 = SKSpriteNode(imageNamed: "background3")
        background3.anchorPoint = CGPoint.zero
        background3.position = CGPoint(x: background1.size.width + background2.size.width, y: 0)
        backgroundNode.addChild(background3)
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width + background3.size.width,
                                     height: background1.size.height)
        return backgroundNode
    }

    // Camera
    private var cameraRect: CGRect {
        guard let playableRect = playableRect else { return CGRect()}
        let x = cameraNode.position.x - size.width / 2 + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height / 2 + (size.height - playableRect.height)/2
        return CGRect(x: x, y: y, width: playableRect.width, height: playableRect.height)
    }

    private func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        cameraNode.addChild(counter.killLabel)
        cameraNode.addChild(counter.livesLabel)
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

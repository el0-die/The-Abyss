//
//  Enemy.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 28/04/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(cameraRect: CGRect) {
        let texture = SKTexture(imageNamed: "pulp1")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        name = "enemy"
        
        setupPosition(from: cameraRect)
        startAnimations()
    }
    
    private func setupPosition(from cameraRect: CGRect) {
        let yPosition = CGFloat.random(
            min: cameraRect.minY + size.height/2,
            max: cameraRect.maxY - size.height/2
        )
        
        position = CGPoint(
            x: cameraRect.maxX + size.width/2,
            y: yPosition
        )
        
        zPosition = 50
    }
    
    private func startAnimations() {
        startTextureAnimation()
        startMoveAnimation()
    }
    
    private func startTextureAnimation() {
        var enemyAnimations: SKAction?
        var enemyTextures: [SKTexture] = []
        let numberOfEnemyTexture = 2
        for textureIndex in 1...numberOfEnemyTexture {
            enemyTextures.append(SKTexture(imageNamed: "pulp\(textureIndex)"))
        }
        enemyTextures.append(enemyTextures[1])
        enemyAnimations = SKAction.animate(with: enemyTextures, timePerFrame: 0.1)
        guard let enemyAnimation = enemyAnimations else { return }
        run(SKAction.repeatForever(enemyAnimation))
    }
    
    private func startMoveAnimation() {
        let duration = 6.0
        let actionMove = SKAction.moveBy(x: -size.width, y: 0, duration: duration)
        let actionRemove = SKAction.removeFromParent()
        run(SKAction.sequence([actionMove, actionRemove]))
    }
}

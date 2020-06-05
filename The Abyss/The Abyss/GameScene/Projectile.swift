//
//  Projectile.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 29/04/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//


import Foundation
import SpriteKit

class Projectile: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        let texture = SKTexture(imageNamed: "projectile")
        super.init(texture: texture, color: .clear, size: texture.size())
        name = "projectile"
        
        startMoveAnimation()
    }

    func hit(enemy: SKSpriteNode, counter: Counter) {
        counter.kill += 1
        counter.killLabel.text = "Kill: \(counter.kill)"
        enemy.removeFromParent()
    }

    func hitBonus(bonus: SKSpriteNode, difficultyLevel: DifficultyLevel, counter: Counter) {
        difficultyLevel.numberOfLives += 1
        bonus.removeFromParent()
    }

    private func startMoveAnimation() {
        let duration = 4.0
        let actionMove = SKAction.moveBy(x: size.width + 3000, y: 0, duration: duration)
        let actionRemove = SKAction.removeFromParent()
        run(SKAction.sequence([actionMove, actionRemove]))
    }
}

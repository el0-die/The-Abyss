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

    init() {
        let texture = SKTexture(imageNamed: "projectile")
        super.init(texture: texture, color: .clear, size: texture.size())
        name = "projectile"
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let submarine = Submarine()
    
    func moveAnimation(_ touchLocation: CGPoint) {
        self.position = submarine.spriteNode.position
        
        let offset = touchLocation - self.position
        
        if offset.x < 0 { return }
        
        let direction = offset.normalized()
        
        let shootAmount = direction * 2000

        let realDest = shootAmount + self.position
        
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        run(SKAction.sequence([actionMove, actionMoveDone]))
    }

    func hit(enemy: SKSpriteNode, counter: Counter) {
        counter.kill += 1
        counter.killLabel.text = "Kill: \(counter.kill)"
        enemy.removeFromParent()
    }

//    private func startMoveAnimation() {
//        let duration = 4.0
//        let actionMove = SKAction.moveBy(x: size.width + 3000, y: 0, duration: duration)
//        let actionRemove = SKAction.removeFromParent()
//        run(SKAction.sequence([actionMove, actionRemove]))
//    }
}

//
//  Submarine.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 19/04/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//

import Foundation
import SpriteKit

class Submarine {
    let spriteNode = SKSpriteNode(imageNamed: "submarine1")
    var velocity = CGPoint.zero
    var dt: TimeInterval = 0
    var invincible = false

    func setup() {
        spriteNode.position = CGPoint(x: 400, y: 400)
        spriteNode.zPosition = 100

    }

    func setupAnimation() {
        var submarineTextures: [SKTexture] = []
        let numberOfTexture = 6
        for textureIndex in 1...numberOfTexture {
            submarineTextures.append(SKTexture(imageNamed: "submarine\(textureIndex)"))
        }
        submarineTextures.append(submarineTextures[2])
        submarineTextures.append(submarineTextures[1])
        animation = SKAction.animate(with: submarineTextures, timePerFrame: 0.1)
    }

    func moveToward(location: CGPoint) {
        startAnimation()
        let offset = location - spriteNode.position
        let direction = offset.normalized()
        velocity = direction * movePointsPerSec
    }

    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }

    func boundsCheck(bottomLeft:( x: CGFloat, y: CGFloat), topRight: ( x: CGFloat, y: CGFloat)) {
        if spriteNode.position.x <= bottomLeft.x {
            spriteNode.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
        }
        if spriteNode.position.x >= topRight.x {
            spriteNode.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if spriteNode.position.y <= bottomLeft.y {
            spriteNode.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if spriteNode.position.y >= topRight.y {
            spriteNode.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }

    func manageInvincibility() {
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.spriteNode.isHidden = false
            self?.invincible = false
        }
        spriteNode.run(SKAction.sequence([blinkAction, setHidden]))
    }

    private var animation: SKAction?
    private let movePointsPerSec: CGFloat = 480.0
    private func startAnimation() {
        guard let animation = animation else { return }
        spriteNode.run(SKAction.repeatForever(animation))
    }
}

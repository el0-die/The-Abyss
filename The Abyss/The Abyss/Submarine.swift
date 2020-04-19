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

    let submarine = SKSpriteNode(imageNamed: "submarine1")
    private var submarineAnimation: SKAction?
    private let submarineMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var dt: TimeInterval = 0
    var invincible = false

    func setupSubmarine() {
        submarine.position = CGPoint(x: 400, y: 400)
        submarine.zPosition = 100
        
    }

     func setupSubmarineAnimation() {
        var submarineTextures: [SKTexture] = []
        let numberOfSubmarineTexture = 6
        for textureIndex in 1...numberOfSubmarineTexture {
            submarineTextures.append(SKTexture(imageNamed: "submarine\(textureIndex)"))
        }
        submarineTextures.append(submarineTextures[2])
        submarineTextures.append(submarineTextures[1])
        submarineAnimation = SKAction.animate(with: submarineTextures, timePerFrame: 0.1)
    }

    func startSubmarineAnimation() {
        guard let submarineAnimation = submarineAnimation else { return }
        submarine.run(SKAction.repeatForever(submarineAnimation))
    }

    func moveSubmarineToward(location: CGPoint) {
        startSubmarineAnimation()
        let offset = location - submarine.position
        let direction = offset.normalized()
        velocity = direction * submarineMovePointsPerSec
    }

    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }

    func boundsCheckSubmarine(bottomLeft:( x: CGFloat, y: CGFloat), topRight: ( x: CGFloat, y: CGFloat)) {
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
}

//
//  BonusObject.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 05/06/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//

import Foundation
import SpriteKit

class JellyfishBonus: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(cameraRect: CGRect) {
        let texture = SKTexture(imageNamed: "jellyfish1")
        super.init(texture: texture, color: .clear, size: texture.size())

        name = "jellyfish"

        setupPosition(from: cameraRect)
        startAnimations()
    }

    func setupPosition(from cameraRect: CGRect) {
        position = CGPoint(
            x: cameraRect.maxX + size.width/2,
            y: cameraRect.maxY - size.height * 10
        )

        zPosition = 40
    }

    private func startAnimations() {
        startTextureAnimation()
        startMoveAnimation()
    }

    private func startTextureAnimation() {
        var jellyfishAnimations: SKAction?
        var jellyfishTextures: [SKTexture] = []
        let numberOfJellyfishTexture = 5
        for textureIndex in 1...numberOfJellyfishTexture {
            jellyfishTextures.append(SKTexture(imageNamed: "jellyfish\(textureIndex)"))
        }
        jellyfishTextures.append(jellyfishTextures[1])
        jellyfishAnimations = SKAction.animate(with: jellyfishTextures, timePerFrame: 0.1)
        guard let jellyfishAnimation = jellyfishAnimations else { return }
        run(SKAction.repeatForever(jellyfishAnimation))
    }

    func startMoveAnimation() {
        let duration = 10.0
        let actionMove = SKAction.moveBy(x: 0 , y: size.width + 1000, duration: duration)
        let actionRemove = SKAction.removeFromParent()
        run(SKAction.sequence([actionMove, actionRemove]))
    }
    
}

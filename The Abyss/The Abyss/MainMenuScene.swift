//
//  MainMenuScene.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 13/04/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background2")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }
  
    private func sceneTapped() {
        let myScene = GameScene(size: size)
        myScene.scaleMode = scaleMode
        myScene.view?.showsPhysics = true
        let reveal = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(myScene, transition: reveal)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    sceneTapped()
    }
}

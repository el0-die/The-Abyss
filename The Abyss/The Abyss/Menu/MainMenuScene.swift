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
    let easyBtn = SKSpriteNode(imageNamed: "buttoneasy")
    let mediumBtn = SKSpriteNode(imageNamed: "buttonmedium")
    let hardBtn = SKSpriteNode(imageNamed: "buttonhard")

   
    override func didMove(to view: SKView) {
        let centerPoint = CGPoint(x: size.width/2, y: size.height/2)
        setupBackground(at: centerPoint)
        setupGameLabel()
        setupButtons()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            guard let touch = touches.first else {
                return
            }
                 
            let touchLocation = touch.location(in: self)
            let touchedNode = self.atPoint(touchLocation)
                 
            if(touchedNode.name == "easyBtn"){
                presentGameScene()
            }
            if(touchedNode.name == "mediumBtn"){
                presentGameScene()
            }
            if(touchedNode.name == "hardBtn"){
                presentGameScene()
            }
        }

    private func setupGameLabel() {
        let gameLabel = SKSpriteNode(imageNamed: "gametitle")
        gameLabel.position = CGPoint(x: size.width/2, y: size.height / 1.3)
        gameLabel.zPosition = 1
        addChild(gameLabel)
    }
    private func setupBackground(at position: CGPoint) {
           let background = SKSpriteNode(imageNamed: "mainMenuScene")
           background.position = position
           background.zPosition = 0
           addChild(background)
       }

    private func setupButtons(){
        easyBtn.name = "easyBtn"
        addChild(easyBtn)
        easyBtn.position = CGPoint(x: size.width/2, y: size.height/1.8)
        easyBtn.zPosition = 1
             
        mediumBtn.name = "mediumBtn"
        addChild(mediumBtn)
        mediumBtn.position = CGPoint(x: size.width/2, y: size.height/2.48)
        mediumBtn.zPosition = 1
             
        hardBtn.name = "hardBtn"
        addChild(hardBtn)
        hardBtn.position = CGPoint(x: size.width/2, y: size.height/4)
        hardBtn.zPosition = 1
    }

    private func presentGameScene() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        gameScene.view?.showsPhysics = true
        let reveal = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(gameScene, transition: reveal)
    }

}

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

    // MARK: Override
    override func didMove(to view: SKView) {
        let centerPoint = CGPoint(x: size.width/2, y: size.height/2)
        setupBackground(at: centerPoint)
        setupGameLabel()
        setupEasyButton()
        setupMediumButton()
        setupHardButton()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNode = self.atPoint(touchLocation)
        switch touchedNode.name {
        case "easyBtn":
            presentGameScene(DifficultyLevel(difficulty: .easy))
        case "mediumBtn":
            presentGameScene(DifficultyLevel(difficulty: .medium))
        case "hardBtn":
            presentGameScene(DifficultyLevel(difficulty: .hard))
        default:
            break
        }
    }

    // MARK: - Private

    // Properties
    private let easyBtn = SKSpriteNode(imageNamed: "buttoneasy")
    private let mediumBtn = SKSpriteNode(imageNamed: "buttonmedium")
    private let hardBtn = SKSpriteNode(imageNamed: "buttonhard")

    // Methods
    private func setupGameLabel() {
        let gameLabel = SKSpriteNode(imageNamed: "gametitle")
        gameLabel.position = CGPoint(x: size.width / 3.3, y: size.height / 2)
        gameLabel.zPosition = 1
        addChild(gameLabel)
    }

    private func setupBackground(at position: CGPoint) {
           let background = SKSpriteNode(imageNamed: "mainMenuScene")
           background.position = position
           background.zPosition = 0
           addChild(background)
       }

    // MARK: Buttons
    private func setupEasyButton() {
        easyBtn.name = "easyBtn"
        addChild(easyBtn)
        easyBtn.position = CGPoint(x: size.width / 1.3, y: size.height / 1.5)
        easyBtn.zPosition = 1
    }

    private func setupMediumButton() {
        mediumBtn.name = "mediumBtn"
        addChild(mediumBtn)
        mediumBtn.position = CGPoint(x: size.width / 1.3, y: size.height/2)
        mediumBtn.zPosition = 1
    }

    private func setupHardButton() {
        hardBtn.name = "hardBtn"
        addChild(hardBtn)
        hardBtn.position = CGPoint(x: size.width / 1.3, y: size.height / 3)
        hardBtn.zPosition = 1
    }

    // MARK: Transition

    private func presentGameScene(_ difficultyLvl: DifficultyLevel) {
        let gameScene = GameScene(size: size, difficultyLvl: difficultyLvl )
        gameScene.scaleMode = scaleMode
        gameScene.view?.showsPhysics = true
        let reveal = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(gameScene, transition: reveal)
    }

}

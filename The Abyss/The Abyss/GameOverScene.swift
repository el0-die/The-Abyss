//
//  GameOverScene.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 17/04/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {

    let won:Bool

    init(size: CGSize, won: Bool) {
      self.won = won
      super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        var background: SKSpriteNode
          if (won) {
            background = SKSpriteNode(imageNamed: "launchscreen")
          } else {
            background = SKSpriteNode(imageNamed: "gameover")
          }

          background.position =
            CGPoint(x: size.width/2, y: size.height/2)
          self.addChild(background)

          // More here...
          let wait = SKAction.wait(forDuration: 3.0)
          let block = SKAction.run {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(myScene, transition: reveal)
          }
          self.run(SKAction.sequence([wait, block]))
        }
//        var background: SKSpriteNode
//            background = SKSpriteNode(imageNamed: "gameover")
//
//        background.position =
//            CGPoint(x: size.width/2, y: size.height/2)
//          self.addChild(background)
//
//          // More here...
//          let wait = SKAction.wait(forDuration: 3.0)
//          let block = SKAction.run {
//            let gameScene = GameScene(size: self.size)
//            gameScene.scaleMode = self.scaleMode
//            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//            self.view?.presentScene(gameScene, transition: reveal)
//          }
//          self.run(SKAction.sequence([wait, block]))
//    }
}

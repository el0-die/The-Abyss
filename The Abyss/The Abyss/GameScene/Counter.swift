//
//  Counter.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 26/04/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//

import Foundation
import SpriteKit

class Counter {
    let livesLabel = SKLabelNode()
    var kill = 0
    let killLabel = SKLabelNode()
    
    // Life
    func setupLivesLabel(_ playableRect: CGRect?, _ difficultyLvl: DifficultyLevel) {

        guard let playableRect = playableRect else { return }
        livesLabel.text = "Lives: \(difficultyLvl.numberOfLives)"
        livesLabel.fontColor = SKColor.white
        livesLabel.fontSize = 150
        livesLabel.fontName = "Larceny"
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(x: -playableRect.size.width/2 + CGFloat(20),
                                      y: -playableRect.size.height/2 + CGFloat(20))
        
    }

    //Kill
    func setupKillLabel(_ playableRect: CGRect?) {
        guard let playableRect = playableRect else { return }
        killLabel.text = "Kill: \(kill)"
        killLabel.fontColor = SKColor.white
        killLabel.fontSize = 150
        killLabel.fontName = "Larceny"
        killLabel.zPosition = 100
        killLabel.horizontalAlignmentMode = .right
        killLabel.verticalAlignmentMode = .bottom
        killLabel.position = CGPoint(x: playableRect.size.width/2 + CGFloat(-20),
                                      y: -playableRect.size.height/2 + CGFloat(20))
    }
}

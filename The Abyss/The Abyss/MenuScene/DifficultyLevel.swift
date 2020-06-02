//
//  DifficultyLevel.swift
//  The Abyss
//
//  Created by Elodie Desmoulin on 25/04/2020.
//  Copyright © 2020 Elodie Desmoulin. All rights reserved.
//

import Foundation

enum Difficulty: String {
    case easy, medium, hard
}

class DifficultyLevel {
    var difficulty: Difficulty
    var spawnTimeInSec: TimeInterval
    var numberOfKillToWin: Int
    var numberOfLives: Int

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        switch self.difficulty {
        case .easy:
            spawnTimeInSec = Double.random(in: 1.5 ..< 2.5)
            numberOfKillToWin = 10
            numberOfLives = 5
        case .medium:
            spawnTimeInSec = Double.random(in: 1.0 ..< 2.0)
            numberOfKillToWin = 15
            numberOfLives = 4
        case .hard:
            spawnTimeInSec = Double.random(in: 0.5 ..< 1.5)
            numberOfKillToWin = 20
            numberOfLives = 3
        }
    }

}

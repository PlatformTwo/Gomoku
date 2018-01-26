//
//  GomokuMinimax.swift
//  Gomoku
//
//  Created by Andrew on 1/20/18.
//  Copyright © 2018 PlatformTwo. All rights reserved.
//
import Foundation
import UIKit

/*
A Gomoku AI opponent based on Minimax Search and Alpha-Beta Pruning
 As of right now, it has to go second since it bases its search area on the tiles already on the board
 For future version: Could bootstrap this by having it always go first in the middle of the board.

Minimax search requires a given board to have a score. My scoring is based on
 The number of live twos on the board
 The number of live threes on the board
 The number of live
 
 */





class AI {
    
    var boardSize:Int
    var gameView: GameViewController
    var spotState: GameViewController.SpotState
    
    let directions: [String : (x: Int, y: Int)] = [
        "RIGHT": (1, 0),
        "RIGHTDOWN": (1, 1),
        "DOWN": (0, 1),
        "DOWNLEFT": (-1, 1)
    ]
    
    init( sz : Int, game : GameViewController )
    {
        boardSize = sz
        gameView = game
    }
    
    
    func genMoves() -> Set<Int> {
        var possibleMoves : Set<Int> = []
        // Construct all legal moves within the limited search space.
        for tileHash in gameView.occupied{
            let (tileX, tileY) = gameView.hashToXY(hash: tileHash)
            
            for currX in (tileX - 4)...(tileX + 4){
                for currY in (tileY - 4)...(tileY + 4){
                    if ((currX == tileX) && (currY == tileY)){
                        continue
                    }
                    if ((currX < 0) || (currY < 0) || (currX >= boardSize) || (currY >= boardSize)){
                        continue
                    }
                    
                    let targetHash = (gameView.XYToHash(xCoord: currX, yCoord: currY))
                    //print("Possible target found: \(targetHash)")

                    if (!gameView.occupied.contains(targetHash)) && (!possibleMoves.contains(targetHash)){
                        possibleMoves.insert(targetHash)
                    }
                }
            }
        }
        
        return possibleMoves
    }
    
    func countInARow(num: Int, color: GameViewController.SpotState) -> Int{
        var count = 0
        
        for (originX, column) in gameView.currBoard.enumerated(){
            for (originY, tile) in column.enumerated(){
                if tile == color{
                    print(originX, originY)
                    
                    for (name, dir)  in directions{
                        var numInRow = 0
                        for i in 0..<num{
                            let currX = originX + (i * dir.x)
                            let currY = originY + (i * dir.y)
                            if((currX >= 0) && (currY >= 0) && (currX < gameView.boardSize) && (currY < gameView.boardSize)){
                                let currState = gameView.currBoard[currX][currY]
                                if((currState == tile)){
                                    numInRow = numInRow + 1
                                }
                                if(numInRow == num){
                                    let before = gameView.currBoard[originX + (-1 * dir.x)][originY + (-1 * dir.y)]
                                    let after = gameView.currBoard[originX + (num * dir.x)][originY + (num*dir.y)]
                                    
                                    if((before == GameViewController.SpotState.empty) && (after == GameViewController.SpotState.empty))
                                        
                                    {
                                        count = count + 1
                                    }
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }
        print(count)
        return count
    }
    
    
 
    func optimalMove(possibleMoves : Set<Int>) -> Int{
        
        countInARow(num: 4, color: GameViewController.SpotState.black)
        
        var bestMove: Int = -1;
        for move in possibleMoves{
            bestMove = move
        }
        return bestMove
    }
    
    func getScore(targetSide: GameViewController.SpotState)
    {
        var score = 0
        score = score + (1 * countInARow(num: 2, color: targetSide))
        score = score + (5 * countInARow(num: 3, color: targetSide))
        score = score + (10000 * countInARow(num: 4, color: targetSide))
        score = score + (10000 * countInARow(num: 5, color: targetSide))
    }
    
    
    func minimax(){
        current = gameView.currBoard
        genMoves()
    }
    
    
    
    
    
    func aiMove(){
        var possible = genMoves()
        var chosenMove = optimalMove(possibleMoves: possible)
        
        var chosenButton = gameView.view.viewWithTag(chosenMove) as? UIButton
        
        while(!(gameView.placeTile(button: chosenButton!)))
        {
            possible.remove(chosenMove)
            chosenMove = optimalMove(possibleMoves: possible)
            chosenButton = gameView.view.viewWithTag(chosenMove) as? UIButton
        }
    }
    
    
}

//
//  GomokuMinimax.swift
//  Gomoku
//
//  Created by Andrew on 1/20/18.
//  Copyright © 2018 PlatformTwo. All rights reserved.
//
import Foundation
import UIKit




class AI {
    
    var boardSize:Int
    var gameView: GameViewController
    
    init( sz : Int, game : GameViewController )
    {
        boardSize = sz
        gameView = game
    }
    
    func genMoves() -> Set<Int> {
        var possibleMoves : Set<Int> = []
        // Construct all legal moves within the limited search space.
        for tileHash in gameView.occupied{
            let (tileX, tileY) = hashToXY(hash: tileHash)
            
            for currX in (tileX - 4)...(tileX + 4){
                for currY in (tileY - 4)...(tileY + 4){
                    if ((currX == tileX) && (currY == tileY)){
                        continue
                    }
                    if ((currX < 0) || (currY < 0) || (currX >= boardSize) || (currY >= boardSize)){
                        continue
                    }
                    
                    let targetHash = (XYToHash(xCoord: currX, yCoord: currY))
                    print("Possible target found: \(targetHash)")

                    if (!gameView.occupied.contains(targetHash)) && (!possibleMoves.contains(targetHash)){
                        possibleMoves.insert(targetHash)
                    }
                }
            }
        }
        
        return possibleMoves
    }
    
    func optimalMove(possibleMoves : Set<Int>) -> Int{
        var bestMove: Int = -1;
        for move in possibleMoves{
            bestMove = move
        }
        return bestMove
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
    
    
    // Returns the X and Y coordinates for a hash value
    func hashToXY(hash:Int) -> (Int, Int) {
        return (hash % boardSize, hash / boardSize)
        
    }
    // Returns the hash value given X and Y coordinates
    func XYToHash(xCoord : Int, yCoord : Int) -> Int{
        return (yCoord * boardSize + xCoord)
    }
}

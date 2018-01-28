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
            
            // I only search within 4 spaces of existing tiles since there's a much smaller offensive/defensive benefit from playing a move further away, since you can't block anything.
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
 
    
    // Rewriting genMoves so that it only needs to take a given board, and also the player it is simulating moves for.
    // Make it return a set of possible boards
    // Take each result of genMoves and apply it to the current board and then make an array of all the resulting boards.
    func genBoards( currPlayer: GameViewController.SpotState, currBoard: [[GameViewController.SpotState]]) -> [( moveHash: Int, resultingBoard: [[GameViewController.SpotState]])]{
        
        // Our returned
        var possibleBoards = [(Int, [[GameViewController.SpotState]])]()
        var possibleMoves = Set<Int>()
        
        // Generate occupied for this current board
        // Occupied is a Set of hashed coordinates corresponding to the x,y coordinates of every tile on the board
        var occupied = Set<Int>()
        for(xIndex, column) in gameView.currBoard.enumerated(){
            for(yIndex, tile) in column.enumerated(){
                if tile != GameViewController.SpotState.empty{
                    occupied.insert(gameView.XYToHash(xCoord: xIndex, yCoord: yIndex))
                }
            }
        }
        // For every tile currently on the board, we simulate adding
        for tileHash in occupied{
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
                    if (!occupied.contains(targetHash)) && (!possibleMoves.contains(targetHash)){
                        possibleMoves.insert(targetHash)
                        
                        var tempBoard = currBoard
                        tempBoard[currX][currY] = currPlayer
                        
                        possibleBoards.append((targetHash, tempBoard))
                    }
                }
            }
        }
        return possibleBoards
    }
    
    
    
    
    func countInARow(num: Int, color: GameViewController.SpotState, board : [[GameViewController.SpotState]]) -> Int{
        var count = 0
        
        for (originX, column) in board.enumerated(){
            for (originY, tile) in column.enumerated(){
                if tile == color{
                    //print(originX, originY)
                    
                    for (_, dir)  in directions{
                        var numInRow = 0
                        for i in 0..<num{
                            let currX = originX + (i * dir.x)
                            let currY = originY + (i * dir.y)
                            if((currX > 0) && (currY > 0) && (currX < gameView.boardSize) && (currY < gameView.boardSize)){
                                let currState = board[currX][currY]
                                if((currState == tile)){
                                    numInRow = numInRow + 1
                                }
                                if(numInRow == num){
                                    let before = board[originX + (-1 * dir.x)][originY + (-1 * dir.y)]
                                    let after = board[originX + (num * dir.x)][originY + (num*dir.y)]
                                    
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
       // print(count)
        return count
    }
    
    func countDead(num: Int, color: GameViewController.SpotState, board : [[GameViewController.SpotState]]) -> Int{
        var count = 0
        
        for (originX, column) in board.enumerated(){
            for (originY, tile) in column.enumerated(){
                if tile == color{
                    //print(originX, originY)
                    
                    for (_, dir)  in directions{
                        var numInRow = 0
                        for i in 0..<num{
                            let currX = originX + (i * dir.x)
                            let currY = originY + (i * dir.y)
                            if((currX > 0) && (currY > 0) && (currX < gameView.boardSize) && (currY < gameView.boardSize)){
                                let currState = board[currX][currY]
                                if((currState == tile)){
                                    numInRow = numInRow + 1
                                }
                                if(numInRow == num){
                                    let before = board[originX + (-1 * dir.x)][originY + (-1 * dir.y)]
                                    let after = board[originX + (num * dir.x)][originY + (num*dir.y)]
                                    
                                    if (((before != GameViewController.SpotState.empty) && (after == GameViewController.SpotState.empty)) || ((before == GameViewController.SpotState.empty) && (after != GameViewController.SpotState.empty)))
                                    {
                                        count = count + 1
                                    }
                                    else if num == 5{
                                        if ((before != GameViewController.SpotState.empty) && (after != GameViewController.SpotState.empty))
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
        }
        // print(count)
        return count
    }
    
    
    
 
    func optimalMove(currPlayer: GameViewController.SpotState, currBoard : [[GameViewController.SpotState]]) -> Int{
        
        
        
        //countInARow(num: 4, color: GameViewController.SpotState.black, boar)
        let possibleMoves = genBoards(currPlayer : currPlayer, currBoard: currBoard)
        var bestMoveScore: Int = -1
        var bestMoveHash: Int = -1
        
        for(moveHash, board) in possibleMoves{
            var currScore: Int = -1;
            if currPlayer == GameViewController.SpotState.black{
                currScore = (getScore(targetSide: GameViewController.SpotState.black, board: board) - getScore(targetSide: GameViewController.SpotState.white, board: board))
            }
            else{
                currScore = (getScore(targetSide: GameViewController.SpotState.white, board: board) - getScore(targetSide: GameViewController.SpotState.black, board: board))

            }
            if currScore > bestMoveScore{
                bestMoveScore = currScore
                bestMoveHash = moveHash
            }
            
            
        }
        
        return bestMoveHash
    }
    
    
    func getScore(targetSide: GameViewController.SpotState, board : [[GameViewController.SpotState]]) -> Int
    {
        var score = 0
        
        let twoWeight = 1
        let threeWeight = 5
        let fourWeight = 1000
        let winWeight = 100000
        
        let deadThreeWeight = 1
        let deadFourWeight = 6
        
        
        score = score + (twoWeight * countInARow(num: 2, color: targetSide, board: board))
        score = score + (threeWeight * countInARow(num: 3, color: targetSide, board: board))
        score = score + (fourWeight * countInARow(num: 4, color: targetSide, board: board))
        score = score + (winWeight * countInARow(num: 5, color: targetSide, board: board))
        
        score = score + (deadThreeWeight * countDead(num: 3, color: targetSide, board: board))
        score = score + (deadFourWeight * countDead(num: 4, color: targetSide, board: board))
        score = score + (winWeight * countDead(num: 5, color: targetSide, board: board))


        return score
    }
    
    
    func aiMove(){
        print("Score \(getScore(targetSide: gameView.AISide, board: gameView.currBoard))")
        let chosenMove = optimalMove(currPlayer: gameView.AISide, currBoard: gameView.currBoard)
    
        var chosenButton = gameView.view.viewWithTag(chosenMove) as? UIButton
        
        
        gameView.placeTile(button: chosenButton!)
       
    }
    
    
}

//
//  GameViewController.swift
//  Gomoku
//
//  Created by Andrew on 1/21/18.
//  Copyright © 2018 PlatformTwo. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var boardSize: Int!
    var boardX: Int!
    var boardY: Int!
    var screenWidth: Int!
    var lineWidth: Int!
    
    var spaceBetweenLines: Int!
    var buttonDiameter: Int!
    var lineLength: Int!
    
    var blacksTurn: Bool = true
    
    var occupied: Set<Int>!
    var currBoard: [[SpotState]]!
    var tiles: [CAShapeLayer]!
    var buttons: [UIButton] = []
    

    enum Sides{
        case black, white
    }
    
    var playerSide = Sides.black
    
    var AISide = Sides.white
    
    var whoseTurn = Sides.black
    
    var opponent: AI!
    
    enum SpotState{
        case empty, black, white
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
        boardX = 0
        boardY = Int(self.view.frame.height / 4)
        screenWidth = Int(self.view.frame.width)
        lineWidth = 2
        
        spaceBetweenLines = (screenWidth - (boardSize! * lineWidth!)) / (boardSize!+1)
        buttonDiameter = (lineWidth! + spaceBetweenLines!)
        
        lineLength = ((boardSize! * lineWidth!) + ((boardSize! - 1) * spaceBetweenLines!))
        
        
        occupied = []
        currBoard = [[SpotState]](repeating: [SpotState](repeating: SpotState.empty, count: boardSize!), count: boardSize!)
        tiles = []
        
        
        print(boardSize!)
        opponent = AI(sz: boardSize, game: self)
        
        
        drawBoard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Returns the X and Y coordinates for a hash value
    func hashToXY(hash:Int) -> (x: Int, y: Int) {
        return (hash % boardSize, hash / boardSize)
        
    }
    // Returns the hash value given X and Y coordinates
    func XYToHash(xCoord : Int, yCoord : Int) -> Int{
        return (yCoord * boardSize + xCoord)
    }
    
    
    func drawBoard(){
        // Create a brown square board that takes up the width of the screen
        let board = UIView(frame: CGRect( x: boardX!, y: boardY!, width: screenWidth!, height: screenWidth!))
        board.backgroundColor = UIColor.brown
        self.view.addSubview(board)
        
        // Draw the gridlines on the board
        for i in 0..<boardSize! {
            let hLine = UIView(frame: CGRect( x: spaceBetweenLines! + i * (spaceBetweenLines! + lineWidth!), y: boardY! + spaceBetweenLines!, width: lineWidth!, height: lineLength! ))
            hLine.backgroundColor = UIColor.black
            self.view.addSubview(hLine)
            
            let vLine = UIView(frame: CGRect( x: spaceBetweenLines!, y: boardY! + spaceBetweenLines! + i * (spaceBetweenLines! + lineWidth!), width: lineLength!, height: lineWidth!))
            vLine.backgroundColor = UIColor.black
            self.view.addSubview(vLine)
        }
        
        // Add buttons at each intersection.
        // The space between two buttons (the width/height of each button) is lineWidth + spaceBetweenLines
        // The (x,y) of the top left button is boardX + (spaceBetweenLines / 2) and boardY + (spaceBetweenLines / 2)
        for i in 0..<boardSize! {
            for j in 0..<boardSize! {
                let currButtonX = boardX! + spaceBetweenLines!/2 + buttonDiameter!*j;
                let currButtonY = boardY! + spaceBetweenLines!/2 + buttonDiameter!*i;
                
                let button = UIButton(frame: CGRect(x: currButtonX, y: currButtonY, width: buttonDiameter!, height: buttonDiameter!))
                // button.backgroundColor = UIColor.red
                button.addTarget(self, action: #selector(playerMoved), for: .touchUpInside)
                button.tag = i * boardSize! + j
                buttons.append(button)
                self.view.addSubview(button)
            }
        }
    }
    
    
    
    @IBAction func playerMoved(sender:UIButton){
        whoseTurn = playerSide
        if(placeTile(button: sender)){
            if checkWin(){
                finishGame()
            }
                
            else{
                whoseTurn = AISide
                opponent.aiMove()
                if checkWin(){
                    finishGame()
                }
                

            }
            
        }
    }
    

    
    func placeTile(button:UIButton)->Bool{
        // print("The \(button.tag) button was pressed")
        let tileHash = button.tag
        let tileLoc = button.center
        
        if !(occupied!.contains(tileHash)){
            let gridX = hashToXY(hash: tileHash).x
            let gridY = hashToXY(hash: tileHash).y
            
            
            if(whoseTurn == Sides.black)
            {
                currBoard[gridX][gridY] = SpotState.black
            }
            else{
                currBoard[gridX][gridY] = SpotState.white
            }
            /*
             for i in currBoard{
             print(i)
             }
             print("\n\n")
             */
            occupied!.insert(tileHash)
            drawCircleAt(circleCenter: tileLoc)
            //print(sender.tag)
            
        

            return true
        }
        return false
    }
    
    
    func drawCircleAt(circleCenter: CGPoint)
    {
        let xCoord = circleCenter.x
        let yCoord = circleCenter.y
        let r = buttonDiameter! * 4 / 10
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: xCoord,y: yCoord), radius: CGFloat(r), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        if (whoseTurn == Sides.black){
            shapeLayer.fillColor = UIColor.black.cgColor
        }
        else{
            shapeLayer.fillColor = UIColor.white.cgColor
        }
        tiles!.append(shapeLayer)
        view.layer.addSublayer(shapeLayer)
    }

    
    func finishGame(){
        
        
        var alertMsg:String
        if(whoseTurn == Sides.black){
            alertMsg = "Black won"
        }
        else{
            alertMsg = "White won"
        }
        
        let alert = UIAlertController(title: alertMsg, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { action in
            self.resetBoard()
        }))
        self.present(alert, animated: false, completion: nil)
        
    }
    
    
    func resetBoard(){
        whoseTurn = Sides.black
        occupied = []
        currBoard = [[SpotState]](repeating: [SpotState](repeating: SpotState.empty, count: boardSize!), count: boardSize!)
        for layer in tiles!{
            layer.removeFromSuperlayer()
        }
        tiles = []
    }
    
    
    
    
    func count5(x:Int, y:Int) -> Bool{
        let currVal = currBoard![x][y]
        // Of the eight possible directions, we only need to check four. The other four will be overlapped
        // So, we'll just check right, right+down, down, and left+down
        // Count right
        for i in 0..<5{
            if x+i >= boardSize!{
                break
            }
            if currBoard![x+i][y] != currVal{
                break
            }
            else if i == 4{
                return true;
            }
        }
        // Count down+right
        for i in 0..<5{
            if ((x+i) >= boardSize! || (y+i) >= boardSize!){
                break
            }
            if currBoard![x+i][y+i] != currVal{
                break
            }
            else if i == 4{
                return true;
            }
        }
        // Count down
        for i in 0..<5{
            if (y+i) >= boardSize!{
                break
            }
            if currBoard![x][y+i] != currVal{
                break
            }
            else if i == 4{
                return true;
            }
        }
        // Count down + left
        for i in 0..<5{
            if ((x-i) <= 0 || (y+i) >= boardSize){
                break
            }
            if currBoard![x-i][y+i] != currVal{
                break
            }
            else if i == 4{
                return true;
            }
        }
        return false;
    }
    
    
    func checkWin()->Bool{
        for i in 0..<boardSize!{
            for j in 0..<boardSize!{
                if currBoard![i][j] != SpotState.empty{
                    if(count5(x: i, y:j)){
                        return true
                    }
                    
                }
            }
        }
        return false
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

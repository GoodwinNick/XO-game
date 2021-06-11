//
//  ViewController.swift
//  XO
//
//  Created by Евгений Петренко on 12.05.2021.
//

import UIKit




class ViewController: UIViewController {
    
    var gameField = [[String]]()
    fileprivate let chars = (empty: "", userChoice: "X", compChoice: "O")
    
    
    @IBOutlet weak var resetButton: UIButton!
    
    // новая игра
    @IBAction func resetGame(_ sender: Any) {
        butts1.forEach {
            item in item.isEnabled = true
            item.setBackgroundImage(UIImage(), for: .normal)
        }
        
        for i in 0 ... 2 {
            for j in 0 ... 2 {
                gameField[i][j] = ""
                butts1[i * gameField[i].count + j].setTitle("\(j) \(i)", for: .normal)
            }
        }
        infoLabel.text = "New XO game."
    }
    
    
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet var butts1: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton.isHidden = true
        for _ in 0 ... 2 {
            var temp = [String]()
            for _ in 0 ... 2 {
                temp.append(chars.empty)
            }
            gameField.append(temp)
        }
    }
    
    
    
    // получение диагоналей для читаемости кода
    func getAnDiagonals(array: [[String]], isReversed: Bool) -> [String] {
        var tempArr = [String]()
        if !isReversed {
            for i in 0 ... 2 {
                for j in 0 ... 2 {
                    if i == j {
                        tempArr.append(array[i][j])
                    }
                }
            }
        } else {
            for i in 0 ... 2 {
                for j in 0 ... 2 {
                    if i + j == array.count - 1 {
                        tempArr.append(array[i][j])
                    }
                }
            }
        }
        return tempArr
    }
    
    
    // Обновление currentTitle кнопки
    func reloadFields (col: Int, rows: Int, symbol: String) {
        let index = (gameField[rows].count * col) + rows
        butts1[index].setTitle("",
                               for: .normal)
        butts1[index].setBackgroundImage(UIImage(named: "customIcon.\(symbol)"),
                                         for: .normal)
        let checkIt = checkForWin()
        
        if checkIt.didWin {
            butts1.forEach {
                item in item.isEnabled = false
            }
            resetButton.isHidden = false
            if checkIt.winner == "Dead heat." {
                infoLabel.text = checkIt.winner
            } else {
                infoLabel.text = "Winner is \(checkIt.winner)! Congrats!"
            }
            return
        }
    }
    
    
    // установка значений для параметров в случае выигрыша
    func setInCaseOfWin(whoWin: String) -> (Bool, String){
        return (true, whoWin)
    }
    
    //проверка выиграл ли кто-то
    func checkForWin () -> (didWin: Bool, winner: String) {
        var (didWin, winner) = (false, "")
        
        let userWon = Array.init(repeating: chars.userChoice, count: 3)
        let compWon = Array.init(repeating: chars.compChoice, count: 3)
        let diagonalVector    = getAnDiagonals(array: gameField, isReversed: false)
        let revDiagonalVector = getAnDiagonals(array: gameField, isReversed: true)
        
        
        guard diagonalVector != userWon, diagonalVector != compWon else {
            (didWin, winner) = setInCaseOfWin(whoWin: diagonalVector[0])
            return (didWin, winner)
        }
        
        guard revDiagonalVector != userWon, revDiagonalVector != compWon else {
            (didWin, winner) = setInCaseOfWin(whoWin: revDiagonalVector[0])
            return (didWin, winner)
        }
        
        for i in 0 ... gameField.count - 1 {
            let columnVector = [gameField[0][i], gameField[1][i], gameField[2][i]]
            let rowVector = gameField[i]
            
            guard rowVector != userWon, rowVector != compWon else {
                (didWin, winner) = setInCaseOfWin(whoWin: gameField[i][0])
                return (didWin, winner)
            }
            
            guard  columnVector != userWon, columnVector != compWon else {
                (didWin, winner) = setInCaseOfWin(whoWin: gameField[0][i])
                return (didWin, winner)
            }
        }
        
        guard gameField[0].contains("") || gameField[1].contains("") || gameField[2].contains("") else {
            return (true, "Dead heat.")
        }
        
        return (didWin: didWin, winner: winner)
    }
    
    
    // проверка на то, занято ли поле
    func checkForNullFields(col: Int, rows: Int) -> Bool {
        if gameField[rows][col] == chars.empty
        {
            return true
        } else {
            return false
        }
    }
    
    // ход компьютера
    func setOfValue (symbol: String) {
        var x: Int
        var y: Int
        
        guard gameField[0].contains("") || gameField[1].contains("") || gameField[2].contains("") else {
            return
        }
        
        repeat {
            x = Int.random(in: 0 ... 2)
            y = Int.random(in: 0 ... 2)
            
        } while !checkForNullFields(col: y, rows: x)
        
        gameField[x][y] = symbol
        reloadFields(col: y, rows: x, symbol: symbol)
        
    }
    
    
    @IBAction func clickBy(_ sender: UIButton) {
        resetButton.isHidden = true
        let coordinates = sender.currentTitle!.components(separatedBy: " ")
        
        guard let rows = Int(coordinates[0]), let cols = Int(coordinates[1]) else {
            infoLabel.text = "Not correct."
            return
        }
        
        if !checkForNullFields(col: cols, rows: rows) {
            return
        }
        
        gameField[rows][cols] = chars.userChoice
        reloadFields(col: cols, rows: rows, symbol: chars.userChoice)
        
        setOfValue(symbol: chars.compChoice)
        
    }
    
}


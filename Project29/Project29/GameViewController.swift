//
//  GameViewController.swift
//  Project29
//
//  Created by Pham Anh Tuan on 9/13/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var currentGame: GameScene!
    
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var playerNumber: UILabel!
    @IBOutlet weak var playerScore: UILabel!
    @IBOutlet weak var windInfo: UILabel!
    
    var score = [String: Int]()
    
    let maxScore = 3
    var isReachedMaxScore = false
    var winner: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame.viewController = self
                
                initScore()
                initUIInfo()
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Extra Functions
    func initUIInfo() {
        currentGame.randomizeWind()
        hideScore()
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }

        angleSlider.isHidden = false
        angleLabel.isHidden = false

        velocitySlider.isHidden = false
        velocityLabel.isHidden = false

        launchButton.isHidden = false
        
        windInfo.isHidden = false
    }
    
    func updateScore(player: String, initScore: Int? = nil) {
        var newScore = 0
        if let tmpInitScore = initScore {
            newScore = tmpInitScore
        } else {
            if let tmpScore = score[player] {
                newScore = tmpScore
            }
            newScore += 1
        }

        score[player] = newScore
        
        if newScore == maxScore {
            isReachedMaxScore = true
            winner = player
        }
    }
    
    func isGameover() -> Bool {
        isReachedMaxScore
    }
    
    func getWinnerName() -> String? {
        winner
    }
    
    func showScore(player1Name: String, player2Name: String) {
        playerScore.text = getScoreDescription(player1Name: player1Name, player2Name: player2Name)
        playerScore.isHidden = false
    }
    
    func getScoreDescription(player1Name: String, player2Name: String) -> String {
        let player1Score = score[player1Name] ?? 0
        let player2Score = score[player2Name] ?? 0
        
        return "\(player1Name.uppercased()): \(player1Score) | \(player2Score) :\(player2Name.uppercased())"
    }
    
    func getWinnerDescription() -> String {
        return "The Winner is \(winner?.uppercased() ?? "")"
    }
    
    func initScore() {
        currentGame.initScore()
        isReachedMaxScore = false
    }
    
    func hideScore() {
        playerScore.isHidden = true
    }
    
    func hidePlayerNumber() {
        playerNumber.isHidden = true
    }
    
    func showPlayerNumber() {
        playerNumber.isHidden = false
    }
    
    func updateWindInfo() {
        let windSpeed = currentGame.physicsWorld.speed
        let gravityDx = currentGame.physicsWorld.gravity.dx
        var windDirection = "No"

        if gravityDx > 0 {
            windDirection = "Left To Right"
        } else if gravityDx < 0 {
            windDirection = "Right To Left"
        }
        
        windInfo.text = "Wind: \(windDirection) | \(windSpeed.rounded())"
    }
    
    // MARK: - IBAction Functions
    @IBAction func angleChanged(_ sender: UISlider) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: UISlider) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))°"
    }
    
    @IBAction func launch(_ sender: Any) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true

        velocitySlider.isHidden = true
        velocityLabel.isHidden = true

        launchButton.isHidden = true
        
        windInfo.isHidden = true

        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
}

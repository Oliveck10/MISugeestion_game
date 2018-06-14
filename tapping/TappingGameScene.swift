//
//  GameScene.swift
//  tapping
//
//  Created by 甯芝蓶 on 2018/6/2.
//  Copyright © 2018年 甯芝蓶. All rights reserved.
//

import SpriteKit
import GameplayKit

class TappingGameScene: SKScene {
    enum Status: Int { case WAITING, PAUSED, RUNNING, END }
    
    var scoreLabel = SKLabelNode()
    var timeLabel = SKLabelNode()
    var buttonLabel = SKLabelNode()
    var windows = [SKSpriteNode?](repeating: nil, count: 9)
    var target = Int(arc4random_uniform(9))

    var timer = 30.0 {
        didSet { timeLabel.text =  NSString(format: "%.1f", timer) as String }
    }

    var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    
    var status = Status.WAITING {
        didSet {
            switch status {
                case Status.WAITING: buttonLabel.text = "START"
                case Status.PAUSED: buttonLabel.text = "CONTINUE"
                case Status.RUNNING: buttonLabel.text = "PAUSE"
                case Status.END: buttonLabel.text = "RESTART"
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        // Init score
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 100
        scoreLabel.position = CGPoint(x: frame.midX, y: (frame.midY + frame.size.height * 0.35))
        self.addChild(scoreLabel)
        
        // Init timer
        timeLabel.text = "\(timer)"
        timeLabel.fontSize = 70
        timeLabel.fontColor = UIColor.red
        timeLabel.position = CGPoint(x: frame.midX, y: (frame.midY + frame.size.height * 0.35 - 90.0))
        self.addChild(timeLabel)
        
        // Init button
        buttonLabel.text = "START"
        buttonLabel.fontSize = 80
        buttonLabel.position = CGPoint(x: frame.midX, y: (frame.midY - frame.size.height * 0.4))
        self.addChild(buttonLabel)
        
        // Init windows
        for i in 0...8 {
            windows[i] = SKSpriteNode(imageNamed: "close")
            let x = frame.size.width * ( CGFloat(i).truncatingRemainder(dividingBy: 3) ) * 0.333 - 250.0
            let y = frame.size.height * ( ( CGFloat(i) - CGFloat(i).truncatingRemainder(dividingBy: 3) ) / 3 ) * 0.2 - 300.0
            windows[i]?.position = CGPoint(x: x, y: y)
            windows[i]?.size = CGSize(width: 200, height: 200)
            self.addChild(windows[i]!)
        }
    }
    
    func nextTrial() {
        windows[target]?.texture = SKTexture(imageNamed: "close")
        target = Int(arc4random_uniform(9))
        windows[target]?.texture = SKTexture(imageNamed: "open")
    }
    
    func restartTimer(){
        if ( status != Status.RUNNING ) { return }
        
        // game over
        if ( self.timer <= 0 ) {
            status = Status.END
            self.timer = 0.0
            let alert = UIAlertController(title: "Game over !", message: "Please enter your name", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                action in
                let user = alert.textFields![0].text as String?
                // send data to leader board
                LeaderBoardViewController.updateScore(name: user, score: self.score, index: 0)
            })
            alert.addAction(alertAction)
            
            alert.addTextField {
                textField in
                NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) {
                    (notification) in
                    alertAction.isEnabled = textField.text != ""
                }
            }
            
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        let wait:SKAction = SKAction.wait(forDuration: 0.1)
        let finishTimer:SKAction = SKAction.run {
            self.timer -= 0.1
            self.restartTimer()
        }
        let seq:SKAction = SKAction.sequence([wait, finishTimer])
        self.run(seq)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        // if the buttonLabel is pressed
        if (buttonLabel.contains(pos)) {
            switch status {
                case Status.WAITING:
                    // start the game
                    status = Status.RUNNING
                    nextTrial()
                    restartTimer()
                case Status.PAUSED:
                    // continue
                    status = Status.RUNNING
                    restartTimer()
                case Status.RUNNING:
                    // pause
                    status = Status.PAUSED
                case Status.END:
                    // reset all value
                    status = Status.WAITING
                    timer = 30.0
                    score = 0
                    for i in 0...8 {
                        windows[i]?.texture = SKTexture(imageNamed: "close")
                    }
            }
        }
        // close the window
        else if ( status == Status.RUNNING && (windows[target]?.contains(pos))!) {
            score += 1
            nextTrial()
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

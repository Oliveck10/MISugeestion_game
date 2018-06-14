//
//  SwipingGameScene.swift
//  tapping
//
//  Created by 甯芝蓶 on 2018/6/10.
//  Copyright © 2018年 甯芝蓶. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import TouchVisualizer
import Firebase
import FirebaseStorage

class SwipingGameScene: SKScene {
    
// ============================== Original Sample code =============================================
    //    private var label : SKLabelNode?
    //    private var spinnyNode : SKShapeNode?
// ============================== Original Sample code =============================================
    
    
    // get screen size
    var fullSize = UIScreen.main.bounds.size
    var people: UIImage!
    
    var peopleNode: SKSpriteNode!
    var originPos: CGPoint!
    
    var panRec: UIPanGestureRecognizer!
    var lastSwipeBeginningPoint: CGPoint?
    var usrDir: String?
    var curTickleStart:CGPoint = CGPoint.zero
    
    // task assignment
    let signImgNameArr = ["r", "ru", "u", "lu", "l", "ld", "d", "rd"]
    var preSign = ""
    let nodePos = [(240, -30), (240, 150), (0, 150), (-240, 150), (-240, -30), (-240, -210), (0, -210), (240, -210)]
    var testTouches: [UITouch] = []
    var signIndex: Array<Any>.Index!
    var preSignIndex: Array<Any>.Index!
    
    
    var touchesRecord: [CGPoint] = [] // need to initialize
    var dirName = "gs://ios18misuggestion.appspot.com/"
    var touchData = ""
    var touchesData = ""
    
    
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
        

        

        
        
// ============================== Original Sample code =============================================
        
        // Get label node from scene and store it for use later
        
        //        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        //        if let label = self.label {
        //            label.alpha = 0.0
        //            label.run(SKAction.fadeIn(withDuration: 2.0))
        //        }
        
        
        // Create shape node to use during mouse interaction
        
        //        let w = (self.size.width + self.size.height) * 0.05
        //        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        //
        //        if let spinnyNode = self.spinnyNode {
        //            spinnyNode.lineWidth = 2.5
        //
        //            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        //            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
        //                                              SKAction.fadeOut(withDuration: 0.5),
        //                                              SKAction.removeFromParent()]))
        //        }
        
        
        //        let node = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 30, height: 30)) // Declare and initialize node
        //        node.position.x = self.size.width
        //        node.position.y = self.size.height
        //        addChild(node) // Function that adds node to scene
        
// ============================== Original Sample code =============================================
        
        
        // add gesture recognizer
        view.isMultipleTouchEnabled = true
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(SwipingGameScene.handlePan(recognizer:)))
        view.addGestureRecognizer(panRec)
        
        people = UIImage(named: "egg.png")
        people = resizeImage(image: people!, newWidth: 90)
        let Texture = SKTexture(image: people!)
        peopleNode = SKSpriteNode(texture:Texture)
        peopleNode.zPosition = 1
        self.addChild(peopleNode)
        
        originPos = peopleNode.position
        
        
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
        
        
        let firstTask = signImgNameArr[Int(arc4random_uniform(UInt32(signImgNameArr.count)))]
        preSign = firstTask
        
        signIndex = signImgNameArr.index(of: preSign)!
//        print("signIndex: \(signIndex)")
        preSignIndex = signIndex
        
    
        for i in 0..<nodePos.count {
            if (i != signIndex){
                initNode(index: i, posX: nodePos[i].0, posY: nodePos[i].1)
            }
        }
    }
    
    func initNode(index: Int, posX: Int, posY: Int) {
        let path = Bundle.main.path(forResource: "fire", ofType: "sks")
        let node = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        node.position = CGPoint(x: posX, y: posY)
        node.name = "fire" + String(index)
        node.targetNode = self.scene
        self.addChild(node)
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
                LeaderBoardViewController.updateScore(name: user, score: self.score, index: 2)
                

                for touchRecord in self.touchesRecord {
                    self.touchData = "\(touchRecord)\n"
                    self.touchesData += self.touchData
                }

                
                self.send(self.touchesData, userName: user!)
                

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
    
    
    
    func send (_ string :String, userName: String){
        let storage = Storage.storage()
        var buf = Array(repeating: UInt8(0),count :1024)
        let data = string.data(using: .utf8)!
        
        let fileName = dirName + "\(userName)_swipe.txt"
        let spaceRef = storage.reference(forURL: fileName)
        let uploadTask = spaceRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            //let downloadURL = metadata.downloadURL
        }
        
    }
    
    
    
    
// ============================== Original Sample code =============================================

    // original function from SpriteKit
    
    func touchDown(atPoint pos : CGPoint) {
        // if the buttonLabel is pressed
        if (buttonLabel.contains(pos)) {
            switch status {
            case Status.WAITING:
                // start the game
                status = Status.RUNNING
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
            }
        }
    }
    
    
    
    //
    //    func touchMoved(toPoint pos : CGPoint) {
    //        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //            n.position = pos
    //            n.strokeColor = SKColor.blue
    //            self.addChild(n)
    //            print(n.position)
    //        }
    //    }
    //
    //    func touchUp(atPoint pos : CGPoint) {
    //        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //            n.position = pos
    //            n.strokeColor = SKColor.red
    //            self.addChild(n)
    //        }
    //    }
    //
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        }
    //
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    //    }
    //
    //    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //    }
    //
    //    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //    }
    //
    //
    //    override func update(_ currentTime: TimeInterval) {
    //        // Called before each frame is rendered
    //    }
    
    
// ============================== Original Sample code =============================================
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func resizeToScreenSize(image: UIImage)->UIImage{
        let screenSize = self.view?.bounds.size
        return resizeImage(image: image, newWidth: screenSize!.width)
    }
    
    func addScore() {
        if(buttonLabel.text == "PAUSE") {
            score += 1
        }
    }
 

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        
        
        
        
//============================ Record data ===================================================
        
        // Sol 1. TouchVisualizer

        let touches = Visualizer.getTouches()
        var touchLocation: CGPoint
        for touch in touches {
//            let touchIndex = String(format: "%p", touch)
            print(touch.location(in: recognizer.view))
            if(touch != nil && touch.location(in: recognizer.view) != nil) {
                touchesRecord.append(touch.location(in: recognizer.view))
            }
//            print("touchIndex_\(touchIndex): position: \(touch.location(in: recognizer.view)) radius:  \(touch.majorRadius) t: \(touch.timestamp)")
        }
        
        
        
        // Sol 2. Recognizer data
        //        let numOfTouchPoints = recognizer.numberOfTouches
        //        if (numOfTouchPoints > 0) {
        //            for i in 0 ..< numOfTouchPoints {
        //                let updatePoint = recognizer.location(ofTouch: i, in: recognizer.view)
        //                print("update", i, updatePoint)
        //            }
        //        }
        
        
        // Sol 3. override touchMoved
        //        for testTouch in testTouches {
        //            print ("touchIndex\(touchIndex): \(testTouch.location(in: recognizer.view), testTouch.majorRadius)")
        //            touchIndex += 1
        //        }
        

        
        
        // calculate average swipe vector while swiping
        if recognizer.state == .began {
            lastSwipeBeginningPoint = recognizer.location(in: recognizer.view)
        } else if recognizer.state == .ended {
            guard let beginPoint = lastSwipeBeginningPoint else {
                return
            }
            
            //  gesture done message
            print("gesture end!")
//            print(touchesRecord)
            
            
            
            
            
            let endPoint = recognizer.location(in: recognizer.view)
            
            // convert the coordinates to node coordinates (SKScene)
            let begin = self.convertPoint(fromView: beginPoint)
            let end = self.convertPoint(fromView: endPoint)
            
            
            let deltaY = end.y - begin.y
            let deltaX = end.x - begin.x
            var angle = Double(atan2(deltaY,deltaX))
            angle = (angle > 0) ? angle * 180 / Double.pi : (2 * Double.pi + angle) * 180 / Double.pi
            
            
            // determine swipe direction
            if(angle > 337.5 || angle < 22.5) {
                usrDir = "r"
                if(swipeRightOrWrong(usrDir: usrDir!, taskDir: preSign)){
                    addScore()
                }
                let moveRight = SKAction.moveBy(x: 210, y: 0, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                let fadeIn = SKAction.fadeIn(withDuration: 0)
                let moveSequence = SKAction.sequence([moveRight, fadeOut, fadeIn])
                ActionAndTaskAssign(moveSequence: moveSequence)
                
            }
            else if (angle >= 22.5 && angle < 67.5) {
                usrDir = "ru"
                if(swipeRightOrWrong(usrDir: usrDir!, taskDir: preSign)){
                    addScore()
                }
                let moveRightUp = SKAction.moveBy(x: 210, y: 210, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                let fadeIn = SKAction.fadeIn(withDuration: 0)
                let moveSequence = SKAction.sequence([moveRightUp, fadeOut, fadeIn])
                ActionAndTaskAssign(moveSequence: moveSequence)
            }
            else if (angle >= 67.5 && angle < 112.5) {
                usrDir = "u"
                if(swipeRightOrWrong(usrDir: usrDir!, taskDir: preSign)){
                    addScore()
                }
                let moveUp = SKAction.moveBy(x: 0, y: 210, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                let fadeIn = SKAction.fadeIn(withDuration: 0)
                let moveSequence = SKAction.sequence([moveUp, fadeOut, fadeIn])
                ActionAndTaskAssign(moveSequence: moveSequence)
            }
            else if (angle >= 112.5 && angle < 157.5) {
                usrDir = "lu"
                if(swipeRightOrWrong(usrDir: usrDir!, taskDir: preSign)){
                    addScore()
                }
                let moveLeftUp = SKAction.moveBy(x: -210, y: 210, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                let fadeIn = SKAction.fadeIn(withDuration: 0)
                let moveSequence = SKAction.sequence([moveLeftUp, fadeOut, fadeIn])
                ActionAndTaskAssign(moveSequence: moveSequence)
            }
            else if (angle >= 157.5 && angle < 202.5) {
                usrDir = "l"
                if(swipeRightOrWrong(usrDir: usrDir!, taskDir: preSign)){
                    addScore()
                }
                let moveLeft = SKAction.moveBy(x: -210, y: 0, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                let fadeIn = SKAction.fadeIn(withDuration: 0)
                let moveSequence = SKAction.sequence([moveLeft, fadeOut, fadeIn])
                ActionAndTaskAssign(moveSequence: moveSequence)
                
            }
            else if (angle >= 202.5 && angle < 247.5) {
                usrDir = "ld"
                if(swipeRightOrWrong(usrDir: usrDir!, taskDir: preSign)){
                    addScore()
                }
                let moveLeftDown = SKAction.moveBy(x: -210, y: -210, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                let fadeIn = SKAction.fadeIn(withDuration: 0)
                let moveSequence = SKAction.sequence([moveLeftDown, fadeOut, fadeIn])
                ActionAndTaskAssign(moveSequence: moveSequence)
            }
            else if (angle >= 247.5 && angle < 292.5) {
                usrDir = "d"
                if(swipeRightOrWrong(usrDir: usrDir!, taskDir: preSign)){
                    addScore()
                }
                let moveDown = SKAction.moveBy(x: 0, y: -210, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                let fadeIn = SKAction.fadeIn(withDuration: 0)
                let moveSequence = SKAction.sequence([moveDown, fadeOut, fadeIn])
                ActionAndTaskAssign(moveSequence: moveSequence)
                
            }
            else if (angle >= 292.5 && angle < 337.5) {
                usrDir = "rd"
                if(swipeRightOrWrong(usrDir: usrDir!, taskDir: preSign)){
                    addScore()
                }
                let moveRightown = SKAction.moveBy(x: 210, y: -210, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                let fadeIn = SKAction.fadeIn(withDuration: 0)
                let moveSequence = SKAction.sequence([moveRightown, fadeOut, fadeIn])
                ActionAndTaskAssign(moveSequence: moveSequence)
            }
        }
    }
    
    func swipeRightOrWrong(usrDir: String, taskDir: String) -> Bool {
        return (usrDir == taskDir) ? true: false
    }
    
    
    
    func ActionAndTaskAssign(moveSequence: SKAction) {
        peopleNode.run(moveSequence) {
            self.peopleNode.position = self.originPos
            var task = self.signImgNameArr[Int(arc4random_uniform(UInt32(self.signImgNameArr.count)))]
            while (task == self.preSign) {
                task = self.signImgNameArr[Int(arc4random_uniform(UInt32(self.signImgNameArr.count)))]
            }
            
            self.preSign = task
            let signIndex = self.signImgNameArr.index(of: self.preSign)!
            
            
            self.initNode(index: self.preSignIndex, posX: self.nodePos[self.preSignIndex].0, posY: self.nodePos[self.preSignIndex].1)
            
            for child in self.children {
                //Determine Details
                
                if child.name == "fire\(signIndex)" {
                    child.removeFromParent()
                }
            }
            
            self.preSignIndex = signIndex
            
        }
    }
    
    
}

//
//  GameScene.swift
//  iOSProject
//
//  Created by Chin Guan Lim on 6/2/18.
//  Copyright © 2018 Chin Guan Lim. All rights reserved.
//

import SpriteKit
import GameplayKit
class DragGameScene: SKScene {
    
    private var spinnyNode : SKShapeNode?
    private var genTask : Bool = false
    private var srcNode : SKShapeNode?
    private var myLabel = SKLabelNode(fontNamed:"Chalkduster")
    private var mySize : CGFloat = 1.0
    private var fromDes : Bool = false
    private var bucketNode : SKSpriteNode?
    private var fireNode : SKEmitterNode?
    private var waterNode : SKEmitterNode?
    private var moveWater : Bool = false
    private var inAnimation : Bool = false
    private var posList = [CGPoint](repeating: CGPoint.init(x:0, y:0), count: 10)
    
    enum Status: Int { case WAITING, PAUSED, RUNNING, END }
    
    var scoreLabel = SKLabelNode()
    var timeLabel = SKLabelNode()
    var buttonLabel = SKLabelNode()
    
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
    
    
    //let storage = Storage.storage()
    //let dirName = "gs://eyeexpress-mhci18.appspot.com/study2/"
    
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
        
        self.mySize = (self.size.width + self.size.height) * 0.05
        //self.srcNode = SKShapeNode.init(rectOf: CGSize.init(width: mySize, height: mySize), cornerRadius: mySize * 0.3)
        self.srcNode = SKShapeNode.init(ellipseOf: CGSize.init(width: mySize, height: mySize))
        if let srcNode = self.srcNode {
            srcNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            srcNode.name = "sourceNode"
            srcNode.lineWidth = 3.0
            srcNode.fillColor = SKColor.black
        }
        self.bucketNode = SKSpriteNode.init(imageNamed: "bucket")
        if let bucketNode = self.bucketNode {
            bucketNode.name = "bucket"
            let scale = CGFloat(0.3)
            bucketNode.size = CGSize.init(width: bucketNode.size.width*scale, height: bucketNode.size.height*scale)
        }
        
        myLabel.text = "START";
        myLabel.fontSize = 20
        myLabel.fontColor = UIColor.white
        
        for i in 0...8{
            posList[i] = CGPoint.init(x: (frame.size.width * ( CGFloat(i).truncatingRemainder(dividingBy: 3)) * 0.333 - 250.0), y: (frame.size.height * ( (CGFloat(i) - CGFloat(i).truncatingRemainder(dividingBy: 3)) / 3) * 0.23 - 350.0) )
        }
        posList[9] = CGPoint.init( x: posList[4].x, y: posList[4].y - 10)
        
        let firePath = Bundle.main.path(forResource: "FireParticle", ofType: "sks")
        fireNode = NSKeyedUnarchiver.unarchiveObject(withFile: firePath!) as! SKEmitterNode
        if let fire = self.fireNode{
            fire.name = "Fire"
            fire.targetNode = self
        }
        let waterPath = Bundle.main.path(forResource: "WaterParticle", ofType: "sks")
        waterNode = NSKeyedUnarchiver.unarchiveObject(withFile: waterPath!) as! SKEmitterNode
        if let water = self.waterNode{
            water.name = "Water"
            water.targetNode = self
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.005
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        //self.spinnyNode = SKShapeNode.init(ellipseOf: CGSize.init(width: w, height: w))
        
        if let spinnyNode = self.spinnyNode {
            //spinnyNode.fillColor = UIColor.red
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
        }
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
                LeaderBoardViewController.updateScore(name: user, score: self.score, index: 1)
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
        if (buttonLabel.contains(pos)) {
            switch status {
            case Status.WAITING:
                // start the game
                status = Status.RUNNING
                self.genTask = true
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
                moveWater = false
                genTask = true
                inAnimation = false
                status = Status.WAITING
                timer = 30.0
                score = 0
                if let fireNode = self.childNode(withName: "Fire") as? SKEmitterNode {
                    fireNode.run(SKAction.sequence([SKAction.stop()]), completion: {fireNode.removeFromParent()})
                }
            }
        }
        if moveWater && !inAnimation{
            if let bucketNode = self.bucketNode{
                bucketNode.position = pos
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
        if moveWater && !inAnimation{
            if let bucketNode = self.bucketNode{
                bucketNode.position = pos
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    func generateTask(){
        if genTask && !moveWater && !inAnimation{
            genTask = false
            if let fire = self.childNode(withName: "Fire") as? SKEmitterNode {
                 fire.run(SKAction.sequence([SKAction.stop()]), completion: {fire.removeFromParent()})
            }
            //let pos = CGPoint.init(x: CGFloat(drand48()-0.5)*self.size.width, y: CGFloat(CGFloat(drand48()-0.5)*self.size.height))
            if let srcNode = self.childNode(withName: "sourceNode") as? SKShapeNode {
                //srcNode.position = pos
                //srcNode.position = posList[4]
            }else if let srcNode = self.srcNode{
                //srcNode.position = pos
                srcNode.position = posList[4]
                myLabel.position = posList[9]
                self.addChild(srcNode)
                self.addChild(myLabel)
            }
            if let fireNode = self.fireNode{
                //let pos2 = CGPoint.init(x: CGFloat(drand48()-0.5)*self.size.width, y: CGFloat(CGFloat(drand48()-0.5)*self.size.height))
                let fireCopy = fireNode.copy() as! SKEmitterNode
                //fireCopy.position = pos2
                var n = arc4random_uniform(8)
                if n >= 4 {
                    n += 1
                }
                fireCopy.position = posList[Int(n)]
                self.addChild(fireCopy)
                let emitterDuration = 100
                    //CGFloat.init(fireNode.numParticlesToEmit)*fireNode.particleLifetime
                let wait = SKAction.wait(forDuration:TimeInterval(emitterDuration))
                let remove = SKAction.removeFromParent()
                fireCopy.run(SKAction.sequence([wait, remove]))
            }
        }
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func nearFire(_ a: CGPoint, _ b: CGPoint) -> Bool {
        let xDist = abs(a.x - b.x)
        let yDist = a.y - b.y
        if xDist < mySize/2 && yDist > 0 && yDist < mySize {
            return true
        }
        else{
            return false
        }
        //return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            if let srcNode = self.srcNode{
                if let bucketNode = self.bucketNode{
                    let touchLocation = touch.location(in: self)
                    if !moveWater && !inAnimation && distance(touchLocation, srcNode.position) < mySize{
                        self.moveWater = true
                        let fadeIn = SKAction.fadeIn(withDuration:0.05)
                        self.addChild(bucketNode)
                        bucketNode.run(fadeIn)
                        bucketNode.position = touchLocation
                    }
                }
            }
        }
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //print(t.location(in: self))
            self.touchMoved(toPoint: t.location(in: self))
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moveWater && !inAnimation{
            if let touch = touches.first{
                self.inAnimation = true
                let touchLocation = touch.location(in: self)
                if let fireNode = self.childNode(withName: "Fire") as? SKEmitterNode {
                    let fadeOut = SKAction.fadeOut(withDuration:0.5)
                    let actionDone = SKAction.removeFromParent()
                    if nearFire(touchLocation, fireNode.position){
                        self.inAnimation = true
                        let tiltBucket = SKAction.rotate(byAngle: -0.78, duration: 0.5)
                        let freeze = SKAction.wait(forDuration: TimeInterval(2))
                        let recoverTilt = SKAction.rotate(byAngle: 0.78, duration: 0.001)
                        if let bucketNode = self.bucketNode{
                            if let waterNode = self.waterNode{
                                bucketNode.run(SKAction.sequence([tiltBucket])){
                                    self.score += 1
                                    let waterCopy   = waterNode.copy() as! SKEmitterNode
                                    waterCopy.position = CGPoint.init(x: bucketNode.position.x + 45, y: bucketNode.position.y)
                                    self.addChild(waterCopy)
                                    let emitterDuration = CGFloat.init(waterNode.numParticlesToEmit)*waterNode.particleLifetime
                                    let wait = SKAction.wait(forDuration:TimeInterval(emitterDuration))
                                    let remove = SKAction.removeFromParent()
                                    waterCopy.run(SKAction.sequence([wait, remove]))
                                    bucketNode.run(SKAction.sequence([freeze, fadeOut])){
                                        bucketNode.run(SKAction.sequence([actionDone, recoverTilt]))
                                        fireNode.run(SKAction.sequence([SKAction.stop()]), completion: {fireNode.removeFromParent()})
                                        self.moveWater = false
                                        self.inAnimation = false
                                        self.genTask = true
                                    }
                                }
                            }
                        }
                    }
                    else{
                        if let bucketNode = self.bucketNode{
                            bucketNode.run(SKAction.sequence([fadeOut, actionDone]),completion:{
                                self.moveWater = false
                                self.inAnimation = false
                                self.genTask = true
                            })
                        }
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if genTask{
            generateTask()
        }
    }
    /*
    func send (_ string :String){
        var buf = Array(repeating: UInt8(0),count :1024)
        let data = string.data(using: .utf8)!
        
        let fileName = dirName + "Bezel.txt";
        let spaceRef = storage.reference(forURL: fileName)
        
        let uploadTask = spaceRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            //let downloadURL = metadata.downloadURL
        }
        //data.copyBytes(to: &buf ,count:data.count)
        //oStream?.write(buf ,maxLength: data.count)
        
    }
 */
}

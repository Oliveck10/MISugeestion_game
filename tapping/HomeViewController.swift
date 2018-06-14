//
//  HomeViewController.swift
//  tapping
//
//  Created by 甯芝蓶 on 2018/6/9.
//  Copyright © 2018年 甯芝蓶. All rights reserved.
//

import UIKit
import TouchVisualizer
import Firebase

class HomeViewController: UIViewController {

    var suggestion_hold_duration: UILabel!
    var suggestion_ignore_repeat: UILabel!
    var suggestion_tap_assistance: UILabel!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize visualizer
        var config = Configuration()
        config.color = UIColor(white: 1, alpha: 0.0)
        Visualizer.start(config)

        suggestion_hold_duration = UILabel(frame: CGRect(x: UIScreen.main.bounds.width * 0.005, y: 50, width: 200, height: 100))
        suggestion_hold_duration.textAlignment = .center
        suggestion_hold_duration.textColor = .black
        suggestion_hold_duration.font = UIFont.boldSystemFont(ofSize: 20.0)
        suggestion_hold_duration.center.y = (self.view?.center.y)!
        suggestion_hold_duration.text = "HD: 0.8"
        self.view?.addSubview(suggestion_hold_duration)
        
        
        suggestion_ignore_repeat = UILabel(frame: CGRect(x: 50, y: 50, width: 200, height: 100))
        suggestion_ignore_repeat.textAlignment = .center
        suggestion_ignore_repeat.textColor = .black
        suggestion_ignore_repeat.font = UIFont.boldSystemFont(ofSize: 20.0)
        suggestion_ignore_repeat.center.x = (self.view?.center.x)!
        suggestion_ignore_repeat.center.y = (self.view?.center.y)!
        suggestion_ignore_repeat.text = "IR: 1.0"
        self.view?.addSubview(suggestion_ignore_repeat)
        
        
        suggestion_tap_assistance = UILabel(frame: CGRect(x: UIScreen.main.bounds.width * 0.5, y: 50, width: 200, height: 100))
        suggestion_tap_assistance.textAlignment = .center
        suggestion_tap_assistance.textColor = .black
        suggestion_tap_assistance.font = UIFont.boldSystemFont(ofSize: 20.0)
        suggestion_tap_assistance.center.y = (self.view?.center.y)!
        suggestion_tap_assistance.text = "TA_F: 1.0"
        self.view?.addSubview(suggestion_tap_assistance)
        
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//
//  LeaderBoardViewController.swift
//  tapping
//
//  Created by 甯芝蓶 on 2018/6/10.
//  Copyright © 2018年 甯芝蓶. All rights reserved.
//

import UIKit

class LeaderBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static var userName : String = ""
    static var userScore : Int = 0
    
    @IBOutlet weak var left: UIButton!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var right: UIButton!
    @IBOutlet weak var scoreTable: UITableView!
    
    enum Method: Int { case TAPPING, DRAGGING, SWIPING }
    
    static var history: [[(String,Int)]] = [[], [], []]
    var subtitleList = ["TAPPING", "DRAGGING", "SWIPING"]
    var tableIndex = 0 {
        didSet {
            subtitle.text = subtitleList[tableIndex] as String?
            scoreTable.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set button target

        left.addTarget(self, action: #selector(nextTable), for: .touchUpInside)
        right.addTarget(self, action: #selector(prevTable), for: .touchUpInside)
        
        // init tableView
        tableIndex = 0
        scoreTable.delegate = self
        scoreTable.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    @objc func prevTable(sender: UIButton!) {
        tableIndex = Int(CGFloat( tableIndex + 2 ).truncatingRemainder(dividingBy: 3))
    }
    
    @objc func nextTable(sender: UIButton!) {
        tableIndex = Int(CGFloat( tableIndex + 1 ).truncatingRemainder(dividingBy: 3))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     static func updateScore(name: String?, score: Int, index: Int) {
        let newRecord = (name as! String, score)
        LeaderBoardViewController.history[index].append(newRecord)
    }
    
    // table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(8, LeaderBoardViewController.history[tableIndex].count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath) as UITableViewCell
        
        let (cellName, cellScore) = LeaderBoardViewController.history[tableIndex][indexPath.row]
        cell.textLabel?.text = "\(indexPath.row+1). \(cellName)"
        cell.detailTextLabel?.text = "\(cellScore)"
        
        return cell
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

//
//  BoardDevDetailViewController.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 10. 13..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class BoardDevDetailViewController: UIViewController {
    
    @IBOutlet weak var boardDetailTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        boardDetailTableView.delegate = self
        boardDetailTableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
extension BoardDevDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardDetailCell", for: indexPath)
        
        return cell
    }
}

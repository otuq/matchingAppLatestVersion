//
//  Unnecessary.swift
//  matchingApp
//
//  Created by USER on 2020/11/18.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit

class Unnecessary: UIViewController {
    
    @IBOutlet weak var profileTableView: UITableView!
    
    let sectionTitle = [" "," "," "]
    var infoData = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        
        infoData[0] = [
            "おしくらまんじゅうあはははん",
            "18",
        ]
        infoData[1] = [
            "東京",
            "ぺぺぺぺぺ",
        ]
        infoData[2] = [
            "お問合せ",
            "規約"
        ]
        
    }
    
    private func settingView(){
//        profileTableView.delegate = self
//        profileTableView.dataSource = self
//        profileTableView.tableFooterView = UIView()
    }
}

//MARK: - UITableViewDelegate,Datasource
//extension Unnecessary: UITableViewDelegate,UITableViewDataSource{
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.sectionTitle.count
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.infoData[section].count
//    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return " "
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//    //headerの背景色、テキストの色とか変える
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.tintColor = .clear
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = profileTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
//        cell.textLabel?.text = infoData[indexPath.section][indexPath.row]
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
//}

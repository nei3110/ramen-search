//
//  KuchikomiViewController.swift
//  sample
//
//  Created by 尾嵜壮太郎 on 2021/07/24.
//

import UIKit
import SwiftyJSON

class KuchikomiViewController: UIViewController {
    
    @IBOutlet weak var keywordsLabel: UILabel!
    @IBOutlet weak var kuchikomiTableView: UITableView!

    var kuchikomiArr = [Kuchikomi]()
    private var entitiesDataSource = [EntityFrequency]()
    let networkManager = NetworkManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        kuchikomiTableView.delegate = self
        kuchikomiTableView.dataSource = self
        
        var count = 0
        for kuchikomi in kuchikomiArr {
            networkManager.analyzeKuchikomi(text: kuchikomi.text) {data in
                if data != nil {
                    if let json = try? JSON(data: data!) {
                        var entities = [String]()
                        for entityInfo in json["entities"].arrayValue {
                            self.keywordsLabel.text! += entityInfo["name"].stringValue
                            entities.append(entityInfo["name"].stringValue)
                        }
                        self.parseEntityArr(arr: entities)
                    }
                }
            }
            count += 1
            if count >= 5 {
                break
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.black
        ]
        self.view.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "paper.jpeg")!)

    }
    
    private func parseEntityArr(arr: [String]) {
        for entity in arr {
            if let index = entitiesDataSource.firstIndex(where: { $0.name == entity }) {
                entitiesDataSource[index].frequency += 1
            } else {
                entitiesDataSource.append(EntityFrequency.init(name: entity, frequency: 1))
            }
        }

        // 頻度が多い単語から上位５つを表示する（単語数は要検討）
        entitiesDataSource = entitiesDataSource.sorted(by: { $0.frequency > $1.frequency })
        print(entitiesDataSource)
        keywordsLabel.text = ""
        var count = 0
        for en in entitiesDataSource {
            keywordsLabel.text! += en.name + ", "
            count += 1
            if count >= 5 {
                break
            }
        }
        keywordsLabel.text = String(keywordsLabel.text!.dropLast(2))
    }

}

extension KuchikomiViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kuchikomiArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = kuchikomiArr[indexPath.row].text
        return cell
    }
 
    private struct EntityFrequency {
        var name: String
        var frequency: Int
    }
    
}

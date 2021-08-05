//
//  SearchResultViewController.swift
//  sample
//
//  Created by 尾嵜壮太郎 on 2021/07/23.
//

import UIKit

class SearchResultViewController: UIViewController {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var resultTableView: UITableView!
    
    let networkManager = NetworkManager.sharedInstance
    
    var data = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.vc = self
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.register(UINib.init(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: String(describing: SearchResultTableViewCell.self))
        resultTableView.separatorStyle = .none
        resultTableView.showsVerticalScrollIndicator = false
        
        numberLabel.text = String(data.count) + "件"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.init(named: "ThemeColor")
        ]
        self.view.backgroundColor = UIColor(patternImage: UIImage.init(named: "top_bgImage.jpeg")!)
    }

}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultTableViewCell.self)) as! SearchResultTableViewCell
        
//        cell.wrapperView.layer.shadowColor = UIColor.white.cgColor
//        cell.wrapperView.layer.shadowOpacity = 0.2
//        cell.wrapperView.layer.shadowRadius = 5
//        
        cell.shopInfo = data[indexPath.row]
        cell.nameLabel.text = data[indexPath.row].name
        cell.genreLabel.text = data[indexPath.row].genreCatch
        cell.kuchikomiButton.isEnabled = true
        cell.kuchikomiButton.alpha = 1
        cell.parentVC = self

        cell.selectionStyle = .none
        return cell
    }
    
    
}

//
//  SearchResultTableViewCell.swift
//  sample
//
//  Created by 尾嵜壮太郎 on 2021/07/23.
//

import UIKit
import SwiftyJSON

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var kuchikomiButton: UIButton!
    var parentVC: SearchResultViewController?
    
    var shopInfo: SearchResult?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        wrapperView.layer.masksToBounds = true
        wrapperView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func kuchikomiButtonPushed(_ sender: Any) {
        parentVC?.networkManager.getKuchikomi(name: shopInfo?.name) {data in
            
            let vc = KuchikomiViewController()
            
            if let json = try? JSON(data: data ?? Data()) {
                for kuchikomi in json["result"]["reviews"].arrayValue {
                    vc.kuchikomiArr.append(
                        Kuchikomi.init(
                            text: kuchikomi["text"].stringValue,
                            rating: kuchikomi["rating"].doubleValue
                        )
                    )
                }
            }
            
            self.parentVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

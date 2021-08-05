//
//  NetworkManager.swift
//  sample
//
//  Created by 尾嵜壮太郎 on 2021/07/23.
//

import UIKit
import Alamofire
import ProgressHUD
import SwiftyJSON

class NetworkManager: NSObject {
    
    static let sharedInstance = NetworkManager()
    typealias HandlerBlock = (Data?) -> Void
    
    var vc: UIViewController?
        
    override init() {}
    
    func getShopInfoBySearch(keyword: String, handler: @escaping HandlerBlock) {
        let url = "https://map.yahooapis.jp/search/local/V1/localSearch?appid=\(googleApiKey)&query=\(keyword)&output=json"
        let encordedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let en = encordedUrl {
            AF.request(en, method: .get).responseJSON {res in
                if let code = res.response?.statusCode, code >= 200, code < 300 {
                    handler(res.data)
                } else {
                    ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
                    print(res)
                    handler(nil)
                }
            }
        } else {
            ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
            print("URLエンコーディングに失敗")
            handler(nil)
        }
        
    }
    
    func getShopInfoByDistanceWithGoogle(distance: Double, lat: Double, lon: Double, handler: @escaping HandlerBlock) {
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=\(distance * 1000)&keyword=ラーメン&key=\(googleApiKey)"
        let encordedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let en = encordedUrl {
            AF.request(en, method: .get).responseJSON {res in
                if let code = res.response?.statusCode, code >= 200, code < 300 {
                    handler(res.data)
                } else {
                    ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
                    print(res)
                    handler(nil)
                }
            }
        } else {
            ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
            print("URLエンコーディングに失敗")
            handler(nil)
        }
        
    }
    
    func getShopInfoByDistanceWithHotPepper(distance: Double, lat: Double, lon: Double, handler: @escaping HandlerBlock) {
        var distanceForURL = 0
        switch distance {
        case 0.3:
            distanceForURL = 1
        case 0.5:
            distanceForURL = 2
        case 1:
            distanceForURL = 3
        case 2:
            distanceForURL = 4
        case 3:
            distanceForURL = 5
        default:
            distanceForURL = 3
        }
        let url = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?keyword=ラーメン&key=\(hotPepperApiKey)&lat=\(lat)&lng=\(lon)&range=\(distanceForURL)&order=4&count=100&format=json"
        let encordedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let en = encordedUrl {
            AF.request(en, method: .get).responseJSON {res in
                if let code = res.response?.statusCode, code >= 200, code < 300 {
                    handler(res.data)
                } else {
                    ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
                    print(res)
                    handler(nil)
                }
            }
        } else {
            ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
            print("URLエンコーディングに失敗")
            handler(nil)
        }
        
    }

    func getKuchikomi(uid: String? = nil, name: String? = nil, handler: @escaping HandlerBlock) {
        if(uid != nil) {
            let url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(uid!)&fields=review&language=ja&key=\(googleApiKey)"
            
            AF.request(url, method: .get).responseJSON {res in
                if let code = res.response?.statusCode, code >= 200, code < 300 {
                    handler(res.data)
                } else {
                    ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
                    print(res)
                    handler(nil)
                }
            }
        } else if(name != nil){
            // 店名で検索
            let nameSearchURL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=\(name!)&inputtype=textquery&fields=place_id,name&key=\(googleApiKey)"
            let encodedURL = nameSearchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let en = encodedURL {
                AF.request(encodedURL as! URLConvertible, method: .get).responseJSON {res in
                    if let code = res.response?.statusCode, code >= 200, code < 300 {
                        if let data = res.data {
                            if let json = try? JSON(data: data) {
                                let candidates = json["candidates"].arrayValue
                                if candidates.count > 1 {
                                    let alert = UIAlertController.init(title: "候補選択", message: "候補が複数あります。", preferredStyle: .alert)
                                    for candidate in candidates {
                                        alert.addAction(UIAlertAction.init(title: candidate["name"].stringValue, style: .default) {_ in
                                            let url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(candidate["place_id"].stringValue)&fields=review&language=ja&key=\(googleApiKey)"
                                            
                                            AF.request(url, method: .get).responseJSON {res in
                                                if let code = res.response?.statusCode, code >= 200, code < 300 {
                                                    handler(res.data)
                                                } else {
                                                    ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
                                                    print(res)
                                                    handler(nil)
                                                }
                                            }
                                        })
                                    }
                                    alert.addAction(UIAlertAction.init(title: "キャンセル", style: .default, handler: nil))
                                    
                                    self.vc?.present(alert, animated: false, completion: nil)
                                } else if candidates.count == 1 {
                                    let url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(candidates[0]["place_id"].stringValue)&fields=review&language=ja&key=\(googleApiKey)"
                                    
                                    AF.request(url, method: .get).responseJSON {res in
                                        if let code = res.response?.statusCode, code >= 200, code < 300 {
                                            handler(res.data)
                                        } else {
                                            ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
                                            print(res)
                                            handler(nil)
                                        }
                                    }
                                }

                                

                            }
                        }
                    } else {
                        ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
                        print(res)
                        handler(nil)
                    }
                }

            }

        }

    }
    
    func analyzeKuchikomi(text: String, handler: @escaping HandlerBlock) {
        let url = "https://language.googleapis.com/v1/documents:analyzeEntities?key=\(googleApiKey)"
        
        let parameters: [String: Any] = [
            "document": [
                "type": "PLAIN_TEXT",
                "language": "ja",
                "content": text
            ],
            "encodingType":"UTF8"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {res in
            if let code = res.response?.statusCode, code >= 200, code < 300 {
                handler(res.data)
            } else {
                ProgressHUD.showError("データの取得に失敗しました。", image: nil, interaction: false)
                print(res)
                handler(nil)
            }
        }

    }

}

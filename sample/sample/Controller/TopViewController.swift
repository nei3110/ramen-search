//
//  ViewController.swift
//  sample
//
//  Created by 尾嵜壮太郎 on 2021/07/23.
//

import UIKit
import CoreLocation
import SwiftyJSON

class TopViewController: UIViewController {
    
    let networkManager = NetworkManager.sharedInstance
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var kmTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    let kmPicker = UIPickerView()
//    let kms = [0.1, 0.3, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let kms = [0.3, 0.5, 1, 2, 3]

    var latitudeNow: String = ""
    var longitudeNow: String = ""
    var searchResultArr = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        networkManager.vc = self
        
        kmTextField.inputView = kmPicker
        kmPicker.delegate = self
        kmPicker.dataSource = self
        let toolBar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(pickerCanceled))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didKmChanged))
        toolBar.setItems([cancelItem, flexSpaceItem, doneButtonItem], animated: false)
        kmTextField.inputAccessoryView = toolBar
        
        searchButton.layer.cornerRadius = 5
        searchButton.layer.masksToBounds = true
        searchButton.layer.borderWidth = 2
        let startColor = #colorLiteral(red: 0.9202401042, green: 0.428943336, blue: 0.2142723799, alpha: 1)
        let endColor = #colorLiteral(red: 0.9202401042, green: 0.428943336, blue: 0.2142723799, alpha: 0.2894905822)
        let gradientColors: [CGColor] = [startColor.cgColor, endColor.cgColor]

        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()

        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame = self.view.bounds

        //グラデーションレイヤーをビューの一番下に配置
        searchButton.layer.insertSublayer(gradientLayer, at: 0)
        searchButton.layer.borderColor = #colorLiteral(red: 0.9374591708, green: 0.82595402, blue: 0.7341863513, alpha: 0.794734589)
        
        searchButton.isHidden = true
        
        setUpLocationManager()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.init(named: "ThemeColor")
        ]
        self.view.backgroundColor = UIColor(patternImage: UIImage.init(named: "top_bgImage.jpeg")!)
    }
    
    private func setUpLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        // マネージャの設定
        let status = CLLocationManager.authorizationStatus()
        // ステータスごとの処理
        if status == .authorizedWhenInUse  || status == .authorizedAlways {
            locationManager.delegate = self
            // 位置情報取得を開始
            locationManager.startUpdatingLocation()
        }
    }
    
    func checkStatus() -> Bool {
        // マネージャの設定
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            return true
        } else {
            showAlert()
            return false
        }
    }
    
    private func showAlert() {
        let alertTitle = "位置情報取得が許可されていません。"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert: UIAlertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle:  UIAlertController.Style.alert
        )
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        // UIAlertController に Action を追加
        alert.addAction(defaultAction)
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    @objc func pickerCanceled() {
        kmTextField.endEditing(true)
    }
    
    @objc func didKmChanged() {
        
        self.view.endEditing(true)
        kmTextField.text = String(kms[kmPicker.selectedRow(inComponent: 0)])
        
        if(checkStatus()) {
            
            networkManager.getShopInfoByDistanceWithHotPepper(distance: Double(kmTextField.text ?? "0") ?? 0.0, lat: Double(latitudeNow) ?? 0.0, lon: Double(longitudeNow) ?? 0.0) {data in
                
                self.resultLabel.text = "検索中..."
                
                self.searchResultArr.removeAll()
                if let resData = data {
                    if let json = try? JSON(data: resData) {
//                        for shopInfo in json["results"].arrayValue {
//                            self.searchResultArr.append(SearchResult.init(
//                                            uid: shopInfo["place_id"].stringValue,
//                                            name: shopInfo["name"].stringValue,
//                                            reviewCount: shopInfo["Property"]["ReviewCount"].intValue)
//                            )
//                        }
                        for shopInfo in json["results"]["shop"].arrayValue {
                            self.searchResultArr.append(SearchResult.init(
                                name: shopInfo["name"].stringValue,
                                genreCatch: shopInfo["genre"]["catch"].stringValue
                            ))
                        }
                    }
                }
                self.resultLabel.text = "\(String(self.searchResultArr.count))件見つかったよ！"
                self.searchButton.isHidden = false
            }
        }
        
        
    }
    
    @IBAction func searchButtonPushed(_ sender: Any) {
        let vc = SearchResultViewController()
        vc.data = self.searchResultArr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension TopViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        self.latitudeNow = String(latitude!)
        self.longitudeNow = String(longitude!)
    }
}

extension TopViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(kms[row])
    }
    
}

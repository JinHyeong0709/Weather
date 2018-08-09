//
//  ViewController.swift
//  Weather
//
//  Created by 김진형 on 2018. 4. 28..
//  Copyright © 2018년 김진형. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

extension UIViewController {
    func alertMessage(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true, completion: nil)
    }
}

class ViewController: UIViewController {
    
    var weather: Weather?
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStatusBarStyle
    }
    
    var currentStatusBarStyle = UIStatusBarStyle.lightContent
    
    lazy var locationManager: CLLocationManager = {
        let m = CLLocationManager()
        m.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        m.delegate = self
        return m
    }()
    
    
    
    //좌표(coordinate) - latitude, longtitude
    func fetchCurrent(with coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.3) {
            self.listTableView.alpha = 0.0
        }
        if let url = URL(string: "https://api2.sktelecom.com/weather/current/minutely?version=1&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appKey=5acc7e09-172f-42da-8bff-1abf6f8d5ad2") {
           
            Alamofire.request(url).responseSwiftyJSON { (response) in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        if let weather = Weather(dict: json) {
                            self.weather = weather
                            self.listTableView.reloadData()
                            UIView.animate(withDuration: 0.3) {
                                self.listTableView.alpha = 1.0
                            }
                        }
                    }
                } else {
                    //error Handling
                }
            }
        }
    }
    
    func fetchForcast(with coordinate: CLLocationCoordinate2D) {
        if let url = URL(string: "https://api2.sktelecom.com/weather/forecast/3days?version=1&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appKey=5acc7e09-172f-42da-8bff-1abf6f8d5ad2") {
            Alamofire.request(url).responseSwiftyJSON { (response) in
                if let json = response.result.value {
                    var list = [Forecast]()
                    
                    var now = Date()
                    var index = 4
                    while index <= 67 {
                        defer {
                            index += 3
                            //한 회차가 끝날 떄, 마지막에 실행
                            //while같은 반복문을 쓸 때는 우선 디퍼 블럭을 우선적으로 작성하고 변경되는 컨디션을 먼저 작성해둔다.
                        }
                        
                        let dt = now.addingTimeInterval(TimeInterval(3600 * index))
                        
                        guard let skyDict = json["weather"]["forecast3days"][0]["fcst3hour"]["sky"].dictionary else {
                            continue
                        } //dicntionary를 먼저 찾고
                        let skyCodeKey = "code\(index)hour"
                        let skyNameKey = "name\(index)hour"
                        //4~67까지 각각의 key를 생성
                        
                        guard let skyCode = skyDict[skyCodeKey]?.string else {
                            continue
                        }
                        guard let skyName = skyDict[skyNameKey]?.string else {
                            continue
                        }
                        //dictionary로부터 키로 코드를 빼고 있다.
                        
                        
                        guard let tempDict = json["weather"]["forecast3days"][0]["fcst3hour"]["temperature"].dictionary else {
                            continue
                        }
                        
                        let tempKey = "temp\(index)hour"
                        
                        guard let tempStr = tempDict[tempKey]?.string, let temp = Double(tempStr) else {
                            continue
                        }
                        
                        let newDate = Forecast(date: dt, skyName: skyName, skyCode: skyCode, temperature: temp)
                        
                        list.append(newDate)
                    }
                    print(list)
                }
            }
        }
    }
    
    
    var topInset: CGFloat = 0.0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //view에 포함된 모든 뷰의 배치가 완료된 후에 반복적으로 호출
        
        if topInset == 0.0 {
            //한번만 호출되도록
            let indexPath = IndexPath(row:0, section:0)
            if let cell = listTableView.cellForRow(at: indexPath) {
                let cellHeight = cell.frame.height
                let tableHeight = listTableView.frame.height
                
                topInset = tableHeight - cellHeight
                
                listTableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
            }
            //listTableView의 topInset 지정
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.alpha = 0.0
        
        listTableView.rowHeight = UITableViewAutomaticDimension
        listTableView.estimatedRowHeight = 200
        
        listTableView.backgroundColor = UIColor.clear
        listTableView.separatorStyle = .none
        //fetchCurrent(with: )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //위치 확인 후, 설정으로 들어가는 작업은 특정 작업이 일어난 후에 진행되어야 하므로, ViewDidAppear에서 처리해줘야 한다.
        //ViewDidLoad에서 구현하고, flag로 상태값만 저장한다음, 나중에 update단 다음 setting설정을 호출하는 방식
        if CLLocationManager.locationServicesEnabled() {
            //GPS를 사용할 수 있다면
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                //update
                updateLocation()
                break
            case .denied, .restricted:
                //denied는 사용 안함을 한 경우, restricted는 설정자체에서 설정을 안한 경우
                //move to setting
                let alert = UIAlertController(title: "권한확인", message: "GPS 권한", preferredStyle: .alert)
                
                let setting = UIAlertAction(title: "설정으로", style: .default) { (action) in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                alert.addAction(setting)
                
                let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                alert.addAction(cancel)
                
                present(alert, animated: true, completion: nil)
            }
        } else {
            
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "summary") as! SummaryTableViewCell
            
            if let target = weather {
                cell.weatherImageView.image = UIImage(named: target.skyCode)
                cell.skyNameLabel.text = target.skyName
                cell.minMaxLabel.text = "최대 \(target.tempMax)℃, 최소 \(target.tempMin)℃"
                cell.currentTempLabel.text = "\(target.tempCurrnt)"
            }
            
            return cell
        case 1:
            fatalError()
        default:
            fatalError()
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
extension ViewController: CLLocationManagerDelegate {
    //protocol에 선언되어 있는 특정 메서드
    func updateLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //그동안 업데이터 된 정보들이 배열 형태로 넘어온다.(마지막 정보가 가장 최신)
        if let first = locations.first {
            //좌표를 주소로 바꾸는 것->GeoCodng
            //기본적으로 미국 주소 체계이기 때문에 필요한 경우는 국내 디비를 써야 한다.
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(first) { (placemarks, error) in
                //error가 nil이면 성공, 아니면 실패
                if let error = error {
                    //error handling
                } else {
                    if let last = placemarks?.last {
                        if let gu = last.locality, let dong = last.subLocality {
                            self.addressLabel.text = "\(gu), \(dong)"
                        } else {
                            self.addressLabel.text = last.description
                            //제대로 구와 동의 정보가 넘어오지 않는다면 전체를 출력
                        }
                    }
                }
            }
            
            
            fetchCurrent(with: first.coordinate)
            fetchForcast(with: first.coordinate)
        }
        
        manager.stopUpdatingLocation()
        //실시간 GPS정보를 사용하지 않는 이상, 한번 fetch를 한 다음 정지를 해줘야 한다.
        //그 이후 필요할 때, 다시 fetch 그리고 stop
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            updateLocation()
        default:
            break
            //go to setting
        }
    }
}







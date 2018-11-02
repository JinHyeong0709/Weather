//
//  Model.swift
//  Weather
//
//  Created by 김진형 on 2018. 5. 9..
//  Copyright © 2018년 김진형. All rights reserved.
//

import Foundation
import SwiftyJSON
/* 파싱데이터
 sky의 code와 name
 temperatur의 tc,tmax,tmin (Double)
 */

struct Weather {
    let skyCode: String
    let skyName: String
    let tempMin: Double
    let tempMax: Double
    let tempCurrnt: Double
    init?(dict: JSON) {
        /*
         //일반 Swift 배열일 경우는
         guard let weatherDict = dict["weather"] as? [String: Any] else {
         return nil
         } //weather key로 dictionary 꺼내기(minutely key가 들어있다)
         guard let minutelyList = weatherDict["minutely"] as? [[String: Any]] else {
         return nil
         } //minutely key로 해당 배열을 꺼내는 과정
         
         guard  let skyDict = minutelyList.first as? [String:Any] else {
         return nil
         } //minutely는 배열
         
         guard  let skyCode = skyDict["sky"] as? String else {
         return nil
         }
         
         //바인딩 할 대상을 제대로 정하는 것이 중요하다. -> SwiftyJSON을 쓰자.
         */
        
        guard let skyCode = dict["weather"]["minutely"][0]["sky"]["code"].string else {
            return nil
        }
        self.skyCode = skyCode
        
        guard let skyName = dict["weather"]["minutely"][0]["sky"]["name"].string else {
            return nil
        }
        self.skyName = skyName
        
        guard let tcStr = dict["weather"]["minutely"][0]["temperature"]["tc"].string, let tc = Double(tcStr) else {
            return nil
        }
        self.tempCurrnt = tc
        
        guard let tmaxStr = dict["weather"]["minutely"][0]["temperature"]["tmax"].string, let tmax = Double(tmaxStr)  else {
            return nil
        }
        self.tempMax = tmax
        
        guard let tminStr = dict["weather"]["minutely"][0]["temperature"]["tmin"].string, let tmin = Double(tminStr) else {
            return nil
        }
        self.tempMin = tmin
    }
}

struct Forecast {
    let date: Date
    let skyName: String
    let skyCode: String
    let temperature: Double
    
}











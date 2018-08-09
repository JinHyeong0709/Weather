//
//  Model.swift
//  Weather
//
//  Created by 김진형 on 2018. 5. 9..
//  Copyright © 2018년 김진형. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Weather {
    let skyCode: String
    let skyName: String
    let tempMin: Double
    let tempMax: Double
    let tempCurrnt: Double
    init?(dict: JSON) {
      
        guard let skyCode = dict["weather"]["minutely"][0 ]["sky"]["code"].string else {
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











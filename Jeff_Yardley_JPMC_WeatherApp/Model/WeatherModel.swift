//
//  WeatherModel.swift
//  Jeff_Yardley_JPMC_WeatherApp
//
//  Created by Jeff Yardley on 4/18/23.
//

import Foundation
import UIKit


struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    //var icon: UIImage
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
    
}







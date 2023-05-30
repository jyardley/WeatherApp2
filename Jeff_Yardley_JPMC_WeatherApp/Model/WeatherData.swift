//
//  WeatherData.swift
//  Jeff_Yardley_JPMC_WeatherApp
//
//  Created by Jeff Yardley on 4/18/23.
//

import Foundation
struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}

//
//  WeatherIconRetrieval.swift
//  Jeff_Yardley_JPMC_WeatherApp
//
//  Created by Jeff Yardley on 5/29/23.
//

import Foundation
import UIKit


func getDayOrNight() -> String {
    // Get the current hour
    let hour = Calendar.current.component(.hour, from: Date())
    
    // Check the hour and return "d" for day (6AM to 5PM) and "n" for night
    if hour >= 6 && hour < 18 {
        return "d"
    } else {
        return "n"
    }
}



//Get weather condition icon depending on the conditonId in the Weather Model
func getIconFromId(_ id: Int) -> String {
    let icon: String
    switch id {
    case 200...299:
        icon = "11"
    case 300...399:
        icon = "09"
    case 500...599:
        icon = "10"
    case 600...699:
        icon = "13"
    case 700...799:
        icon = "50"
    case 800:
        icon = "01"
    case 801:
        icon = "02"
    case 802:
        icon = "03"
    case 803, 804:
        icon = "04"
        
    default:
        icon = "unknown"
    }
    return icon
}


func createWeatherIconCodeURL(conditionID: Int) -> String {
    let weatherIconURL = "https://openweathermap.org/img/wn/"
    let iconSize = "@2x.png"
    
    //String part of wather icon that designates either day("d") or night("n")
    let isDayOrNight = getDayOrNight()
    let iconCode = getIconFromId(conditionID)
    if iconCode != "unknown" {
        let iconUrlString = "\(weatherIconURL)\(iconCode)\(isDayOrNight)\(iconSize)"
        return iconUrlString
    } else {
        print("ERROR: Icon Code Is Unknown!!")
        return "none"
    }
}


func fetchIconImage(urlString: String) async throws -> UIImage? {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }

    let (data, _) = try await URLSession.shared.data(from: url)

    return UIImage(data: data)
}

func getImageAsync(urlString: String) {
    let wvc = WeatherViewController()
    Task.init {
        do {
            guard let weatherIcon = try await fetchIconImage(urlString: urlString) else { return }
            
            // Now `updatedModel` contains the updated icon
            // Update the UI on the main thread
            DispatchQueue.main.async {
                wvc.conditionImageView?.image = weatherIcon
                // Perform other UI updates...
            }
        } catch {
            print("Failed to fetch image with error: \(error)")
            // Handle error
        }
    }
}



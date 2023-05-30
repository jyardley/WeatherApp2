//
//  WeatherManager.swift
//  Jeff_Yardley_JPMC_WeatherApp
//
//  Created by Jeff Yardley on 4/18/23.
//

/*
Notes: Apparently, the retrieved data from the openweather API does not have an "icon" field returned
 like the API docs(https://openweathermap.org/api/one-call-3#parameter) say they do.  Here's an example
 of what is returned:
 
 Decoded Data: WeatherData(name: "Houston", main: Jeff_Yardley_JPMC_WeatherApp.Main(temp: 67.71), weather: [Jeff_Yardley_JPMC_WeatherApp.Weather(description: "mist", id: 701)])
 
 The tutorial I used here from a Udemy course I took already uses the system icons to display the weather, so I will use that.  If I had a bit more time, I might be able to further investigate why that is.
*/
 
import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let newAPIK = "30967ca69566f2138640260ff9ef190f"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        //Older API(from the tutorial I found on Udemy) supports city inputs. The newer does not
        let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(newAPIK)&units=imperial"
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        //Newer API only accepts GPS Coordinates.  Using both API versions for ease and flexibility
        //of use.
        let weatherURL_newAPI = "https://api.openweathermap.org/data/3.0/weather?appid=\(newAPIK)&units=imperial"
        let urlString = "\(weatherURL_newAPI)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            //let icon = decodedData.weather[0].icon
            
            print("Decoded Data: \(decodedData)")
            
            let weatherIconURL = createWeatherIconCodeURL(conditionID: id)
            print("\n\n weatherIconURL is supposed to be: \(weatherIconURL) \n\n")
            getImageAsync(urlString: weatherIconURL)
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}



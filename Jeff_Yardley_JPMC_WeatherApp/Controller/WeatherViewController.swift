//
//  ViewController.swift
//  Jeff_Yardley_JPMC_WeatherApp
//
//  Created by Jeff Yardley on 4/18/23.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        searchTextField.delegate = self
        
        let lastCitySearched = retrieveLastLocation()
        if(lastCitySearched == "None"){
            //Gets the device location and it signals if there is any error
            let statusError = getWeatherForDeviceLocation()
            //If there is an error(i.e. no device location), we simply set the city to a known one.
            if(statusError != 0) {
                weatherManager.fetchWeather(cityName: "Dallas")
            }
        } else {
            weatherManager.fetchWeather(cityName: lastCitySearched)
        }
        
        /*  Get Weather Icon here?
        let weatherIconURL = createWeatherIconCodeURL(conditionID: Weather.id)
        print("Weather Icon URL: \(weatherIconURL)")
        let weatherVM = WeatherViewController()
        weatherVM.getIconImageAsync(url: weatherIconURL)
        */
        
        }
        
        
    }//EndViewDidLoad...


//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextField.text {
            //This will allow a fix for cities with spaces in the name, such as "New York" or "San Diego," but will not work for cities such as "Ft. Worth" or "St. Louis". if I had more
            //time, I'd see if I could perhaps fix this, but at least the "spaced city names" work,
            //as before you could only look up one word city names
            //Note: City will default to "London" when the app starts up if there is a city that
            //was last searched on that didn't work or if it's just starting up.
            let cityPeriodEncoded = city.replacingOccurrences(of: ".", with: "%2E").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let cityPercentEncoded = cityPeriodEncoded.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            weatherManager.fetchWeather(cityName: cityPercentEncoded)
            saveLastLocation(city: cityPercentEncoded)
        }
        
        searchTextField.text = ""
        
    }
}

//MARK: - WeatherManagerDelegate


extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate


extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    //Function will return non-zero statusCode if anything goes wrong
    func getWeatherForDeviceLocation() -> Int{
        //Status code set to one unless it's set to 0, which means task was successful.
        var statusCode: Int = 1
        // Get the user's current location
        if let location = locationManager.location {
            // Extract the latitude and longitude coordinates
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            //Make sure lat and long coordinates are comming back, then get weather on them
            print("Latitude: \(latitude), Longitude: \(longitude)")
            weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
            
            statusCode = 0
        } else {
            print("Location not available")
            statusCode = 1
        }
        
        return statusCode
    }
    

    
    
    func saveLastLocation(city: String){
        // Get the user defaults object
        let defaults = UserDefaults.standard

        // Set a string value for a key
        defaults.set(city, forKey: "cityLastSearched")

        // Save the changes to disk
        defaults.synchronize()
    }
    
    func retrieveLastLocation() -> String{
        // Get the user defaults object
        let defaults = UserDefaults.standard

        //Assume there is no User Defaults stored, set to known city
        var defaultCityLastSearched = "None"
        
        // Retrieve the stored string for the key
        if let cityLastSearched = defaults.string(forKey: "cityLastSearched") {
            print("City Last Searched: \(cityLastSearched)")
            
            //Set default city to last searched location
            defaultCityLastSearched = cityLastSearched
        }
        
        return defaultCityLastSearched
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

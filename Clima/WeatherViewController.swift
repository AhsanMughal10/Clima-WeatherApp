//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ahsan Mughal on 23/08/2018.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate{
   
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "46601e9a50893d5a9d1d1f928794a9c1"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherdm = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    @IBOutlet weak var Switchtoggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    //MARK: - UISwitch Toggle
    
    @IBAction func SwitchtToggled(_ sender: UISwitch) {
        if Switchtoggle.isOn{
           
           temperatureLabel.text = "\(String(weatherdm.tempratre))°"
        }
        else{
           
            temperatureLabel.text!.removeLast()
            var temp = Int(temperatureLabel.text!)!
            temp = temp + 273
            temperatureLabel.text = "\(temp)"
            
            
        }
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String , parameters: [String:String])
    {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                print("Success.Got the Weather Data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateweatherdata(json: weatherJSON)
            }
            else{
                print("Error \(response.result.error ?? "Error" as! Error )")
                self.cityLabel.text = "Connection Issues"
            }
                
            
        }
        
        
        
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateweatherdata(json: JSON){
        if let tempresult = json["main"]["temp"].double {
        weatherdm.tempratre = Int(tempresult - 273.15)
        weatherdm.city = json["name"].stringValue
        weatherdm.condition = json["weather"][0]["id"].intValue
        weatherdm.weathericonname = weatherdm.updateWeatherIcon(condition: weatherdm.condition)
            updateUIWithWeatherData()
        }
        else
        {
            cityLabel.text = " Weather Unavailable  "
        }
    }
    
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherdm.city
        temperatureLabel.text = "\(String(weatherdm.tempratre))°"
        weatherIcon.image = UIImage.init(named: weatherdm.weathericonname)
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("Longitude : \(location.coordinate.longitude) - Latitude : \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
//            let param : [String:String] = ["lat": latitude , "lon": longitude, "appid": APP_ID]
//            getWeatherData(url: WEATHER_URL, parameters: param)
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnterednewCityName(city: String) {
        let params : [String:String] = ["q":city , "appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}



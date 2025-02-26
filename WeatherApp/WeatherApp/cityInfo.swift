//
//  cityInfo.swift
//  WeatherApp
//
//  Created by Stra1 T on 11.02.25.
//

import Foundation

import UIKit
import CoreData

class TownViewController: UIViewController {
    let key: String = "4486fe6eb8f0a36bcb10e48bfc7c49d3"
    var town: Town?
    var index: Int?
    
    private let weatherIcon = UIImageView()
    private let cityNameLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    
    private let cloudiness = CustomInfoView(icon: UIImage(), text1: "", text2: "")
    private let humidity = CustomInfoView(icon: UIImage(), text1: "", text2: "")
    private let windSpeed = CustomInfoView(icon: UIImage(), text1: "", text2: "")
    private let windDirection = CustomInfoView(icon: UIImage(), text1: "", text2: "")
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openForecast))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func openForecast() {
        guard let city = town?.name else { return }

        showLoadingIndicator()

        let forecastVC = ForecastViewController()
        forecastVC.cityName = city

        forecastVC.fetchWeatherForecast { result in
            DispatchQueue.main.async { // 🔹 Ensure all UI updates happen on the main thread
                switch result {
                case .failure(_):
                    if let top = self.navigationController?.topViewController, top is ErrorViewController {
                        return
                    } else {
                        self.hideLoadingIndicator()
                        self.showErrorPage(retryAction: { self.openForecast() })
                    }

                case .success(_):
                    self.hideLoadingIndicator()

                    // 🔹 Ensure navigationController exists before pushing
                    if let navController = self.navigationController {
                        navController.pushViewController(forecastVC, animated: true)
                    } else {
                        print("⚠️ Error: navigationController is nil")
                    }
                }
            }
        }
    }

    
    func showLoadingIndicator() {
        let loading: UIViewController = UIViewController()
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        activityIndicator.color = .yellow
        loading.view.addSubview(activityIndicator)
        loading.view.applyGradientBackground(topColor: UIColor(hex: "#616e85")!, bottomColor: UIColor(hex: "274a87")!)
        
        navigationController?.pushViewController(loading, animated: true)
    }

    func hideLoadingIndicator() {
        
        navigationController?.popViewController(animated: true)
    }
    
    
    func showErrorPage(retryAction: @escaping () -> Void){
        let errorVC = ErrorViewController()
        errorVC.reloadAction = retryAction
        navigationController?.pushViewController(errorVC, animated: true)
        
    }
    
    private func setupUI() {
        
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cityNameLabel.textColor = .white
        weatherDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        cloudiness.translatesAutoresizingMaskIntoConstraints = false
        humidity.translatesAutoresizingMaskIntoConstraints = false
        windSpeed.translatesAutoresizingMaskIntoConstraints = false
        windDirection.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [cloudiness, humidity, windSpeed, windDirection])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 40
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: town?.collor ?? "FFFFFF")
        containerView.layer.cornerRadius = 25
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(weatherIcon)
        containerView.addSubview(cityNameLabel)
        containerView.addSubview(weatherDescriptionLabel)
      
        containerView.addSubview(stackView)
        view.addSubview(containerView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            
            weatherIcon.widthAnchor.constraint(equalToConstant: 150),
            weatherIcon.heightAnchor.constraint(equalToConstant: 150),
            weatherIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            weatherIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            
            
            cityNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cityNameLabel.topAnchor.constraint(equalTo: weatherIcon.bottomAnchor, constant: 10),
            
            
            weatherDescriptionLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            weatherDescriptionLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 10),
            
            
            
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -130),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -110)
        ])
        
    }
    

    
    func loadWeatherData(completion: @escaping (Result<WeatherResponse, CityError>)->Void) {
        guard let town = town else { return }

        guard let cityName = town.name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            
            completion(.failure(.unknown))
            return
        }
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(key)"

        guard let url = URL(string: urlString) else {
            
            completion(.failure(.unknown))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                
                completion(.failure(.unknown))
                return
            }

            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: weatherResponse)
                }
                completion(.success(weatherResponse))
            } catch {
               
                completion(.failure(.unknown))
                
                print("Failed to decode weather data: \(error)")

                // Debugging: Print the raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                return
            }
        }.resume()
    }
    
    private func direction(_ deg: Double) ->String{
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N"]
        let index = Int((deg/22.5)+5)%16
        return directions[index]
    }

    private func kelvinToCelsius(kelvin: Double) -> String{
        return String(format: "%.2f", kelvin-273.15)
    }
    
    private func updateUI(with weather: WeatherResponse) {
        let name: String = weather.name!
        let deck: String = weather.weather.first!.description
        let temp: String = kelvinToCelsius(kelvin: weather.main.temp)
        
        cityNameLabel.text = "\(name), \(weather.sys.country)"
        weatherDescriptionLabel.text = "\(temp)°C | \(deck.capitalized)"
        weatherDescriptionLabel.textColor = .yellow
        
        cloudiness.updateFields(icon: UIImage(systemName: "cloud.rain")!, text1: "Cloudiness", text2: "\(weather.clouds.all)%")
        humidity.updateFields(icon: UIImage(systemName: "drop")!, text1: "Humidity", text2: "\(weather.main.humidity) mm")
        windSpeed.updateFields(icon: UIImage(systemName: "wind")!, text1: "Wind Speed", text2: "\(weather.wind.speed) m/s")
        windDirection.updateFields(icon: UIImage(named: "compas")!, text1: "Wind Direction", text2: direction(Double(weather.wind.deg)))
            
        if let icon = weather.weather.first?.icon {
            loadWeatherIcon(icon)
        }
    }
    
    private func loadWeatherIcon(_ icon: String) {
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!
        URLSession.shared.dataTask(with: iconURL) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.weatherIcon.image = image
                }
            }
        }.resume()
    }
    
}

enum CityError: Error {
    case unknown
    case ignore
}

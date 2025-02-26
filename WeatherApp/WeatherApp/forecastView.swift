//
//  forecastView.swift
//  WeatherApp
//
//  Created by Stra1 T on 12.02.25.
//

import Foundation


import UIKit


class ForecastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let key: String = "4486fe6eb8f0a36bcb10e48bfc7c49d3"
    var cityName = ""
    let tableView = UITableView()
    var groupedForecasts: [String: [WeatherForecast]] = [:]
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradientBackground(topColor: UIColor(hex: "#616e85")!, bottomColor: UIColor(hex: "#274a87")!)
        
        title = "Forecast"
        let navBarApp = UINavigationBarAppearance()
        navBarApp.configureWithTransparentBackground()
        navBarApp.backgroundColor = UIColor(hex: "#616e85")?.withAlphaComponent(1)
        navBarApp.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarApp.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarApp
        navigationController?.navigationBar.scrollEdgeAppearance = navBarApp
        navigationController?.navigationBar.compactAppearance = navBarApp
        
        navigationController?.navigationBar.tintColor = .yellow
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.isTranslucent = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.backgroundColor = .clear
        tableView.tintColor = .clear
        tableView.isOpaque = false
        tableView.separatorStyle = .none
        tableView.register(ForecastCell.self, forCellReuseIdentifier: "ForecastCell")
    
    }
    
    func fetchWeatherForecast(completion: @escaping (Result<CityError, CityError>)->Void){
        let apiKey = key
        let city = cityName
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            
            completion(.failure(.unknown))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                
                completion(.failure(.unknown))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
                self.groupForecasts(response.list)
                completion(.success(.ignore))
                //return
            } catch {
                completion(.failure(.unknown))
                print("Decoding error: \(error)")
                return
            }
        }.resume()
    }
    
    func groupForecasts(_ forecasts: [WeatherForecast]) {
        dateFormatter.dateFormat = "EEEE, MMM d"
        
        groupedForecasts = Dictionary(grouping: forecasts) { forecast in
            let date = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            return dateFormatter.string(from: date)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedForecasts.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedKeys = groupedForecasts.keys.sorted()
        return sortedKeys[section]
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {return}
        
        headerView.textLabel?.textColor = .yellow
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerView.backgroundView = UIView()
        headerView.backgroundView?.backgroundColor = UIColor(hex: "#274a87")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedKeys = groupedForecasts.keys.sorted()
        let key = sortedKeys[section]
        return groupedForecasts[key]?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
        
        let sortedKeys = groupedForecasts.keys.sorted()
        let key = sortedKeys[indexPath.section]
        if let forecasts = groupedForecasts[key] {
            let forecast = forecasts[indexPath.row]

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(forecast.dt)))
            
            cell.timeLabel.text = timeString
            cell.descriptionLabel.text = forecast.weather.first?.description.capitalized ?? "Unknown"
            cell.temperatureLabel.text = "\(Int(forecast.main.temp))°C"

            if let icon = forecast.weather.first?.icon {
                let iconUrl = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: iconUrl!), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.iconImageView.image = image
                        }
                    }
                }
            }
        }
        
        return cell
    }

}


extension UIView {
    func applyGradientBackground(topColor: UIColor, bottomColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}




class ForecastCell: UITableViewCell {

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)  // Bigger and bold
        label.textColor = .yellow  // Yellow color for temperature
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear

        addSubview(iconImageView)
        addSubview(timeLabel)
        addSubview(descriptionLabel)
        addSubview(temperatureLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            timeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),

            descriptionLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor),

            temperatureLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            temperatureLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



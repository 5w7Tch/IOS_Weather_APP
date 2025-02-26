//
//  jsonParsers.swift
//  WeatherApp
//
//  Created by Stra1 T on 11.02.25.
//

import Foundation
import UIKit


struct WeatherResponse: Codable {
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let sys: Sys
    let visibility: Int?
    let timezone: Int?
    let id: Int?
    let name: String?
    let cod: Int?
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let country: String
    let sunrise: Int
    let sunset: Int
}





struct ForecastResponse: Codable {
    let list: [WeatherForecast]
}

struct WeatherForecast: Codable {
    let dt: Int
    let main: WMain
    let weather: [Weather5]
    let dt_txt: String
}

struct WMain: Codable {
    let temp: Double
}

struct Weather5: Codable {
    let description: String
    let icon: String
}


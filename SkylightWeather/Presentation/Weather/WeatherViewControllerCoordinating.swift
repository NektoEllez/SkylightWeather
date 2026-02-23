    //
    //  WeatherViewControllerCoordinating.swift
    //  SkylightWeather
    //

import UIKit

@MainActor
protocol WeatherViewControllerCoordinating: AnyObject {
    func showSettings(from presenter: UIViewController, appSettings: AppSettings)
}


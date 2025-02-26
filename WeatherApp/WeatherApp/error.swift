//
//  error.swift
//  WeatherApp
//
//  Created by Stra1 T on 11.02.25.
//

import Foundation

import UIKit

class ErrorViewController: UIViewController {

    var reloadAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationController?.navigationBar.tintColor = .yellow
        title = "Forecast"
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        let errorIcon = UILabel()
        errorIcon.text = "☁️⚠️"
        errorIcon.font = UIFont.systemFont(ofSize: 80)
        errorIcon.textAlignment = .center

        let errorMessage = UILabel()
        errorMessage.text = "Error occurred while loading data"
        errorMessage.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        errorMessage.textAlignment = .center
        errorMessage.textColor = .white

        let reloadButton = UIButton(type: .system)
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.backgroundColor = .yellow
        reloadButton.setTitleColor(.black, for: .normal)
        reloadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        reloadButton.layer.cornerRadius = 10
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [errorIcon, errorMessage, reloadButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        view.applyGradientBackground(topColor: UIColor(hex: "#616e85")!, bottomColor: UIColor(hex: "274a87")!)
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            reloadButton.widthAnchor.constraint(equalToConstant: 120),
            reloadButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func reloadTapped() {
        navigationController?.popViewController(animated: true)
        reloadAction?()
    }
}

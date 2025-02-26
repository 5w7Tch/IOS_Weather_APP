//
//  detailInfoLine.swift
//  WeatherApp
//
//  Created by Stra1 T on 11.02.25.
//

import Foundation
import UIKit




class CustomInfoView: UIView {
    
    private let iconImageView: UIImageView
    private let textLabel: UILabel
    private let yellowTextLabel: UILabel
    
    public func updateFields(icon: UIImage, text1: String, text2: String){
        iconImageView.image = icon
        iconImageView.tintColor = .yellow
        textLabel.text = text1
        yellowTextLabel.text = text2
    }
    
    init(icon: UIImage, text1: String, text2: String) {
        self.iconImageView = UIImageView(image: icon)
        self.textLabel = UILabel()
        self.yellowTextLabel = UILabel()
        
        super.init(frame: .zero)
        
        setupUI(text1: text1, text2: text2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(text1: String, text2: String) {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        textLabel.text = text1
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = .white
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        yellowTextLabel.text = text2
        yellowTextLabel.font = UIFont.boldSystemFont(ofSize: 20)
        yellowTextLabel.textColor = .yellow
        yellowTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let back: UIView = UIView()
        back.translatesAutoresizingMaskIntoConstraints = false
        back.addSubview(iconImageView)
        back.addSubview(textLabel)
        back.addSubview(yellowTextLabel)
        addSubview(back)
        
        NSLayoutConstraint.activate([
            back.widthAnchor.constraint(equalToConstant: 260),
            back.heightAnchor.constraint(equalToConstant: 45),
            
            iconImageView.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: back.leadingAnchor),
            
            textLabel.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5),
            
            yellowTextLabel.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            yellowTextLabel.trailingAnchor.constraint(equalTo: back.trailingAnchor)
            
        ])
    }
}

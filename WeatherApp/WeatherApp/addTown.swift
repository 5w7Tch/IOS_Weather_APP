//
//  addTown.swift
//  WeatherApp
//
//  Created by Stra1 T on 11.02.25.
//

import Foundation
import UIKit


extension WeatherViewController{

    
    
    @objc func showAddTownForm() {
        guard let window = UIApplication.shared.windows.first else{return}
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = window.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0.8
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAddTownForm)))
        window.addSubview(blurView)
        blur = blurView
        buildAddTownView()
    }
    
    
    @objc func addTown() {
        switchToLoader(true)
        guard let cityName = cityNameTextField?.text, !cityName.isEmpty else {
            switchToLoader(false)
            return
        }
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if self.doesCityExist(cityName: cityName, context: context){
            switchToLoader(false)
            self.dismissAddTownForm()
            return
        }
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(key)"
        guard let url = URL(string: urlString) else {
            switchToLoader(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.switchToLoader(false)
                    self.dismissAddTownForm()
                    
                    self.showErrorPage(retryAction: {self.addTown()})
                    
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.switchToLoader(false)
                    self.dismissAddTownForm()
                    
                    self.showErrorPage(retryAction: {self.addTown()})
                   
                    return
                }
                
                if httpResponse.statusCode == 404 {
                    self.error?.isHidden = false
                    self.switchToLoader(false)
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    self.switchToLoader(false)
                    self.dismissAddTownForm()
                    
                    self.showErrorPage(retryAction: {self.addTown()})
                    return
                }
                
                if let data = data {
                    do {
                        
                        _ = try JSONDecoder().decode(WeatherResponse.self, from: data)
                        
                        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        let newTown = Town(context: context)
                        newTown.name = cityName
                        newTown.collor = self.randomBackgroundColor().toHex()
                        
                        try context.save()
                        
                        self.switchToLoader(false)
                        self.dismissAddTownForm()
                        self.pageControl.currentPage = 0
                        self.loadTowns()
                        
                        
                    } catch {
                        self.switchToLoader(false)
                        self.dismissAddTownForm()
                        self.showErrorPage(retryAction: {self.addTown()})
                    }
                }
            }
        }.resume()
    }
    
    
    @objc func dismissAddTownForm() {
        addTownView?.removeFromSuperview()
        error?.removeFromSuperview()
        blur?.removeFromSuperview()
    }
    
    
    
    func buildAddTownView(){
        guard let window = UIApplication.shared.windows.first else{return}
        
        let formView = UIView()
        formView.applyGradientBackground(topColor: UIColor(hex: "#21c47b")!, bottomColor: UIColor(hex: "#189e74")!)
        formView.backgroundColor = .systemGreen
        formView.layer.cornerRadius = 25
        formView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(formView)
        addTownView = formView
        
        let titleLabel = UILabel()
        titleLabel.text = "Add City"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Enter city name you wish to add"
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        textField.placeholder = "City Name"
        textField.textAlignment = .center
        cityNameTextField = textField
        
        
                                 
        let errorLabel = UIView()
        errorLabel.backgroundColor = .red
        
        let err = UILabel()
        err.text = "Error Occured"
        err.textColor = .white
        err.font = UIFont.boldSystemFont(ofSize: 20)
        let msg = UILabel()
        msg.text = "City with that name was not found!"
        msg.textColor = .white
        msg.font = UIFont.systemFont(ofSize: 15)
        err.translatesAutoresizingMaskIntoConstraints = false
        msg.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isHidden = true
        self.error = errorLabel
        errorLabel.addSubview(err)
        errorLabel.addSubview(msg)
        window.addSubview(errorLabel)
        errorLabel.layer.cornerRadius = 20
        
        formView.addSubview(titleLabel)
        formView.addSubview(instructionLabel)
        formView.addSubview(textField)
        plusButton.addTarget(self, action: #selector(addTown), for: .touchUpInside)
        loader.hidesWhenStopped = true
        formView.addSubview(plusButton)
        formView.addSubview(loader)
        
        loader.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: view.topAnchor, constant:100),
            errorLabel.widthAnchor.constraint(equalToConstant: 320),
            errorLabel.heightAnchor.constraint(equalToConstant: 70),
            
            err.leadingAnchor.constraint(equalTo: errorLabel.leadingAnchor, constant: 20),
            err.bottomAnchor.constraint(equalTo: errorLabel.centerYAnchor,constant: -2),
            msg.leadingAnchor.constraint(equalTo: err.leadingAnchor),
            msg.topAnchor.constraint(equalTo: err.bottomAnchor, constant: 2),
            
            formView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            formView.widthAnchor.constraint(equalToConstant: 300),
            formView.heightAnchor.constraint(equalToConstant: 250),
            
            titleLabel.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: formView.topAnchor, constant: 10),
            
            instructionLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            
            textField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            textField.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            textField.widthAnchor.constraint(equalToConstant: 160),
            textField.heightAnchor.constraint(equalToConstant: 30),
            
            plusButton.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            plusButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 30),
            plusButton.widthAnchor.constraint(equalToConstant: 50),
            plusButton.heightAnchor.constraint(equalToConstant: 50),
            
            loader.centerXAnchor.constraint(equalTo: plusButton.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            loader.widthAnchor.constraint(equalToConstant: 50),
            loader.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    func switchToLoader(_ doIt: Bool){
        if doIt {
            plusButton.isHidden = true
            loader.startAnimating()
        }else {
            plusButton.isHidden = false
            loader.stopAnimating()
        }
    }
    
}

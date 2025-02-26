//
//  HomePage.swift
//  WeatherApp
//
//  Created by Stra1 T on 29.01.25.
//

import Foundation
import UIKit

import CoreData
import CoreLocation





class WeatherViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let key: String = "4486fe6eb8f0a36bcb10e48bfc7c49d3"
    var pageViewController: UIPageViewController!
    var pageControl: UIPageControl!
    var towns: [Town] = []
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var addTownView: UIView?
    var cityNameTextField: UITextField?
    var loadingIndicator: UIActivityIndicatorView?
    var error: UIView?
    var blur: UIVisualEffectView?
    var townViewControllers: [TownViewController] = []
    var errorPageViewDisplayed = false
    
    
    let plusButton: UIButton = {
        let pb = UIButton(type: .system)
        let plusImage = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        pb.setImage(plusImage, for: .normal)
        pb.imageView?.tintColor = .clear
        pb.imageView?.backgroundColor = .clear
        pb.backgroundColor = .white
        pb.layer.cornerRadius = 25
        pb.translatesAutoresizingMaskIntoConstraints = false
        return pb
    }()
    
    let loader: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        return spinner
    }()
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? TownViewController, let index = currentVC.index, index > 0 else {
            return nil
        }
        let townVC = townViewController(for: index - 1)
        
       
        townVC!.loadWeatherData{ result in
            switch result{
            case .failure(_):
                if self.errorPageViewDisplayed {
                    return
                }
                if let top = self.navigationController?.topViewController {
                    if top is ErrorViewController{
                    }else{
                        self.errorPageViewDisplayed = true
                        DispatchQueue.main.async {                                    self.showErrorPage(retryAction: {self.loadTowns()})
                        }
                    }
                }
            case .success(_):
                print("")
            }
        }
    
        return townVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? TownViewController, let index = currentVC.index, index < towns.count - 1 else {
            return nil
        }
        
        
        let townVC = townViewController(for: index + 1)
        
        townVC!.loadWeatherData{ result in
            switch result{
            case .failure(_):
                
                if self.errorPageViewDisplayed {
                    return
                }
                if let top = self.navigationController?.topViewController {
                    if top is ErrorViewController{
                    }else{
                        self.errorPageViewDisplayed = true
                        DispatchQueue.main.async {                                    self.showErrorPage(retryAction: {self.loadTowns()})
                        }
                    }
                }
                
            case .success(_):
                print("")
            }
        }
    
        return townVC
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradientBackground(topColor: UIColor(hex: "#616e85")!, bottomColor: UIColor(hex: "274a87")!)
        
        setupNavigationBar()
        setupPageViewController()
        setupPageControl()
        promptForLocationActivation()
        //showLoadingIndicator()
        loadTowns()
        //hideLoadingIndicator()
    }

    
    
    func setupNavigationBar() {
        
        navigationItem.title = "Today"
        navigationItem.titleView?.backgroundColor = .white
        navigationItem.titleView?.tintColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWeather))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddTownForm))
        navigationItem.leftBarButtonItem?.tintColor = .yellow
        navigationItem.rightBarButtonItem?.tintColor = .yellow
    }
    
    
    func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstVC = townViewController(for: 0) {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        
        let longPresRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        pageViewController.view.addGestureRecognizer(longPresRecognizer)
        
        pageViewController.didMove(toParent: self)
        
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
       
        
        
    }
    
    
    func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = towns.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .yellow
        
        pageControl.addTarget(self, action: #selector(pageControllChanged(_:)), for: .valueChanged)
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first as? TownViewController{
            pageControl.currentPage = visibleViewController.index ?? 0
        }
    }
    
    @objc func pageControllChanged(_ sender: UIPageControl){
        let curentIndex = sender.currentPage
        if let townVC = townViewControllers[safe: curentIndex]{
            pageViewController.setViewControllers([townVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    func loadTowns() {
        let fetchRequest: NSFetchRequest<Town> = Town.fetchRequest()
        errorPageViewDisplayed = false
        showLoadingIndicator()

        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            towns = try context.fetch(fetchRequest)

            townViewControllers.removeAll()

            let dispatchGroup = DispatchGroup() // 🔹 Helps track when all async calls complete

            for (index, town) in towns.enumerated() {
                let townVC = TownViewController()
                townVC.town = town
                townVC.index = index

                dispatchGroup.enter() // 🔹 Mark the start of an async task

                townVC.loadWeatherData { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .failure(_):
                            if self.errorPageViewDisplayed {
                                dispatchGroup.leave()
                                return
                            }

                            if let top = self.navigationController?.topViewController, !(top is ErrorViewController) {
                                self.hideLoadingIndicator()
                                self.errorPageViewDisplayed = true
                                self.showErrorPage(retryAction: { self.loadTowns() })
                            }

                        case .success(_):
                            self.townViewControllers.append(townVC)
                        }

                        dispatchGroup.leave() // 🔹 Mark the completion of an async task
                    }
                }
            }

            dispatchGroup.notify(queue: .main) { // 🔹 This runs when all towns finish loading
                if let top = self.navigationController?.topViewController, !(top is ErrorViewController) {
                    self.hideLoadingIndicator()
                }

                if let firstVC = self.townViewControllers.first {
                    self.pageViewController.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
                }

                self.pageControl.numberOfPages = self.townViewControllers.count
                self.pageControl.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(self.pageControl)

                NSLayoutConstraint.activate([
                    self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    self.pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10)
                ])
            }
        } catch {
            showErrorPage(retryAction: { self.loadTowns() })
        }
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let allertController = UIAlertController(title: "Delete town", message: "Are you sure you want to delete this town", preferredStyle: .alert)
            
            allertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            allertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteTown(index: self.pageControl.currentPage)
            }))
            
            self.present(allertController, animated: true, completion: nil)
        }
        
        
    }
    
    func deleteTown(index: Int){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        do{
            context.delete(self.towns[index])
            try context.save()
        } catch {
            showErrorPage(retryAction: {self.deleteTown(index: index)})
        }
        
        self.towns.remove(at: index)
        self.pageControl.currentPage = 0
        self.loadTowns()
        
    }
    
    @objc func refreshWeather() {
        loadTowns()
       
       
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
    
    
    
    func townViewController(for index: Int) -> TownViewController? {
        guard index >= 0, index < towns.count else { return nil }
        let vc = TownViewController()
        vc.town = towns[index]
        vc.index = index
        return vc
    }
    
    func randomBackgroundColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0.5...1),
            green: CGFloat.random(in: 0.5...1),
            blue: CGFloat.random(in: 0.5...1),
            alpha: 1.0
        )
    }
}


extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension UIColor {
    
    func toHex() -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "000000"
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return String(format: "#%02X%02X%02X", Int(r*255),Int(g*255),Int(b*255))
    }
    
    convenience init?(hex: String) {
        var hexSnt = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSnt = hexSnt.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSnt).scanHexInt64(&rgb)
       
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}


//
//  ViewController.swift
//  Project16
//
//  Created by Pham Anh Tuan on 8/16/22.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initCapitals()
        
        setupChangeMapTypeButton()
    }

    // MARK: - Extra Functions
    private func initCapitals() {
        let hanoi = Capital(title: "Ha Noi", coordinate: CLLocationCoordinate2D(latitude: 21.028333, longitude: 105.854167), info: "Capital of Viet Nam", wikipediaUrl: "https://en.wikipedia.org/wiki/hanoi")
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.", wikipediaUrl: "https://en.wikipedia.org/wiki/london")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.", wikipediaUrl: "https://en.wikipedia.org/wiki/oslo")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.", wikipediaUrl: "https://en.wikipedia.org/wiki/paris")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.", wikipediaUrl: "https://en.wikipedia.org/wiki/rome")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.", wikipediaUrl: "https://en.wikipedia.org/wiki/Washington,_D.C.")
        
        mapView.addAnnotations([hanoi, london, oslo, paris, rome, washington])
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }
        
        let identifier = "Capital"
        if let capitalView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            return capitalView
        } else {
            let capitalView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            capitalView.pinTintColor = .cyan
            capitalView.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            capitalView.rightCalloutAccessoryView = btn
            
            return capitalView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard
            let capital = view.annotation as? Capital,
            let wikipediaUrl = capital.wikipediaUrl
        else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let wikipediaViewController = storyboard.instantiateViewController(withIdentifier: "Wikipedia") as? WikipediaViewController else { return }
        
        wikipediaViewController.wikipediaUrl = wikipediaUrl
        
        navigationController?.pushViewController(wikipediaViewController, animated: true)
    }
    
    private func setupChangeMapTypeButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleChangeMapTypeButtonTapped))
    }
    
    @objc private func handleChangeMapTypeButtonTapped() {
        let ac = UIAlertController(title: "Change Map Type", message: "Choose map type", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .standard
        }))
        
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .satellite
        }))

        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .hybrid
        }))
        
        ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .hybridFlyover
        }))
        
        ac.addAction(UIAlertAction(title: "Muted Standard", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .mutedStandard
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
}


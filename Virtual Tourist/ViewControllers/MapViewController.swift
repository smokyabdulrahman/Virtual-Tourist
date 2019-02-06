//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by ABDULRAHMAN ALRAHMA on 1/21/19.
//  Copyright © 2019 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    // MARK: -Lifecycle Events
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupFetchedResultsController()
        loadMapAnnotations()
        
        // Add LongTapGesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        mapView.delegate = self
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)

        setupFetchedResultsController()
        loadMapAnnotations()
        // TODO: update pins
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: -Setup code
    // TODO: Setup/update pins
    private func loadMapAnnotations() {
        if let pins = fetchedResultsController.fetchedObjects {
            mapView.addAnnotations(pins)
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: -Functionalities
    // TODO: add pin by holding on a location on map
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if(sender.state != .began){
            let touchPoint = sender.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            addPin(longitude: newCoordinates.longitude, latitude: newCoordinates.latitude)
            return
        }
    }
    
    // MARK: -Model Functions
    
    /// Adds a new pin to the end of the `pins` array
    func addPin(longitude: Double, latitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.longitude = longitude
        pin.latitude = latitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // TODO: by pressing on a pin go to photosListViewController
        mapView.deselectAnnotation(view.annotation! , animated: true)
        let pin: Pin = view.annotation as! Pin
        let photosListVC = storyboard?.instantiateViewController(withIdentifier: "PhotosListViewController") as! PhotosListViewController;
        
        photosListVC.pin = pin
        photosListVC.dataController = dataController
        
        navigationController?.pushViewController(photosListVC, animated: true)
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let pin = anObject as? Pin else {
            preconditionFailure("NOT A PIN!")
        }
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
            break
        default: ()
        }
    }
}

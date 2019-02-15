//
//  PhotosListViewController.swift
//  Virtual Tourist
//
//  Created by ABDULRAHMAN ALRAHMA on 1/21/19.
//  Copyright © 2019 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import Kingfisher

class PhotosListViewController: UIViewController {
    
    // Injected by default
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    private let itemsPerRow: CGFloat = 2
    private let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private let reuseId = "PhotoCell"
    @IBOutlet weak var getNewPhotosButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupFetchedResultsController()
        
        setGetNewPhotosButtonEnabled(to: false)
        
        if (fetchedResultsController.sections?[0].numberOfObjects ?? 0 == 0) {
            getPhotos()
        } else {
            setGetNewPhotosButtonEnabled(to: true)
        }
        
        mapView.addAnnotation(pin)
        mapView.showAnnotations([pin], animated: true)
        mapView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    private func setGetNewPhotosButtonEnabled(to state: Bool) {
        getNewPhotosButton.isEnabled = state
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin!.creationDate!)-photos")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func getPhotos() {
        setGetNewPhotosButtonEnabled(to: false)
        FlickrAPI.getListOfPhotosIn(lat: pin.latitude, lon: pin.longitude) { (error, photosURL) in
            // if photos is empty show empty background
            switch error {
            case .notConnected:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Hmmmm..", message:
                        "There seems to be no internet connection! please, connect to a network then try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                break
            case .connected:
                for photoURL in photosURL! {
                    self.addPhoto(url: photoURL)
                }
                break
            case .other:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Hmmmm..", message:
                        "Something bad occured. Please, try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                break
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.setGetNewPhotosButtonEnabled(to: true)
            }
        }
    }
    
    func addPhoto(url: String) {
        let photo = Photo(context: dataController.viewContext)
        photo.creationDate = Date()
        photo.url = url
        photo.pin = pin
        try? dataController.viewContext.save()
    }
    
    func deletePhoto(_ photo: Photo) {
        dataController.viewContext.delete(photo)
        do {
            try dataController.viewContext.save()
        } catch {
            print("Error saving")
        }
        
    }
    
    @IBAction func removeAllPhotos() {
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("Error saving")
                }
            }
        }
        getPhotos()
    }
    
}

extension PhotosListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = insets.right * (itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let widthOfItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthOfItem, height: widthOfItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.right
    }
}

extension PhotosListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (fetchedResultsController.sections?[section].numberOfObjects ?? 0 == 0) {
            collectionView.setEmptyMessage("No photos :(, try to refresh.")
        } else {
            collectionView.deleteEmptyMessage()
        }
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! PhotoCell
        
        // Configure cell
        if let photoData = aPhoto.data {
            cell.imageView.image = UIImage(data: photoData)
        } else if let photoURL = aPhoto.url {
            guard let url = URL(string: photoURL) else {
                print("no!")
                return cell
            }
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: nil, progressBlock: nil) { (img, err, cacheType, url) in
                if ((err) != nil) {
                    
                } else {
                    aPhoto.data = img?.pngData()
                    try? self.dataController.viewContext.save()
                }
            }
        }
        
        return cell
    }
}

extension PhotosListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        deletePhoto(photoToDelete)
    }
    
}

extension PhotosListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        default: ()
        }
    }
}

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func deleteEmptyMessage() {
        self.backgroundView = nil
    }
}

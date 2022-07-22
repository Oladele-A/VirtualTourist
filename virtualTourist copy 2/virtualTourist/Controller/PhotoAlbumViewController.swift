//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Oladele Abimbola on 6/26/22.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData
 
class PhotoAlbumViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<FlickrImage>!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var location: Location!
    var serverId: String = ""
    var id: String = ""
    var secret: String = ""
    var photoURL: String?
    var urlStore:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        mapViewSetup()
        flowLayoutConfiguration()
        setUpFetchedResultsController()
        imageLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        getPhotos()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func mapViewSetup(){
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        annotation.coordinate = coordinate
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func flowLayoutConfiguration(){
        let space: CGFloat = 3.0
        let layoutWidth = (view.frame.size.width - (2*space))/3.0
        let layoutHeight = (view.frame.size.height - (2*space))/5.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: layoutWidth, height: layoutHeight)
    }
    
    @IBAction func newCollectionButton(_ sender: Any) {
        newCollectionButton.isEnabled = false
        
        if let album = fetchedResultsController.fetchedObjects{
            for photo in album{
                dataController.viewContext.delete(photo)
                try? dataController.viewContext.save()
                
                setUpFetchedResultsController()
                getPhotos()
                try? dataController.viewContext.save()
                
                newCollectionButton.isEnabled = true
            }
        }
    }
    
    
    //MARK: FLICKR CLIENT CALL
    func getPhotos(){
        
        if fetchedResultsController.fetchedObjects!.count == 0 {
            FlickrClient.flickrPhotoSearch(lat: latitude, lon: longitude) { response, error in
                if error == nil && response?.photos.photo != nil && response?.photos.total != 0 {
                    guard let response = response else {return}
                    for image in response.photos.photo{
                        let photo = FlickrImage(context: self.dataController.viewContext)
                        photo.url = "https://live.staticflickr.com/\(image.server)/\(image.id)_\(image.secret).jpg"
                        photo.location = self.location
                        
                        do {
                            try self.dataController.viewContext.save()
                        }catch{
                            fatalError("Unable to save photos: \(error.localizedDescription)")
                        }
                        
                        self.collectionView.reloadData()
                    }
                    print("album saved")
                }else{
                    print("No photo downloaded")
                }
            }
        }else{
            return
        }
    }
    
    
    // MARK: MAPVIEW DELEGATE
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
}

// MARK: COLLECTION VIEW DELEGATE
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setUpFetchedResultsController()
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = "collectionCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! photoAlbumCell
        let anImage = fetchedResultsController.object(at: indexPath)
        
        if let url = anImage.url{
            if let image = anImage.photo{
                cell.imageView.image = UIImage(data: image)
            }else{
                
                FlickrClient.getPhotoImage(imageURL: URL(string: (url))!) { data, error in
                    
                    if let data = data {
                        let image = UIImage(data: data)
                        anImage.photo = data
                        cell.imageView.image = image
                        
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            fatalError("Unable to save photos: \(error.localizedDescription)")
                        }
                        
                    } else {
                        fatalError("error:\(error?.localizedDescription)")
                    }
                }
            }
        }else{
            
            let placeholderImage = UIImage(systemName: "photo")
            cell.imageView.image = placeholderImage
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! photoAlbumCell
           
           if cell.isSelected {
               let alertVC = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
               alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                   let image = self.fetchedResultsController.object(at: indexPath)
                   self.dataController.viewContext.delete(image)
                do {
                   try self.dataController.viewContext.save()
                    try self.fetchedResultsController.performFetch()
                } catch {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.collectionView.deleteItems(at: [indexPath])
                    self.collectionView.reloadData()
                }
               }))
               present(alertVC, animated: true, completion: nil)
           }
       }
}

// MARK: FETCHED RESULTS CONTROLLER
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{

    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<FlickrImage> = FlickrImage.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: true)
        let predicate = NSPredicate(format: "location == %@", location)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}

// MARK: UI UPDATE METHOD
extension PhotoAlbumViewController{
    
    func cellImage(is downloading: Bool) {
           newCollectionButton.isEnabled = !downloading
       }
    
}

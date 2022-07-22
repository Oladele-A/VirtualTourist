//
//  ViewController.swift
//  virtualTourist
//
//  Created by Oladele Abimbola on 6/26/22.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Location>!
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var location: Location!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        view.backgroundColor = UIColor.systemPink
        setUpFetchedResultsController()
        addGestureRecognizer()
        getCoreDataLocation()
        
        configureMapView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func configureMapView(){
        mapView.showsBuildings = true
        mapView.showsCompass = true
    }
    
    func getCoreDataLocation(){
        for location in fetchedResultsController.fetchedObjects!{
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = location.latitude
            annotation.coordinate.longitude = location.longitude
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: Mapview Delegate 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.animatesDrop = true
            pinView!.tintColor = UIColor.systemPink
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var selectedAnnotation: MKPointAnnotation!
        selectedAnnotation = view.annotation as? MKPointAnnotation
        latitude = selectedAnnotation.coordinate.latitude
        longitude = selectedAnnotation.coordinate.longitude
        let pins = fetchedResultsController.fetchedObjects! as [Location]
        location = pins.filter({ $0.latitude == view.annotation?.coordinate.latitude && $0.longitude == view.annotation?.coordinate.longitude}).first
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegue(withIdentifier: "photoView", sender: self)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        debugPrint("Map has been fully loaded. Start working")
    }
    
    // MARK: Transition
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoView"{
            let controller = segue.destination as? PhotoAlbumViewController
            controller?.latitude = latitude
            controller?.longitude = longitude
            controller?.dataController = dataController
            controller?.location = location
        }
    }
}

extension MapViewController: UIGestureRecognizerDelegate{
    
    fileprivate func addGestureRecognizer() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapViewTapped(gestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 1
        longPressGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func mapViewTapped(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let locationContext = Location(context: dataController.viewContext)
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            locationContext.longitude = annotation.coordinate.longitude
            locationContext.latitude = annotation.coordinate.latitude
            mapView.addAnnotation(annotation)
            
            do{
                try dataController.viewContext.save()
            }catch{
                print(error)
            }
            try? fetchedResultsController.performFetch()
        }
    }
}

extension MapViewController : NSFetchedResultsControllerDelegate{
    
    fileprivate func setUpFetchedResultsController() {
        // Generally, fetchRequest don't have to be sorted. But fetchRequest that will be used to instantiate a fetchedResultsController must be sorted.
        let fetchRequest:NSFetchRequest<Location> = Location.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
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

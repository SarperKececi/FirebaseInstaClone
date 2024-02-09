import UIKit
import MapKit
import CoreLocation

class MapKitViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    var delegate: UploadViewController?
    let locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults: [MKMapItem] = []
    var chosenLocation: String?


    // MARK: - IBOutlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTableView: UITableView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        title = "Search"

        // Configure the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a location"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Add long press gesture recognizer
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)

        // Configure the tableView
        mapTableView.delegate = self
        mapTableView.dataSource = self
    }

    // MARK: - Actions

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
       
           performSegue(withIdentifier: "saveButtonVC", sender: nil)
       
        
        }
  


    // MARK: - Location Manager Delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    // MARK: - Search Results Updating

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            // Search işlemini yap
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText

            let search = MKLocalSearch(request: request)
            search.start { [weak self] response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let response = response else {
                    return
                }

                self?.searchResults = response.mapItems
                self?.mapTableView.reloadData() // tableView'ı yeniden yükle
            }
        } else {
            // Eğer searchText boş ise, tableView'ı temizle
            searchResults = []
            mapTableView.reloadData()
        }
    }


    // MARK: - Gesture Recognizer

    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude

          
            // Arama çubuğunu devre dışı bırakın ve kaydet düğmesini görünür yapın
            navigationItem.searchController = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonPressed(_:)))
        }
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.name // Bu sonucun adını kullanabilirsiniz, gerektiğinde diğer özellikleri de ekleyebilirsiniz.
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        let selectedLocationCoordinate = selectedResult.placemark.coordinate
        let selectedLocationName = selectedResult.name
       
        searchController.isActive = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonPressed(_:)))
        // Konumu haritada merkezleyin
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: selectedLocationCoordinate, span: span)
        mapView.setRegion(region, animated: true)

      
     

        // SearchBar'a seçilen konumu yerleştirin ve diğer işlemleri gerçekleştirin
        searchController.searchBar.text = selectedLocationName
        chosenLocation = selectedLocationName
        searchController.searchBar.showsCancelButton = false
        if let UploadViewController = delegate {
            UploadViewController.selectedLocation = chosenLocation
        }
      
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveButtonVC" {
            if let destinationVC = segue.destination as? UploadViewController {
                destinationVC.selectedLocation = self.chosenLocation
                print("selectedLocation sent to UploadViewController: \(String(describing: self.chosenLocation))")
            }
        }
    }




}


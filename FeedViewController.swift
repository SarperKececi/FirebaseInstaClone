//import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SDWebImage




class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    var postedBy = [String]()
    var postComment = [String]()
    var likes = [Int]()
    var imageUrlArray = [String]()
    var documentIdArray = [String]()
    var locationArray = [String]() // Yeni bir dizi ekleyin
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(openMapView(_:)), name: Notification.Name("LocationTapped"), object: nil)
        feedTableView.delegate = self
        feedTableView.dataSource = self
        getDataFromFirestore()
        
    }
    
    func getDataFromFirestore() {
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Posts")
            .order(by: "Date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if error != nil {
                    // Hata işleme
                } else {
                    if let documents = snapshot?.documents {
                        self?.postedBy.removeAll()
                        self?.postComment.removeAll()
                        self?.likes.removeAll()
                        self?.imageUrlArray.removeAll()
                        self?.documentIdArray.removeAll()
                        self?.locationArray.removeAll()
                        
                        for document in documents {
                            let documentID = document.documentID
                            self?.documentIdArray.append(documentID)
                            if let postedBy = document.get("PostedBy") as? String {
                                self?.postedBy.append(postedBy)
                            }
                            if let postComment = document.get("PostComment") as? String {
                                self?.postComment.append(postComment)
                            }
                            if let likes = document.get("Like") as? Int {
                                self?.likes.append(likes)
                            }
                            if let imageUrl = document.get("imageUrl") as? String {
                                self?.imageUrlArray.append(imageUrl)
                            }
                            if let location = document.get("Location") as? String {
                                self?.locationArray.append(location) // Location bilgisini çekin
                            }
                        }
                        
                        self?.feedTableView.reloadData()
                    }
                }
            }
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postedBy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedTableViewCell
        
        cell.userText.text = postedBy[indexPath.row]
        cell.commentText.text = postComment[indexPath.row]
        cell.likeLabel.text = String(likes[indexPath.row])
        if let idLabel = cell.IdLabel {
            idLabel.text = documentIdArray[indexPath.row]
        } else {
            print("HATA: cell.IdLabel nil")
        }

        cell.locationText.text = locationArray[indexPath.row] // Location bilgisini hücreye yerleştirin
        
        if let imageURL = URL(string: imageUrlArray[indexPath.row]) {
            cell.photoView.sd_setImage(with: imageURL)
        } else {
            print("Geçersiz resim URL'i: \(imageUrlArray[indexPath.row])")
        }
        
        return cell
    }
    
    @objc func openMapView(_ notification: Notification) {
        if let locationText = notification.object as? String {
            let mapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedMapViewController") as! FeedMapViewController
            mapViewController.selectedLocation = locationText
            navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    
}


   



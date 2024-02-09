//
//  UploadViewController.swift
//  FirebaseInstaClone
//
//  Created by Sarper Kececi on 25.09.2023.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore



class UploadViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
   
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var locationText: UITextField!
    
    var selectedLocation: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Kullanıcının dokunma işlemi algılandığında belirli bir fonksiyonu çalıştırır.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        photoView.isUserInteractionEnabled = true // Kullanıcı görsele tıklayabilir mi? Evet!
        // Gesture recognizer özelliğini NEYE EKLEMEK İSTERSENİZ ONA EKLEYEBİLİRSİNİZ, MESALA SELECTIMAGE'E EKLENMİŞTİR.
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        photoView.addGestureRecognizer(imageTapRecognizer)
       
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedLocation = selectedLocation {
            locationText.text = selectedLocation
            print("selectedLocation dolu: \(selectedLocation)")
        } else {
            print("selectedLocation boş")
        }
    }


    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func pickImage () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // Güzel bir hile: sourceType, kameradan mı açacaksınız, fotoğraf albümünden mi açacaksınız gibi seçenekleri belirtir.
        picker.allowsEditing = true // Kullanıcı seçilen görseli düzenleyebilir
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        photoView.image = info[.originalImage] as? UIImage // Bu satır, seçilen görüntünün orijinalini alır ve "selectImage.image" bu görüntüyü atar.
        saveButton.isEnabled = true
        self.dismiss(animated: true) // Ve bu şekilde işlevi kapatırız. Kullanıcı resmi seçtikten sonra resim seçme ekranını kapatır.
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "mapViewVC", sender: nil)
        
    }
    
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if photoView.image == nil || photoView.image?.isEqual(UIImage(named: "photopng")) == true {
            self.alertMessage(title: "Error", message: "Please select an image.")
            return
        }

        

        if let comment = commentText.text, comment.isEmpty {
            // Kullanıcı bir yorum girmediyse, hata mesajı göster
            self.alertMessage(title: "Error", message: "Please enter a comment.")
            return
        }
        if let location = locationText.text, location.isEmpty {
               self.alertMessage(title: "Error", message: "Please enter a location.")
               return
           }


        // Görüntü seçildiği durumda buraya gelecek ve kaydetme işlemi devam edecek.

        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")

        if let data = photoView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { metadata, error in
                if let error = error {
                    self.alertMessage(title: "Error", message: error.localizedDescription)
                } else {
                    imageReference.downloadURL { url, error in
                        if let error = error {
                            self.alertMessage(title: "Error", message: error.localizedDescription)
                        } else if let imageUrl = url?.absoluteString {
                            // Firestore veritabanına kaydetme işlemi
                            let firestoreDatabase = Firestore.firestore()
                            let firestorePost: [String: Any] = [
                                "imageUrl": imageUrl,
                                "PostedBy": Auth.auth().currentUser!.email!,
                                "PostComment": self.commentText.text ?? "",
                                "Date": Date(),
                                "Like": 0 ,
                                "Location": self.locationText.text ?? ""
                            ]

                            firestoreDatabase.collection("Posts").addDocument(data: firestorePost) { error in
                                if let error = error {
                                    self.alertMessage(title: "Error", message: error.localizedDescription)
                                } else {
                                    // Başarıyla kaydedildi.
                                    self.alertMessage(title: "Success", message: "Post uploaded successfully!")
                                    self.photoView?.image = UIImage(named: "photopng")
                                    self.commentText.text = ""
                                    self.locationText.text = ""
                                    
                                
                                

                                    
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    func alertMessage (title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        
        present(alert, animated: true)
    }
    
    
  
    
}

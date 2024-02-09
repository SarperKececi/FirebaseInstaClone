//
//  FeedTableViewCell.swift
//  FirebaseInstaClone
//
//  Created by Sarper Kececi on 27.09.2023.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FeedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var IdLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var locationText: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLocationTap(_:)))
        locationText.isUserInteractionEnabled = true
        locationText.addGestureRecognizer(tapGestureRecognizer)

        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func likeButtınPressed(_ sender: UIButton) {
        let likeKey = "\(Auth.auth().currentUser?.uid ?? "")_\(IdLabel.text ?? "")"
               
               let fireStoreDataBase = Firestore.firestore()
               
               // Kullanıcının daha önce bu gönderiye like eklemişse, işlem yapma
               if UserDefaults.standard.bool(forKey: likeKey) {
                   print("Kullanıcı daha önce bu gönderiye like eklemiş.")
                   
                   // Like'i kaldırmak için isSelected özelliğini false yap
                   sender.isSelected = false
                   
                   // LikeLabel'i güncelle -1 yap
                   if let likeCount = Int(likeLabel.text!), likeCount > 0 {
                       let newLikeCount = likeCount - 1
                       likeLabel.text = String(newLikeCount)
                       
                       // Firestore'da like sayısını güncelle
                       let likeStore = [ "Like" : newLikeCount ] as [String : Any]
                       fireStoreDataBase.collection("Posts").document(IdLabel.text!).setData(likeStore, merge: true)
                       
                       // UserDefaults'tan like'ı kaldır
                       UserDefaults.standard.set(false, forKey: likeKey)
                   }
                   
                   return
               }
               
               if let likeCount = Int(likeLabel.text!) {
                   let newLikeCount = likeCount + 1
                   likeLabel.text = String(newLikeCount)
                   
                   let likeStore = [ "Like" : newLikeCount ] as [String : Any]
                   fireStoreDataBase.collection("Posts").document(IdLabel.text!).setData(likeStore, merge: true) { error in
                       if let error = error {
                           print("Like eklenirken hata oluştu: \(error.localizedDescription)")
                       } else {
                           print("Like başarıyla eklendi.")
                           
                           // Kullanıcının bu gönderiye like eklediğini işaretlemek için UserDefaults kullanın
                           UserDefaults.standard.set(true, forKey: likeKey)
                           
                           // Like ekledikten sonra like butonunu devre dışı bırakabilirsiniz
                           // sender.isEnabled = false  // Bu satırı yorum satırına aldım
                           // Like ekledikten sonra isSelected özelliğini true yaparak like simgesini gösterebilirsiniz
                           sender.isSelected = true
                       }
                   }
               }
           }
            

    @objc func handleLocationTap(_ sender: UITapGestureRecognizer) {
      
            if let locationText = locationText.text {
                NotificationCenter.default.post(name: Notification.Name("LocationTapped"), object: locationText)
            
        }

    }


    
    
       }

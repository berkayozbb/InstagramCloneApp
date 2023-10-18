//
//  homePageTableViewCell.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 5.10.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class homePageTableViewCell: UITableViewCell {

    @IBOutlet var profilPictureImageView: UIImageView!
    
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var likeCountLabel: UILabel!
    
    @IBOutlet var commentUsernameLabel: UILabel!
    
    @IBOutlet var commentLabel: UILabel!
    
    @IBOutlet var commentButton: UIButton!
    
    @IBOutlet var documentIdLabel: UILabel!
    
    @IBOutlet var userIdLabel: UILabel!
    var likedBy = [String]()
    
    
    
    
    
    
    @IBAction func likeButtonClicked(_ sender: Any) {
            let userId = Auth.auth().currentUser!.uid
            var firestoreReference : DocumentReference? = nil
        
        let firestoreDatabase = Firestore.firestore()
        var isAlreadyLiked = false
        
        firestoreDatabase.collection("UserLikedPost").getDocuments { snapshot, error in
            if error != nil{
                print(error ?? "error")
                return
            }
            for document in snapshot!.documents{
                if document.get("postId") as! String == self.documentIdLabel.text! &&  document.get("userId") as! String == userId {
                    isAlreadyLiked = true
                }
            }
            
            //Daha önce beğenmemiş, ilk kez beğenecek
            if(isAlreadyLiked == false){
                let userLikedPosts = ["userId": userId, "postId": self.documentIdLabel.text!]
                firestoreReference = firestoreDatabase.collection("UserLikedPost").addDocument(data: userLikedPosts, completion: { error in
                    if error != nil {
                        print("error")
                    }
                })
            
                firestoreDatabase.collection("UserLikedPost").getDocuments { snapshot, error in
                    if error != nil{
                        print(error ?? "error")
                        return
                    }
                    var likeCounter = -1
                    for document in snapshot!.documents{
                        if document.get("postId") as! String == self.documentIdLabel.text! {
                            likeCounter += 1
                        }
                    }
                    self.likeCountLabel.text = String(likeCounter)
                    self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
                return
            } 
            
            //Daha önce beğendiği için ters like yapacağız
            let query = firestoreDatabase.collection("UserLikedPost")
                                            .whereField("postId", isEqualTo: self.documentIdLabel.text!)
                                            .whereField("userId", isEqualTo: userId)

            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Belgeler getirilemedi: \(error.localizedDescription)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    
                    for document in documents {
                        document.reference.delete { error in
                            if let error = error {
                                print("Belge silinemedi: \(error.localizedDescription)")
                            } else {
                                print("Belge başarıyla silindi.")
                                self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                            }
                        }
                    }
                    firestoreDatabase.collection("UserLikedPost").getDocuments { snapshot, error in
                        if error != nil{
                            print(error ?? "error")
                            return
                        }
                        var likeCounter = -1
                        for document in snapshot!.documents{
                            if document.get("postId") as! String == self.documentIdLabel.text! {
                                likeCounter += 1
                            }
                        }
                        self.likeCountLabel.text = String(likeCounter)
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func commentButtonClicked(_ sender: Any) {
        
        print("comment")
    }
    

    
    
}

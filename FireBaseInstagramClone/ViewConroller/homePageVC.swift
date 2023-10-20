//
//  homePageVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 4.10.2023.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage
import Dispatch
import Lottie
import SwiftUI

class homePageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    private var animationView: LottieAnimationView?
    private let dispatchGroup = DispatchGroup()
    
    var usernameArray = [String]()
    var userIdArray = [String]()
    var userCommentArray = [String]()
    var likearray = [Int]()
    var postImageArray = [String]()
    var documentIdArray = [String]()
    var hadLikedArray = [Bool]()
    var ppArray = [String]()
    
    var common = Common()
    
    override func viewWillAppear(_ animated: Bool) {
        animationView = .init(name: "loader.json")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1.5
        view.addSubview(animationView!)
        animationView!.play() 
        dispatchGroup.enter() // Dispatch Group'a giriş yapın

            Task {
                await getDataFromFirestore()
                
                dispatchGroup.leave() // Dispatch Group'tan çıkış yapın
            }
            
            // Dispatch Group'un bitişini bekleyin ve animasyonu gizleyin
            dispatchGroup.notify(queue: .main) {
                self.animationView!.removeFromSuperview()
            }
    }
    
    func getDataFromFirestore() async {
        let userId = Auth.auth().currentUser!.uid
        let firestoreDatabase = Firestore.firestore()
        
        do {
            let snapshot = try await firestoreDatabase.collection("Posts").order(by: "date", descending: true).getDocuments()
            
            if !snapshot.isEmpty {
                self.likearray.removeAll(keepingCapacity: false)
                self.usernameArray.removeAll(keepingCapacity: false)
                self.userCommentArray.removeAll(keepingCapacity: false)
                self.postImageArray.removeAll(keepingCapacity: false)
                self.documentIdArray.removeAll(keepingCapacity: false)
                self.hadLikedArray.removeAll(keepingCapacity: false)
                self.userIdArray.removeAll(keepingCapacity: false)
                self.ppArray.removeAll(keepingCapacity: false)
                
                for document in snapshot.documents {
                    let documentId = document.documentID
                    self.documentIdArray.append(documentId)
                    
                    if let userId = document.get("userId") as? String {
                        self.userIdArray.append(userId)
                    }
                    
                    if let postedBy = document.get("postedBy") as? String {
                        self.usernameArray.append(postedBy)
                    }
                    
                    if let userComment = document.get("postComment") as? String {
                        self.userCommentArray.append(userComment)
                    }
                    
                    if let imageBase = document.get("postBase") as? String {
                        self.postImageArray.append(imageBase)
                    }
                }
                
                // Profil fotoğraflarını al
                
                for userId in self.userIdArray {
                    let ppSnapshot = try await firestoreDatabase.collection("Users").whereField("userId", isEqualTo: userId).getDocuments()
                    if let userDocument = ppSnapshot.documents.first, let profilePicture = userDocument.get("profilePicture") as? String {
                        self.ppArray.append(profilePicture)
                    }
                }
                
                // Beğenileri al
                for documentId in self.documentIdArray {
                    let likeSnapshot = try await firestoreDatabase.collection("UserLikedPost").whereField("postId", isEqualTo: documentId).getDocuments()
                    var likeCounter = 0
                    
                    for document in likeSnapshot.documents {
                        if let documentUserId = document.get("userId") as? String {
                            if(!documentUserId.isEmpty) {
                                likeCounter += 1
                            }
                        }
                    }
                    self.likearray.append(likeCounter)
                    
                    let a = try await firestoreDatabase.collection("UserLikedPost").whereField("userId", isEqualTo: userId).whereField("postId", isEqualTo: documentId).getDocuments()
                    self.hadLikedArray.append(a.documents.count > 0)
                }
                
                // Verileri ekledikten sonra tabloyu güncelleyin
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Hata: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postImageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! homePageTableViewCell
        cell.profilPictureImageView.layer.cornerRadius = cell.profilPictureImageView.frame.size.width / 2
        cell.profilPictureImageView.clipsToBounds = true
        
        cell.likeButton.setImage(UIImage(systemName: hadLikedArray[indexPath.row] ? "heart.fill" : "heart"), for: .normal)
        cell.commentLabel.text = userCommentArray[indexPath.row]
        if userCommentArray[indexPath.row] != ""{
            cell.commentUsernameLabel.text = usernameArray[indexPath.row]
        }
        cell.likeCountLabel.text = "\(likearray[indexPath.row])"
        cell.usernameLabel.text = usernameArray[indexPath.row]
        cell.postImageView.image = common.base64ToImage(base64String: self.postImageArray[indexPath.row])
        cell.documentIdLabel.text = documentIdArray[indexPath.row]
        cell.userIdLabel.text = userIdArray[indexPath.row]
        cell.profilPictureImageView.image = common.base64ToImage(base64String: self.ppArray[indexPath.row])
        
        return cell
    }
    
    
    

}

//
//  customizeProfileVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 19.10.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class customizeProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var username = Auth.auth().currentUser?.displayName
    
    @IBOutlet var ppImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var bioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ppImageView.isUserInteractionEnabled = true
        //gestureRecognizer tanımlanıyor tap olduğunda hangi func çalışacak
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectPP))
        //imageView e atanıyor hazırlanan Recognizer
        ppImageView.addGestureRecognizer(imageTapRecognizer)
        
        nameLabel.isUserInteractionEnabled = true
        //gestureRecognizer tanımlanıyor tap olduğunda hangi func çalışacak
        let nameLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(goChangeNameVC))
        //imageView e atanıyor hazırlanan Recognizer
        nameLabel.addGestureRecognizer(nameLabelTapRecognizer)
        
        usernameLabel.isUserInteractionEnabled = true
        //gestureRecognizer tanımlanıyor tap olduğunda hangi func çalışacak
        let userNameLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(goChangeUsernameVC))
        //imageView e atanıyor hazırlanan Recognizer
        usernameLabel.addGestureRecognizer(userNameLabelTapRecognizer)
        
        bioLabel.isUserInteractionEnabled = true
        //gestureRecognizer tanımlanıyor tap olduğunda hangi func çalışacak
        let bioLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(goChangeBioVC))
        //imageView e atanıyor hazırlanan Recognizer
        bioLabel.addGestureRecognizer(bioLabelTapRecognizer)
        
        usernameLabel.text = username

        //profil fotoğrafını daire çerçeveye aldım.
        ppImageView.layer.cornerRadius = ppImageView.frame.size.width / 2
        ppImageView.clipsToBounds = true
        
        if let currentUserId = Auth.auth().currentUser?.uid {
                  let db = Firestore.firestore()
                  let usersCollectionRef = db.collection("Users")

                  // Belirtilen kullanıcının belgesini sorgula
                  usersCollectionRef.whereField("userId", isEqualTo: currentUserId).getDocuments { (querySnapshot, error) in
                      if let error = error {
                          print("Belge sorgulama hatası: \(error.localizedDescription)")
                      } else if let document = querySnapshot?.documents.first {
                          // İlk eşleşen belgeyi aldık ve "name" alanındaki değeri alıyoruz
                          if let name = document["name"] as? String {
                              self.nameLabel.text = name // UILabel içine adı yazdır
                          }
                      }
                  }
              }
        
        if let currentUserId = Auth.auth().currentUser?.uid {
                  let db = Firestore.firestore()
                  let usersCollectionRef = db.collection("Users")

                  // Belirtilen kullanıcının belgesini sorgula
                  usersCollectionRef.whereField("userId", isEqualTo: currentUserId).getDocuments { (querySnapshot, error) in
                      if let error = error {
                          print("Belge sorgulama hatası: \(error.localizedDescription)")
                      } else if let document = querySnapshot?.documents.first {
                          // İlk eşleşen belgeyi aldık ve "bio" alanındaki değeri alıyoruz
                          if let bio = document["bio"] as? String {
                              self.bioLabel.text = bio // UILabel içine adı yazdır
                          }
                      }
                  }
              }
        
        fetchProfilePicture()
    }
    
    @objc func goChangeNameVC() {
        performSegue(withIdentifier: "goChangeNameVC", sender: nil)
    }
    
    @objc func goChangeUsernameVC() {
        performSegue(withIdentifier: "goChangeUsernameVC", sender: nil)
    }
    
    @objc func goChangeBioVC() {
        performSegue(withIdentifier: "goChangeBioVC", sender: nil)
    }
    func fetchProfilePicture() {
        let firestoreDatabase = Firestore.firestore()

        if let currentUserUID = Auth.auth().currentUser?.uid {
            let usersCollection = firestoreDatabase.collection("Users")

            // Kullanıcının UID'si ile eşleşen dökümanı aramak için bir sorgu oluşturun
            usersCollection.whereField("userId", isEqualTo: currentUserUID).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Sorgu hatası: \(error.localizedDescription)")
                } else {
                    // Sorgu sonuçlarına göz atın
                    for document in querySnapshot!.documents {
                        if let profilePictureString = document.data()["profilePicture"] as? String,
                           let profilePictureData = Data(base64Encoded: profilePictureString),
                           let profilePicture = UIImage(data: profilePictureData) {
                            // Profil resmini başarıyla çektik, şimdi ImageView'e yerleştirebiliriz
                            self.ppImageView.image = profilePicture
                        }
                    }
                }
            }
        }
    }
    @objc func selectPP(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    //seçildikten sonra ne olacağını yazmak için didFinishPickingMediaWithInfo func yazılıyor
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        ppImageView.image = info[.editedImage] as? UIImage
           self.dismiss(animated: true, completion: nil)

           if let data = ppImageView.image?.jpegData(compressionQuality: 0.5) {
               let firestoreDatabase = Firestore.firestore()
               var firestoreReference: DocumentReference? = nil
               var toUpdateDocumentId = ""

               if let currentUserUID = Auth.auth().currentUser?.uid {
                   let usersCollection = firestoreDatabase.collection("Users")

                   // Kullanıcının UID'si ile eşleşen dökümanı aramak için bir sorgu oluşturun
                   usersCollection.whereField("userId", isEqualTo: currentUserUID).getDocuments { (querySnapshot, error) in
                       if let error = error {
                           print("Sorgu hatası: \(error.localizedDescription)")
                       } else {
                           // Sorgu sonuçlarına göz atın
                           for document in querySnapshot!.documents {
                               print("Bulunan döküman ID: \(document.documentID)")
                               toUpdateDocumentId = document.documentID

                               // Döküman ID'sini aldıktan sonra Firestore işlemini yapabilirsiniz
                               let firestorePp = ["profilePicture": data.base64EncodedString()] as [String: Any]
                               firestoreDatabase.collection("Users").document(toUpdateDocumentId).setData(firestorePp, merge: true)
                           }
                       }
                   }
               }
           }
        }
    
    
}

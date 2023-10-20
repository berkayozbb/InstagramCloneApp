//
//  profileVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 4.10.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class profileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    var postImageArray = [String]()
    var common = Common()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! profileCollectionViewCell
        cell.postImageView.image = common.base64ToImage(base64String: self.postImageArray[indexPath.row])
        return cell
    }
    

    var username = Auth.auth().currentUser?.displayName
    
    @IBOutlet var profilePictureImageView: UIImageView!
    
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var bioLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePictureImageView.isUserInteractionEnabled = true
        //gestureRecognizer tanımlanıyor tap olduğunda hangi func çalışacak
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectPP))
        //imageView e atanıyor hazırlanan Recognizer
        profilePictureImageView.addGestureRecognizer(imageTapRecognizer)
        
        
        postCountLabel.text = String(self.postImageArray.count)
        //profil fotoğrafını daire çerçeveye aldım.
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        profilePictureImageView.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usernameLabel.text = username
        fetchBioData()
        fetchProfilePicture()
        fetchNameData()
        Task {
            await getDataFromFirestore()
        }
    }
    
    func getDataFromFirestore() async {
        let userId = Auth.auth().currentUser!.uid
        let firestoreDatabase = Firestore.firestore()
        
        do {
            let snapshot = try await firestoreDatabase.collection("Posts").order(by: "date", descending: true).getDocuments()
            
            if !snapshot.isEmpty {
                self.postImageArray.removeAll(keepingCapacity: false)
                
                for document in snapshot.documents {
                    if document.get("userId") as? String == userId{
                        if let imageBase = document.get("postBase") as? String {
                            self.postImageArray.append(imageBase)
                        }
                    }
                }
                
                
                // Verileri ekledikten sonra tabloyu güncelleyin
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        } catch {
            print("Hata: \(error.localizedDescription)")
        }
        postCountLabel.text = String(self.postImageArray.count)
    }
    
    func fetchBioData(){
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
                              self.nameLabel.text = bio // UILabel içine adı yazdır
                          }
                      }
                  }
              }
        postCountLabel.text = String(self.postImageArray.count)
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
                            self.profilePictureImageView.image = profilePicture
                        }
                    }
                }
            }
        }
        postCountLabel.text = String(self.postImageArray.count)
    }
    
  
    
    func fetchNameData(){
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
                        if let nameData = document.data()["name"] as? String{
                            // Profil resmini başarıyla çektik, şimdi ImageView'e yerleştirebiliriz
                            self.bioLabel.text = nameData
                        }
                    }
                }
            }
        }
        postCountLabel.text = String(self.postImageArray.count)
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
        
        
        profilePictureImageView.image = info[.editedImage] as? UIImage
           self.dismiss(animated: true, completion: nil)

           if let data = profilePictureImageView.image?.jpegData(compressionQuality: 0.5) {
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
    
    @IBAction func customizeButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "goToCustomize", sender: nil)
    }
    
    @IBAction func logOutButtonClicked(_ sender: Any) {
        do{
            try
            Auth.auth().signOut()
            self.performSegue(withIdentifier: "goToSignInVC", sender: nil)
        }catch{
            print("error")
        }
    }
   

}

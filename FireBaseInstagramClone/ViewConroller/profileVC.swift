//
//  profileVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 4.10.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class profileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var username = Auth.auth().currentUser?.displayName
    
    @IBOutlet var profilePictureImageView: UIImageView!
    
    @IBOutlet var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePictureImageView.isUserInteractionEnabled = true
        //gestureRecognizer tanımlanıyor tap olduğunda hangi func çalışacak
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectPP))
        //imageView e atanıyor hazırlanan Recognizer
        profilePictureImageView.addGestureRecognizer(imageTapRecognizer)
        
        usernameLabel.text = username

        //profil fotoğrafını daire çerçeveye aldım.
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        profilePictureImageView.clipsToBounds = true
        
        fetchProfilePicture()
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
    
    @IBAction func logOutButtonClicked(_ sender: Any) {
        do{
            try
            Auth.auth().signOut()
            self.performSegue(withIdentifier: "goToSignInVC", sender: nil)
        }catch{
            print("error")
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

}

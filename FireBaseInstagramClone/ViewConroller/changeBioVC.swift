//
//  changeBioVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 20.10.2023.
//

import UIKit
import Firebase

class changeBioVC: UIViewController {

    @IBOutlet var newBioTextField: UITextField!
    
    var userId = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func finishButtonClicked(_ sender: Any) {
        let db = Firestore.firestore()
        let usersCollectionRef = db.collection("Users")
           
           // Kullanıcı kimliği (userId) ile belgeleri sorgulayın
        usersCollectionRef.whereField("userId", isEqualTo: self.userId!).getDocuments { (querySnapshot, error) in
               if let error = error {
                   print("Belge sorgulama hatası: \(error.localizedDescription)")
               } else {
                   for document in querySnapshot!.documents {
                       let documentID = document.documentID
                       print("Current User's Document ID: \(documentID)")
                       
                       
                       
                       // Öncelikle güncellemek istediğiniz belgenin referansını alın
                       let userRef = db.collection("Users").document(documentID)
                       
                       // Güncelleme yapmadan önce bir veri sözlüğü oluşturun
                       let updatedData: [String: Any] = ["bio": self.newBioTextField.text!]
                       
                       // Belgeyi güncelleyin
                       userRef.updateData(updatedData) { error in
                           if let error = error {
                               print("Veri güncelleme hatası: \(error.localizedDescription)")
                           } else {
                               print("Veri güncelleme başarılı.")
                           }
                       }
                   }
               }
           }
    }
}

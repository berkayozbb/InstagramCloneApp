//
//  createPasswordVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 4.10.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class createPasswordVC: UIViewController {

    var email = ""
    var username = ""
    
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWelcomeInstagramVC" {
            
            if let destinationVC = segue.destination as? welcomeInstagramVC {
                destinationVC.username = username
            }
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        if passwordTextField.text != nil{
            Auth.auth().createUser(withEmail: email, password: passwordTextField.text!) { authdata, error in
                if error != nil{
                    self.makeAlert(titleInput: "HATA", messageInput: error?.localizedDescription ?? "ERROR")
                }else{    
                    
                    
                    let storage = Storage.storage()
                    let storageReferences = storage.reference()
                    //firebase storage içinde media klasörü oluştur.
                    let userFolder = storageReferences.child("Users")
                    
                    let userReference = userFolder.child(Auth.auth().currentUser!.uid)
                    
                    let firestoreDatabase = Firestore.firestore()
                    
                    var firestoreReference : DocumentReference? = nil
                    
                    let firestoreUser = ["userId" : Auth.auth().currentUser!.uid,"profilePicture" : "https://w7.pngwing.com/pngs/205/731/png-transparent-default-avatar-thumbnail.png"]
                    
                    firestoreReference = firestoreDatabase.collection("Users").addDocument(data: firestoreUser, completion: { error in
                        if error != nil{
                            self.makeAlert(titleInput: "HATA", messageInput: error?.localizedDescription ?? "ERROR")
                        }else{
                            print("okey")
                        }
                    })
                    
                    
                    // Kullanıcı oluşturuldu, şimdi "display name" ayarlamak için UserProfileChangeRequest kullanalım.
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.username
                    
                    changeRequest?.commitChanges { error in
                        if let error = error {
                            print("Görünen ad güncellenemedi: \(error.localizedDescription)")
                        } else {
                            print("Görünen ad başarıyla ayarlandı.")
                            // Yeni kullanıcı kaydı oluşturuldu ve görünen ad başarıyla ayarlandı.
                        }
                    }
                    self.performSegue(withIdentifier: "goToWelcomeInstagramVC", sender: nil)
                }
            }
        }else{
            makeAlert(titleInput: "HATA", messageInput: "Şifre boş bırakılamaz!")
        }
        
    }
    
    
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func hidePasswordButtonClicked(_ sender: Any) {
        passwordTextField.isSecureTextEntry.toggle()
    }
}

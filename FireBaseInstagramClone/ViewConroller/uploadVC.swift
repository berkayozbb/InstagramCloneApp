//
//  uploadVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 4.10.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var sharedImageView: UIImageView!
    
    @IBOutlet var commentTextField: UITextField!
    
    @IBOutlet var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isEnabled = false
        //imageview tıklanabilir yapılıyor
        sharedImageView.isUserInteractionEnabled = true
        //gestureRecognizer tanımlanıyor tap olduğunda hangi func çalışacak
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        //imageView e atanıyor hazırlanan Recognizer
        sharedImageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    //seçildikten sonra ne olacağını yazmak için didFinishPickingMediaWithInfo func yazılıyor
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        sharedImageView.image = info[.editedImage] as? UIImage
        shareButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func shareButtonClicked(_ sender: Any) {
        
        if let data = sharedImageView.image?.jpegData(compressionQuality: 0.5){
            let firestoreDatabase = Firestore.firestore()
            var firestoreReference : DocumentReference? = nil
            
            
            
            
            let firestorePost = ["userId" : Auth.auth().currentUser!.uid, "postedBy" : Auth.auth().currentUser!.displayName!, "postComment" : self.commentTextField.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0, "postBase": data.base64EncodedString()] as [String : Any]
            
            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
                if error != nil {
                    self.makeAlert(titleInput: "HATA", messageInput: error?.localizedDescription ?? "ERROR")
                }else{
                    self.sharedImageView.image = UIImage(named: "placeholder")
                    self.commentTextField.text = ""
                    self.tabBarController?.selectedIndex = 0
                    self.shareButton.isEnabled = false
                }
            })
            
            
            let documentId = firestoreReference?.documentID
            let userPosts = ["userId": Auth.auth().currentUser?.uid, "postId": documentId]
            firestoreReference = firestoreDatabase.collection("UserPosts").addDocument(data: userPosts as [String : Any], completion: { error in
                if error != nil {
                    self.makeAlert(titleInput: "HATA", messageInput: error?.localizedDescription ?? "ERROR")
                }
            })
            
            let userLikedPosts = ["userId": "", "postId": documentId]
            firestoreReference = firestoreDatabase.collection("UserLikedPost").addDocument(data: userLikedPosts as [String : Any], completion: { error in
                if error != nil {
                    self.makeAlert(titleInput: "HATA", messageInput: error?.localizedDescription ?? "ERROR")
                }
            })
            
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    

}

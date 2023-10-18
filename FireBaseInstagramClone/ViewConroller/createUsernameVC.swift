//
//  createUsernameVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 4.10.2023.
//

import UIKit
import Firebase

class createUsernameVC: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //email verisini şifre belirleme ekranına gönderiyorum ki şifre belirlendikten sonra bu iki veriyi kullanarak kullanıcı oluşturayım.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreatePasswordVC" {
            
            if let destinationVC = segue.destination as? createPasswordVC {
                destinationVC.email = emailTextField.text!
                destinationVC.username = usernameTextField.text!
            }
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        //kullanıcı adı kısmı boş bırakılamaz kontrolü.
        if usernameTextField.text != "" && emailTextField.text != nil{//Bu kullanıcı adı alınmış mı diye kontrol et.
                    self.performSegue(withIdentifier: "goToCreatePasswordVC", sender: nil)
                }
        else{
            makeAlert(titleInput: "HATA", messageInput: "Kullanıcı adı veya E-posta adresi boş bırakılamaz!")
        }
        
    }
    
    
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

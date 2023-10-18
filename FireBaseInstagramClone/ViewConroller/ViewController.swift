//
//  ViewController.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 2.10.2023.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //aktif kullanıcı çıkış yapmadıysa doğrudan anasayfaya yönlendirmeyi scene delegate yerine burada yapıyorum çünkü çıkış yap butonum unwind segue olduğu için öncesinde bir segueyle oraya ulaşmam lazım çıkış yapmak için. scene delegate üzerinden window root u değiştirebilirdim yoksa.
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            self.performSegue(withIdentifier: "successLoginGoHomePageVC", sender: nil)
        }
        
    }
    
    @IBAction func singInButtonClicked(_ sender: Any) {
        if emailTextField.text != nil && passwordTextField.text != nil{
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authdata, error in
                if error != nil{
                    self.makeAlert(titleInput: "HATA", messageInput: error?.localizedDescription ?? "ERROR")
                }else{
                    self.performSegue(withIdentifier: "successLoginGoHomePageVC", sender: nil)
                }
            }
        }else{
            makeAlert(titleInput: "HATA", messageInput: "Kullanıcı adı veya E-posta adresi boş bırakılamaz!")
        }
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    //şifreyi göster gizle func text field içindeki image a dokunulduğunda tetikleniyor.
    @IBAction func hidePasswordButtonClicked(_ sender: Any) {
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
            self.performSegue(withIdentifier: "goToCreateUsernameVC", sender: nil)
    }
    
    //uyarı mesajı vermek istediğimde bu alert i kullanacağım için hazır func oluşturdum.
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //unwind segue oluşturarak geri dönüş seguesinin kontrolünü ve o ana kadar gerçekleşen seguelerin iptalini sağladım.
    @IBAction func goToSignInVC(_ unwindSegue: UIStoryboardSegue) {
        _ = unwindSegue.source
    }
    
    
    
}


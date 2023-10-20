//
//  changeUsernameVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 20.10.2023.
//

import UIKit
import Firebase

class changeUsernameVC: UIViewController {

    @IBOutlet var newUsernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func finishButtonClicked(_ sender: Any) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = self.newUsernameTextField.text
        changeRequest?.commitChanges { error in
            if let error = error {
                print("Görünen ad güncellenemedi: \(error.localizedDescription)")
            } else {
                print("Görünen ad başarıyla ayarlandı.")
                // Yeni kullanıcı kaydı oluşturuldu ve görünen ad başarıyla ayarlandı.
            }
        }
    }
}

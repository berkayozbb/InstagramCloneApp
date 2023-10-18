//
//  welcomeInstagramVC.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 4.10.2023.
//

import UIKit

class welcomeInstagramVC: UIViewController {

    var username = ""
    
    @IBOutlet var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLabel.text = username
    }
        
    @IBAction func completeRegisterButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "successRegisterGoHomePageVC", sender: nil)
    }
    
}

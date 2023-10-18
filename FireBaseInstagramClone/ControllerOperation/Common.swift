//
//  Common.swift
//  FireBaseInstagramClone
//
//  Created by Berkay Özbaba on 18.10.2023.
//

import Foundation
import UIKit

class Common {
    func base64ToImage(base64String: String) -> UIImage? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
}

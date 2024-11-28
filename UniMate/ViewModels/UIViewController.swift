//
//  UIApplication.swift
//  UniMate
//
//  Created by Sheky Cheung on 26/11/2024.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

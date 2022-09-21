//
//  UITextField+Eye.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/21/22.
//

import Foundation
import UIKit

extension UITextField {
    private func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry){
            button.setImage(UIImage(systemName: "eye"), for: .normal)
        }else{
            button.setImage(UIImage(systemName: "eye.slash"), for: .normal)

        }
    }

    func enablePasswordToggle(){
        let configuration = UIButton.Configuration.borderless()
        let button = UIButton(configuration: configuration)
        setPasswordToggleImage(button)
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}

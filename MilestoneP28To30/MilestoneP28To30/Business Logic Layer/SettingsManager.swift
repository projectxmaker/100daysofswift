//
//  SettingsManager.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/21/22.
//

import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    
    var biometricState: Bool {
        get {
            UserDefaults.standard.bool(forKey: SettingsManager.Keys.biometricSettingKey)
        }
        
        set (newValue)  {
            UserDefaults.standard.set(newValue, forKey: SettingsManager.Keys.biometricSettingKey)
        }
    }
    
    var passcodeState: Bool {
        get {
            UserDefaults.standard.bool(forKey: SettingsManager.Keys.passcodeStateSettingKey)
        }
        
        set (newValue)  {
            var allowToSave = false
            if newValue == false {
                passcode = nil
                allowToSave = true
            } else {
                guard let passcode = passcode else { return }
                if !passcode.isEmpty {
                    allowToSave = true
                }
            }
            
            if allowToSave {
                UserDefaults.standard.set(newValue, forKey: SettingsManager.Keys.passcodeStateSettingKey)
            }
        }
    }
    
    var passcode: String?  {
        get {
            UserDefaults.standard.string(forKey: SettingsManager.Keys.passcodeSettingKey) ?? ""
        }
        
        set (newValue)  {
            UserDefaults.standard.set(newValue, forKey: SettingsManager.Keys.passcodeSettingKey)
        }
    }
}

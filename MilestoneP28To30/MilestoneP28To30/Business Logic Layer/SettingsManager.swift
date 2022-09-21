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
            UserDefaults.standard.set(newValue, forKey: SettingsManager.Keys.passcodeStateSettingKey)
        }
    }
    
    var passcode: String  {
        get {
            UserDefaults.standard.string(forKey: SettingsManager.Keys.passcodeSettingKey) ?? ""
        }
        
        set (newValue)  {
            if !passcode.isEmpty {
                UserDefaults.standard.set(newValue, forKey: SettingsManager.Keys.passcodeSettingKey)
            }
        }
    }
}

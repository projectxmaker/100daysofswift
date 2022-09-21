//
//  AppEngine.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/21/22.
//

import Foundation

struct AppEngine {
    var settings = Settings()
}

// MARK: - Settings
struct Settings {
    private var settings = SettingsManager.shared
    
    var biometricState: Bool {
        get {
            settings.biometricState
        }
        
        set (newValue)  {
            settings.biometricState = newValue
        }
    }
    
    var passcodeState: Bool {
        get {
            settings.passcodeState
        }
        
        set (newValue)  {
            settings.passcodeState = newValue
        }
    }
    
    var passcode: String  {
        get {
            settings.passcode
        }
        
        set (newValue)  {
            settings.passcode = newValue
        }
    }
}

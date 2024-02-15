//
//  KeychainManager.swift
//  Movies
//
//  Created by Yura Sabadin on 07.02.2024.
//

import Foundation
import AuthenticationServices

final class KeychainManager {
    
    static let shared = KeychainManager()
    
    private init () {}
    
    func save(password toSave: String, service: String = TitleConstants.service, account: String) {
        
        guard let data = toSave.data(using: .utf8) else {return}
        
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
            
        let saveStatus = SecItemAdd(query, nil)
     
        if saveStatus != errSecSuccess {
            print("Error: \(saveStatus)")
        }
        
        if saveStatus == errSecDuplicateItem {
            update(data, service: service, account: account)
        }
    }
    
    func update(_ data: Data, service: String = TitleConstants.service, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
            
        let updatedData = [kSecValueData: data] as CFDictionary
        SecItemUpdate(query, updatedData)
    }
    
    func read(service: String = TitleConstants.service, account: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let resultData = result as? Data else {return nil}
        
        return String(data: resultData, encoding: .utf8)
    }
    
    func delete(service: String = TitleConstants.service, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
            
        SecItemDelete(query)
    }
}

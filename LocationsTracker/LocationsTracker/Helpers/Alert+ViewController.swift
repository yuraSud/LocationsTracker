//
//  Alert+ViewController.swift
//  Movies
//
//  Created by Olga Sabadina on 06.01.2024.
//

import UIKit

extension UIViewController {
   
    func presentAlert(with title: String, message: String?, buttonTitles options: String...,styleActionArray: [UIAlertAction.Style?], alertStyle: UIAlertController.Style, completion: ((Int) -> Void)?) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
            
            for (index, option) in options.enumerated() {
                alertController.addAction(UIAlertAction.init(title: option, style: styleActionArray[index] ?? .default, handler: { (action) in
                    completion?(index)
                }))
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func alertError(_ error: Error?) {
        presentAlert(with: "Error", message: error?.localizedDescription.description ?? "Unknow", buttonTitles: "Ok", styleActionArray: [.cancel], alertStyle: .alert, completion: nil)
    }
    
    func alertErrorString(_ error: String?) {
        presentAlert(with: "Error", message: error, buttonTitles: "Ok", styleActionArray: [.cancel], alertStyle: .alert, completion: nil)
    }
}

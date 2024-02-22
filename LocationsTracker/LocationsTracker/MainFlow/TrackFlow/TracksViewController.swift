//
//  TracksViewController.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 22.02.2024.
//

import UIKit

class TracksViewController: UIViewController {
    
    lazy var tracksTable = UITableView(frame: view.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()
        title = "Users Tracks"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configureTable() {
        
    }
}

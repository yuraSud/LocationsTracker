//
//  TracksViewController.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 22.02.2024.
//
import Combine
import UIKit

class TracksViewController: UIViewController {
    
    lazy var tracksTable = UITableView(frame: view.bounds, style: .insetGrouped)
    private var cancellable = Set<AnyCancellable>()
    private let vm = TrackViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()
        sinkToProperties()
        title = vm.userProfile?.login
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func sinkToProperties() {
        vm.$tracksData
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tracksTable.reloadData()
        }
            .store(in: &cancellable)
    }
    
    private func configureTable() {
        view.addSubview(tracksTable)
        tracksTable.delegate = self
        tracksTable.dataSource = self
        tracksTable.register(TrackCell.self, forCellReuseIdentifier: TrackCell.cellID)
    }
}

extension TracksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        vm.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.cellID, for: indexPath) as? TrackCell else { return UITableViewCell() }
    
        cell.model = vm.tracksData[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        vm.titleForHeader(in: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? TrackCell,
              let model = cell.model else {return}
        let mapVC = PathViewController(model)
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let cell = tableView.cellForRow(at: indexPath) as? TrackCell else { return }
            guard let model = cell.model else { return }
            vm.deleteTrack(track: model)
        }
    }
    
}

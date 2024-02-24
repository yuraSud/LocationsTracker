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
    private var dateSearchButton = UIButton(type: .system)
    private var resetDateButton = UIButton(type: .system)
    private var datePicker = UIDatePicker()
    private var datePickerView = UIView()
    private var cancellable = Set<AnyCancellable>()
    private let vm = TrackViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()
        sinkToProperties()
        setDateSearchButton()
        setDatePicker()
        configureResetButton()
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
        
        vm.$filterDate.sink { [weak self] date in
            if date == nil {
                self?.resetDateButton.isHidden = true
            } else {
                self?.resetDateButton.isHidden = false
            }
        }
        .store(in: &cancellable)
    }
    
    private func configureTable() {
        view.addSubview(tracksTable)
        tracksTable.delegate = self
        tracksTable.dataSource = self
        tracksTable.register(TrackCell.self, forCellReuseIdentifier: TrackCell.cellID)
    }
    
    private func setDateSearchButton() {
        
        let openDatePicker = UIAction { [weak self] _ in
            guard let self else { return }
            datePickerView.isHidden.toggle()
        }
        dateSearchButton.setBackgroundImage(ImageConstants.calendar, for: .normal)
        dateSearchButton.tintColor = .black
        dateSearchButton.addAction(openDatePicker, for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateSearchButton)
    }
    
    private func setDatePicker() {
        let selectDate = UIAction { [weak self] _ in
            guard let self else { return }
            vm.filterDate = datePicker.date
            datePickerView.isHidden = true
        }
        
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "en")
        datePicker.addAction(selectDate, for: .valueChanged)
        datePickerView.frame = .init(x: 20, y: 100, width: view.bounds.width - 40, height: view.bounds.height * 0.4)
        datePicker.frame = datePickerView.bounds
        configurePickerView(datePickerView)
        datePickerView.addSubview(datePicker)
        view.addSubview(datePickerView)
    }
    
    private func configurePickerView(_ self: UIView) {
        self.isHidden = true
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        self.backgroundColor = .white
        self.layer.borderWidth = 0.6
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.setShadow(colorShadow: .gray, offset: .zero, opacity: 0.6, radius: 8, cornerRadius: 15)
    }
    
    private func configureResetButton() {
        let resetDate = UIAction { [weak self] _ in
            guard let self else { return }
            vm.filterDate = nil
        }
        resetDateButton.setTitle("Reset date", for: .normal)
        resetDateButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        resetDateButton.tintColor = .white
        resetDateButton.backgroundColor = .red
        resetDateButton.addAction(resetDate, for: .touchUpInside)
        resetDateButton.frame = .init(x: view.bounds.midX - 80, y: view.bounds.maxY - 100, width: 160, height: 44)
        resetDateButton.isHidden = true
        resetDateButton.layer.cornerRadius = 22
        view.addSubview(resetDateButton)
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
            vm.deleteTrack(track: model, indexPath: indexPath)
        }
    }
}

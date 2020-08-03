//
//  MainViewController.swift
//  PunkeBeerApp
//
//  Created by Marc Gallardo on 03/08/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit
import SDWebImage

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    
    var viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewMain.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "maintableviewcell")
        configureView()
        bind()
    }
    
    private func configureView() {
        viewModel.retriveDataList()
    }
    
    private func bind() {
        viewModel.refreshData = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableViewMain.reloadData()
            }
        }
        
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewMain.dequeueReusableCell(withIdentifier: "maintableviewcell") as! MainTableViewCell
        
        let object = viewModel.dataArray[indexPath.row]
        
        cell.lblNameBeer.text = object.name
        cell.lblTagLine.text = object.tagline
        cell.lblDescription.text = object.description
        cell.lblAbv.text = String(object.abv)
        cell.imgBeer.sd_setImage(with: URL(string: object.image_url), placeholderImage: nil)
        
        return cell
    }
    
    
    
}

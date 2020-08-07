//
//  MainViewController.swift
//  PunkeBeerApp
//
//  Created by Marc Gallardo on 03/08/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit
import SDWebImage
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var btn_Filter: UIButton!
    @IBOutlet weak var srchBar_Food: UISearchBar!
    
    
    var viewModel = MainViewModel()
    var countPage = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewMain.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "maintableviewcell")
        connection()
        configureView()
        bind()
    }
    
    private func configureView() {
        viewModel.dataArray = viewModel.loadBeers()
        if viewModel.dataArray.count == 0 {
            viewModel.retriveDataList { (beers, error) in
                self.viewModel.dataArray = beers
                self.bind()
            }
        } 
        tableViewMain.keyboardDismissMode = .onDrag
        srchBar_Food.searchTextField.clearButtonMode = .never
    }
    
    private func bind() {
        viewModel.refreshData = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableViewMain.reloadData()
            }
        }
        
    }
    
    
    @IBAction func sortBeers(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose option for sort Beers", preferredStyle: .actionSheet)
    
        let deleteAction = UIAlertAction(title: "Sort Increase ABV", style: .default) { action -> Void in
            self.viewModel.sortedElements(option: 1)
            self.btn_Filter.setImage(UIImage(named: "img_filter_enabled"), for: .normal)
            self.bind()
        }
        let saveAction = UIAlertAction(title: "Sort Decrease ABV", style: .default) { action -> Void in
            self.viewModel.sortedElements(option: 2)
            self.btn_Filter.setImage(UIImage(named: "img_filter_enabled"), for: .normal)
            self.bind()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.viewModel.sortedElements(option: 3)
            self.btn_Filter.setImage(UIImage(named: "img_filter_disabled"), for: .normal)
            self.bind()
        }
              
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
              
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.sortDataArray.count == 0 {
            return viewModel.dataArray.count
        } else {
            return viewModel.sortDataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewMain.dequeueReusableCell(withIdentifier: "maintableviewcell") as! MainTableViewCell
        var object : Beer
        
        if viewModel.sortDataArray.count != 0 {
                   object = viewModel.sortDataArray[indexPath.row]
        } else {
                   object = viewModel.dataArray[indexPath.row]
        }
        cell.lblNameBeer.text = object.name
        cell.lblTagLine.text = object.tagline
        cell.lblDescription.text = object.description
        cell.lblAbv.text = String(object.abv)
        cell.imgBeer.sd_setImage(with: URL(string: object.image_url), placeholderImage: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.dataArray.count - 1 {
            viewModel.countPage = viewModel.loadCountPage()
            if viewModel.countPage > viewModel.countPageInit {
                viewModel.retriveNextDataList(pageIndex: String(viewModel.countPage)) { (beers, errors) in
                    self.viewModel.dataArray.append(contentsOf: beers)
                    self.bind()
                }
                viewModel.countPage += 1
                viewModel.saveCountpage(countpage: viewModel.countPage)
                print(viewModel.countPage)
                print(viewModel.countPageInit)
            } else {
                 viewModel.retriveNextDataList(pageIndex: String(viewModel.countPageInit)) { (beers, errors) in
                                   self.viewModel.dataArray.append(contentsOf: beers)
                    self.bind()
                }
                viewModel.countPage = Int16(viewModel.countPageInit)
                viewModel.countPage += 1
                viewModel.saveCountpage(countpage: viewModel.countPage)
                print("Pasadoooooooooooo",viewModel.countPage)
                print(viewModel.countPageInit)
            }
            bind()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            viewModel.restartSearch()
            return
        }
        viewModel.searchByFood(searchTextFood: searchText)
        bind()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.restartSearch()
        srchBar_Food.searchTextField.text = ""
        srchBar_Food.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        viewModel.searchByFood(searchTextFood: text)

        if viewModel.sortDataArray.count == 0 {
            DispatchQueue.main.async {
                self.viewModel.getFoodNetwork(searchFood: text)
            }
        }
        bind()
        srchBar_Food.resignFirstResponder()
    }

    func connection() {
          let delegate = UIApplication.shared.delegate as! AppDelegate
          viewModel.context = delegate.persistentContainer.viewContext
      }
}

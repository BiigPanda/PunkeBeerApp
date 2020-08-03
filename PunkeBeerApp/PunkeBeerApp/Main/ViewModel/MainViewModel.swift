//
//  MainViewModel.swift
//  PunkeBeerApp
//
//  Created by Marc Gallardo on 03/08/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation

class MainViewModel {
    
    var refreshData = { () -> () in}
    
    var dataArray: [Beer] = [] {
        didSet{
            refreshData()
        }
    }
    
    func retriveDataList() {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers/random") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let json = data else { return }
            
            do {
                let decorder = JSONDecoder()
                self.dataArray = try decorder.decode([Beer].self, from: json)
            } catch let error {
                print("Ha ocurrido un error : \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
}

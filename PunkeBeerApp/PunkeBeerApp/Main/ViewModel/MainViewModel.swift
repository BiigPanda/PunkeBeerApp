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
    
    var sortDataArray: [Beer] = [] {
           didSet{
               refreshData()
           }
       }
    
    func retriveDataList() {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=1") else { return }
        
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
    
    func retriveNextDataList(pageIndex: String) {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(pageIndex)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let json = data else { return }
            
            do {
                let decorder = JSONDecoder()
                self.dataArray.append(contentsOf: try decorder.decode([Beer].self, from: json))
            } catch let error {
                print("Ha ocurrido un error : \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func sortedElements (option: Int) {
        switch option {
            case 1:
                self.sortDataArray =  self.dataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv > BeerB.abv
            }
            case 2:
                self.sortDataArray = self.dataArray.sorted { (BeerA, BeerB) -> Bool in
                        return BeerA.abv < BeerB.abv
            }
            case 3:
                self.sortDataArray.removeAll()
            default:
                break
        }
    }
    
    func searchByFood(searchTextFood: String) {
        
        guard !searchTextFood.isEmpty else {
            restartSearch()
            return
        }
        //Caramel toffee cake
        
        let strings = ["Caramel toffee cake", "PEPE"]
        strings.filter { (string) -> Bool in
            return strings.contains(string)
        }
        
        if strings.contains(where: { $0 == "Caramel" }){
            print("yessssss")
        }else {
            print("nooooooooo")
        }
        
        
        let filteredStrings = strings.filter({(item: String) -> Bool in

            let stringMatch = item.lowercased().range(of: searchTextFood.lowercased())
           // print(stringMatch != nil ? true : false)
             return stringMatch != nil ? true : false
        })
        
        print(filteredStrings)
        
        
        sortDataArray = dataArray.filter({ (Beer) -> Bool in
            var check: Bool = false
            for beerfood in Beer.food_pairing {
                // string match fuera para hacer un return
                let stringMatch = beerfood.lowercased().range(of: searchTextFood.lowercased())
                check = stringMatch != nil ? true : false
            }
            // si el check es falso hacer la petición url con el hud incorporado
            return check
        })
    }
    
    func restartSearch() {
        self.sortDataArray.removeAll()
    }
    
    
    
    
}

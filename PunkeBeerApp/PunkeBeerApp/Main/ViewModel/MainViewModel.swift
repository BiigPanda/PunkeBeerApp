//
//  MainViewModel.swift
//  PunkeBeerApp
//
//  Created by Marc Gallardo on 03/08/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation
import CoreData
import UIKit


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
    
     func connection() -> NSManagedObjectContext {
         let delegate = UIApplication.shared.delegate as! AppDelegate
         return delegate.persistentContainer.viewContext
     }
    
    func retriveDataList() {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=1") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let json = data else { return }
            
            do {
                let decorder = JSONDecoder()
                self.dataArray = try decorder.decode([Beer].self, from: json)
                for beer in self.dataArray {
                    self.saveCoreData(objectBeer: beer)
                }
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
    
    func getFoodNetwork(searchFood: String) {
        self.sortDataArray.removeAll()
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?food=\(searchFood)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let json = data else { return }
            do {
                let decorder = JSONDecoder()
                self.sortDataArray.append(contentsOf: try decorder.decode([Beer].self, from: json))
            } catch let error {
                print("Ha ocurrido un error : \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func sortedElements (option: Int) {
        switch option {
        case 1:
            if self.sortDataArray.count > 0 {
                self.sortDataArray =  self.sortDataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv > BeerB.abv
                }
            }else {
                self.dataArray =  self.dataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv > BeerB.abv
                }
            }
        case 2:
            if self.sortDataArray.count > 0 {
                self.sortDataArray =  self.sortDataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv < BeerB.abv
                }
            }else {
                self.dataArray =  self.dataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv < BeerB.abv
                }
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
        
        sortDataArray = dataArray.filter({ (Beer) -> Bool in
            var check: Bool = false
            for beerfood in Beer.food_pairing {
                let stringMatch = beerfood.lowercased().range(of: searchTextFood.lowercased())
                check = stringMatch != nil ? true : false
                if check == true {
                    return check
                }
            }
            return check
        })
    }
    
    func restartSearch() {
        self.sortDataArray.removeAll()
    }
 
    
    func saveCoreData(objectBeer: Beer) {
        let context = connection()
        guard let beerEntity = NSEntityDescription.entity(forEntityName: "BeerCoreData", in: context) else {
            return
        }
        let beerTask = NSManagedObject(entity: beerEntity, insertInto: context)
        beerTask.setValue(objectBeer.id, forKey: "id")
        beerTask.setValue(objectBeer.name, forKey: "name")
        beerTask.setValue(objectBeer.tagline, forKey: "tagline")
        beerTask.setValue(objectBeer.description, forKey: "descriptionBeer")
        beerTask.setValue(objectBeer.image_url, forKey: "image_url")
        beerTask.setValue(objectBeer.abv, forKey: "abv")
        beerTask.setValue(objectBeer.food_pairing, forKey: "food_pairing")
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error al guardar", error.localizedDescription)
        }
    }
    
    func loadBeers() -> [Beer] {
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          let managedContext = appDelegate.persistentContainer.viewContext
          var arrayBeerC : [BeerFromCoredata] = []
          var emptyBeerC: BeerFromCoredata = BeerFromCoredata()
        
        var beer: Beer = Beer()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BeerCoreData")

          do {
            let records = try managedContext.fetch(fetchRequest)
           
             if let records = records as? [NSManagedObject]{
                 for record in records {
                     emptyBeerC.id = record.value(forKey: "id") as? Int16
                     emptyBeerC.name = record.value(forKey: "name") as? String ?? ""
                     emptyBeerC.tagline = record.value(forKey: "tagline") as? String ?? ""
                     emptyBeerC.description = record.value(forKey: "descriptionBeer") as? String
                     emptyBeerC.image_url = record.value(forKey: "image_url") as? String ?? ""
                     emptyBeerC.abv = record.value(forKey: "abv") as? Double
                     emptyBeerC.food_pairing = record.value(forKey: "food_pairing") as! [String]
                     arrayBeerC.append(emptyBeerC)
                     emptyBeerC = BeerFromCoredata()
                 }
                
                for beerC in arrayBeerC {
                    
                    beer.id = beerC.id ?? 0
                    beer.name = beerC.name
                    beer.tagline = beerC.tagline ?? ""
                    beer.description = beerC.description ?? ""
                    beer.image_url = beerC.image_url
                    beer.abv = beerC.abv ?? 0.0
                    beer.food_pairing = beerC.food_pairing
                    dataArray.append(beer)
                    beer = Beer()
                }
                print(dataArray.count)
                return dataArray
             }
         } catch let error as NSError {
            print("No ha sido posible cargar \(error), \(error.userInfo)")
             return []
         }
         // 4
         return []
        
    }
    
    
    
    
}

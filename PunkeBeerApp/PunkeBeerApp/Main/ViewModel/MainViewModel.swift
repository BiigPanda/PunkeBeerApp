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
import Alamofire
import SwiftyJSON


class MainViewModel {
    
    var refreshData = { () -> () in}
    
    var dataArray: [Beer] = [] {
        didSet{
            refreshData()
        }
    }
    
    var filterDataArray: [Beer] = [] {
        didSet{
            refreshData()
        }
    }
    var context: NSManagedObjectContext?
    var countPage: Int16 = 0
    var countPageInit: Int = 2
    
    func retriveDataList(completionHandler: @escaping (_ result: [Beer], _ error: Error?) -> Void) {
        var beers : [Beer] = []
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=1") else { return }
        AF.request(url).responseJSON { (response) in
            switch response.result {
            case .success(_):
                guard let result = response.value as? [Any] else{
                    assertionFailure()
                    return
                }
                let json = JSON(result)
                beers =  self.parsedBeer(json: json)
                completionHandler(beers,nil)
                break
            case .failure(let error):
                completionHandler(beers,error)
                break
            }
            
        }
        
    }
    
    func retriveNextDataList(pageIndex: String, completionHandler: @escaping (_ result: [Beer], _ error: Error?) -> Void)  {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(pageIndex)") else { return }
        var beers : [Beer] = []
        AF.request(url).responseJSON { (response) in
            switch response.result {
            case .success(_):
                guard let result = response.value as? [Any] else{
                    assertionFailure()
                    return
                }
                let json = JSON(result)
                beers =  self.parsedBeer(json: json)
                completionHandler(beers,nil)
                break
            case .failure(let error):
                completionHandler(beers,error)
                break
            }
            
        }
    }
    
    func getFoodNetwork(searchFood: String, completionHandler: @escaping (_ result: [Beer], _ error: Error?) -> Void) {
        let searchFoodUnderline = searchFood.replacingOccurrences(of: " ", with: "_")
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?food=\(searchFoodUnderline)") else { return }
        
        var beers : [Beer] = []
        AF.request(url).responseJSON { (response) in
            switch response.result {
            case .success(_):
                guard let result = response.value as? [Any] else{
                    assertionFailure()
                    return
                }
                let json = JSON(result)
                beers =  self.parsedBeer(json: json)
                completionHandler(beers,nil)
                break
            case .failure(let error):
                completionHandler(beers,error)
                break
            }
        }
    }
  
    func searchByFood(searchTextFood: String) {
        guard !searchTextFood.isEmpty else {
            restartSearch()
            return
        }
        
        filterDataArray = dataArray.filter({ (Beer) -> Bool in
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
        self.filterDataArray.removeAll()
    }
    
    func sortedElements (option: Int) {
        switch option {
        case 1:
            if self.filterDataArray.count > 0 {
                self.filterDataArray =  self.filterDataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv > BeerB.abv
                }
            }else {
                self.filterDataArray =  self.dataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv > BeerB.abv
                }
            }
        case 2:
            if self.filterDataArray.count > 0 {
                self.filterDataArray =  self.filterDataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv < BeerB.abv
                }
            }else {
                self.filterDataArray =  self.dataArray.sorted { (BeerA, BeerB) -> Bool in
                    return BeerA.abv < BeerB.abv
                }
            }
        case 3:
            self.filterDataArray.removeAll()
        default:
            break
        }
    }
    
    func saveCoreData(objectBeer: Beer) {
        if !isEntityAttributeExist(id: Int(objectBeer.id), entityName: "BeerCoreData") {
            guard let beerEntity = NSEntityDescription.entity(forEntityName: "BeerCoreData", in: self.context!) else {
                return
            }
            let beerTask = NSManagedObject(entity: beerEntity, insertInto: self.context!)
            beerTask.setValue(objectBeer.id, forKey: "id")
            beerTask.setValue(objectBeer.name, forKey: "name")
            beerTask.setValue(objectBeer.tagline, forKey: "tagline")
            beerTask.setValue(objectBeer.description, forKey: "descriptionBeer")
            beerTask.setValue(objectBeer.image_url, forKey: "image_url")
            beerTask.setValue(objectBeer.abv, forKey: "abv")
            beerTask.setValue(objectBeer.food_pairing, forKey: "food_pairing")
            
            do {
                try self.context!.save()
            } catch let error as NSError {
                print("Error al guardar", error.localizedDescription)
            }
        }
    }
    
    
    func isEntityAttributeExist(id: Int, entityName: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %i", id)
        
        let res = try! managedContext.fetch(fetchRequest)
        return res.count > 0 ? true : false
    }
    
    func  saveCountpage(countpage: Int16)  {
        guard let utilsEntity = NSEntityDescription.entity(forEntityName: "Utils", in: self.context!) else {
            return
        }
        let utilsTask = NSManagedObject(entity: utilsEntity, insertInto: self.context!)
        utilsTask.setValue(countpage, forKey: "countPage")
        
        do {
            try self.context!.save()
        } catch let error as NSError {
            print("Error al guardar", error.localizedDescription)
        }
        
    }
    
    func  loadCountPage() -> Int16  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Utils")
        
        do {
            let records = try managedContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject]{
                for record in records {
                    self.countPage = record.value(forKey: "countPage") as? Int16 ?? 0
                }
                
                return self.countPage
            }
        } catch let error as NSError {
            print("No ha sido posible cargar \(error), \(error.userInfo)")
            return 0
        }
        return 0
    }
    
    func loadBeers() -> [Beer] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        var arrayBeerC : [Beer] = []
        var emptyBeerC: Beer = Beer()
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BeerCoreData")
        
        do {
            let records = try managedContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject]{
                for record in records {
                    emptyBeerC.id = (record.value(forKey: "id") as? Int16)!
                    emptyBeerC.name = record.value(forKey: "name") as? String ?? ""
                    emptyBeerC.tagline = record.value(forKey: "tagline") as? String ?? ""
                    emptyBeerC.description = (record.value(forKey: "descriptionBeer") as? String)!
                    emptyBeerC.image_url = record.value(forKey: "image_url") as? String ?? ""
                    emptyBeerC.abv = (record.value(forKey: "abv") as? Double)!
                    emptyBeerC.food_pairing = record.value(forKey: "food_pairing") as! [String]
                    arrayBeerC.append(emptyBeerC)
                    emptyBeerC = Beer()
                }
                
                return arrayBeerC
            }
        } catch let error as NSError {
            print("No ha sido posible cargar \(error), \(error.userInfo)")
            return []
        }
        return []
        
    }
    
    func parsedBeer(json: JSON) -> [Beer] {
        var beer = Beer()
        var beers : [Beer] = []
        for (_,subJson):(String, JSON) in json {
            beer.id = Int16(subJson["id"].intValue)
            beer.name = subJson["name"].stringValue
            beer.tagline = subJson["tagline"].stringValue
            beer.description = subJson["description"].stringValue
            beer.image_url = subJson["image_url"].stringValue
            beer.abv = subJson["abv"].doubleValue
            for (_,food) in subJson["food_pairing"] {
                beer.food_pairing.append(food.string!)
            }
            saveCoreData(objectBeer: beer)
            beers.append(beer)
            beer = Beer()
        }
        return beers
        
    }
    
}

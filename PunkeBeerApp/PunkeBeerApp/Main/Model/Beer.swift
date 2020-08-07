//
//  Beer.swift
//  PunkeBeerApp
//
//  Created by Marc Gallardo on 03/08/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation

class Beer: Codable {
    var id: Int16 = 0
    var name: String = ""
    var tagline: String = ""
    var description: String = ""
    var image_url: String = ""
    var abv: Double = 0.0
    var food_pairing: [String] = []
}






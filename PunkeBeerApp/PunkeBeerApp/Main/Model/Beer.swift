//
//  Beer.swift
//  PunkeBeerApp
//
//  Created by Marc Gallardo on 03/08/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation

struct Beer: Codable {
    let id: Int
    let name: String
    let tagline: String
    let description: String
    let image_url: String
    let abv: Double
    let food_pairing: [String]
}

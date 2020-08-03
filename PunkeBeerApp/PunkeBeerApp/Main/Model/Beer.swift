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
    let first_brewed: String
    let description: String
    let image_url: String
    let abv: Double
    let ibu: Double
    let target_fg: Double
    let target_og: Double
    let ebc: Double
    let srm: Double
    let ph: Double
    let attenuation_level: Double
    let volume: [String: String]
    let boil_volume : [String: String]
}

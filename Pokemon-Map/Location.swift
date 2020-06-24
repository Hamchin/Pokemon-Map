//
//  Location.swift
//  Pokemon-Map
//
//  Created by Kenta Terada on 2020/06/24.
//  Copyright © 2020 Kenta Terada. All rights reserved.
//

struct Location: Codable {
    var location: String
    var realLocation: String
    var address: String
    var latitude: Float
    var longitude: Float
}

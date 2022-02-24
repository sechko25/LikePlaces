//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by secha on 16.11.21.
//

import UIKit

struct Place{
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    
    static let restaurantName = ["Nevinniy", "Rose", "Cheer Bear", "Office"]
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        
        for place in restaurantName {
            places.append(Place(name: place, location: "Minsk", type: "Bar", image: nil, restaurantImage: place))
        }
        
        return places
    }
}

//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by secha on 16.11.21.
//
import RealmSwift
      
class Place: Object {
    
    @objc dynamic var name = " "
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
  
}

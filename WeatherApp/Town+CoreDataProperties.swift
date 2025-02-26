//
//  Town+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Stra1 T on 29.01.25.
//
//

import Foundation
import CoreData


extension Town {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Town> {
        return NSFetchRequest<Town>(entityName: "Town")
    }

    @NSManaged public var name: String?
    @NSManaged public var collor: String?

}

extension Town : Identifiable {

}

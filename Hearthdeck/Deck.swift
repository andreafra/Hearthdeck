//
//  Deck.swift
//  
//
//  Created by Andrea Franchini on 10/05/15.
//
//

import Foundation
import CoreData

class Deck: NSManagedObject {

    @NSManaged var desc: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var cards: String

}

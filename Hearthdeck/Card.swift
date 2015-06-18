//
//  Card.swift
//  
//
//  Created by Andrea Franchini on 10/05/15.
//
//

import Foundation
import CoreData

class Card: NSManagedObject {

    @NSManaged var attack: NSNumber
    @NSManaged var cost: NSNumber
    @NSManaged var durability: NSNumber
    @NSManaged var flavor: String
    @NSManaged var health: NSNumber
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var playerClass: String
    @NSManaged var rarity: String
    @NSManaged var text: String
    @NSManaged var type: String
    @NSManaged var image: NSData
    @NSManaged var hasImage: Bool

    // Save card function
    class func createCardInManagedObjectContext(moc: NSManagedObjectContext, name: String, id: String, cost: Int, type: String, rarity: String, text: String, flavor: String, attack: Int, health: Int, playerClass: String, durability: Int, image: NSData, hasImage: Bool) -> Card {
        
        let newCard = NSEntityDescription.insertNewObjectForEntityForName("Card", inManagedObjectContext: moc) as! Card
        
        newCard.name = name
        newCard.id = id
        newCard.cost = cost
        newCard.type = type
        newCard.rarity = rarity
        newCard.text = text
        newCard.flavor = flavor
        newCard.attack = attack
        newCard.health = health
        newCard.playerClass = playerClass
        newCard.durability = durability
        newCard.image = image
        newCard.hasImage = hasImage
        
        var saveError:NSError?
        if !moc.save(&saveError) {
            println("Error saving: \(saveError), \(saveError?.userInfo)")
        }
        
        return newCard
    }
    
}

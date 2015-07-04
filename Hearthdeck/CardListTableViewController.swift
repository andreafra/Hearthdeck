//
//  CardListTableViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 21/04/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData

class CardListTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    var isPickingCard: Bool = false
    
    // MOC
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    // Error
    var error: NSError?

    // CardCellIdentifier
    let CardCellIdentifier = "CardCell"
    
    // Empty array of card
    var cards = [Card]()
    // Empty filtered cards
    var filteredCards = [Card]()
    
    // If picking - picked cards
    var pickedCards = [String]()
    var pickedCardsQuantity = [Int]()
    var numOfPickedCards = 0
    var deckName: String?
    
    // Search
    var searchController = UISearchController()
    var searchResultsController = UITableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get the cards from core data
        fetchCard()
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.definesPresentationContext = true
        
        if isPickingCard {
            let fetchRequest = NSFetchRequest(entityName: "Deck")
            fetchRequest.predicate = NSPredicate(format: "name = %@", deckName!)
            
            do {
                let fetchResults = try self.appDel.managedObjectContext.executeFetchRequest(fetchRequest)
                if fetchResults.count != 0 {

                    let managedObject = fetchResults[0] as! Deck
                    let cardsOfDeck: String = managedObject.cards
                    
                    // Parse string into array
                    if cardsOfDeck != "" {
                        var cardsArrayRaw = cardsOfDeck.componentsSeparatedByString(" ")
                        cardsArrayRaw.removeLast()
                        for card in cardsArrayRaw {
                            let cardRaw = card.componentsSeparatedByString("@")
                            pickedCards.append(cardRaw[0])
                            pickedCardsQuantity.append(Int(cardRaw[1])!)
                        }
                    }
                }
            } catch {
                print("Error")
            }
        }
        for i in pickedCardsQuantity {
            numOfPickedCards += i
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.hideSearchBar()
    }

    // MARK: - Custom functions
    
    func fetchCard() {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Card")
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "name" , ascending: true)
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try moc.executeFetchRequest(fetchRequest)
            cards = results as! [Card]
                /*if (cards.count > 0) { // Debug purpose
                    for card in cards as [Card] {
                        println(card.name)
                    }
                } else {
                    println("No Cards")
                }*/
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    func hideSearchBar() {
        let yOffset = self.navigationController!.navigationBar.bounds.height + UIApplication.sharedApplication().statusBarFrame.height
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.tableView.contentOffset = CGPointMake(0, self.searchController.searchBar.bounds.height - yOffset)
        }, completion: nil)
    }
    
    
    func filterContent(searchedText: String, scope: String = "All") {

        filteredCards.removeAll(keepCapacity: true)
        for card in cards {
            var justOne = false
            if (scope == "All") || (card.type == scope) {
                if((card.name.rangeOfString(searchedText) != nil) && justOne == false) {

                    filteredCards.append(card)
                    justOne = true
                }
            }
            self.tableView.reloadData()
        }
    }
    
    // Filter with scope
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Add scopes
        //let scopes = resultSearchController.searchBar.scopeButtonTitles as! [String]
        //let currentScope = scopes[resultSearchController.searchBar.selectedScopeButtonIndex] as String
        
        filterContent(searchController.searchBar.text!, scope: "All")
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.

        if self.searchController.active {
            if !self.filteredCards.isEmpty {
                return self.filteredCards.count
            } else {
                return 0
            }
        } else {
            return self.cards.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.CardCellIdentifier , forIndexPath: indexPath) as! CardCell
        
        var card: Card?
        
        if self.searchController.active {
            if !self.filteredCards.isEmpty{
                card = self.filteredCards[indexPath.row] as Card
            }
        } else {
            card = self.cards[indexPath.row]
        }
        
        cell.nameLabel?.text = card!.name ?? "[No Name]"
        cell.costLabel?.text = card!.cost.stringValue ?? "[?]"
        
        if isPickingCard {
            
            cell.costLabel.hidden = true
            
            if pickedCards.contains(card!.id) {
                if pickedCardsQuantity[pickedCards.indexOf(card!.id)!] == 2 {
                    cell.costLabel.hidden = false
                    cell.costLabel.text = "2x"
                }
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell
    }
    
    func cardCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CardCellIdentifier) as! CardCell
        
        return cell
    }
    
    // If a row is selected, move to a view controller
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        func alertDeckIsFull() {
            let alertController = UIAlertController(title: "You're deck is full!", message: "Try to uncheck some cards.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in }
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) {}
        }
        
        if isPickingCard {

            if numOfPickedCards < 30 {
            
                if self.searchController.active {
                    let card = filteredCards[indexPath.row].id
                    
                    // Cycle in this way: NO CARD -> 1 CARD -> 2 CARD -> NO CARD ...
                    
                    if pickedCards.contains(card) {
                        
                        let cardIndex = pickedCards.indexOf(card)!
                        
                        if pickedCardsQuantity[cardIndex] >= 2 {
                            // Delete card
                            pickedCards.removeAtIndex(cardIndex)
                            pickedCardsQuantity.removeAtIndex(cardIndex)
                            numOfPickedCards -= 2
                        } else {
                            // Add second copy
                            pickedCardsQuantity[cardIndex] += 1
                            numOfPickedCards += 1
                        }
                    } else {
                        // Add card
                        pickedCards.append(card)
                        pickedCardsQuantity.append(1)
                        numOfPickedCards += 1
                    }
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                } else {
                    let card = cards[indexPath.row].id
                    
                    if pickedCards.contains(card) {
                        
                        let cardIndex = pickedCards.indexOf(card)!
                        
                        if pickedCardsQuantity[cardIndex] >= 2 {
                            // Delete card
                            pickedCards.removeAtIndex(cardIndex)
                            pickedCardsQuantity.removeAtIndex(cardIndex)
                            numOfPickedCards -= 2
                        } else {
                            // Add second copy
                            pickedCardsQuantity[cardIndex] += 1
                            numOfPickedCards += 1
                        }
                    } else {
                        // Add card
                        pickedCards.append(card)
                        pickedCardsQuantity.append(1)
                        numOfPickedCards += 1
                    }
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            } else {
                // You can only delete:
                if self.searchController.active {
                    let card = filteredCards[indexPath.row].id

                    if pickedCards.contains(card) {
                        let cardIndex = pickedCards.indexOf(card)!
                        
                        if pickedCardsQuantity[cardIndex] >= 1 {
                            // Delete card
                            pickedCards.removeAtIndex(cardIndex)
                            pickedCardsQuantity.removeAtIndex(cardIndex)
                            numOfPickedCards -= pickedCardsQuantity[cardIndex]
                        }
                    } else {
                        alertDeckIsFull()
                    }
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                } else {
                    let card = cards[indexPath.row].id
                    
                    if pickedCards.contains(card) {
                        let cardIndex = pickedCards.indexOf(card)!
                        
                        if pickedCardsQuantity[cardIndex] >= 2 {
                            // Delete card
                            pickedCards.removeAtIndex(cardIndex)
                            pickedCardsQuantity.removeAtIndex(cardIndex)
                            numOfPickedCards -= 2
                        } else if pickedCardsQuantity[cardIndex] == 1 {
                            pickedCards.removeAtIndex(cardIndex)
                            pickedCardsQuantity.removeAtIndex(cardIndex)
                            numOfPickedCards -= 1
                        }
                    } else {
                        alertDeckIsFull()
                    }
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
            print(pickedCards)
            print(pickedCardsQuantity)
            self.title = "\(numOfPickedCards)/30"
            
            // Then, deselect the row
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            
            //==========================END OF isPicking=========================//
        } else {
            if self.searchController.active {
                // Remove search bar & hide it
                //self.searchController.active = false
                self.hideSearchBar()
            }
            self.performSegueWithIdentifier("CardDetailSegue", sender: tableView)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if isPickingCard {
            let fetchRequest = NSFetchRequest(entityName: "Deck")
            fetchRequest.predicate = NSPredicate(format: "name = %@", deckName!)
            
            // Parse the 2 picked cards array into one string.
            // " " divides two cards, quantity is expressed by "@" and a number
            var resultString: String = ""
            for var i = 0; i < pickedCards.count; i++ {
                let block = pickedCards[i] + "@" + String(pickedCardsQuantity[i])
                resultString += block + " "
            }
            
            // Save data
            do {
                let fetchResults = try self.appDel.managedObjectContext.executeFetchRequest(fetchRequest)
                if fetchResults.count != 0 {
                    let managedObject = fetchResults[0] as! Deck
                    
                    managedObject.setValue(resultString, forKey: "cards")
                    do {
                        try self.moc.save()
                    } catch _ {
                    }
                }
            } catch {
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "CardDetailSegue" {
            let cardDetailViewController = segue.destinationViewController as! CardDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            
            var thisCard: Card
            if self.searchController.active {
                thisCard = self.filteredCards[indexPath!.row]
            } else {
                thisCard = self.cards[indexPath!.row]
            }
            
            // var in cardDVC | var in tableView

            cardDetailViewController.titleBar = thisCard.name
            cardDetailViewController.cost = thisCard.cost.stringValue
            cardDetailViewController.health = thisCard.health.stringValue
            cardDetailViewController.attack = thisCard.attack.stringValue
            cardDetailViewController.id = thisCard.id
            cardDetailViewController.playerClass = thisCard.playerClass
            cardDetailViewController.rarity = thisCard.rarity
            cardDetailViewController.type = thisCard.type
            cardDetailViewController.text = thisCard.text
            if !thisCard.hasImage {
                // If current card has no image
                // Download image
                
                let baseUrl = "http://wow.zamimg.com/images/hearthstone/cards/enus/medium/" + thisCard.id + ".png"
                do {
                    thisCard.image = try NSData(contentsOfURL: NSURL(string: baseUrl)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    thisCard.hasImage = true
                    do {
                        try moc.save()
                    } catch {
                        print("Cannot save: \(error)")
                    }
                } catch {
                    print("Cannot convert image!")
                }
            }
            cardDetailViewController.imageData = thisCard.image
        }
    }
    
    // MARK:- UISearchControllerDelegate methods
    
    func longPressToSeeDetails(sender: UIGestureRecognizer) {
        performSegueWithIdentifier("CardDetailSegue", sender: tableView)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.hideSearchBar()
            }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

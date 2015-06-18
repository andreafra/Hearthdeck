//
//  CardListTableViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 21/04/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData

class CardListTableViewController: UITableViewController, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate {
    
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
            
            if let fetchResults = self.appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Deck] {
                if fetchResults.count != 0 {

                    var managedObject = fetchResults[0]
                    let cardsOfDeck: String = managedObject.cards
                    
                    // Parse string into array
                    if cardsOfDeck != "" {
                        var cardsArrayRaw = cardsOfDeck.componentsSeparatedByString(" ")
                        cardsArrayRaw.removeLast()
                        for card in cardsArrayRaw {
                            let cardRaw = card.componentsSeparatedByString("@_")
                            pickedCards.append(cardRaw[0])
                            pickedCardsQuantity.append(cardRaw[1].toInt()!)
                        }
                    }
                }
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.hideSearchBar()
    }

    // MARK: - Custom functions
    
    func fetchCard() {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Card")
        var sorter: NSSortDescriptor = NSSortDescriptor(key: "name" , ascending: true)
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.returnsObjectsAsFaults = false
        
        var error : NSError?
        if let results = moc!.executeFetchRequest(fetchRequest, error: &error) as? [Card] {
            cards = results
            /*if (cards.count > 0) { // Debug purpose
                for card in cards as [Card] {
                    println(card.name)
                }
            } else {
                println("No Cards")
            }*/
        } else {
            println("Fetch failed: \(error)")
            // Handle error ...
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
            for (i, type) in enumerate(card.type) {
                if (scope == "All") || (card.type == scope) {
                    if((card.name.rangeOfString(searchedText) != nil) && justOne == false) {

                        filteredCards.append(card)
                        justOne = true
                    }
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
        
        filterContent(searchController.searchBar.text, scope: "All")
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
            
            if contains(pickedCards, card!.id) {
                if pickedCardsQuantity[find(pickedCards, card!.id)!] == 2 {
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
                    
                    if contains(pickedCards, card) {
                        
                        let cardIndex = find(pickedCards, card)!
                        
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
                    
                    if contains(pickedCards, card) {
                        
                        let cardIndex = find(pickedCards, card)!
                        
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

                    if contains(pickedCards, card) {
                        let cardIndex = find(pickedCards, card)!
                        
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
                    
                    if contains(pickedCards, card) {
                        let cardIndex = find(pickedCards, card)!
                        
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
            println(pickedCards)
            println(pickedCardsQuantity)
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
            // " " divides two cards, quantity is expressed by "@_" and a number
            var resultString: String = ""
            for var i = 0; i < pickedCards.count; i++ {
                let block = pickedCards[i] + "@_" + String(pickedCardsQuantity[i])
                resultString += block + " "
            }
            
            // Save data
            if let fetchResults = self.appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Deck] {
                if fetchResults.count != 0 {
                    var managedObject = fetchResults[0]
                    
                    managedObject.setValue(resultString, forKey: "cards")
                    self.moc?.save(nil)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "CardDetailSegue" {
            let cardDetailViewController = segue.destinationViewController as! CardDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
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
                var downloadImageError: NSError?
                var imageError: NSError?
                let baseUrl = "http://wow.zamimg.com/images/hearthstone/cards/enus/medium/" + thisCard.id + ".png"
                thisCard.image = NSData(contentsOfURL: NSURL(string: baseUrl)!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &imageError)!
                thisCard.hasImage = true
                moc?.save(&downloadImageError)
                if downloadImageError != nil {
                    println(downloadImageError)
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

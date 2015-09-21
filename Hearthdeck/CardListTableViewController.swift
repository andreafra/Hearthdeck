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
    var isPickingCardClass: String = ""

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
    
    @IBOutlet var classPickerButton: UIBarButtonItem!
    
    var isPickingCardIndexPath: NSIndexPath?
    
    /*==== FILTER VARIABLES =====*/
    var definitivePredicate = NSPredicate(value: true)
    var classFilter: NSPredicate = NSPredicate(value: true)
    var activeClass: String = ""
    var typeFilter: NSPredicate = NSPredicate(value: true)
    var activeType: String = ""
    var costFilter: NSPredicate = NSPredicate(value: true)
    var activeCost: String = "All"
    var rarityFilter: NSPredicate = NSPredicate(value: true)
    var activeRarity: String = ""
    
    // END OF VARs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(isPickingCardClass)
        
        //first fetch deck and setup filters
        if isPickingCard {
            
            classFilter = NSPredicate(format: "playerClass = %@ OR playerClass = \"Neutral\"", isPickingCardClass)
            classPickerButton.enabled = false
            
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
            longPressGestureRecognizer.minimumPressDuration = 1.0
            self.tableView.addGestureRecognizer(longPressGestureRecognizer)
            
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
        
        //get ready to filter cards
        combinePredicates()
        
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
            
            classPickerButton.enabled = false
            
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
            longPressGestureRecognizer.minimumPressDuration = 1.0
            self.tableView.addGestureRecognizer(longPressGestureRecognizer)
            
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
        
        let tapOnWrapper = UIGestureRecognizer(target: self, action: "handleTap:")

        wrapperView?.addGestureRecognizer(tapOnWrapper)
    }

    // MARK: - Custom functions
    
    func fetchCard() {
        
        cards = []
        
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Card")
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "name" , ascending: true)
        fetchRequest.predicate = definitivePredicate
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.returnsObjectsAsFaults = true
        
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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.navigationController?.setToolbarHidden(true, animated: true)
        
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
            var indexPath: NSIndexPath?
            if isPickingCard {
                indexPath = isPickingCardIndexPath
            } else {
                indexPath = self.tableView.indexPathForSelectedRow
            }
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
    
    // MARK:- Selection of search parameters
    var containerView: UIView?
    var wrapperView: UIView?
    
    // A flexible button with a secret property
    class SFButton : UIButton {
        var secretValue: String = ""
    }
    
    // Cost Slider
    let costValues = [0, 1, 2, 3, 4, 5, 6, 7 ,8]
    let actualCost = UILabel()
    
    func showFilterView(whichView: String) {
        
        //self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);

        
        
        if containerView != nil {
            containerView?.removeFromSuperview()
            if wrapperView != nil {
                wrapperView!.removeFromSuperview()
            }
        }
        
        var numOfElements: Double = 0
        var rows: Double = 1
        switch whichView {
            case "Class":
                numOfElements = 9
                rows = 3
                break
            case "Type":
                numOfElements = 3
                rows = 1
                break
            case "Cost":
                numOfElements = 1
                rows = 1
                break
            case "Rarity":
                numOfElements = 5
                rows = 2
            default:
                numOfElements = 3
                rows = 1
        }
        
        
        wrapperView = UIView(frame: self.view.frame)
        wrapperView!.backgroundColor = UIColor.grayColor()
        wrapperView!.alpha = 0.0
        UIView.animateWithDuration(0.4, animations: {
            wrapperView?.alpha = 0.5
        })
        tableView.scrollEnabled = false
        tableView.allowsSelection = false
        //position
        let height = CGFloat(100 * rows) + 50 // iPhone 4/5 width
        containerView = UIView(frame: CGRectMake(0, 0, 350, height))
        containerView!.center = self.view.center
        // appearance
        containerView!.backgroundColor = UIColor.whiteColor()
        containerView!.layer.shadowColor = UIColor.blackColor().CGColor
        containerView!.layer.shadowOpacity = 0.5
        containerView!.layer.shadowOffset = CGSize(width: 1, height: 1)
        containerView!.layer.shadowRadius = 5
        containerView!.layer.cornerRadius = 5
        containerView?.alpha = 1.0
        UIView.animateWithDuration(0.4, animations: {
            self.wrapperView?.alpha = 0.5
            self.containerView?.alpha = 1.0
        })
        // draw grid
        let gridLayer = CAShapeLayer()
        
        // path
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 50))
        path.addLineToPoint(CGPointMake(350, 50))
        if whichView != "Cost" {
            path.moveToPoint(CGPointMake((350-2)/3, 50))
            path.addLineToPoint(CGPointMake((350-3)/3, height))
            path.moveToPoint(CGPointMake((350-2)/3*2, 50))
            path.addLineToPoint(CGPointMake((350-3)/3*2, height))
            path.moveToPoint(CGPointMake(0, 50))
            path.addLineToPoint(CGPointMake(350, 50))
            for var i: Double = 0; i < rows; i++ {
                let newHeight: CGFloat = 50 + (height - 50) / CGFloat(rows) * CGFloat(i)
                path.moveToPoint(CGPointMake(0, newHeight))
                path.addLineToPoint(CGPointMake(350, newHeight))
            }
        }
        gridLayer.path = path.CGPath
        gridLayer.strokeColor = UIColor.lightGrayColor().CGColor
        gridLayer.lineWidth = 1.0
        
        // Add elements
        let _title = UILabel(frame: CGRectMake(0, 0, 350, 50))
        _title.text = whichView
        _title.textColor = UIColor.grayColor()
        _title.textAlignment = NSTextAlignment.Center
        
        let _close = UIButton(type: UIButtonType.System)
        _close.frame = CGRectMake(300, 0, 50, 50)
        _close.tintColor = UIColor.grayColor()
        _close.setImage(UIImage(named: "Delete Sign-50.png"), forState: .Normal)
        _close.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)

        _close.addTarget(self, action: "closeButtonIsTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        containerView?.addSubview(_close)
        
        switch whichView {
            
            case "Class":
                let playerClasses = ["Mage", "Priest", "Shaman", "Rogue", "Warrior", "Warlock", "Paladin", "Hunter", "Druid"]
                var selectedClassNum: Int?
                if playerClasses.contains(activeClass) {
                    selectedClassNum = playerClasses.indexOf(activeClass)
                }
                
                
                    
            
                var k = 0
                for x in 0...Int(numOfElements-1) {
                    
                    let button = SFButton(type: UIButtonType.Custom)
                    let image = UIImage(named: playerClasses[x]+".png")
                    button.setImage(image, forState: .Normal)
                    button.setTitle(playerClasses[x], forState: .Normal)
                    button.secretValue = playerClasses[x] // value to work with future l10n
                    button.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                    button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
                    button.addTarget(self, action: "didSelectClass:", forControlEvents: UIControlEvents.TouchUpInside)
                    
                    if x < 3 { // row 1
                            button.frame = CGRectMake(CGFloat(0+k*350/3), 50, 350/3, CGFloat(height - 50)/CGFloat(rows))
                    } else if x < 6 { // row 2
                            button.frame = CGRectMake(CGFloat(0+k*350/3), 50 + (height-50)/3, 350/3, CGFloat(height - 50)/CGFloat(rows))
                    } else { // row 3...
                            button.frame = CGRectMake(CGFloat(0+k*350/3), 50 + (height-50)/3*2, 350/3, CGFloat(height - 50)/CGFloat(rows))
                    }
                    k++
                    if k > 2 {
                        k = 0
                    }
                    
                    // Format pre-selected cell
                    if x == selectedClassNum {
                        let selectedImageView = UIImageView()
                        selectedImageView.image = UIImage(named: "Ok Filled-50.png")!
                        selectedImageView.frame = CGRectMake(button.frame.width-30, 5, 25, 25)
                        button.addSubview(selectedImageView)
                    }
                    containerView?.addSubview(button)
                }
                break
            case "Type":
                let types = ["Minion", "Spell", "Weapon"]
                var selectedTypeNum: Int?
                if types.contains(activeType) {
                    selectedTypeNum = types.indexOf(activeType)
                }
                
                for x in 0...types.count-1 {
                    let button = SFButton(type: UIButtonType.Custom)
                    button.setTitle(types[x], forState: .Normal)
                    button.secretValue = types[x] // value to work with future l10n
                    button.setTitleColor(UIColor(red:0, green:0.589, blue:1, alpha:1), forState: .Normal)
                    button.frame = CGRectMake(CGFloat(0+x*(350-2)/3), 50, 350/3, height-50)
                    button.addTarget(self, action: "didSelectType:", forControlEvents: UIControlEvents.TouchUpInside)
                    
                    // Format pre-selected cell
                    if x == selectedTypeNum {
                        let selectedImageView = UIImageView()
                        selectedImageView.image = UIImage(named: "Ok Filled-50.png")!
                        selectedImageView.frame = CGRectMake(button.frame.width-30, 5, 25, 25)
                        button.addSubview(selectedImageView)
                    }
                    
                    containerView?.addSubview(button)
                }
            case "Cost":
                let slider = UISlider(frame: CGRectMake(25, 50, 300, height-50))
                
                let costNumOfSteps: Float = Float(costValues.count - 1)
                slider.maximumValue = costNumOfSteps
                slider.minimumValue = 0
                
                slider.continuous = true
                slider.addTarget(self, action: "costValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
                
                actualCost.frame = CGRectMake(slider.frame.width/2-50, 5, 100, 20)
                actualCost.textColor = UIColor.grayColor()
                actualCost.textAlignment = NSTextAlignment.Center
                actualCost.text = activeCost
                
                if activeCost == "All" {
                    slider.setValue(8, animated: false)
                } else if activeCost == "7+" {
                    slider.setValue(7, animated: false)
                } else {
                    slider.setValue(Float(activeCost)!, animated: false)
                }
                
                slider.addSubview(actualCost)
                
                containerView?.addSubview(slider)
            break
            case "Rarity":
                let rarityArray = ["Free", "Common", "Rare", "Epic", "Legendary"]
                let rarityColorArray = [UIColor(red:0.38, green:0.38, blue:0.38, alpha:1), UIColor(red:0.794, green:0.794, blue:0.794, alpha:1), UIColor(red:0.25, green:0.561, blue:0.969, alpha:1), UIColor(red:0.806, green:0.277, blue:0.883, alpha:1), UIColor(red:0.956, green:0.662, blue:0.227, alpha:1)]
                var selectedRarityNum: Int?
                if rarityArray.contains(activeRarity) {
                    selectedRarityNum = rarityArray.indexOf(activeRarity)
                }
                
                var k = 0
                for x in 0...rarityArray.count-1 {
                    
                    let button = SFButton()
                    button.secretValue = rarityArray[x] // value to work with future l10n
                    button.addTarget(self, action: "didSelectRarity:", forControlEvents: UIControlEvents.TouchUpInside)
                    
                    let buttonSubtitle = UILabel()
                    buttonSubtitle.text = rarityArray[x] as String
                    buttonSubtitle.textAlignment = NSTextAlignment.Center
                    buttonSubtitle.textColor = rarityColorArray[x]
                    
                    let image = rarityArray[x] + ".png"
                    button.setImage(UIImage(named: image), forState: .Normal)
                    button.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                    button.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 20, 40)
                    
                    if x < 3 { // row 1
                        button.frame = CGRectMake(CGFloat(0+k*350/3), 50, 350/3, CGFloat(height - 50)/CGFloat(rows))
                        buttonSubtitle.frame = CGRectMake(CGFloat(0+k*350/3), button.bounds.height + 15, 350/3, 30)
                    } else if x < 6 { // row 2
                        button.frame = CGRectMake(CGFloat(0+k*350/3), 50 + (height-50)/2, 350/3, CGFloat(height - 50)/CGFloat(rows))
                        buttonSubtitle.frame = CGRectMake(CGFloat(0+k*350/3), button.bounds.height+15 + (height-50)/2, 350/3, 30)
                    }
                    
                    k++
                    if k > 2 {
                        k = 0
                    }
                    
                    // Format pre-selected cell
                    if x == selectedRarityNum {
                        let selectedImageView = UIImageView()
                        selectedImageView.image = UIImage(named: "Ok Filled-50.png")!
                        selectedImageView.frame = CGRectMake(button.frame.width-30, 5, 25, 25)
                        button.addSubview(selectedImageView)
                    }
                    
                    containerView?.addSubview(button)
                    containerView?.addSubview(buttonSubtitle)
                }
                
                
            break
            
            default:
                print("No button type recognised")
                break
        }
        
        
        // add grid
        containerView!.layer.addSublayer(gridLayer)
        containerView!.addSubview(_title)
        // add to view
        self.view.addSubview(wrapperView!)
        self.view.addSubview(containerView!)
    }
    
    func closeButtonIsTapped(sender: UIButton) {
        dismissFilterView()
    }
    
    func dismissFilterView() {
        UIView.animateWithDuration(0.4, animations: {
            self.containerView?.alpha = 0.0
            self.wrapperView?.alpha = 0.0
            
            }, completion: {
            _ in
            self.containerView?.removeFromSuperview()
            self.wrapperView?.removeFromSuperview()
            
            self.restoreInteractionWithTableView()
        })
        
        combinePredicates()
        
        fetchCard()
        self.tableView.reloadData()
        print("reloaded")
    }
    
    
    // CLASS
    func didSelectClass(sender: SFButton) {
        
        let playerClass = sender.secretValue
        
        if playerClass != activeClass {
            classFilter = NSPredicate(format: "playerClass = %@", playerClass)
            let selectedImageView = UIImageView()
            selectedImageView.image = UIImage(named: "Ok Filled-50.png")!
            selectedImageView.frame = CGRectMake(sender.frame.width-30, 5, 25, 25)
            sender.addSubview(selectedImageView)
            activeClass = playerClass
        } else {
            sender.secretValue = ""
            activeClass = ""
            classFilter = NSPredicate(value: true)
        }
        print(sender.secretValue)
        dismissFilterView()
    }
    
    // TYPE
    func didSelectType(sender: SFButton) {
        
        let type = sender.secretValue
        if type != activeType {
            typeFilter = NSPredicate(format: "type = %@", type)
            let selectedImageView = UIImageView()
            selectedImageView.image = UIImage(named: "Ok Filled-50.png")!
            selectedImageView.frame = CGRectMake(sender.frame.width-30, 5, 25, 25)
            sender.addSubview(selectedImageView)
            activeType = type
        } else {
            sender.secretValue = ""
            activeType = ""
            typeFilter = NSPredicate(value: true)
        }
        
        print(sender.secretValue)
        dismissFilterView()
    }
    
    // COST
    func costValueChanged(sender: UISlider) {
        let index = sender.value + 0.5
        let number = costValues[Int(index)]
        sender.setValue(Float(number), animated: true)
        if number == 8 {
            actualCost.text = "All"
            activeCost = "All"
            costFilter = NSPredicate(format: "cost > 0")
        } else if number == 7 {
            actualCost.text = "7+"
            activeCost = "7+"
            costFilter = NSPredicate(format: "cost > 6")
        } else {
            actualCost.text = String(number)
            activeCost = String(number)
            costFilter = NSPredicate(format: "cost = %i", number)
        }
        
        print(number)
        // can't dismiss or view close on drag - copy-and-past dismiss...() function
        combinePredicates()
        fetchCard()
        self.tableView.reloadData()
        print("reloaded")
    }
    
    // RARITY
    func didSelectRarity(sender: SFButton) {
        let  rarity = sender.secretValue
        
        if rarity != activeRarity {
            rarityFilter = NSPredicate(format: "rarity = %@", rarity)
            activeRarity = rarity
            print("DIVERSO")
        } else {
            print("UGUALE")
            sender.secretValue = ""
            activeRarity = ""
            rarityFilter = NSPredicate(value: true)
        }
        let selectedImageView = UIImageView()
        selectedImageView.image = UIImage(named: "Ok Filled-50.png")!
        selectedImageView.frame = CGRectMake(sender.frame.width-30, 5, 25, 25)
        sender.addSubview(selectedImageView)
        
        print(sender.secretValue)
        dismissFilterView()
    }
    // COMBINE PREDICATES
    func combinePredicates() {
        definitivePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [classFilter, typeFilter, costFilter, rarityFilter])
        print("Combined results!")
    }
    
    
    
    @IBAction func showClass(sender: AnyObject) {
        showFilterView("Class")
    }
    
    @IBAction func showType(sender: AnyObject) {
        showFilterView("Type")
    }
    
    @IBAction func showCost(sender: AnyObject) {
        showFilterView("Cost")
    }
    
    @IBAction func showRarity(sender: AnyObject) {
        showFilterView("Rarity")
    }
    
    func restoreInteractionWithTableView() {
        tableView.scrollEnabled = true
        tableView.allowsSelection = true
    }
    
    func handleTap(gesture: UIGestureRecognizer) {
        
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p: CGPoint = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        if indexPath == nil {
            print("longpress but not on a row")
        } else if gestureRecognizer.state == UIGestureRecognizerState.Began {
            print("long press on table view at row \(indexPath!.row)")
            
            isPickingCardIndexPath = indexPath
            performSegueWithIdentifier("CardDetailSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

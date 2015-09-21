//
//  PlayDeckTableViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 30/06/15.
//  Copyright © 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData

class PlayDeckTableViewController: UITableViewController {

    var deckName: String?
    
    // Core Data
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    var pickedCards = [String]()
    var pickedCardsQuantity = [Int]()
    var usedCardsQuantity = [Int]()
    var cardImages = [UIImage]()
    @IBOutlet var deckTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer.minimumPressDuration = 1.0
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        createOverlay()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadCards()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pickedCards.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayDeckCell", forIndexPath: indexPath) as! PlayDeckCell

        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Card")
        fetchRequest.predicate = NSPredicate(format: "id = %@", pickedCards[indexPath.row])
        
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            let card = results[0] as! Card
            
            // set labels
            cell.name.text = card.name
            cell.quantity.text = String(usedCardsQuantity[indexPath.row])
            cell.manaValue.text = String(card.cost)
            cell.healthValue.text = String(card.health)
            cell.attackValue.text = String(card.attack)
            
            let durability = String(card.durability)
            let cardType = card.type
            
            cell.attackIcon.image = cell.attackIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.attackIcon.tintColor = UIColor(red:0.826, green:0.696, blue:0.063, alpha:1)
            
            // Card counter rotation and antialiasing
            let degrees: Double = 15
            let angle = CGFloat(degrees * M_PI/180)
            cell.backCard.transform = CGAffineTransformMakeRotation(angle)
            cell.backCard.layer.allowsEdgeAntialiasing = true
            
            // Show the right number of detail
            if usedCardsQuantity[indexPath.row] == 2 {

                cell.backCard.hidden = false
                cell.topCard.hidden = false
                cell.manaIcon.hidden = false
                cell.manaValue.hidden = false
                cell.attackIcon.hidden = false
                cell.attackValue.hidden = false
                cell.healthIcon.hidden = false
                cell.healthValue.hidden = false
                cell.quantity.hidden = false
                cell.cardImage.hidden = false
                cell.name.textColor = UIColor.blackColor()
                
            } else if usedCardsQuantity[indexPath.row] == 1 {
                
                cell.backCard.hidden = true
                cell.topCard.hidden = false
                cell.manaIcon.hidden = false
                cell.manaValue.hidden = false
                cell.attackIcon.hidden = false
                cell.attackValue.hidden = false
                cell.healthIcon.hidden = false
                cell.healthValue.hidden = false
                cell.quantity.hidden = false
                cell.cardImage.hidden = false
                cell.name.textColor = UIColor.blackColor()
                
            } else if usedCardsQuantity[indexPath.row] == 0 {
                
                cell.backCard.hidden = true
                cell.topCard.hidden = true
                cell.manaIcon.hidden = true
                cell.manaValue.hidden = true
                cell.attackIcon.hidden = true
                cell.attackValue.hidden = true
                cell.healthIcon.hidden = true
                cell.healthValue.hidden = true
                cell.quantity.hidden = true
                cell.cardImage.hidden = true
                cell.name.textColor = UIColor.lightGrayColor()
            }
            
            if cardType == "Minion" {
                cell.healthIcon.image = cell.healthIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.healthIcon.tintColor = UIColor.redColor()
                cell.healthValue.textColor = UIColor.redColor()
            } else if cardType == "Weapon" {
                cell.healthIcon.image = UIImage(named: "Durability-50.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.healthIcon.tintColor = UIColor(red:0.504, green:0.504, blue:0.504, alpha:1)
                cell.healthValue.text = durability
                cell.healthValue.textColor = UIColor(red:0.504, green:0.504, blue:0.504, alpha:1)
            } else if cardType == "Spell" {
                cell.healthIcon.hidden = true
                cell.attackIcon.hidden = true
                cell.healthValue.hidden = true
                cell.attackValue.hidden = true
            }
            
            if card.hasImage {
                cell.cardImage.image = UIImage(data: card.image)
            } else {
                // If current card has no image
                // Download image
                let baseUrl = "http://wow.zamimg.com/images/hearthstone/cards/enus/medium/" + card.id + ".png"
                card.image = try! NSData(contentsOfURL: NSURL(string: baseUrl)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                card.hasImage = true
                print("Downloaded image")
                do {
                    try self.managedObjectContext.save()
                } catch  {
                    print(error)
                }
                
                cell.cardImage.image = UIImage(data: card.image)
            }
            
            cardImages.append(UIImage(data: card.image)!)
            
        } catch _ {
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if usedCardsQuantity[indexPath.row] == 0 { // then collapse the cell
            return 40
        } else {
            return 75
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if usedCardsQuantity[indexPath.row] > 0 {
            usedCardsQuantity[indexPath.row] -= 1
            
        } else {
            if pickedCardsQuantity[indexPath.row] == 2 {
                usedCardsQuantity[indexPath.row] = 2
            } else {
                usedCardsQuantity[indexPath.row] = 1
            }
        }
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Utility
    func loadCards() {
        
        //reset
        pickedCards = []
        pickedCardsQuantity = []
        
        //fetch
        let fetchRequest = NSFetchRequest(entityName: "Deck")
        fetchRequest.predicate = NSPredicate(format: "name = %@", deckTitle.title!)
        
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
                        
                        // SETUP CARDS IN CELLS
                        pickedCards.append(cardRaw[0])
                        pickedCardsQuantity.append(Int(cardRaw[1])!)
                        usedCardsQuantity.append(Int(cardRaw[1])!)
                    }
                }
            }
        } catch {
            print(error)
        }
        print(pickedCards)
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p: CGPoint = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        if indexPath == nil {
            print("longpress but not on a row")
        } else if gestureRecognizer.state == UIGestureRecognizerState.Began {
            print("long press on table view at row \(indexPath!.row)")
            
            let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Card")
            fetchRequest.predicate = NSPredicate(format: "id = %@", pickedCards[indexPath!.row])
            
            do {
                let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                let card = results[0] as! Card
                showAlert(UIImage(data: card.image)!)
            } catch {
                print(error)
            }
        }
        
    }
    
    // PHYSICAL BASED ALERT VIEW
    var overlayView: UIView!
    var alertView: UIView!
    
    func createOverlay() {
        // Create a gray view and set its alpha to 0 so it isn't visible
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.grayColor()
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
    }
    
    func createAlert() {
        alertView = UIView()
        let width: CGFloat = 300
        let heigth: CGFloat = 400
        alertView.frame = CGRectMake(0, 0, width, heigth)
        alertView.backgroundColor = UIColor.whiteColor()
        alertView.layer.cornerRadius = 10
        alertView.layer.shadowColor = UIColor.blackColor().CGColor
        alertView.layer.shadowOpacity = 0.5
        alertView.layer.shadowRadius = 3
        alertView.layer.shadowOffset = CGSizeMake(2, 2)
        alertView.alpha = 0.0
        alertView.center = self.tableView.center
        
        view.addSubview(alertView)
    }
    
    var alertViewAlreadyPresented = false
    
    func showAlert(image: UIImage) {
        
        if alertViewAlreadyPresented == false {
            print("No alertview")
            createAlert()
        }
        
        //Scroll to top
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        tableView.scrollEnabled = false
        
        // Image
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 40, alertView.frame.width, alertView.frame.height-100)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        alertView.addSubview(imageView)
        // Close button
        let closeButton = UIButton(type: UIButtonType.System)
        closeButton.frame = CGRectMake(0, 0, alertView.frame.width, 40)
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.addTarget(self, action: "closeButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        alertView.addSubview(closeButton)
        
        alertView.center.y += self.view.frame.height
        // Move alert view
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseIn, animations: {
            self.overlayView.alpha = 0.5
            self.overlayView.userInteractionEnabled = false
            
            self.alertView.center = self.view.center
            self.alertView.alpha = 1.0
            }, completion: {_ in})

        alertViewAlreadyPresented = true
    }
    
    func dismissAlert() {
        UIView.animateWithDuration(0.4, animations: {
            self.overlayView.alpha = 0.0
            self.overlayView.userInteractionEnabled = true
            self.alertView.alpha = 0.0
            self.alertView.center.y += self.view.frame.height
            }, completion: {
            _ in
                self.alertView.removeFromSuperview()
                self.tableView.scrollEnabled = true
        })
        alertViewAlreadyPresented = false
    }
    
    func closeButtonAction(sender: AnyObject) {
        dismissAlert()
    }
    
}

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
    
    @IBOutlet var deckTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer.minimumPressDuration = 1.0
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        animator = UIDynamicAnimator(referenceView: view)
        createOverlay()
        createAlert()
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
            cell.quantity.text = String(pickedCardsQuantity[indexPath.row])
            cell.manaValue.text = String(card.cost)
            cell.healthValue.text = String(card.health)
            cell.attackValue.text = String(card.attack)
            
            let durability = String(card.durability)
            let cardType = card.type
            
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
            } else if usedCardsQuantity[indexPath.row] == 1 {
                cell.backCard.hidden = true
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
            showAlert()
        }
        
    }
    
    // PHYSICAL BASED ALERT VIEW
    var overlayView: UIView!
    var alertView: UIView!
    var animator: UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var snapBehavior : UISnapBehavior!
    
    func createOverlay() {
        // Create a gray view and set its alpha to 0 so it isn't visible
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.grayColor()
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
    }
    
    func createAlert() {
        // Here the red alert view is created. It is created with rounded corners and given a shadow around it
        let alertWidth: CGFloat = 250
        let alertHeight: CGFloat = 150
        let alertViewFrame: CGRect = CGRectMake(0, 0, alertWidth, alertHeight)
        alertView = UIView(frame: alertViewFrame)
        alertView.backgroundColor = UIColor.redColor()
        alertView.alpha = 0.0
        alertView.layer.cornerRadius = 10;
        alertView.layer.shadowColor = UIColor.blackColor().CGColor;
        alertView.layer.shadowOffset = CGSizeMake(0, 5);
        alertView.layer.shadowOpacity = 0.3;
        alertView.layer.shadowRadius = 10.0;
        
        // Create a button and set a listener on it for when it is tapped. Then the button is added to the alert view
        let button = UIButton(type: UIButtonType.System) as UIButton
        button.setTitle("Dismiss", forState: UIControlState.Normal)
        button.backgroundColor = UIColor.whiteColor()
        button.frame = CGRectMake(0, 0, alertWidth, 40.0)
        
        button.addTarget(self, action: Selector("dismissAlert"), forControlEvents: UIControlEvents.TouchUpInside)
        
        alertView.addSubview(button)
        view.addSubview(alertView)
    }
    
    func showAlert() {
        // When the alert view is dismissed, I destroy it, so I check for this condition here
        // since if the Show Alert button is tapped again after dismissing, alertView will be nil
        // and so should be created again
        if (alertView == nil) {
            createAlert()
        }
        
        // I create the pan gesture recognizer here and not in ViewDidLoad() to
        // prevent the user moving the alert view on the screen before it is shown.
        // Remember, on load, the alert view is created but invisible to user, so you
        // don't want the user moving it around when they swipe or drag on the screen.
        createGestureRecognizer()
        
        animator.removeAllBehaviors()
        
        // Animate in the overlay
        UIView.animateWithDuration(0.4) {
            self.overlayView.alpha = 0.5
        }
        
        // Animate the alert view using UIKit Dynamics.
        alertView.alpha = 1.0
        
        let snapBehaviour: UISnapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
        animator.addBehavior(snapBehaviour)
    }
    
    func dismissAlert() {
        
        animator.removeAllBehaviors()
        
        let gravityBehaviour: UIGravityBehavior = UIGravityBehavior(items: [alertView])
        gravityBehaviour.gravityDirection = CGVectorMake(0.0, 10.0);
        animator.addBehavior(gravityBehaviour)
        
        // This behaviour is included so that the alert view tilts when it falls, otherwise it will go straight down
        let itemBehaviour: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [alertView])
        itemBehaviour.addAngularVelocity(CGFloat(-M_PI_2), forItem: alertView)
        animator.addBehavior(itemBehaviour)
        
        // Animate out the overlay, remove the alert view from its superview and set it to nil
        // If you don't set it to nil, it keeps falling off the screen and when Show Alert button is
        // tapped again, it will snap into view from below. It won't have the location settings we defined in createAlert()
        // And the more it 'falls' off the screen, the longer it takes to come back into view, so when the Show Alert button
        // is tapped again after a considerable time passes, the app seems unresponsive for a bit of time as the alert view
        // comes back up to the screen
        UIView.animateWithDuration(0.4, animations: {
            self.overlayView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.alertView.removeFromSuperview()
                self.alertView = nil
        })
        
    }
    
    func createGestureRecognizer() {
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // This gets called when a pan gesture is recognized. It was set as the selector for the UIPanGestureRecognizer in the
    // createGestureRecognizer() function
    // We check for different states of the pan and do something different in each state
    // In Began, we create an attachment behaviour. We add an offset from the center to make the alert view twist in the
    // the direction of the pan
    // In Changed we set the attachment behaviour's anchor point to the location of the user's touch
    // When the user stops dragging (In Ended), we snap the alert view back to the view's center (which is where it was originally located)
    // When the user drags the view too far down, we dismiss the view
    // I check whether the alert view is not nil before taking action. This ensures that when the user dismisses the alert view
    // and drags on the screen, the app will not crash as it tries to move a view that hasn't been initialized.
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if (alertView != nil) {
            let panLocationInView = sender.locationInView(view)
            let panLocationInAlertView = sender.locationInView(alertView)
            
            if sender.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                
                let offset = UIOffsetMake(panLocationInAlertView.x - CGRectGetMidX(alertView.bounds), panLocationInAlertView.y - CGRectGetMidY(alertView.bounds));
                attachmentBehavior = UIAttachmentBehavior(item: alertView, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
                
                animator.addBehavior(attachmentBehavior)
            }
            else if sender.state == UIGestureRecognizerState.Changed {
                attachmentBehavior.anchorPoint = panLocationInView
            }
            else if sender.state == UIGestureRecognizerState.Ended {
                animator.removeAllBehaviors()
                
                snapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
                animator.addBehavior(snapBehavior)
                
                if sender.translationInView(view).y > 100 {
                    dismissAlert()
                }
            }
        }
        
    }
}

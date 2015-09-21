//
//  DecksTableViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 07/05/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData

class DecksTableViewController: UITableViewController {

    // for new deck segue
    var newDeckCreated = false
    
    // MOC
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    // Error
    var error: NSError?

    // CardCellIdentifier
    let DeckCellIdentifier = "DeckCell"
    
    // Empty array of card
    var decks = [Deck]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchDeck()
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        newDeckCreated = false
        self.tableView.reloadData()
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    // MARK: - Custom Function

    @IBAction func addNewItem(sender: AnyObject) {
        
        let newDeck: Deck = NSEntityDescription.insertNewObjectForEntityForName("Deck", inManagedObjectContext: moc) as! Deck
        newDeck.name = "Deck " + String(decks.count+1)
        newDeck.desc = "A new deck"
        newDeck.type = "Mage"
        newDeck.cards = ""
        
        do {
            try moc.save()
        } catch {
            print("Error saving: \(error)")
        }

        print(newDeck.name)
        newDeckCreated = true
        
        fetchDeck()
        tableView.reloadData()
        performSegueWithIdentifier("goToNewDeck", sender: tableView)
        
        
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
        return decks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DeckCellIdentifier, forIndexPath: indexPath) as! DeckCell

        // Configure the cell...
        let deck = decks[indexPath.row]
        cell.deckTitle.text = deck.name
        cell.deckClassThumbnail.image = UIImage(named: (deck.type+"_thumb.png"))
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            moc.deleteObject(decks[indexPath.row] as Deck)
            decks.removeAtIndex(indexPath.row)
            do {
                try moc.save()
            } catch _ {
            }
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("goToNewDeck", sender: tableView)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToNewDeck" {
            
            let deckOverviewVC = segue.destinationViewController as! DeckDetailViewController
            
            var indexPath:NSIndexPath?
            
            if newDeckCreated {
                indexPath = NSIndexPath(forRow: decks.count-1, inSection: 0)
            } else {
                indexPath = self.tableView.indexPathForSelectedRow!
            }
            
            
            deckOverviewVC.deckTitle.title = decks[indexPath!.row].name
        }
    }

    // Other functions
    
    func fetchDeck() {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Deck")
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "name" , ascending: true)
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try moc.executeFetchRequest(fetchRequest)
            decks = results as! [Deck]
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
}

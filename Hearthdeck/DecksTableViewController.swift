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
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    // MARK: - Custom Function

    @IBAction func addNewItem(sender: AnyObject) {
        
        let newDeck: Deck = NSEntityDescription.insertNewObjectForEntityForName("Deck", inManagedObjectContext: moc!) as! Deck
        newDeck.name = "Deck " + String(decks.count+1)
        newDeck.desc = "A new deck"
        newDeck.type = "Mage"
        newDeck.cards = ""
        
        var saveError:NSError?
        if !moc!.save(&saveError) {
            println("Error saving: \(saveError), \(saveError?.userInfo)")
        }

        println(newDeck.name)
        fetchDeck()
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(DeckCellIdentifier, forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = decks[indexPath.row].name
        
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
            
            moc?.deleteObject(decks[indexPath.row] as Deck)
            decks.removeAtIndex(indexPath.row)
            moc?.save(nil)
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
            
            let tabBarController = segue.destinationViewController as! UITabBarController
            let NC1 = tabBarController.viewControllers![0] as! UINavigationController
            let NC2 = tabBarController.viewControllers![1] as! UINavigationController
            let deckOverviewVC = NC1.topViewController as! DeckDetailViewController
            let deckTableVC = NC2.topViewController as! DeckDetailTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            
            deckOverviewVC.deckTitle.title = decks[indexPath.row].name
            deckTableVC.deckTitle = decks[indexPath.row].name
        }
    }

    // Other functions
    
    func fetchDeck() {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Deck")
        var sorter: NSSortDescriptor = NSSortDescriptor(key: "name" , ascending: true)
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.returnsObjectsAsFaults = false
        
        var error : NSError?
        if let results = moc!.executeFetchRequest(fetchRequest, error: &error) as? [Deck] {
            decks = results
        } else {
            println("Fetch failed: \(error)")
            // Handle error ...
        }
    }
    
}

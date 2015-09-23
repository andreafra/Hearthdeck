//
//  CardDetailViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 04/05/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData

class CardDetailViewController: UIViewController {

    // MOC
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var titleBarLabel: UINavigationItem!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var healthLabel: UILabel!
    @IBOutlet var attackLabel: UILabel!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var playerClassLabel: UILabel!
    @IBOutlet var rarityLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var descriptionContainer: UIVisualEffectView!
    @IBOutlet var loadingImageIndicator: UIActivityIndicatorView!

    var card: Card!
    
    var titleBar: String?
    var cost: String?
    var health: String?
    var attack: String?
    var id: String! // From here it fetch
    var playerClass: String?
    var rarity: String?
    var type: String?
    var text: String?
    var imageData: NSData?
    
    //Backup tint colors
    var navbarBackgroundColor: UIColor?
    var navbarTintColor: UIColor?
    var viewBackgroundColor: UIColor?
    var buttonTintColor: UIColor?
    
    override func viewWillAppear(animated: Bool) {
        
        viewBackgroundColor = self.navigationController!.view.backgroundColor
        navbarBackgroundColor = self.navigationController?.navigationBar.backgroundColor
        navbarTintColor = self.navigationController!.navigationBar.barTintColor
        buttonTintColor = self.navigationController!.navigationBar.tintColor
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController!.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController!.navigationBar.barTintColor = UIColor.clearColor()

        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        titleBarLabel.titleView?.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        downloadImage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = false
        self.navigationController!.view.backgroundColor = viewBackgroundColor
        self.navigationController?.navigationBar.backgroundColor = navbarBackgroundColor
        self.navigationController!.navigationBar.barTintColor = navbarTintColor
        
        self.navigationController!.navigationBar.tintColor = buttonTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        titleBarLabel.titleView?.tintColor = UIColor.blackColor()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCard()
        
        titleBarLabel.title = titleBar
        costLabel.text = cost
        healthLabel.text = health
        attackLabel.text = attack
        idLabel.text = id
        playerClassLabel.text = playerClass
        rarityLabel.text = rarity
        typeLabel.text = type
        if card.hasImage {
            cardImageView.image = UIImage(data: imageData!)
        }
        
        descriptionContainer.layer.cornerRadius = 10
        descriptionContainer.clipsToBounds = true
        
        backgroundImage.backgroundColor = UIColor(red:0.304, green:0.28, blue:0.346, alpha:1)
        if card.hasImage {
            backgroundImage.image = UIImage(data: imageData!)
        }
        
//        // Get data from Url
//        func getDataFromUrl(url:NSURL, completion: ((data: NSData?) -> Void)) {
//            NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
//                completion(data: NSData(data: data))
//                }.resume()
//        }
//        
//        // Download the image - start the task
//        func downloadImage(url:NSURL){
//            println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
//            getDataFromUrl(url) { data in
//                dispatch_async(dispatch_get_main_queue()) {
//                    println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
//                    self.cardImageView.image = UIImage(data: data!)
//                }
//            }
//        }
//        
//        // Set the image
//        let baseUrl = "http://wow.zamimg.com/images/hearthstone/cards/enus/medium/" + id + ".png"
//        if let checkedUrl = NSURL(string: baseUrl) {
//            downloadImage(checkedUrl)
//        }
        
        // Make attributed text
        func convertText(inputText: String) -> NSAttributedString {
            
            let attrString = NSMutableAttributedString(string: inputText)
            let boldFont = UIFont(name: "Helvetica-Bold", size: 15.0)!
            
            var r1 = (attrString.string as NSString).rangeOfString("<b>")
            while r1.location != NSNotFound {
                let r2 = (attrString.string as NSString).rangeOfString("</b>")
                if r2.location != NSNotFound  && r2.location > r1.location {
                    let r3 = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length)
                    attrString.addAttribute(NSFontAttributeName, value: boldFont, range: r3)
                    attrString.replaceCharactersInRange(r2, withString: "")
                    attrString.replaceCharactersInRange(r1, withString: "")
                } else {
                    break
                }
                r1 = (attrString.string as NSString).rangeOfString("<b>")
            }
            
            return attrString
        }
        
        textLabel.attributedText = convertText(text!)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchCard() {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Card")
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "id" , ascending: true)
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let results = try moc.executeFetchRequest(fetchRequest)
            let cards = results as! [Card]
            card = cards[0]
            titleBar = card.name
            cost = card.cost.stringValue
            health = card.health.stringValue
            attack = card.attack.stringValue
            playerClass = card.playerClass
            rarity = card.rarity
            type = card.type
            text = card.text
            imageData = card.image
            
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    func downloadImage() {
        if !card.hasImage {
            loadingImageIndicator.startAnimating()
            let quality = "medium"
            let baseUrl = "http://wow.zamimg.com/images/hearthstone/cards/enus/" + quality + "/" + card.id + ".png"
            do {
                card.image = try NSData(contentsOfURL: NSURL(string: baseUrl)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                card.hasImage = true
                do {
                    try moc.save()
                } catch {
                    print("Cannot save: \(error)")
                }
            } catch {
                print("Cannot convert image!")
            }
            loadingImageIndicator.stopAnimating()
            loadingImageIndicator.hidden = true
            cardImageView.image = UIImage(data: card.image)
            backgroundImage.image = UIImage(data: card.image)
        }
    }
}

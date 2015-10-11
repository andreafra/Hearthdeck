//
//  IntroViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 12/05/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData

class IntroViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var languagePickerView: CustomView!
    @IBOutlet var languagePicker: UIPickerView!
        
    @IBOutlet var downloadImagesView: CustomView!
    @IBOutlet var downloadImages: UISwitch!
    
    @IBOutlet var loadingView: CustomView!
    
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var loadingBar: UIProgressView!
    var downloadProgress: Float = 0
    
    @IBOutlet var endSetupButton: UIButton!
    
    // Languages and sets for the initialise func later
    let languages = ["zhCN", "zhTW", "enGB", "enUS", "frFR", "deDE", "itIT", "koKR", "plPL", "ptBR", "ptPT", "ruRU", "esMX", "esES"]
    let languagesDescription = ["Chinese", "Chinese (Taiwan)", "English (British)", "English (US)", "French", "Tedesco", "Italian", "Korean", "Polish", "Portuguese (Brazilian)", "Portuguese", "Russian", "Spanish (Mexican)", "Spanish"]
    var selectedLanguage: String = "enUS"
    
    var howManyCards: Float = 0
    var howManyCardsAdded: Float = 0
    var howManySetDone: Float = 0
    
    let cardSets = ["Basic","Blackrock Mountain","Classic",/*"Credits",*/"Curse of Naxxramas",/*"Debug",*/"Goblins vs Gnomes",/*"Missions",*/ "Promotion","Reward", /*"System",*/ "The Grand Tournament"]
    
    // core data
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var existingCards = [Card]()

    var duplicatedCards = [Card]()
    
    // Start the setup
    @IBAction func startSetup(sender: AnyObject) {

        loadingView.hidden = false
        
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModeCubic, animations: {
        
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2, animations: {
                // fade
                self.languagePickerView.center.y *= 2
                self.downloadImagesView.center.y *= 2
                self.languagePickerView.alpha = 0
                self.downloadImagesView.alpha = 0
            })
            UIView.addKeyframeWithRelativeStartTime(1/2, relativeDuration: 1/2, animations: {
                //fade & move up
                self.loadingView.center = self.view.center
                self.loadingView.alpha = 1
                self.loadingView.layer.cornerRadius = 5
                self.view.backgroundColor = UIColor.lightGrayColor()
                self.bottomView.center.y += self.bottomView.frame.height
            })
            
        
            }, completion: {
                (value: Bool) in
                
                
                self.performSelectorInBackground("initialiseHearthdeckDatabase", withObject: nil)
                //self.initialiseHearthdeckDatabase()
                
                print("Setting up complete!")
                self.view.userInteractionEnabled = true
                
        })
    }
    
    @IBAction func endSetup(sender: AnyObject) {
        // Back to main menu
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        languagePicker.delegate = self
        languagePicker.dataSource = self
        
        endSetupButton.enabled = false
        endSetupButton.hidden = true
        
        loadingBar.progress = 0
        loadingView.alpha = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languagesDescription.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languagesDescription[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabel()
    }
    
    func updateLabel(){
        let theLang = languages[languagePicker.selectedRowInComponent(0)]
        print(theLang)
        selectedLanguage = theLang
    }
    
    func initialiseHearthdeckDatabase() {
        
        let moc = self.managedObjectContext
        
        // DO: - Setup JSON
        
        // Data path
        let path = NSBundle.mainBundle().pathForResource("cardListLocalized", ofType: "json"),
        url = NSURL(fileURLWithPath: path!),
        data = NSData(contentsOfURL: url)
        
        let jsonOptional: AnyObject!
        do {
            jsonOptional = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
        } catch {
            print(error)
            jsonOptional = nil
        }

        // DO: - Count how many card in total
        
        // Count how many cards
        if let json = jsonOptional as? Dictionary<String, AnyObject> {
            
            // for theLanguage in languages  //LET'S USE A LANGUAGE THAT THE USER CHOOSE.
            if let language = json[selectedLanguage] as? Dictionary<String, AnyObject> {
                
                for set in cardSets {
                    if let theSet = language[set] as? Array<Dictionary<String, AnyObject>> {
                    howManyCards += Float(theSet.count)
                    }
                }
            }
        }

        // Cycle through sets
        if let json = jsonOptional as? Dictionary<String, AnyObject> {
            
            //LET'S USE A LANGUAGE THAT THE USER CHOOSE.
            if let language = json[selectedLanguage] as? Dictionary<String, AnyObject> {
                
                for set in cardSets {
                    if let theSet = language[set] as? Array<Dictionary<String, AnyObject>> {
                        
                        for (var i = 0; i < theSet.count; i++) {
                            let card = theSet[i] as Dictionary<String, AnyObject>
                            if let name = card["name"] as? String { // all
                                if let id = card["id"] as? String { // all
                                    
                                    // DO: - Fetch existing cards
                                    let fetchRequest = NSFetchRequest(entityName: "Card")
                                    do {
                                        let results = try moc.executeFetchRequest(fetchRequest)
                                        let cards = results as! [Card]
                                        if !results.isEmpty {
                                            for x: Card in cards {
                                                if x.id == id {
                                                    //println("ID c'è già")
                                                    moc.deleteObject(x)
                                                    do {
                                                        try moc.save()
                                                    } catch _ {
                                                    }
                                                }
                                            }
                                        }
                                        
                                        
                                    } catch {
                                        print(error)
                                    }
                                    
                                    if let cost = card["cost"] as? Int { // all
                                        if let type = card["type"] as? String { // all
                                            if let rarity = card["rarity"] as? String { // all
                                                if let collectible = card["collectible"] as? Bool { // all
                                                    var text = card["text"] as? String
                                                    var flavor = card["flavor"] as? String
                                                    var playerClass = card["playerClass"] as? String
                                                    var mechanics = card["mechanics"] as? Array<String>
                                                    var attack = card["attack"] as? Int
                                                    var health = card["health"] as? Int
                                                    var durability = card["durability"] as? Int
                                                    
                                                    if text == nil {
                                                        text = ""
                                                    }
                                                    if flavor == nil {
                                                        flavor = ""
                                                    }
                                                    if playerClass == nil {
                                                        playerClass = "Neutral"
                                                    }
                                                    if mechanics == nil {
                                                        mechanics = []
                                                    }
                                                    if attack == nil {
                                                        attack = 0
                                                    }
                                                    if health == nil {
                                                        health = 0
                                                    }
                                                    if durability == nil {
                                                        durability = 0
                                                    }
                                                    
                                                    var imageData: NSData?
                                                    var thumbnailData: NSData?
                                                    
                                                    if downloadImages.on {
                                                        // Download image
                                                        let baseUrl = "http://wow.zamimg.com/images/hearthstone/cards/enus/medium/" + id + ".png"
                                                        do {
                                                            imageData = try NSData(contentsOfURL: NSURL(string: baseUrl)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                                                        } catch {
                                                            print(error)
                                                            imageData = nil
                                                        }
                                                        // Create thumbnail
                                                        var tempImg = UIImage(data: imageData!)
                                                        var h: CGFloat!
                                                        if type == "Spell" {
                                                            h = 70
                                                        } else {
                                                            h = 50
                                                        }
                                                        tempImg = Toucan.Util.croppedImageWithRect(tempImg!, rect: CGRectMake(tempImg!.size.width/2-35, h, 70, 70))
                                                        tempImg = Toucan(image: tempImg!).maskWithEllipse().image
                                                        
                                                        thumbnailData =  UIImagePNGRepresentation(tempImg!)
                                                        
                                                        print("Downloaded \(name)")
                                                    } else {
                                                        // Used placeholder
                                                        imageData = NSData()
                                                        thumbnailData = NSData()
                                                        print("Placeholdered \(name)")
                                                    }
                                                    
                                                    
                                                    
                                                    // Save the card to the Core Data
                                                    Card.createCardInManagedObjectContext(moc, name: name, id: id, cost: cost, type: type, rarity: rarity, text: text!, flavor: flavor!, attack: attack!, health: health!, playerClass: playerClass!, durability: durability!, image: imageData!, hasImage: downloadImages.on, collectible: collectible, thumbnail: thumbnailData!, owned: false)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    howManySetDone += 1
                    performSelectorOnMainThread("setDownloadProgressBar:", withObject: howManySetDone, waitUntilDone: false)
                }
            }
        }
        
        endSetupButton.enabled = true
        endSetupButton.hidden = false
    }
    
    func setDownloadProgressBar(value: Float) {
        
        let _value = howManySetDone / Float(cardSets.count)
        loadingBar.setProgress(_value, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
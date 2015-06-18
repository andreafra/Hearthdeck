//
//  CardDetailViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 04/05/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {

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

    var titleBar: String!
    var cost: String!
    var health: String!
    var attack: String!
    var id: String!
    var playerClass: String!
    var rarity: String!
    var type: String!
    var text: String!
    var imageData: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleBarLabel.title = titleBar
        costLabel.text = cost
        healthLabel.text = health
        attackLabel.text = attack
        idLabel.text = id
        playerClassLabel.text = playerClass
        rarityLabel.text = rarity
        typeLabel.text = type
        cardImageView.image = UIImage(data: imageData)
        
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
        
        textLabel.attributedText = convertText(text)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//
//  Functions.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 26/09/15.
//  Copyright © 2015 Qubex_. All rights reserved.
//

import UIKit

// Make attributed text
func convertText(inputText: String, sizeInPt: Int) -> NSAttributedString {
    
    var cardDesc = inputText
    
    // Embed in a <span> for font attributes:
    cardDesc = "<span style=\"font-family: Helvetica; font-size:" + sizeInPt.description + "pt;\">" + cardDesc + "</span>"
    
    let data = cardDesc.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!
    var attrStr:NSAttributedString?
    do {
        attrStr = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
    } catch {
        print(error)
    }
    return attrStr!
}

// Draw column chart

func drawChart(containerView: UIView) {
    
    //VARIABLES - GET
    //get bottom-left coordinates
    
    let originX = containerView.frame.origin.x - containerView.frame.width/2
    let originY = containerView.frame.origin.y - containerView.frame.height/2
    
    let testRect = UIView(frame: CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, 5, 5))
    testRect.backgroundColor = UIColor.redColor()
    
    containerView.addSubview(testRect)
    
    print(originX)
    print(originY)
}
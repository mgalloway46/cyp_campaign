//
//  NavigationBarViewController.swift
//  cyp_campaign
//
//  Created by Matt Galloway on 6/22/18.
//  Copyright © 2018 Matt Galloway. All rights reserved.
//

import UIKit

class HeaderViewController: UIViewController {
    func buildHeader(vc : UIViewController, titleText : String) -> CGFloat {
        // Set a width for the logo layer to be a sixth of the screen
        let logoWidth = vc.view.bounds.size.width/6
        let logoHeight = logoWidth * 13/16
        
        // Load the logo for the header
        let logo = UIImage(named: "Logo icon")?.cgImage!

        // Create layer for the logo
        let logoLayer = CALayer()

        // Set the size of the layer
        logoLayer.bounds = CGRect(x: 0,
                                  y: 0,
                                  width: logoWidth,
                                  height: logoHeight)
        
        // Set the position of the layer to be in the middle and just below the navigation bar
        let yPositionLogo = logoHeight/2
//            + ((vc.navigationController?.navigationBar.frame.origin.y)! ?? 0.0
//            + (vc.navigationController?.navigationBar.frame.height)! ?? 0.0

        logoLayer.position = CGPoint(x: vc.view.bounds.size.width/2,
                                     y: yPositionLogo)
        
        // Add the logo to the layer
        logoLayer.contents = logo
        
        
        
        // Set a width for the header to be the width of the screen and a height of 20
        let headerWidth = vc.view.bounds.size.width
        let headerHeight =  (CGFloat)(20)
        
        // Create the label for the title
        let headerLabel = UILabel(frame: CGRect(x: 0,
                                                y: 0,
                                                width: headerWidth,
                                                height: headerHeight))
        
        // Set the position of the campaignLabel to be in the middle and just below the logo
        let yPositionHeader = yPositionLogo + logoHeight/2 + headerHeight/2
        headerLabel.center = CGPoint(x: vc.view.bounds.size.width/2,
                                     y: yPositionHeader)
        
        // Set test styles
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont (name: "HelveticaNeue-Bold", size: 14)
        
        // Set the actual text
        headerLabel.text = "CAMPAIGN MODE"
        
        
        
        // Set a width for the title to be the width of the screen and a height of 40
        let titleWidth = vc.view.bounds.size.width
        let titleHeight =  (CGFloat)(40)
        
        // Create the label for the title
        let titleLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: titleWidth,
                                               height: titleHeight))
        
        // Set the position of the campaignLabel to be in the middle and just below the logo
        let yPositionTitle = yPositionLogo + logoHeight/2 + headerHeight/2 + (titleHeight * 3/2)
        titleLabel.center = CGPoint(x: vc.view.bounds.size.width/2,
                                    y: yPositionTitle)
        
        // Set test styles
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 28)
        
        // Set the actual text
        titleLabel.text = titleText
        
        // Create header background layer
        let bgLayer = CALayer()
        
        // Set the height of the header background layer
        let bgLayerHeight = yPositionTitle + titleHeight/2
        
        // Set the y position for the header background layer
        let yPositionBG = bgLayerHeight/2
        
        // Set the header background color
        bgLayer.backgroundColor = UIColor.green.cgColor
        
        // Set the size of the background color layer
        bgLayer.bounds = CGRect(x: 0,
                                y: 0,
                                width: vc.view.bounds.size.width/2,
                                height: bgLayerHeight)
        
        // Set the position of the background color layer
        bgLayer.position = CGPoint(x: vc.view.bounds.size.width/2,
                                   y: yPositionBG)
        
        // Add the background color layer to the view
        vc.view.layer.addSublayer(bgLayer)
        
        // Add the title label to the view
        vc.view.addSubview(titleLabel)
        
        // Add the logo layer to the view
        vc.view.layer.addSublayer(logoLayer)
        
        // Add the label to the view
        vc.view.addSubview(headerLabel)
        
        // return the bottom of the header
        return yPositionBG + bgLayerHeight/2
    }
}

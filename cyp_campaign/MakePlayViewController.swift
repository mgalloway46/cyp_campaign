//
//  MakePlayViewController.swift
//  cyp_campaign
//
//  Created by Matt Galloway on 6/19/18.
//  Copyright © 2018 Matt Galloway. All rights reserved.
//

import UIKit

protocol MakePlayDelegate {
    func updateTitle(title : String)
    func currentPage() -> String
}

class MakePlayViewController: UIViewController, MakePlayDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    var innerViewDelegate : InnerViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle(title: "Choose League")
    }
    
    // Set delegates as the embedded view is loaded
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContainerEmbedInner" {
            let navView = segue.destination as? UINavigationController
            let innerView = navView?.viewControllers.first as! InnerViewController
            innerView.makePlayDelegate = self
        }
    }
    
    // Change the title text
    func updateTitle(title: String) {
        titleLabel.text = title
    }
    
    // Step the inner view back and update the title, unless you are on the first screen,
    //  then just return home
    @IBAction func backBtnPressed(_ sender: Any) {
        var numOfLinesNeeded : Int?
        if currentBet.objective != nil {
            numOfLinesNeeded = innerViewDelegate?.numOfLinesForObjective(objective: currentBet.objective!)
        }
        switch titleLabel.text {
        case "Choose League":
            performSegue(withIdentifier: "ReturnHome", sender: nil)
        case "Choose Objective":
            innerViewDelegate?.stepBack()
            updateTitle(title: "Choose League")
        case "Choose Duration":
            innerViewDelegate?.stepBack()
            updateTitle(title: "Choose Objective")
        case "Summary":
            innerViewDelegate?.stepBack()
            if numOfLinesNeeded == 1 {
                updateTitle(title: "Choose Line")
            } else {
                let title = "Choose Line (" + String(currentBet.lines.count + 1)
                    + " of " + String(numOfLinesNeeded!) + ")"
                updateTitle(title: title)
            }
        default:
            if (titleLabel.text?.contains("Choose Line"))! {
                innerViewDelegate?.stepBack()
                if numOfLinesNeeded == 1 {
                    updateTitle(title: "Choose Duration")
                } else {
                    let title = "Choose Duration (" + String(currentBet.lines.count + 1)
                        + " of " + String(numOfLinesNeeded!) + ")"
                    updateTitle(title: title)
                }
            } else if (titleLabel.text?.contains("Choose Duration (1 of "))! {
                innerViewDelegate?.stepBack()
                updateTitle(title: "Choose Objective")
            } else if (titleLabel.text?.contains("Choose Duration ("))! {
                innerViewDelegate?.stepBack()
                if numOfLinesNeeded == 1 {
                    updateTitle(title: "Choose Line")
                } else {
                    let title = "Choose Line (" + String(currentBet.lines.count + 1)
                        + " of " + String(numOfLinesNeeded!) + ")"
                    updateTitle(title: title)
                }
            } else {
                performSegue(withIdentifier: "~", sender: nil)
            }
        }
    }
    
    // Reuturn the current title
    func currentPage() -> String {
        return titleLabel.text!
    }
}


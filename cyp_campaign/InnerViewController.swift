//
//  InnerViewController.swift
//  cyp_campaign
//
//  Created by Matt Galloway on 6/22/18.
//  Copyright © 2018 Matt Galloway. All rights reserved.
//

import UIKit
import QuartzCore

protocol InnerViewDelegate {
    func stepBack()
}

struct Bet {
    // The index of the league the bet is placed in (Correlates to the leaguesArray)
    var leagueIndex : Int?
    // The index of the objective the bet is placed in (Correlates to the objectivesArray)
    var objectiveIndex : Int?
    // The lines of the bet. Could be just one line if it is a normal bet or many if it is a parlay
    var lines: [Line]
    // The amount placed on the bet
    var wagerAmount : Int?
}

struct Line {
    // The ID to obtain the game from the database
    var GameName: String?
    // The name of the bet they are placing. I.E. could be: "draw" (for soccer), "Bulls", "over"
    var teamFor : String?
    // The spread for the line
    var spread : Int?
    // The line (i.e. -110, +205, etc)
    var line : Int?
}

struct Game {
    var name : String?
    var duration : String?

    var underdogTeam : String?
    var favoredTeam : String?

    var spread : Float?
    var spreadLine : Int?

    var overunderSpread : Float?
    var overunderLine : Int?

    var monylineFavored : Int?
    var moneylineUnderdog : Int?
}

class LineTableViewCell: UITableViewCell {
    var title : String = "test"
    
    @IBAction func awaySpreadPressed(_ sender: Any) {
        print(title)
    }
    
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var awayTeamIcon: UIImageView!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var homeTeamIcon: UIImageView!
}

class InnerViewController: UITableViewController, InnerViewDelegate {
    // Variables
    var makePlayDelegate : MakePlayDelegate?
    let leaguesArray = ["MLB","NBA","NFL","NHL","FIFA","NCAAB","NCAAF","ALL","Featured Play"]
    
    // NOTE: This code identifies if a bet is a parlay by searching for the word "Parlay" in the
    //  objective. If it finds that, it grabs the first number in the objective string. Keep this
    //  in mind when making objectives. See numOfLinesForObjective(objectives : String)
    let objectivesArray = ["Win 2 Bets","Win 5 Bets","Win 10 Bets","Win 2 Team Parlay","Win 3 Team Parlay","Win 4 Team Parlay"]
    let durationsArray = ["Full Game","First Half","Second Half","First Quarter","Second Quarter","Third Quarter","Fourth Quarter"]
    
    let game1 = Game(
        name : "Toronto Raptors vs. Boston Celtics",
        duration : "Full Game",
        underdogTeam: "TOR",
        favoredTeam: "BOS",
        spread : 2,
        spreadLine : -110,
        overunderSpread : 204,
        overunderLine : -110,
        monylineFavored : -135,
        moneylineUnderdog : 160
    )

    let game2 = Game(
        name: "Cleveland Caveliers vs Golden State Warriors",
        duration : "Full Game",
        underdogTeam: "CLE",
        favoredTeam: "GSW",
        spread : 5.5,
        spreadLine : -110,
        overunderSpread : 201.5,
        overunderLine : -105,
        monylineFavored : -155,
        moneylineUnderdog : 170
    )
    
    var games : [Game] = []
    
    var currentBet = Bet(leagueIndex: nil, objectiveIndex: nil, lines: [], wagerAmount: nil)
    
    // Called every time the innerViewController is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        games = [game1,game2]
        
        let navView = parent as? UINavigationController
        let containerView = navView?.parent as! MakePlayViewController
        
        // Only set the delegate if it hasnt been set yet
        if (containerView.innerViewDelegate == nil){
            containerView.innerViewDelegate = self
        }
    }
    
    // Function to tell the dynamic table view the amount of sections (always 1) in the table
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Always only 1 section
        return 1
    }
    
    // Function to tell the dynamic table view the amount of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentPage = makePlayDelegate?.currentPage()
        switch currentPage {
        case "Choose League":
            return leaguesArray.count
        case "Choose Objective":
            return objectivesArray.count
        case "Choose Duration":
            return durationsArray.count
        case "Choose Line":
            return games.count
        default:
            if (currentPage?.contains("Choose Duration ("))! {
                return durationsArray.count
            } else if (currentPage?.contains("Choose Line ("))! {
                return games.count
            } else {
                // Error case: just return 0
                return 0
            }
        }
    }

    
    // Function for what to do when a row is selected in the dynamic table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentPage = makePlayDelegate?.currentPage()

        switch currentPage {
        case "Choose League":
            // If a row was selected on the league selection table, set that as the current league
            currentBet.leagueIndex = indexPath.row
            performSegue(withIdentifier: "LeaguesToObjectives", sender: nil)
        case "Choose Objective":
            // If a row was selected on the objective selection table, set that as the current objective
            currentBet.objectiveIndex = indexPath.row
            switch numOfLinesForObjective(objective: objectivesArray[currentBet.objectiveIndex!]) {
            case 1:
                performSegue(withIdentifier: "ObjectivesToDurations-Single", sender: nil)
            default:
                performSegue(withIdentifier: "ObjectivesToDurations-Parlay", sender: nil)
            }
        case "Choose Duration":
            performSegue(withIdentifier: "DurationsToLines-Single", sender: nil)
        default :
            if (currentPage?.contains("Choose Duration (1 of "))! {
                performSegue(withIdentifier: "DurationsToLines-Parlay", sender: nil)
            }
            // Error case: perform seque that has no mathcing identifier: so that an error will be thrown
            performSegue(withIdentifier: "~", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentPage = makePlayDelegate?.currentPage()

        if currentPage == "Choose Line" {
            return CGFloat(150)
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    // Function to build the dynamic table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentPage = makePlayDelegate?.currentPage()

        switch currentPage {
        case "Choose League":
            // Build league table
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeagueCell", for: indexPath)
            
            // Set the text
            cell.textLabel?.text = leaguesArray[indexPath.row]
            
            // Set the logo
            cell.imageView?.image = UIImage(named: (leaguesArray[indexPath.row] + " icon"))
            
            // Set the accessory
            cell.accessoryView = UIImageView(image: UIImage(named: ("Pin icon")))
            
            return cell
        case "Choose Objective":
            // build objective table
            let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectiveCell", for: indexPath)
            
            // Set the text
            cell.textLabel?.text = objectivesArray[indexPath.row]
            
            // Set the logo
            cell.imageView?.image = UIImage(named: (leaguesArray[currentBet.leagueIndex!] + " icon"))
            
            // Set the accessory
            cell.accessoryView = UIImageView(image: UIImage(named: ("Pin icon")))
            
            return cell
        case "Choose Duration":
            // build objective table
            let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath)
            
            // Set the text
            cell.textLabel?.text = durationsArray[indexPath.row]
            
            // Set the logo
            cell.imageView?.image = UIImage(named: (leaguesArray[currentBet.leagueIndex!] + " icon"))
            
            // Set the accessory
            cell.accessoryView = UIImageView(image: UIImage(named: ("Pin icon")))
            
            return cell
        case "Choose Line":
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell", for: indexPath) as! LineTableViewCell
            
            cell.awayTeamLabel.text = games[indexPath.row].favoredTeam
            
            cell.title = "CHANGED!!"
            
            return cell
        default:
            if (currentPage?.contains("Choose Duration ("))! {
                // build objective table
                let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath)
                
                // Set the text
                cell.textLabel?.text = durationsArray[indexPath.row]
                
                // Set the logo
                cell.imageView?.image = UIImage(named: (leaguesArray[currentBet.leagueIndex!] + " icon"))
                
                // Set the accessory
                cell.accessoryView = UIImageView(image: UIImage(named: ("Pin icon")))
                
                return cell
            } else {
                // Error case: Return a cell for now so it doesnt cause errors, it should throw
                //  an error automaticlaly if this case occurs, since the identifier does not exist
                //  in the story board
                return tableView.dequeueReusableCell(withIdentifier: "~", for: indexPath)
            }
        }
    }
    
    // Segue function to make sure that the bet is passed to the next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LeaguesToObjectives" {
            makePlayDelegate?.updateTitle(title: "Choose Objective")
        } else if segue.identifier == "ObjectivesToDurations-Single" {
            makePlayDelegate?.updateTitle(title: "Choose Duration")
        } else if segue.identifier == "ObjectivesToDurations-Parlay" {
            let totalLines = String(numOfLinesForObjective(objective: objectivesArray[currentBet.objectiveIndex!]))
            let title = "Choose Duration (1 of " + totalLines + ")"
            makePlayDelegate?.updateTitle(title: title)
        } else if segue.identifier == "DurationsToLines-Single" {
            makePlayDelegate?.updateTitle(title: "Choose Line")
        }
        // Pass the Delegate data to the next innerViewController
        let next = segue.destination as! InnerViewController
        next.makePlayDelegate = self.makePlayDelegate
        
        // Pass the bet to the next innerViewController
        next.currentBet = self.currentBet
    }
    
    // Helper function to pop the navigation controller back and deselect the value
    func stepBack() {
        // If you deselect the league, the league must be set back to nil
        if makePlayDelegate?.currentPage() == "Choose Objective" {
            currentBet.leagueIndex = nil
        // If you deselect the objective, the objective must be set back to nil
        } else if makePlayDelegate?.currentPage() == "Choose Duration" {
            currentBet.objectiveIndex = nil
        } else if makePlayDelegate?.currentPage() == "Choose Line" {
            // TODO
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // Obviously this function is uninteligent, but it should be good for now
    func numOfLinesForObjective(objective : String) -> Int  {
        if (objective.contains(" 2 Team Parlay")) {
            return 2
        } else if (objective.contains(" 3 Team Parlay")) {
            return 3
        } else if (objective.contains(" 4 Team Parlay")) {
            return 4
        } else if (objective.contains(" 5 Team Parlay")) {
            return 5
        } else if (objective.contains(" 6 Team Parlay")) {
            return 6
        } else if (objective.contains(" 7 Team Parlay")) {
            return 7
        } else if (objective.contains(" 8 Team Parlay")) {
            return 8
        } else if (objective.contains(" 9 Team Parlay")) {
            return 9
        } else if (objective.contains(" 10 Team Parlay")) {
            return 10
        } else {
            return 1
        }
    }
    
    @IBAction func helloBtn(sender:UIButton){
        print("BUTTON")
    }
    
}

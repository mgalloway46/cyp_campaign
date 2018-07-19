//
//  InnerViewController.swift
//  cyp_campaign
//
//  Created by Matt Galloway on 6/22/18.
//  Copyright © 2018 Matt Galloway. All rights reserved.
//

import UIKit
import QuartzCore

/* ATTENTION: PLEASE READ
 
 PLEASE ASK QUESTIONS IF ANY CLARIFICATION IS NEEDED! If any bugs are discovered, please report them to me, Matt Galloway
 
 ============================FOR TESTING============================
 
 Right now, there is no backend server for me to read data from to get the upcoming games "today," so as
 you can see below, I created some mock structs and mock data that I read from. So right now, the code grabs
 data from arrays and structs, but essentially, that code will eventually pull from the backend API to get a
 JSON with all that data and use it that way. But for right now, since the backend is not created for the
 campaign mode, thats not possible. So instead, I created two sample games that the game reads from to
 populate the screens. Therefore, to test the code out of the box, the only thing that is supported
 right now is selecting NBA since it automatically sends that games array which is only populated with NBA games.
 
 To make this work for another sport, you just need to simulate a different response from the backend server:
 that means you should create new Game structs and place those in the games array in place of the games that are
 currently there. This is becuase this code assumes that the games array has been correctly populated with all the
 games for the desired league. So this code is fully functional as long as games is populated with all the desired
 games. If this code seems to be brittle or hard coded, its really not. Please contact me with any questions so
 that I can possibly clear up any misunderstanding. Some functions may seem unintelligent, but that is because I have
 expedited this code so that you guys can effectively see this application in action. I have complete understanding
 how to make this code more intelligent and cleaner and will do that in the future, but I also believe that all the
 code in place right now should be very adequate and should be able to handle all that is exepected of it. Be sure
 to see the "UPCOMING IMPLEMENTATIONS" section below to see what I plan to work on this next week.
 
 Additionally, the cells on the summary screen are obviously not what we want for the end product (this is one of
 my "upcoming implmentations" in the section below). But for right now, it displays all the information available
 which makes it easy to test and make sure all the correct values are used.
 
 Finally for testing, the app should support all models of the iPhone from 5s to the X. I suggest that you really
 try to see how durable my code is. For example, if you select to create a new 4 team parlay and select the first
 duration to be a full game spead, then if you continue onto the second line and third line and fourth line all
 the way to the summary screen, you can then back step all the way to the the "Choose Line" screen again and
 change the team you were betting on and continue all the way back to the summary screen. You should notice
 that the app was able to remember the duration of that first bet and should have been able to change the team
 that was bet while still keeping the duration the same (even when the duration was not re-selected).
 
 ============================MY UPCOMING IMPLEMENTATIONS============================
 
 Here are the implementations that I still have planned to make on this project. So if something is missing, it
 is probably here and in development:
 
    (Tasks have been importeed to asana)
 
 */

// ============================DELEGATES============================
protocol InnerViewDelegate {
    func stepBack()
    func numOfLinesForObjective(objective : String) -> Int
    func convertLineToString(line : Int?) -> String
    func convertSpreadToString(spread : Float?) -> String
    func addLineToBet(newLine : Line)
}

// ============================BET STRUCTS============================
public struct Bet {
    // The index of the league the bet is placed in (Correlates to the leaguesArray)
    var league : String?
    // The index of the objective the bet is placed in (Correlates to the objectivesArray)
    var objective : String?
    // The lines of the bet. Could be just one line if it is a normal bet or many if it is a parlay
    var lines: [Line]
    // The amount placed on the bet
    var wagerAmount : Int?
}

public struct Line {
    // The ID to obtain the game from the database
    var gameName: String?
    // The name of the bet they are placing. I.E. could be: "draw (3-way)" (for soccer), "Real Madrid (2-way)" (also for soccer), "Bulls", "over"
    var bettingOn : String?
    // The spread for the line (nil when the bet is a moneyline or soccer draws)
    var spread : Float?
    // The line (i.e. -110, +205, etc)
    var line : Int?
    // The index of the duraction of the line
    var duration: String?
}

// ============================GLOBAL BET VARIABLES============================
public var currentLineDuration : String?
public var currentBet : Bet = Bet(league: nil,
                                  objective: nil,
                                  lines: [],
                                  wagerAmount: nil)

// ============================MOCK OBJECTS============================

// Mock Leagues  - I assume this should evetually be pulled from the backend
public var leaguesArray = ["MLB",
                           "NBA",
                           "NFL",
                           "NHL",
                           "FIFA",
                           "NCAAB",
                           "NCAAF",
                           "ALL",
                           "Featured Play"]

// Mock Objectives - I assume this should evetually be pulled from the backend
public var objectivesArray = ["Win 2 Bets",
                              "Win 5 Bets",
                              "Win 10 Bets",
                              "Win 2 Team Parlay",
                              "Win 3 Team Parlay",
                              "Win 4 Team Parlay",
                              "Win 5 Team Parlay",
                              "Win 6 Team Parlay",
                              "Win 7 Team Parlay",
                              "Win 8 Team Parlay",
                              "Win 9 Team Parlay",
                              "Win 10 Team Parlay"]

// Mock Durations - I assume this should evetually be pulled from the backend
public var durationsArray = ["Full Game",
                             "First Half",
                             "Second Half",
                             "First Quarter",
                             "Second Quarter",
                             "Third Quarter",
                             "Fourth Quarter"]

// Temporary struct to inject mocks
public struct Game {
    var gameName : String?
    
    var homeTeamName : String?
    var awayTeamName : String?
    
    var homeTeamSpread : Float?
    var homeTeamSpreadLine : Int?
    
    var awayTeamSpread : Float?
    var awayTeamSpreadLine : Int?
    
    var overUnderSpread : Float?
    var overUnderSpreadLine : Int?
    
    var homeTeamMoneylineLine : Int?
    var awayTeamMoneylineLine : Int?
}

// Mock Game 1
public var game1 = Game(gameName : "TOR @ BOS",
                        homeTeamName: "TOR",
                        awayTeamName: "BOS",
                        homeTeamSpread : 2,
                        homeTeamSpreadLine : -110,
                        awayTeamSpread: -2,
                        awayTeamSpreadLine: -110,
                        overUnderSpread : 204,
                        overUnderSpreadLine : -110,
                        homeTeamMoneylineLine : 160,
                        awayTeamMoneylineLine : -135)

// Mock Game 2
public var game2 = Game(gameName: "MIA @ CLE",
                        homeTeamName: "MIA",
                        awayTeamName: "CLE",
                        homeTeamSpread : -4,
                        homeTeamSpreadLine : -110,
                        awayTeamSpread: 4,
                        awayTeamSpreadLine: -110,
                        overUnderSpread : 208.5,
                        overUnderSpreadLine : -110,
                        homeTeamMoneylineLine : -160,
                        awayTeamMoneylineLine : 200)


// Initialize the mock games array
public var games : [Game] = [game1,
                             game2]

// ============================DYNAMIC CUSTOM CELL CLASSES============================

// "Choose Line" Screen dynamic custom cell class
class LineTableViewCell: UITableViewCell {
    var innerViewDelegate : InnerViewDelegate?
    
    var league : String?
    var gameName : String?
    var homeTeamName : String?
    var awayTeamName : String?
    var homeTeamSpread : Float?
    var homeTeamSpreadLine : Int?
    var awayTeamSpread : Float?
    var awayTeamSpreadLine : Int?
    var overUnderSpread : Float?
    var overUnderSpreadLine : Int?
    var homeTeamMoneylineLine : Int?
    var awayTeamMoneylineLine : Int?
    
    @IBAction func awayTeamSpreadBtnPressed(_ sender: Any) {
        let newLine = Line(gameName: gameName,
                           bettingOn: awayTeamName,
                           spread: awayTeamSpread,
                           line: awayTeamSpreadLine,
                           duration: currentLineDuration)
        innerViewDelegate?.addLineToBet(newLine: newLine)
    }
    
    @IBAction func awayTeamMoneylineBtnPressed(_ sender: Any) {
        let newLine = Line(gameName: gameName,
                           bettingOn: awayTeamName,
                           spread: nil,
                           line: awayTeamMoneylineLine,
                           duration: currentLineDuration)
        innerViewDelegate?.addLineToBet(newLine: newLine)
    }
    @IBAction func underBtnPressed(_ sender: Any) {
        let newLine = Line(gameName: gameName,
                           bettingOn: "UNDER",
                           spread: overUnderSpread,
                           line: overUnderSpreadLine,
                           duration: currentLineDuration)
        innerViewDelegate?.addLineToBet(newLine: newLine)
    }

    @IBAction func homeTeamSpreadBtnPressed(_ sender: Any) {
        let newLine = Line(gameName: gameName,
                           bettingOn: homeTeamName,
                           spread: homeTeamSpread,
                           line: homeTeamSpreadLine,
                           duration: currentLineDuration)
        innerViewDelegate?.addLineToBet(newLine: newLine)
    }

    @IBAction func homeTeamMoneylineBtnPressed(_ sender: Any) {
        let newLine = Line(gameName: gameName,
                           bettingOn: homeTeamName,
                           spread: nil,
                           line: homeTeamMoneylineLine,
                           duration: currentLineDuration)
        innerViewDelegate?.addLineToBet(newLine: newLine)
    }

    @IBAction func overBtnPressed(_ sender: Any) {
        let newLine = Line(gameName: gameName,
                           bettingOn: "OVER",
                           spread: overUnderSpread,
                           line: overUnderSpreadLine,
                           duration: currentLineDuration)
        innerViewDelegate?.addLineToBet(newLine: newLine)
    }
    
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var awayTeamIcon: UIImageView!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var homeTeamIcon: UIImageView!

    @IBOutlet weak var awayTeamSpreadBtn: UIButton!
    @IBOutlet weak var awayTeamMoneylineBtn: UIButton!
    @IBOutlet weak var underBtn: UIButton!

    @IBOutlet weak var homeTeamSpreadBtn: UIButton!
    @IBOutlet weak var homeTeamMoneylineBtn: UIButton!
    @IBOutlet weak var overBtn: UIButton!
    
    func initializeCell() {
        homeTeamLabel.text = homeTeamName
        awayTeamLabel.text = awayTeamName
        
        // Build text in the temporary variable to make code cleaner
        var textHolder : String
        
        textHolder = league! + " " + awayTeamName!
        awayTeamIcon.image = UIImage(named: textHolder)
        
        textHolder = league! + " " + homeTeamName!
        homeTeamIcon.image = UIImage(named: textHolder)

        textHolder = ((innerViewDelegate?.convertSpreadToString(spread: awayTeamSpread))! + " (" +  (innerViewDelegate?.convertLineToString(line: awayTeamSpreadLine))! + ")")
        awayTeamSpreadBtn.setTitle(textHolder, for: .normal)

        textHolder = ((innerViewDelegate?.convertSpreadToString(spread: homeTeamSpread))!
            + " (" +  (innerViewDelegate?.convertLineToString(line: homeTeamSpreadLine))! + ")")
        homeTeamSpreadBtn.setTitle(textHolder, for: .normal)

        textHolder = (innerViewDelegate?.convertLineToString(line: awayTeamMoneylineLine))!
        awayTeamMoneylineBtn.setTitle(textHolder, for: .normal)

        textHolder = (innerViewDelegate?.convertLineToString(line: homeTeamMoneylineLine))!
        homeTeamMoneylineBtn.setTitle(textHolder, for: .normal)

        textHolder = ("u" + overUnderSpread!.description +  "(" +
            (innerViewDelegate?.convertLineToString(line: overUnderSpreadLine))! + ")")
        underBtn.setTitle(textHolder, for: .normal)

        textHolder = ("o" + overUnderSpread!.description + "(" +
            (innerViewDelegate?.convertLineToString(line: overUnderSpreadLine))! + ")")
        overBtn.setTitle(textHolder, for: .normal)
    }
}


// ============================MAIN CLASS============================
class InnerViewController: UITableViewController, InnerViewDelegate {
    // NOTE: This code identifies if a bet is a parlay by searching for the word "Parlay" in the
    //  objective. If it finds that, it grabs the first number in the objective string. Keep this
    //  in mind when making objectives. See numOfLinesForObjective(objectives : String)
    
    // Variables
    var makePlayDelegate : MakePlayDelegate?
    
    // Called every time the innerViewController is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the bet on the first screen
        if makePlayDelegate?.currentPage() == "Choose League" {
            currentBet = Bet(league: nil,
                             objective: nil,
                             lines: [],
                             wagerAmount: nil)
            currentLineDuration = nil
        }
        
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
        case "Summary":
            return currentBet.lines.count
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
            currentBet.league = leaguesArray[indexPath.row]
            performSegue(withIdentifier: "LeaguesToObjectives", sender: nil)
        case "Choose Objective":
            // If a row was selected on the objective selection table, set that as the current objective
            currentBet.objective = objectivesArray[indexPath.row]
            if (numOfLinesForObjective(objective: currentBet.objective!) == 1) {
                performSegue(withIdentifier: "ObjectivesToDurations-Single", sender: nil)
            } else {
                performSegue(withIdentifier: "ObjectivesToDurations-Parlay", sender: nil)
            }
        case "Summary":
            // Do Nothing, and prevent the style from being changed
            tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        default :
            // This will apply to all "Choose Duration" screens of the parlay and single bet
            if (currentPage?.contains("Choose Duration"))! {
                currentLineDuration = durationsArray[indexPath.row]
                performSegue(withIdentifier: "DurationsToLines", sender: nil)
            // This will apply to all "Choose Line" screens of the parlay and single bet
            } else if (currentPage?.contains("Choose Line"))! {
                // Do Nothing, and prevent the style from being changed
                tableView.cellForRow(at: indexPath)?.selectionStyle = .none
            } else {
                // Error case: perform seque that has no mathcing identifier: so that an error will be thrown
                performSegue(withIdentifier: "~", sender: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentPage = makePlayDelegate?.currentPage()
        // Set they height for the custom cells to be 150
        if (currentPage?.contains("Choose Line"))! {
            return CGFloat(150)
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    // Function to build the dynamic table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentPage = makePlayDelegate?.currentPage()
        
        // Build the innerViewTable Differently based on the currentPage
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
            cell.imageView?.image = UIImage(named: (currentBet.league! + " icon"))
            
            // Set the accessory
            cell.accessoryView = UIImageView(image: UIImage(named: ("Pin icon")))
            
            return cell
        case "Summary":
            // build summary table
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell", for: indexPath)
            
            // Note: if currentBet.lines[indexpath.row] == nil, that means it was a moneyline
            
            // Set the text of the cell
            
            if currentBet.lines[indexPath.row].spread == nil {
            // In this case, the game is a moneyline so no spread needs to be shown
                cell.textLabel?.text = currentBet.lines[indexPath.row].duration! + " " +
                    currentBet.lines[indexPath.row].gameName! + " - " +
                    currentBet.lines[indexPath.row].bettingOn! + " " +
                    "(" + convertLineToString(line: currentBet.lines[indexPath.row].line) + ")"
            } else if currentBet.lines[indexPath.row].bettingOn == "UNDER" ||
                currentBet.lines[indexPath.row].bettingOn == "OVER" {
            // In this case, the bet is an under over, so we don't need to convert the spread to a string
                cell.textLabel?.text = currentBet.lines[indexPath.row].duration! + " " +
                    currentBet.lines[indexPath.row].gameName! + " - " +
                    currentBet.lines[indexPath.row].bettingOn! + " " +
                    currentBet.lines[indexPath.row].spread!.description + " " +
                    "(" + convertLineToString(line: currentBet.lines[indexPath.row].line) + ")"
            } else {
            // In this case, the bet is not a moneyline or under/over, so we need to show the line normally
                cell.textLabel?.text = currentBet.lines[indexPath.row].duration! + " " +
                    currentBet.lines[indexPath.row].gameName! + " - " +
                    currentBet.lines[indexPath.row].bettingOn! + " " +
                    convertSpreadToString(spread: currentBet.lines[indexPath.row].spread!) + " " +
                    "(" + convertLineToString(line: currentBet.lines[indexPath.row].line) + ")"
            }
            
            // Set the logo
            if currentBet.lines[indexPath.row].bettingOn == "UNDER" {
                cell.imageView?.image = UIImage(named: ("UNDER icon"))
            } else if currentBet.lines[indexPath.row].bettingOn == "OVER" {
                cell.imageView?.image = UIImage(named: ("OVER icon"))
            } else {
                cell.imageView?.image = UIImage(named: (currentBet.league! + " " + currentBet.lines[indexPath.row].bettingOn!))
            }
            
            return cell
        default:
            if (currentPage?.contains("Choose Duration"))! {
                // build objective table
                let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath)
                
                // Set the text
                cell.textLabel?.text = durationsArray[indexPath.row]
                
                // Set the logo
                cell.imageView?.image = UIImage(named: (currentBet.league! + " icon"))
                
                // Set the accessory
                cell.accessoryView = UIImageView(image: UIImage(named: ("Pin icon")))
                
                return cell
            } else if (currentPage?.contains("Choose Line"))! {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell", for: indexPath) as! LineTableViewCell
                
                // Set the delegate for the cell
                cell.innerViewDelegate = self
                
                // Give the cell the properties needed
                cell.league = currentBet.league
                cell.gameName = games[indexPath.row].gameName
                cell.homeTeamName = games[indexPath.row].homeTeamName
                cell.awayTeamName = games[indexPath.row].awayTeamName
                cell.homeTeamSpread = games[indexPath.row].homeTeamSpread
                cell.homeTeamSpreadLine = games[indexPath.row].homeTeamSpreadLine
                cell.awayTeamSpread = games[indexPath.row].awayTeamSpread
                cell.awayTeamSpreadLine = games[indexPath.row].awayTeamSpreadLine
                cell.overUnderSpread = games[indexPath.row].overUnderSpread
                cell.overUnderSpreadLine = games[indexPath.row].overUnderSpreadLine
                cell.homeTeamMoneylineLine = games[indexPath.row].homeTeamMoneylineLine
                cell.awayTeamMoneylineLine = games[indexPath.row].awayTeamMoneylineLine
                
                cell.initializeCell()
                
                return cell
            } else {
                // Error case: Return a cell for now so it doesnt cause errors, it should throw
                //  an error automaticlaly if this case occurs, since the identifier does not exist
                //  in the story board
                return tableView.dequeueReusableCell(withIdentifier: "~", for: indexPath)
            }
        }
    }
    
    // Segue function to make sure that the delegate is passed to the next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var numOfLinesNeeded : Int?
        if currentBet.objective != nil {
            numOfLinesNeeded = numOfLinesForObjective(objective: currentBet.objective!)
        }
        
        if segue.identifier == "LeaguesToObjectives" {
            makePlayDelegate?.updateTitle(title: "Choose Objective")
        } else if segue.identifier == "ObjectivesToDurations-Single" {
            makePlayDelegate?.updateTitle(title: "Choose Duration")
        } else if segue.identifier == "ObjectivesToDurations-Parlay" {
            let title = "Choose Duration (1 of " + String(numOfLinesNeeded!) + ")"
            makePlayDelegate?.updateTitle(title: title)
        } else if segue.identifier == "DurationsToLines" {
            if numOfLinesNeeded == 1 {
                makePlayDelegate?.updateTitle(title: "Choose Line")
            } else {
                let title = "Choose Line (" + String(currentBet.lines.count + 1)
                    + " of " + String(numOfLinesNeeded!) + ")"
                makePlayDelegate?.updateTitle(title: title)
            }
        } else if segue.identifier == "LinesToDurations" {
            if numOfLinesNeeded == 1 {
                makePlayDelegate?.updateTitle(title: "Choose Duration")
            } else {
                let title = "Choose Duration (" + String(currentBet.lines.count + 1)
                    + " of " + String(numOfLinesNeeded!) + ")"
                makePlayDelegate?.updateTitle(title: title)
            }
        } else if segue.identifier == "LinesToSummary" {
            makePlayDelegate?.updateTitle(title: "Summary")
        }
        
        // Pass the Delegate data to the next innerViewController
        let next = segue.destination as! InnerViewController
        next.makePlayDelegate = self.makePlayDelegate
    }
    
    // Helper function to pop the navigation controller back and deselect the value
    func stepBack() {
        let currentPage = makePlayDelegate?.currentPage()
        // If you deselect the league, the league must be set back to nil
        if currentPage == "Choose Objective" {
            currentBet.league = nil
        // If you deselect the objective, the objective must be set back to nil
        } else if (currentPage?.contains("Choose Duration"))! {
            // If the user is on the first duration of a bet/parlay, you want to rest the objective index
            if currentBet.lines.isEmpty {
                currentBet.objective = nil
            // Otherwise, if the currentBet.lines.count != 0, then that means they are stepping back to
            //  a previously added line, so the last line should be removed and currentBetLineDurationIndex
            //  should be updated to the the duration of the line that was removed
            } else {
                // You need to remove the last element in the currentBet.lines, but first, when you
                //  remove a line, you want to set the currentBetLineDurationIndex to the line that was removed
                currentLineDuration = currentBet.lines.last?.duration
                // Now it is safe to remove the last element of currentBet.lines
                currentBet.lines.removeLast()
            }
        // If you deselect the durration, the duration must be set back to nil
        } else if (currentPage?.contains("Choose Line"))! {
            currentLineDuration = nil
        } else if currentPage == "Summary" {
            // This is the same as deselecting a line above
            
            // You need to remove the last element in the currentBet.lines, but first, when you
            //  remove a line, you want to set the currentBetLineDurationIndex to the line that was removed
            
            currentLineDuration = currentBet.lines.last?.duration
            
            // Now it is safe to remove the last element of currentBet.lines
            currentBet.lines.removeLast()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // HELPER FUNCTIONS
    
    func addLineToBet(newLine : Line) {
        currentBet.lines.append(newLine)
        
        if numOfLinesForObjective(objective: currentBet.objective!) <= currentBet.lines.count {
            performSegue(withIdentifier: "LinesToSummary", sender: nil)
        } else {
            performSegue(withIdentifier: "LinesToDurations", sender: nil)
        }
    }
    
    func convertSpreadToString(spread : Float?) -> String {
        if spread! > Float(0) {
            return "+" + (spread?.description)!
        } else if spread == Float(0) {
            return "pk"
        } else {
            return (spread?.description)!
        }
    }
    
    func convertLineToString(line : Int?) -> String {
        if line! > 0 {
            return "+" + (line?.description)!
        } else if line == 0 {
            return "even"
        } else {
            return (line?.description)!
        }
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
}

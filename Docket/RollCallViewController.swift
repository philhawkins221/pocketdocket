//
//  RollCallViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/9/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit

enum Party {
    case republican
    case democrat
    case independent
}

class RollCallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sens = [String : (name: String, party: Party, id: String)]() //[state-rank : (name, party, id)]
    var senstates = [String]()
    var reps =  [String : (name: String, party: Party, id: String)]() //[state-district : (name, party, id)]
    var repstates = [String]()

    var senateleaders = [String: (name: String, id: String)]()
    var houseleaders = [String: (name: String, id: String)]()
    
    var repids = [String]()
    
    var leaders = [String]()
    
    var senreps = 0
    var sendems = 0
    var housereps = 0
    var housedems = 0
    var statesenreps = 0
    var statesendems = 0
    var statehousereps = 0
    var statehousedems = 0
    
    var filtered = false
    let states = ["Alabama": "AL", "Alaska": "AK", "Arizona": "AZ", "Arkansas": "AR", "California": "CA", "Coloroado": "CO", "Connecticut":"CT", "Delaware": "DE", "Florida": "FL", "Georgia": "GA", "Hawaii": "HI", "Idaho": "ID", "Illinois": "IL", "Indiana": "IN", "Iowa": "IA", "Kansas": "KS", "Kentucky": "KY", "Louisiana": "LA", "Maine": "ME", "Maryland": "MD", "Massachusetts": "MA", "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS", "Missouri": "MO", "Montana": "MT", "Nebraska": "NE", "Nevada": "NV", "New Hampshire": "NH", "New Jersey": "NJ", "New Mexico": "NM", "New York": "NY", "North Carolina": "NC", "North Dakota": "ND", "Ohio": "OH", "Oklahoma": "OK", "Oregon": "OR", "Pennsylvania": "PA", "Rhode Island": "RI", "South Carolina": "SC", "South Dakota": "SD", "Tennessee": "TN", "Texas": "TX", "Utah": "UT", "Vermont": "VT", "Virginia": "VA", "Washington": "WA", "West Virginia": "WV", "Wisconsin": "WI", "Wyoming": "WY"]
    var filterstate = ""
    var staterepdic = [String : (String, Party, String)]()
    var staterepstates = [String]()
    var statesendic = [String : (String, Party, String)]()
    var statesenstates = [String]()

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var chamber: UISegmentedControl!
    @IBOutlet weak var countlabel: UILabel!
    @IBOutlet weak var filterbutton: UIBarButtonItem!
    
    @IBOutlet weak var loadingindicator: UIActivityIndicatorView!
    
    //var rightswipe: UISwipeGestureRecognizer!
    //var leftswipe: UISwipeGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        table.delegate = self
        table.dataSource = self
        table.hidden = true
        
        /*rightswipe = UISwipeGestureRecognizer(target: self, action: "rightSwipe:")
        rightswipe.direction = .Right
        view.addGestureRecognizer(rightswipe)
        
        leftswipe = UISwipeGestureRecognizer(target: self, action: "leftSwipe:")
        leftswipe.direction = .Left
        view.addGestureRecognizer(leftswipe)*/
        
        if reps.count == 0 {
            loadCongress(true)
            
            //chamber.selectedSegmentIndex = 1
            //loadCongress(false)
            
            
        } else {
            table.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 20/255, green: 154/255, blue: 233/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    func loadCongress(house: Bool) {
        var urlToLoad: String = ""
        if house {
            urlToLoad = "https://www.govtrack.us/api/v2/role?current=true&role_type=representative&order_by=state&limit=500"
        } else {
            urlToLoad = "https://www.govtrack.us/api/v2/role?current=true&role_type=senator&order_by=state&limit=100"
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithURL(NSURL(string: urlToLoad)!, completionHandler: {(data, response, error) in
            if data == nil {
                //take care of things - or just leave the thing spinning forever
                return
            }
            do {
                print("loading")
                if let json: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    if let objects: [[String: AnyObject]] = json["objects"] as? [[String: AnyObject]] {
                        for object in objects {
                            if self.chamber.selectedSegmentIndex == 0 {
                                //name
                                let person: [String: AnyObject] = object["person"] as! [String: AnyObject]
                                let name = (person["firstname"] as! String) + " " + (person["lastname"] as! String)
                                
                                //govtrack id
                                let id = (person["id"] as! Int).description
                                
                                //state and rank
                                let state = (object["state"] as! String) + "-" + (object["district"] as! Int).description
                                
                                //party
                                let party: Party
                                let jsonparty = object["party"] as! String
                                if jsonparty == "Republican" {
                                    party = .republican
                                    ++self.housereps
                                } else if jsonparty == "Democrat" {
                                    party = .democrat
                                    ++self.housedems
                                } else {
                                    party = .independent
                                }
                                
                                //put it all together now
                                self.reps[state] = (name, party, id)
                                
                                //leadership title - if any
                                if object["leadership_title"] as? String != nil {
                                    self.houseleaders[object["leadership_title"] as! String] = (name, id)
                                }
                            } else {
                                //name
                                let person: [String: AnyObject] = object["person"] as! [String: AnyObject]
                                let name = (person["firstname"] as! String) + " " + (person["lastname"] as! String)
                                
                                //govtrack id
                                let id = (person["id"] as! Int).description
                                
                                //state and rank
                                let state = (object["state"] as! String) + "-" + (object["senator_rank_label"] as! String)
                                
                                //party
                                let party: Party
                                let jsonparty = object["party"] as! String
                                if jsonparty == "Republican" {
                                    party = .republican
                                    ++self.senreps
                                } else if jsonparty == "Democrat" {
                                    party = .democrat
                                    ++self.sendems
                                } else {
                                    party = .independent
                                }
                                
                                //put it all together now
                                self.sens[state] = (name, party, id)
                                
                                //leadership position - if any
                                if object["leadership_title"] as? String != nil {
                                    self.senateleaders[object["leadership_title"] as! String] = (name, id)
                                }
                            }
                        }
                        //sort
                        self.repstates = Array(self.reps.keys)
                        //self.repstates = self.reps.keys.array
                        self.repstates = self.repstates.sort({ (s1, s2) -> Bool in
                            let state1 = s1.substringToIndex(s1.startIndex.successor().successor())
                            let state2 = s2.substringToIndex(s2.startIndex.successor().successor())
                            if state1 != state2 {
                                return s1 < s2
                            } else {
                                let district1 = Int(s1.substringFromIndex(s1.startIndex.successor().successor().successor()))!
                                let district2 = Int(s2.substringFromIndex(s2.startIndex.successor().successor().successor()))!
                                if district1 < district2 {
                                    return true
                                } else {
                                    return false
                                }
                            }
                        })
                        self.senstates = Array(self.sens.keys)
                        //self.senstates = self.sens.keys.array
                        self.senstates = self.senstates.sort(<)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                    self.prepareLeaders()
                    self.updateCount()
                    self.table.reloadData()
                    self.table.reloadInputViews()
                    self.loadingindicator.stopAnimating()
                    self.table.hidden = false
                    })
                }
                session.finishTasksAndInvalidate()
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func updateCount() {
        if chamber.selectedSegmentIndex == 0 {
            if filtered {
                countlabel.text = statehousereps.description + " Republican, " + statehousedems.description + " Democrat"
            } else {
                countlabel.text = housereps.description + " Republican, " + housedems.description + " Democrat"
            }
        } else {
            if filtered {
                countlabel.text = statesenreps.description + " Republican, " + statesendems.description + " Democrat"
            } else {
                countlabel.text = senreps.description + " Republican, " + sendems.description + " Democrat"
            }
        }
    }

    @IBAction func otherChamber(sender: AnyObject) {
        repids = []
        if chamber.selectedSegmentIndex == 0 {
            if reps.count == 0 {
                loadCongress(true)
            } else {
                prepareLeaders()
                table.reloadInputViews()
                table.reloadData()
                updateCount()
            }
        } else {
            if sens.count == 0 {
                loadCongress(false)
            } else {
                prepareLeaders()
                table.reloadInputViews()
                table.reloadData()
                updateCount()
            }
        }
    }
    
    @IBAction func filter(sender: AnyObject) {
        repids = []
        let filterer = UIAlertController(title: "Select a State", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let statenames = (Array(states.keys)).sort(<)
        //let statenames = states.keys.array.sort(<)
        if !filtered {
            for state in statenames {
                filterer.addAction(UIAlertAction(title: state, style: UIAlertActionStyle.Default, handler: { action -> Void in
                    self.staterepdic.removeAll()
                    self.statesendic.removeAll()
                    self.staterepstates.removeAll()
                    self.statesenstates.removeAll()
                    self.statehousereps = 0
                    self.statehousedems = 0
                    self.statesenreps = 0
                    self.statesendems = 0
                    
                    for repstate in self.repstates {
                        if repstate.substringToIndex(repstate.startIndex.successor().successor()) == self.states[state] {
                            self.staterepdic[repstate] = self.reps[repstate]
                            
                            let party = self.staterepdic[repstate]!.1
                            if party == .republican {
                                ++self.statehousereps
                            } else if party == .democrat {
                                ++self.statehousedems
                            }
                        }
                    }
                    self.staterepstates = (Array(self.staterepdic.keys)).sort({ (s1, s2) -> Bool in
                        let state1 = s1.substringToIndex(s1.startIndex.successor().successor())
                        let state2 = s2.substringToIndex(s2.startIndex.successor().successor())
                        if state1 != state2 {
                            return s1 < s2
                        } else {
                            let district1 = Int(s1.substringFromIndex(s1.startIndex.successor().successor().successor()))!
                            let district2 = Int(s2.substringFromIndex(s2.startIndex.successor().successor().successor()))!
                            if district1 < district2 {
                                return true
                            } else {
                                return false
                            }
                        }
                    })
                    
                    for senstate in self.senstates {
                        if senstate.substringToIndex(senstate.startIndex.successor().successor()) == self.states[state] {
                            self.statesendic[senstate] = self.sens[senstate]
                            
                            let party = self.statesendic[senstate]!.1
                            if party == .republican {
                                ++self.statesenreps
                            } else if party == .democrat {
                                ++self.statesendems
                            }
                        }
                    }
                    self.statesenstates = (Array(self.statesendic.keys)).sort(<)
                    //self.statesenstates = self.statesendic.keys.array.sort(<)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.filtered = true
                        self.filterstate = state
                        self.repids = []
                        self.prepareLeaders()
                        self.table.reloadData()
                        self.table.reloadInputViews()
                        self.updateCount()
                        self.title = "Delegation from " + state
                        self.filterbutton.title = "Clear"
                    })
                }))
            }
            filterer.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action->Void in
                //self.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(filterer, animated: true, completion: nil)
        } else {
            filterbutton.title = "Filter by State"
            self.title = "114th Congress"
            filtered = false
            repids = []
            updateCount()
            prepareLeaders()
            table.reloadInputViews()
            table.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView Stack
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chamber.selectedSegmentIndex == 0 {
            if section == 0 {
                return 5
            } else {
                if filtered {
                    return staterepdic.count
                } else {
                    return reps.count
                }
            }
        } else {
            if section == 0 {
                return 4
            } else {
                if filtered {
                    return statesendic.count
                } else {
                    return sens.count
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Representative", forIndexPath: indexPath) as UITableViewCell
        if leaders.isEmpty {
            return cell
        }
        cell.backgroundColor = UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)
        
        if chamber.selectedSegmentIndex == 0 {
            if indexPath.section == 0 {
                cell.textLabel?.text = leaders[indexPath.row]
                cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
                //cell.backgroundColor = UIColor.whiteColor()
                if indexPath.row == 0 {
                    cell.detailTextLabel?.text = "Speaker of the House"
                } else if indexPath.row == 1 {
                    cell.detailTextLabel?.text = "Majority Leader"
                } else if indexPath.row == 2 {
                    cell.detailTextLabel?.text = "Majority Whip"
                } else if indexPath.row == 3 {
                    cell.detailTextLabel?.text = "Minority Leader"
                } else if indexPath.row == 4 {
                    cell.detailTextLabel?.text = "Minority Whip"
                }
            } else {
                if filtered {
                    let statetemp = staterepdic[staterepstates[indexPath.row]]!
                    //print(statetemp)
                    cell.textLabel?.text = statetemp.0
                    cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
                    cell.detailTextLabel?.text = staterepstates[indexPath.row]
                    //cell.backgroundColor = UIColor.whiteColor()
                    
                    let party = statetemp.1
                    if party == .republican {
                        //cell.backgroundColor = UIColor(red: 1, green: 197/255, blue: 197/255, alpha: 1)
                        cell.detailTextLabel?.textColor = UIColor(red: 1, green: 97/255, blue: 97/255, alpha: 1)
                    } else if party == .democrat {
                        //cell.backgroundColor = UIColor(red: 197/255, green: 197/255, blue: 1, alpha: 1)
                        cell.detailTextLabel?.textColor = UIColor(red: 97/255, green: 97/255, blue: 1, alpha: 1)
                    } else {
                        cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
                    }
                    
                    repids.append(statetemp.2)
                    return cell
                }
                let temp = reps[repstates[indexPath.row]]!
                cell.textLabel?.text = temp.0
                cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
                cell.detailTextLabel?.text = repstates[indexPath.row]
                
                let party = temp.1
                if party == .republican {
                    //cell.backgroundColor = UIColor(red: 1, green: 197/255, blue: 197/255, alpha: 1)
                    cell.detailTextLabel?.textColor = UIColor(red: 1, green: 97/255, blue: 97/255, alpha: 1)
                } else if party == .democrat {
                    //cell.backgroundColor = UIColor(red: 197/255, green: 197/255, blue: 1, alpha: 1)
                    cell.detailTextLabel?.textColor = UIColor(red: 97/255, green: 97/255, blue: 1, alpha: 1)
                } else {
                    cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
                }
            }
        } else {
            if indexPath.section == 0 {
                cell.textLabel?.text = leaders[indexPath.row]
                cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
                //cell.backgroundColor = UIColor.whiteColor()
                if indexPath.row == 0 {
                    cell.detailTextLabel?.text = "Majority Leader"
                } else if indexPath.row == 1 {
                    cell.detailTextLabel?.text = "Majority Whip"
                } else if indexPath.row == 2 {
                    cell.detailTextLabel?.text = "Minority Leader"
                } else if indexPath.row == 3 {
                    cell.detailTextLabel?.text = "Minority Whip"
                }
            } else {
                if filtered {
                    let statetemp = statesendic[statesenstates[indexPath.row]]!
                    //print(statetemp)
                    cell.textLabel?.text = statetemp.0
                    cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
                    cell.detailTextLabel?.text = statesenstates[indexPath.row]
                    //cell.backgroundColor = UIColor.whiteColor()
                    
                    let party = statetemp.1
                    if party == .republican {
                        //cell.backgroundColor = UIColor(red: 1, green: 197/255, blue: 197/255, alpha: 1)
                        cell.detailTextLabel?.textColor = UIColor(red: 1, green: 97/255, blue: 97/255, alpha: 1)
                    } else if party == .democrat {
                        //cell.backgroundColor = UIColor(red: 197/255, green: 197/255, blue: 1, alpha: 1)
                        cell.detailTextLabel?.textColor = UIColor(red: 97/255, green: 97/255, blue: 1, alpha: 1)
                    } else {
                        cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
                    }
                    
                    repids.append(statetemp.2)
                    return cell
                }
                let temp = sens[senstates[indexPath.row]]!
                cell.textLabel?.text = temp.0//senators[indexPath.row]
                cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
                cell.detailTextLabel?.text = senstates[indexPath.row]
                
                let party = temp.1
                if party == .republican {
                    //cell.backgroundColor = UIColor(red: 1, green: 197/255, blue: 197/255, alpha: 1)
                    cell.detailTextLabel?.textColor = UIColor(red: 1, green: 97/255, blue: 97/255, alpha: 1)
                } else if party == .democrat {
                    //cell.backgroundColor = UIColor(red: 197/255, green: 197/255, blue: 1, alpha: 1)
                    cell.detailTextLabel?.textColor = UIColor(red: 97/255, green: 97/255, blue: 1, alpha: 1)
                } else {
                    cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if chamber.selectedSegmentIndex == 0 {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    id = houseleaders["Speaker"]!.id
                } else if indexPath.row == 1 {
                    id = houseleaders["Majority Leader"]!.id
                } else if indexPath.row == 2 {
                    id = houseleaders["Majority Whip"]!.id
                } else if indexPath.row == 3 {
                    id = houseleaders["Minority Leader"]!.id
                } else if indexPath.row == 4 {
                    id = houseleaders["Minority Whip"]!.id
                }
            } else {
                if filtered {
                    id = staterepdic[staterepstates[indexPath.row]]!.2
                } else {
                    id = reps[repstates[indexPath.row]]!.id
                }
            }
        } else {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    id = senateleaders["Majority Leader"]!.id
                } else if indexPath.row == 1 {
                    id = senateleaders["Majority Whip"]!.id
                } else if indexPath.row == 2 {
                    id = senateleaders["Minority Leader"]!.id
                } else if indexPath.row == 3 {
                    id = senateleaders["Minority Whip"]!.id
                }
            } else {
                if filtered {
                    id = statesendic[statesenstates[indexPath.row]]!.2
                } else {
                    id = sens[senstates[indexPath.row]]!.id
                }
            }
        }
        pagetype = .congressperson
        let congressperson = storyboard?.instantiateViewControllerWithIdentifier("congressperson")
        print(id)
        self.showViewController(congressperson!, sender: self)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Leadership"
        } else if section == 1 {
            return "Members"
        } else {
            return nil
        }
    }
    
    func prepareLeaders() {
        leaders = []
        if chamber.selectedSegmentIndex == 0 {
            leaders.append(houseleaders["Speaker"]!.name)
            leaders.append(houseleaders["Majority Leader"]!.name)
            leaders.append(houseleaders["Majority Whip"]!.name)
            leaders.append(houseleaders["Minority Leader"]!.name)
            leaders.append(houseleaders["Minority Whip"]!.name)
        } else {
            leaders.append(senateleaders["Majority Leader"]!.name)
            leaders.append(senateleaders["Majority Whip"]!.name)
            leaders.append(senateleaders["Minority Leader"]!.name)
            leaders.append(senateleaders["Minority Whip"]!.name)
        }
        
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func leftSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .left
        if sender.state == .Ended {
            performSegueWithIdentifier("rollToFloor", sender: nil)
        }
    }
    
    func rightSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .right
        if sender.state == .Ended {
            performSegueWithIdentifier("rollToCommittee", sender: nil)
        }
    }
    
    @IBAction func menu(sender: AnyObject) {
        swipe = .right
        performSegueWithIdentifier("rollcallMenu", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        toViewController.transitioningDelegate = transitionManager
    }

}

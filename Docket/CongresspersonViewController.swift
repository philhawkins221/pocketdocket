//
//  CongresspersonViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/14/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit
import CoreData

class CongresspersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var party: UILabel!
    @IBOutlet weak var description1: UILabel!
    @IBOutlet weak var description2: UILabel!
    @IBOutlet weak var billstable: UITableView!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var trackbutton: UIBarButtonItem!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var forwardbutton: UIButton!
    @IBOutlet weak var tabletitle: UILabel!
    @IBOutlet weak var pagedisplay: UIPageControl!
    
    var committees = [String : String]() //[name : id]
    var bills = [String: (name: String, id: String)]() //[number : (name, id)]
    var committeenames = [String]()
    var billnames = [String]()
    
    var tempcommitteeids = [String]()
    
    var votequestions = [String]()
    var votevalues = [String]()
    
    enum tableuses {
        case sponsors
        case votes
        case committees
    }
    
    var tableuse = tableuses.sponsors
    
    @IBOutlet weak var cover: UIView!
    @IBOutlet weak var loadingindicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        billstable.delegate = self
        billstable.dataSource = self
        
        backbutton.enabled = false
        
        if pagetype == .congressperson {
            loadInfo()
            
            //checkTracking()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 208/255, green: 38/255, blue: 98/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    func loadInfo() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/person/" + id)!, completionHandler: {(data, response, error) in
            if data == nil {
                //take care of things - or just leave the thing spinning forever
                print("no data")
                return
            }
            do {
                if let json: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.titlelabel.text = (json["firstname"] as! String) + " " + (json["lastname"] as! String)
                    let roles = json["roles"] as! [[String: AnyObject]]
                    for role in roles {
                        let current = role["current"] as! Bool
                        self.party.text = (role["party"] as! String)
                        if current {
                            let description = role["description"] as! String
                            if var leadershiptitle = role["leadership_title"] as? String {
                                if leadershiptitle == "Speaker" {
                                    leadershiptitle = "Speaker of the House"
                                }
                                self.description1.text = leadershiptitle
                                self.description2.text = description
                                self.description2.hidden = false
                            } else {
                                self.description1.text = description
                                self.description2.hidden = true
                            }
                            //self.description2.hidden = false
                            self.website.hidden = false
                            self.website.setTitle((role["website"] as! String), forState: .Normal)
                        } else {
                            self.description1.text = "Inactive"
                            self.description2.hidden = true
                            self.website.hidden = true
                        }
                    }
                    })
                    
                    let committeeassignments = json["committeeassignments"] as! [[String : AnyObject]]
                    for committeeassignment in committeeassignments {
                        let commid = (committeeassignment["committee"] as! Int).description
                        self.tempcommitteeids.append(commid)
                    }
                }
                self.checkTracking()
                self.loadBills()
                session.finishTasksAndInvalidate()
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func loadCommittees() {
        let committeesession = NSURLSession(configuration: .defaultSessionConfiguration())
        print(tempcommitteeids)
        for var i=0; i<=tempcommitteeids.count; ++i {
            var cur = ""
            if i == tempcommitteeids.count {
                //committeesession.invalidateAndCancel()
                //print(committees)
                //committeesession.finishTasksAndInvalidate()
                //committeenames = committees.keys.array.sort(<)
                //dispatch_async(dispatch_get_main_queue(), {self.committeetable.reloadData()})
                //loadBills()
                //break
            } else {
                cur = tempcommitteeids[i]
            }
            committeesession.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/committee/" + cur)!, completionHandler: {(data, response, error) in
                if data == nil {
                    //idk
                    print("no data")
                    return
                }
                do {
                    if let committee = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                        if let name = committee["name"] as? String {
                        let commid = cur
                        self.committees.updateValue(commid, forKey: name)
                        } else {
                            self.committeenames = (Array(self.committees.keys)).sort(<)
                            //self.committeenames = self.committees.keys.array.sort(<)
                            dispatch_async(dispatch_get_main_queue(), {self.billstable.reloadData()})
                            self.loadBills()
                            committeesession.finishTasksAndInvalidate()
                        }
                    }
                    committeesession.finishTasksAndInvalidate()
                } catch {
                    print(error)
                }
            }).resume()
        }
    }
    
    func loadBills() {
        let billsession = NSURLSession(configuration: .defaultSessionConfiguration())
        billsession.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/bill?congress=114&order_by=-current_status_date&limit=600")!, completionHandler: {(data, response, error) in
            if data == nil {
                //idk
                return
            }
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    let bills = json["objects"] as! [[String: AnyObject]]
                    for bill in bills {
                        let sponsor = bill["sponsor"] as! [String: AnyObject]
                        if (sponsor["id"] as! Int).description == id {
                            let billname = bill["display_number"] as! String
                            self.bills[billname] = (bill["title_without_number"] as! String, (bill["id"] as! Int).description)
                        }
                    }
                    
                    self.billnames = (Array(self.bills.keys)).sort(<)
                    //self.billnames = self.bills.keys.array.sort(<)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.billstable.reloadData()
                        self.loadingindicator.stopAnimating()
                        self.cover.hidden = true
                    })
                }
                billsession.finishTasksAndInvalidate()
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func loadVotes() {
        let votesession = NSURLSession(configuration: .defaultSessionConfiguration())
        votesession.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/vote_voter?person=" + id + "&order_by=-created")!, completionHandler: {(data, response, error) in
            if data == nil {
                //idk
                return
            }
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? [String: AnyObject] {
                    print("checkpoint 1")
                    let votes = json["objects"] as! [[String: AnyObject]]
                    print("checkpoint 2")
                    for vote in votes {
                        let votevalue = (vote["option"] as! [String: AnyObject])["key"] as! String
                        print("checkpoint 3")
                        let votequestion = (vote["vote"] as! [String: AnyObject])["question"] as! String
                        print("checkpoint 4")
                        
                        self.votevalues.append(votevalue)
                        self.votequestions.append(votequestion)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { self.billstable.reloadData() })
                votesession.finishTasksAndInvalidate()
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func checkTracking() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let congresspersonRequest = NSFetchRequest(entityName:"Representative")
        
        do {
            let trackedcongresspeople = try managedContext.executeFetchRequest(congresspersonRequest) as! [NSManagedObject]
            
            for congressperson in trackedcongresspeople {
                if (congressperson.valueForKey("title") as! String) == description1.text! {
                    trackbutton.title! = "Untrack"
                    break
                }
            }
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewWebsite(sender: AnyObject) {
        let webview = storyboard?.instantiateViewControllerWithIdentifier("research")
        research = website.titleLabel!.text!
        self.showViewController(webview!, sender: self)
    }
    
    @IBAction func trackPressed(sender: AnyObject) {
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //if trackbutton.title! == "Track" {
            //2
            let entity =  NSEntityDescription.entityForName("Representative", inManagedObjectContext: managedContext)
            let congressperson = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            
            //3
            congressperson.setValue(id, forKey: "id")
            //congressperson.setValue(false, forKey: "mydistrict")
            congressperson.setValue(titlelabel.text, forKey: "name")
            congressperson.setValue(party.text, forKey: "party")
            congressperson.setValue(description1.text, forKey: "title")
            //district
            //state
        
            trackbutton.title! = "Tracked"
            trackbutton.enabled = false
        /*} else {
            //2
            //let billRequest = NSFetchRequest(entityName:"Bill")
            //let committeeRequest = NSFetchRequest(entityName: "Committee")
            let congresspersonRequest = NSFetchRequest(entityName: "Representative")
            //let districtRequest = NSFetchRequest(entityName: "District")
        
            //3
            do {
                //let trackedbills = try managedContext.executeFetchRequest(billRequest) as! [NSManagedObject]
                //let trackedcommittees = try managedContext.executeFetchRequest(committeeRequest) as! [NSManagedObject]
                let trackedcongresspeople = try managedContext.executeFetchRequest(congresspersonRequest) as! [NSManagedObject]
                //district = try (managedContext.executeFetchRequest(districtRequest) as! [NSManagedObject])[0]
                
                for rep in trackedcongresspeople {
                    if (rep.valueForKey("title") as! String) == description1.text! {
                        managedContext.deleteObject(rep)
                        break
                    }
                }
                
                trackbutton.title! = "Track"
            } catch {
                print(error)
            }
        }*/
    }
    
    @IBAction func goBack(sender: AnyObject) {
        if tableuse == tableuses.committees {
            forwardbutton.enabled = true
            pagedisplay.currentPage = 1
            
            tableuse = tableuses.votes
            tabletitle.text = "Recent Voting History"
            if votevalues.isEmpty {
                loadVotes()
            } else {
                billstable.reloadData()
            }
        } else if tableuse == tableuses.votes {
            backbutton.enabled = false
            pagedisplay.currentPage = 0
            
            tableuse = tableuses.sponsors
            tabletitle.text = "Recent Bills Sponsored"
            billstable.reloadData()
        }
    }
    
    @IBAction func goForward(sender: AnyObject) {
        if tableuse == tableuses.sponsors {
            backbutton.enabled = true
            pagedisplay.currentPage = 1
            
            tableuse = tableuses.votes
            tabletitle.text = "Recent Voting History"
            if votevalues.isEmpty {
                loadVotes()
            } else {
                billstable.reloadData()
            }
        } else if tableuse == tableuses.votes {
            forwardbutton.enabled = false
            pagedisplay.currentPage = 2
            
            tableuse = tableuses.committees
            tabletitle.text = "Committee Membership"
            if committees.isEmpty {
                loadCommittees()
            } else {
                billstable.reloadData()
            }
        }
    }
    
    //MARK: - TableView Stack
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableuse == tableuses.committees {
            return committeenames.count
        } else if tableuse == tableuses.sponsors {
            return billnames.count
        } else {
            return votevalues.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if tableuse == tableuses.committees {
            let name = committeenames[indexPath.row]
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = nil
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else if tableuse == tableuses.sponsors {
            let name = billnames[indexPath.row]
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = bills[name]!.name
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else {
            cell.textLabel?.text = votequestions[indexPath.row]
            let vote = votevalues[indexPath.row]
            if vote == "+" {
                cell.detailTextLabel?.text = "Voted For"
                cell.detailTextLabel?.textColor = UIColor(red: 66/255, green: 149/255, blue: 14/255, alpha: 1)
            } else if vote == "-" {
                cell.detailTextLabel?.text = "Voted Against"
                cell.detailTextLabel?.textColor = UIColor.redColor()
            } else if vote == "0" {
                cell.detailTextLabel?.text = "Did Not Vote"
                cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
            }
            
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableuse == tableuses.committees {
            let committee = storyboard?.instantiateViewControllerWithIdentifier("committee")
            pagetype = .committee
            id = committees[committeenames[indexPath.row]]!
            self.showViewController(committee!, sender: self)
        } else if tableuse == tableuses.sponsors {
            let bill = storyboard?.instantiateViewControllerWithIdentifier("bill")
            pagetype = .bill
            id = bills[billnames[indexPath.row]]!.id
            self.showViewController(bill!, sender: self)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
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
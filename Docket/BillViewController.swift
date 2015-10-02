//
//  BillViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/14/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit
import CoreData

class BillViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var subtitlelabel: UILabel!
    @IBOutlet weak var sponsor: UIButton!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusdescription: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var trackbutton: UIBarButtonItem!
    
    var committees = [String : String]()
    var committeenames = [String]()
    var sponsorid = String()
    
    @IBOutlet weak var cover: UIView!
    @IBOutlet weak var loadingindicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
        
        if pagetype == .bill {
            loadBill()
            
            //checkTracking()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 208/255, green: 38/255, blue: 98/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    func loadBill() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/bill/" + id)!, completionHandler: {(data, response, error) in
            do {
                if data == nil {
                    //take care of things - or just leave the thing spinning forever
                    return
                }
                if let json: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    let name = json["display_number"] as! String
                    var fullname = (json["title_without_number"] as! String)
                    let titles = json["titles"] as! [[String]]
                    let introtitle = titles[titles.count - 1][2]
                    print(introtitle)
                    if fullname != introtitle {
                        fullname = fullname + " - " + introtitle;
                    }
                    let status = json["current_status_label"] as! String
                    var statusdescription = json["current_status_description"] as! String
                    let statuscode = json["current_status"] as! String
                    if statuscode == "enacted_signed" {
                        let congress = (json["congress"] as! Int).description
                        if json["sliplawpubpriv"] as! String == "PUB" {
                            statusdescription += " (Pub.L. "
                        } else if json["sliplawpubpriv"] as! String == "PRI" {
                            statusdescription += " (Pvt.L. "
                        }
                        statusdescription += (congress + "-" + (json["sliplawnum"] as! Int).description + ")")
                    }
                    let link = json["thomas_link"] as! String
                    let sponsorinfo = json["sponsor"] as! [String : AnyObject]
                    let sponsor = (sponsorinfo["firstname"] as! String) + " " + (sponsorinfo["lastname"] as! String)
                    let sponsorid = (sponsorinfo["id"] as! Int).description
                    var committees = [String : String]() //name : id
                    if let committeesinfo = json["committees"] as? [[String: AnyObject]] {
                        for committee in committeesinfo {
                            committees[committee["name"] as! String] = (committee["id"] as! Int).description
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.titlelabel.text = name
                        self.subtitlelabel.text = fullname
                        self.status.text = status
                        self.statusdescription.text = statusdescription
                        self.website.setTitle(link, forState: .Normal)
                        self.sponsor.setTitle(sponsor + ", Sponsor >", forState: UIControlState.Normal)
                        self.sponsorid = sponsorid
                        self.committees = committees
                        self.committeenames = (Array(committees.keys)).sort(<)
                        //self.committeenames = committees.keys.array.sort(<)
                        self.table.reloadData()
                        
                        self.loadingindicator.stopAnimating()
                        self.cover.hidden = true
                    })
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func checkTracking() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let billRequest = NSFetchRequest(entityName:"Bill")
        
        do {
            let trackedbills = try managedContext.executeFetchRequest(billRequest) as! [NSManagedObject]

            for bill in trackedbills {
                if (bill.valueForKey("number") as! String) == titlelabel.text! {
                    trackbutton.title! = "Untrack"
                    break
                }
            }
        } catch {
            print(error)
        }
    }

    @IBAction func viewSponsor(sender: AnyObject) {
        let congressperson = storyboard?.instantiateViewControllerWithIdentifier("congressperson")
        pagetype = .congressperson
        id = sponsorid
        print(id)
        self.showViewController(congressperson!, sender: self)
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
            let entity =  NSEntityDescription.entityForName("Bill", inManagedObjectContext: managedContext)
            let bill = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            
            //3
            bill.setValue(id, forKey: "id")
            bill.setValue(titlelabel.text, forKey: "number")
            bill.setValue(subtitlelabel.text, forKey: "title")
            
            trackbutton.title! = "Tracked"
            trackbutton.enabled = false
        //} else {
            //2
         /*   let billRequest = NSFetchRequest(entityName:"Bill")
            //let committeeRequest = NSFetchRequest(entityName: "Committee")
            //let congresspersonRequest = NSFetchRequest(entityName: "Representative")
            //let districtRequest = NSFetchRequest(entityName: "District")
            
            //3
            do {
                let trackedbills = try managedContext.executeFetchRequest(billRequest) as! [NSManagedObject]
                //let trackedcommittees = try managedContext.executeFetchRequest(committeeRequest) as! [NSManagedObject]
                //let trackedcongresspeople = try managedContext.executeFetchRequest(congresspersonRequest) as! [NSManagedObject]
                //district = try (managedContext.executeFetchRequest(districtRequest) as! [NSManagedObject])[0]
                
                for bill in trackedbills {
                    if (bill.valueForKey("number") as! String) == titlelabel.text! {
                        managedContext.deleteObject(bill)
                        break
                    }
                }
                
                trackbutton.title! = "Track"
            } catch {
                print(error)
            }
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView Stack
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return committeenames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Committee", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = committeenames[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let committee = storyboard?.instantiateViewControllerWithIdentifier("committee")
        //self.addChildViewController(bill!)
        pagetype = .committee
        id = committees[committeenames[indexPath.row]]!
        self.showViewController(committee!, sender: self)
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

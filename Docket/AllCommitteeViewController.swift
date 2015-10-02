//
//  AllCommitteeViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/17/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit

class AllCommitteeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var committeetype: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var loadingindicator: UIActivityIndicatorView!
    
    //var leftswipe: UISwipeGestureRecognizer!
    //var rightswipe: UISwipeGestureRecognizer!
    
    var house = [String : String]()
    var senate = [String : String]()
    var joint = [String : String]()
    var housenames = [String]()
    var senatenames = [String]()
    var jointnames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*rightswipe = UISwipeGestureRecognizer(target: self, action: "rightSwipe:")
        rightswipe.direction = .Right
        view.addGestureRecognizer(rightswipe)
        
        leftswipe = UISwipeGestureRecognizer(target: self, action: "leftSwipe:")
        leftswipe.direction = .Left
        view.addGestureRecognizer(leftswipe)*/
        
        table.delegate = self
        table.dataSource = self
        table.hidden = true
        //self.automaticallyAdjustsScrollViewInsets = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.loadCommittees()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 20/255, green: 154/255, blue: 233/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    func loadCommittees() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/committee?obsolete=false&committee=null&limit=6000")!, completionHandler: {(data, response, error) in
            if data == nil {
                //take care of things - or just leave the thing spinning forever
                return
            }
            do {
                if let json: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    if let objects: [[String: AnyObject]] = json["objects"] as? [[String: AnyObject]] {
                        for object in objects {
                            let type = object["committee_type"] as! String
                            
                            if type == "house" {
                                self.house[object["name"] as! String] = (object["id"] as! Int).description
                            } else if type == "senate" {
                                self.senate[object["name"] as! String] = (object["id"] as! Int).description
                            } else if type == "joint" {
                                self.joint[object["name"] as! String] = (object["id"] as! Int).description
                            }
                        }
                        self.housenames = (Array(self.house.keys)).sort(<)
                        self.senatenames = (Array(self.senate.keys)).sort(<)
                        self.jointnames = (Array(self.joint.keys)).sort(<)
                        
                        //self.housenames = self.house.keys.array.sort(<)
                        //self.senatenames = self.senate.keys.array.sort(<)
                        //self.jointnames = self.joint.keys.array.sort(<)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.table.reloadData()
                            self.loadingindicator.stopAnimating()
                            self.table.hidden = false
                        })
                    }
                }
                session.finishTasksAndInvalidate()
            } catch {
                print(error)
            }
        }).resume()
    }
    
    

    @IBAction func newType(sender: AnyObject) {
        table.reloadData()
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
        if committeetype.selectedSegmentIndex == 0 {
            return housenames.count
        } else if committeetype.selectedSegmentIndex == 1 {
            return jointnames.count
        } else {
            return senatenames.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("Committee", forIndexPath: indexPath) as UITableViewCell)
        
        if committeetype.selectedSegmentIndex == 0 {
            cell.textLabel?.text = housenames[indexPath.row]
        } else if committeetype.selectedSegmentIndex == 1 {
            cell.textLabel?.text = jointnames[indexPath.row]
        } else {
            cell.textLabel?.text = senatenames[indexPath.row]
        }
       
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if committeetype.selectedSegmentIndex == 0 {
            id = house[housenames[indexPath.row]]!
        } else if committeetype.selectedSegmentIndex == 1 {
            id = joint[jointnames[indexPath.row]]!
        } else {
            id = senate[senatenames[indexPath.row]]!
        }
        
        let committee = storyboard?.instantiateViewControllerWithIdentifier("committee")
        pagetype = .committee
        self.showViewController(committee!, sender: self)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func leftSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .left
        if sender.state == .Ended {
            performSegueWithIdentifier("committeeToRoll", sender: nil)
        }
    }
    
    func rightSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .right
        if sender.state == .Ended {
            performSegueWithIdentifier("committeeToState", sender: nil)
        }
    }
    
    @IBAction func menu(sender: AnyObject) {
        swipe = .right
        performSegueWithIdentifier("committeesMenu", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        toViewController.transitioningDelegate = transitionManager
    }

}

//
//  CommitteeViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/14/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit

class CommitteeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var subtitlelabel: UILabel!
    @IBOutlet weak var chair: UIButton!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var website: UIButton!
    
    var members = [String : (loc: String, id: String)]()
    var membernames = [String]()
    
    @IBOutlet weak var cover: UIView!
    @IBOutlet weak var loadingindicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
        
        if pagetype == .committee {
            loadCongress()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 208/255, green: 38/255, blue: 98/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    func loadCongress() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/committee_member?committee=" + id)!, completionHandler: {(data, response, error) in
            if data == nil {
                //take care of things - or just leave the thing spinning forever
                return
            }
            do {
                if let json: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    let members = json["objects"] as! [[String: AnyObject]]
                    let committee = members[0]["committee"] as! [String: AnyObject]
                    let committeename = committee["name"] as! String
                    let obsolete = committee["obsolete"] as! Bool
                    let website = committee["url"] as? String
                    var chair = ""
                    for member in members {
                        if let person = member["person"] as? [String: AnyObject] {
                            let name = (person["firstname"] as! String) + " " + (person["lastname"] as! String)
                            let id = (person["id"] as! Int).description
                            var loc = (person["name"] as! String)
                            loc = loc.substringFromIndex(loc.endIndex.predecessor().predecessor().predecessor().predecessor().predecessor().predecessor().predecessor())
                            loc.removeAtIndex(loc.endIndex.predecessor())
                            while loc.substringToIndex(loc.startIndex.successor()) == "[" || loc.substringToIndex(loc.startIndex.successor()) == " " {
                                loc.removeAtIndex(loc.startIndex)
                            }
                            self.members[name] = (loc, id)
                            let role = member["role"] as! String
                            if role == "chairman" {
                                chair = name
                            }
                        }
                    }
                    self.membernames = (Array(self.members.keys)).sort(<)
                    //self.membernames = self.members.keys.array.sort(<)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.titlelabel.text = committeename
                        if obsolete {self.subtitlelabel.text = "Obsolete"}
                        if chair != "" {
                            self.chair.setTitle(chair + ", Chair >", forState: .Normal)
                        } else {
                            self.chair.hidden = true
                            self.chair.userInteractionEnabled = false
                        }
                        self.website.setTitle(website, forState: .Normal)
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

    @IBAction func viewChair(sender: AnyObject) {
        let congressperson = storyboard?.instantiateViewControllerWithIdentifier("congressperson")
        pagetype = .congressperson
        var temp = chair.titleLabel?.text
        var result = ""
        for c in temp!.characters {
            if c == "," {
                temp?.removeAtIndex((temp?.endIndex.predecessor())!)
                break
            } else {
                result += String(c)
            }
        }
        id = members[result]!.id
        print(id)
        self.showViewController(congressperson!, sender: self)
    }
    
    @IBAction func viewWebsite(sender: AnyObject) {
        let webview = storyboard?.instantiateViewControllerWithIdentifier("research")
        research = website.titleLabel!.text!
        self.showViewController(webview!, sender: self)
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
        return membernames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Member", forIndexPath: indexPath) as UITableViewCell
        let name = membernames[indexPath.row]
        cell.textLabel?.text = name
        let loc = members[name]!.loc
        cell.detailTextLabel?.text = loc
        if loc.substringToIndex(loc.startIndex.successor()) == "R" {
            cell.detailTextLabel?.textColor = UIColor(red: 1, green: 97/255, blue: 97/255, alpha: 1)
        } else if loc.substringToIndex(loc.startIndex.successor()) == "D" {
            cell.detailTextLabel?.textColor = UIColor(red: 97/255, green: 97/255, blue: 1, alpha: 1)
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let congressperson = storyboard?.instantiateViewControllerWithIdentifier("congressperson")
        //self.addChildViewController(bill!)
        pagetype = .congressperson
        id = members[membernames[indexPath.row]]!.id
        self.showViewController(congressperson!, sender: self)
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

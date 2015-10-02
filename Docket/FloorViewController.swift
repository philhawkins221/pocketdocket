//
//  swift
//  Docket
//
//  Created by Phil Hawkins on 7/10/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit

var housebills = ["empty"]
var housetitles = ["empty"]
var senbills = ["empty"]

class FloorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    var filtered = false
    
    var bills = [NSDate : (displaynumber: String, id: String)]() //date posted : (display number, id)
    var billdates = [NSDate]()
    //var ids = [String]()
    
    @IBOutlet weak var loadingindicator: UIActivityIndicatorView!
    
    //var rightswipe: UISwipeGestureRecognizer!
    //var leftswipe: UISwipeGestureRecognizer!
    
    let inDate = NSDateFormatter()
    let outDate = NSDateFormatter()
    
    @IBOutlet weak var webview: UIWebView!
    var house = true
    
    var failcount = 0
    
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
        
        inDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        outDate.dateFormat = "MMMM d, yyyy"
        
        webview.delegate = self
        
        if housebills[0] == "empty" || senbills[0] == "empty" {
            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://docs.house.gov/floor/")!))
            //})
            //loadBills()
        } else {
            loadingindicator.stopAnimating()
            table.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 20/255, green: 154/255, blue: 233/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webview.stringByEvaluatingJavaScriptFromString("document.readyState")! != "complete" {
            print("webview was not fully rendered")
            ++failcount
            
            if failcount < 3 {
                return
            } else {
                self.webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://docs.house.gov/floor/")!))
            }
        }
        
        if house {
            housebills = []
            housetitles = []
            var skips = [Int]()
            let length = Int(webview.stringByEvaluatingJavaScriptFromString("var bills = document.getElementsByClassName(\"legisNum\"); var size = bills.length; size")!)
            print(length!.description)
            for var i=0; i<length; ++i {
                if let housebill = webview.stringByEvaluatingJavaScriptFromString("bills[" + i.description + "].innerHTML") {
                    if housebill == "" {
                        //skips.append(i)
                        continue
                    }
                    if let _ = Int(housebill[(housebill.characters.count) - 1]) {
                        if housebill[0...1] == "H." || housebill[0...1] == "S." {
                            print(housebill)
                            housebills.append(housebill)
                        } else {
                            skips.append(i)
                        }
                    } else {
                        skips.append(i)
                    }
                }
            }
            let count = Int(webview.stringByEvaluatingJavaScriptFromString("var titles = document.getElementsByClassName(\"floorText\"); var count = titles.length; count")!)
            print(length!.description)
            for var i=0; i<count; ++i {
                var skipit = false
                for skip in skips {
                    if i == skip {
                        skipit = true
                        break
                    }
                }
                if skipit {
                    continue
                }
                if let housetitle = webview.stringByEvaluatingJavaScriptFromString("titles[" + i.description + "].innerHTML") {
                    if housetitle.substringToIndex(housetitle.startIndex.successor()) != " " {//housetitle[0] != " " {
                        housetitles.append(housetitle)
                    }
                }
            }
            if !housebills.isEmpty {
                house = false
                webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.senate.gov/legislative/schedule/floor_schedule.htm")!))
                print("house is done, loading senate")
            }
        } else {
            senbills = []
            if webview.stringByEvaluatingJavaScriptFromString("document.readyState")! != "complete" {
                return
            }
            let length = Int(webview.stringByEvaluatingJavaScriptFromString("var bills = document.getElementsByTagName(\"a\"); var size = bills.length; size")!)
            for var i=0; i<length; ++i {
                if let senatebill = webview.stringByEvaluatingJavaScriptFromString("bills[" + i.description + "].innerHTML") {
                    if let _ = Int(senatebill[senatebill.characters.count - 1]) {
                        print(senatebill)
                        senbills.append(senatebill)
                    } else {
                        break
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                //print(self.bills)
                self.table.reloadData()
                self.loadingindicator.stopAnimating()
                self.table.hidden = false
            })
        }
    }
    
    func loadBills() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/bill?congress=114&order_by=-current_status_date&limit=600")!, completionHandler: {(data, response, error) in
            if data == nil {
                //take care of things - or just leave the thing spinning forever
                return
            }
            do {
                if let json: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    if let objects: [[String: AnyObject]] = json["objects"] as? [[String: AnyObject]] {
                        for object in objects {
                            if let date = object["senate_floor_schedule_postdate"] as? String {
                                //self.names.append(object["display_number"] as! String)
                                //self.dates.append(date)
                                /*var result = ""
                                for c in date.characters {
                                    if c == "T" {
                                        break
                                    } else {
                                        result.append(c)
                                    }
                                }*/
                                let time = self.inDate.dateFromString(date)
                                self.bills[time!] = ((object["display_number"] as! String), (object["id"] as! Int).description)
                            } else if let date = object["docs_house_gov_postdate"] as? String {
                                //self.names.append(object["display_number"] as! String)
                                //self.dates.append(date)
                                /*var result = ""
                                for c in date.characters {
                                    if c == "T" {
                                        break
                                    } else {
                                        result.append(c)
                                    }
                                }*/
                                //print(result)
                                let time = self.inDate.dateFromString(date)
                                self.bills[time!] = ((object["display_number"] as! String), (object["id"] as! Int).description)
                            }
                        }
                        self.billdates = Array(self.bills.keys)
                        //self.billdates = self.bills.keys.array
                        self.billdates = self.billdates.sort({ $0.compare($1) == NSComparisonResult.OrderedDescending })
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            //print(self.bills)
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
        })//?.resume()
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
        if section == 0 {
            return housebills.count
        } else {
            return senbills.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Bill", forIndexPath: indexPath) as UITableViewCell
        //cell.textLabel?.text = bills[billdates[indexPath.row]]!.0
        //cell.detailTextLabel?.text = "Posted to Floor Schedule " + outDate.stringFromDate(billdates[indexPath.row])
        //cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        
        if indexPath.section == 0 {
            cell.textLabel?.text = housebills[indexPath.row]
            cell.detailTextLabel?.text = housetitles[indexPath.row]
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        } else {
            cell.textLabel?.text = senbills[indexPath.row]
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var billnumber = ""
        if indexPath.section == 0 {
            billnumber = housebills[indexPath.row]
        } else {
            billnumber = senbills[indexPath.row]
        }
        var result = ""
        for c in billnumber.lowercaseString.characters {
            if c == "." || c == " " {
                continue
            } else {
                result.append(c)
            }
        }
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/bill?congress=114&q=" + result)!, completionHandler: {(data, response, error) in
            if data == nil {
                //take care of things - or just leave the thing spinning forever
                return
            }
            do {
                if let json: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    if let objects: [[String: AnyObject]] = json["objects"] as? [[String: AnyObject]] {
                        let object = objects[0]
                        id = (object["id"] as! Int).description
                        //print(id)
                    }
                }
            } catch {
                print(error)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                //print("search: " + result)
                //print("id: " + id)
                let bill = self.storyboard?.instantiateViewControllerWithIdentifier("bill")
                //self.addChildViewController(bill!)
                pagetype = .bill
                //id = bills[billdates[indexPath.row]]!.id
                self.showViewController(bill!, sender: self)
            })
        }).resume()
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "This Week in the House"
        } else {
            return "Today in the Senate"
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    func leftSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .left
        if sender.state == .Ended {
            performSegueWithIdentifier("floorToDocket", sender: nil)
        }
    }
    
    func rightSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .right
        if sender.state == .Ended {
            performSegueWithIdentifier("floorToRoll", sender: nil)
        }
    }
    
    @IBAction func menu(sender: AnyObject) {
        swipe = .right
        performSegueWithIdentifier("flooractionMenu", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        toViewController.transitioningDelegate = transitionManager
    }


}

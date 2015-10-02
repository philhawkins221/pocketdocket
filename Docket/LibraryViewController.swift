//
//  LibraryViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/20/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var search: UITextField!
    
    //var rightswipe: UISwipeGestureRecognizer!
    //var leftswipe: UISwipeGestureRecognizer!
    
    var escape: UITapGestureRecognizer!
    
    let categories = ["Agriculture and Food", "Animals", "Armed Forces and National Security", "Arts, Culture, Religion", "Civil Rights and Liberties, Minority Issues", "Commerce", "Congress", "Crime and Law Enforcement", "Economics and Public Finance", "Education", "Emergency Management", "Energy", "Environmental Protection", "Families", "Finance and Financial Sector", "Foreign Trade and International Finance", "Government Operations and Politics", "Health", "Housing and Community Development", "Immigration", "International Affairs", "Labor and Employment", "Law", "Native Americans", "Private Legislation", "Public Lands and Natural Resources", "Science, Technology, Communications", "Social Sciences and History", "Social Welfare", "Sports and Recreation", "Taxation", "Transportation and Public Works", "Water Resources Development"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
        search.delegate = self
        
        /*rightswipe = UISwipeGestureRecognizer(target: self, action: "rightSwipe:")
        rightswipe.direction = .Right
        view.addGestureRecognizer(rightswipe)*/
        
        /*leftswipe = UISwipeGestureRecognizer(target: self, action: "leftSwipe:")
        leftswipe.direction = .Left
        view.addGestureRecognizer(leftswipe)*/
        
        escape = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 20/255, green: 154/255, blue: 233/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        view.addGestureRecognizer(escape)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        view.removeGestureRecognizer(escape)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if search.text == nil {
            return false
        }
        //search.resignFirstResponder()
        //search.becomeFirstResponder()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(NSURL(string: "https://www.govtrack.us/api/v2/bill?congress=114&q=" + search.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!)!, completionHandler: {(data, response, error) in
            do {
                if data == nil {
                    //take care of things - or just leave the thing spinning forever
                    return
                }
                if let json: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] {
                    let objects = json["objects"] as! [[String: AnyObject]]
                    let target = objects[0]
                    id = (target["id"] as! Int).description
                    session.finishTasksAndInvalidate()
                }
                dispatch_async(dispatch_get_main_queue(), {
                    pagetype = .bill
                    let bill = self.storyboard?.instantiateViewControllerWithIdentifier("bill")
                    self.showViewController(bill!, sender: self)
                })
            } catch {
                print(error)
            }
        }).resume()
        
        return false
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
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("Category", forIndexPath: indexPath) as UITableViewCell)
        
        cell.textLabel?.text = categories[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //id = something
        let name = categories[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
        research = "https://www.congress.gov/advanced-search?raw=%5B%7B%22op%22%3A%22AND%22%2C%22conditions%22%3A%5B%7B%22op%22%3A%22AND%22%2C%22inputs%22%3A%7B%22source%22%3A%22legislation%22%2C%22field%22%3A%22congress%22%2C%22operator%22%3A%22is%22%2C%22value%22%3A%22114%22%7D%7D%2C%7B%22op%22%3A%22AND%22%2C%22inputs%22%3A%7B%22source%22%3A%22legislation%22%2C%22field%22%3A%22subject%22%2C%22operator%22%3A%22is%22%2C%22value%22%3A%22" + name + "%22%7D%7D%5D%7D%5D&pageSort=relevancy"
        let resview = storyboard?.instantiateViewControllerWithIdentifier("research")
        self.showViewController(resview!, sender: self)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    /*func leftSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .left
        if sender.state == .Ended {
            performSegueWithIdentifier("floorToDocket", sender: nil)
        }
    }*/
    
    func rightSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .right
        if sender.state == .Ended {
            performSegueWithIdentifier("libraryToDocket", sender: nil)
        }
    }
    
    @IBAction func menu(sender: AnyObject) {
        swipe = .right
        performSegueWithIdentifier("libraryMenu", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        toViewController.transitioningDelegate = transitionManager
    }

}

//
//  MyDocketViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/8/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

let transitionManager = TransitionManager()

enum info {
    case congressperson
    case committee
    case bill
}

var pagetype: info = info.bill
var id = ""

extension String {
    
    subscript (i: Int) -> Character {
        //return self[advance(self.startIndex, i)]
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        //return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
        return substringWithRange(Range(start: self.startIndex.advancedBy(r.startIndex), end: self.startIndex.advancedBy(r.endIndex)))
    }
}

import UIKit
import CoreData

class MyDocketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var districtlabel: UILabel!
    
    //var rightswipe: UISwipeGestureRecognizer!
    //var leftswipe: UISwipeGestureRecognizer!
    
    var bills = [NSManagedObject]()
    //var committees = [NSManagedObject]()
    var congresspeople = [NSManagedObject]()
    let defaults = NSUserDefaults.standardUserDefaults()
    var district = ""
    var districtsaved = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        table.delegate = self
        table.dataSource = self
        
        /*rightswipe = UISwipeGestureRecognizer(target: self, action: "rightSwipe:")
        rightswipe.direction = .Right
        view.addGestureRecognizer(rightswipe)
        
        leftswipe = UISwipeGestureRecognizer(target: self, action: "leftSwipe:")
        leftswipe.direction = .Left
        view.addGestureRecognizer(leftswipe)*/
        
        //fetch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 20/255, green: 154/255, blue: 233/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
        
        fetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetch() {
        print("fetching")
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let billRequest = NSFetchRequest(entityName:"Bill")
        //let committeeRequest = NSFetchRequest(entityName: "Committee")
        let congresspersonRequest = NSFetchRequest(entityName: "Representative")
        //let districtRequest = NSFetchRequest(entityName: "District")
        
        //3
        do {
            bills = try managedContext.executeFetchRequest(billRequest) as! [NSManagedObject]
            //committees = try managedContext.executeFetchRequest(committeeRequest) as! [NSManagedObject]
            congresspeople = try managedContext.executeFetchRequest(congresspersonRequest) as! [NSManagedObject]
            //district = try (managedContext.executeFetchRequest(districtRequest) as! [NSManagedObject])[0]
        } catch {
            print(error)
        }
        
        if let district = defaults.stringForKey("district") {
            self.district = district
            districtsaved = true
            districtlabel.text! += (" " + self.district)
            districtlabel.hidden = false
        }
        
        table.reloadData()
    }
    
    @IBAction func setdistrict(sender: AnyObject) {
        let districtsetter = UIAlertController(title: "Enter a District", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        districtsetter.addTextFieldWithConfigurationHandler({textfield in
            textfield.placeholder = "\"TX-10\", \"AK-0\", e.g."
        })
        districtsetter.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in
            self.defaults.setObject(districtsetter.textFields?.first?.text, forKey: "district")
            self.fetch()
        }))
        districtsetter.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {action in }))
        presentViewController(districtsetter, animated: true, completion: nil)
    }
    
    //MARK: - TableView Stack
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //if districtsaved {
        //    return 3
        //} else {
            return 2
        //}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return bills.count
        } else if section == 1 {
            return congresspeople.count
        } else if section == 2 {
            return 3
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DocketItem", forIndexPath: indexPath) as UITableViewCell
        cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        
        if indexPath.section == 0 && !bills.isEmpty {
            let number = (bills[indexPath.row].valueForKey("number") as! String)
            let title = (bills[indexPath.row].valueForKey("title") as! String)
            cell.textLabel?.text = number
            cell.detailTextLabel?.text = title
        } else if indexPath.section == 1 && !congresspeople.isEmpty {
            let name = (congresspeople[indexPath.row].valueForKey("name") as! String)
            let title = (congresspeople[indexPath.row].valueForKey("title") as! String)
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = title
        } else if indexPath.section == 2 {
            cell.textLabel?.text = "Representative"
            cell.detailTextLabel?.text = "District"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let bill = storyboard?.instantiateViewControllerWithIdentifier("bill")
            //self.addChildViewController(bill!)
            pagetype = .bill
            id = bills[indexPath.row].valueForKey("id") as! String
            self.showViewController(bill!, sender: self)
        } else {
            let congressperson = storyboard?.instantiateViewControllerWithIdentifier("congressperson")
            //self.addChildViewController(bill!)
            pagetype = .congressperson
            id = congresspeople[indexPath.row].valueForKey("id") as! String
            self.showViewController(congressperson!, sender: self)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int)  -> String? {
        if section == 0 {
            return "Bills"
        } else if section == 1 {
            return "Representatives"
        } else if section == 2 {
            return "My District"
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Untrack", handler: {action, indexpath in
                if indexPath.section == 0 {
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let managedContext = appDelegate.managedObjectContext
                    managedContext.deleteObject(self.bills[indexPath.row])
                    self.bills.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                } else if indexPath.section == 1 {
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let managedContext = appDelegate.managedObjectContext
                    managedContext.deleteObject(self.congresspeople[indexPath.row])
                    self.congresspeople.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            })
        
        deleteRowAction.backgroundColor = UIColor.redColor()
        return [deleteRowAction]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    func rightSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .right
        if sender.state == .Ended {
            performSegueWithIdentifier("docketToFloor", sender: nil)
        }
    }
    
    func leftSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .left
        if sender.state == UIGestureRecognizerState.Ended {
            performSegueWithIdentifier("docketToLibrary", sender: nil)
        }
    }
    
    @IBAction func menu(sender: AnyObject) {
        swipe = .right
        performSegueWithIdentifier("mydocketMenu", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        toViewController.transitioningDelegate = transitionManager
    }


}

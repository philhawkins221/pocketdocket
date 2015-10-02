//
//  MenuViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 9/29/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var library: UIButton!
    @IBOutlet weak var mydocket: UIButton!
    @IBOutlet weak var flooraction: UIButton!
    @IBOutlet weak var rollcall: UIButton!
    @IBOutlet weak var committees: UIButton!
    @IBOutlet weak var states: UIButton!
    
    let docketBlue = UIColor(red: 20/255, green: 154/255, blue: 233/255, alpha: 1)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        swipe = .right
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func libraryDown(sender: AnyObject) {
        library.backgroundColor = docketBlue
    }
    @IBAction func libraryUp(sender: AnyObject) {
        swipe = .left
        library.backgroundColor = UIColor.darkGrayColor()
        performSegueWithIdentifier("library", sender: nil)
    }
    
    @IBAction func mydocketDown(sender: AnyObject) {
        mydocket.backgroundColor = docketBlue
    }
    @IBAction func mydocketUp(sender: AnyObject) {
        swipe = .left
        mydocket.backgroundColor = UIColor.darkGrayColor()
        performSegueWithIdentifier("mydocket", sender: nil)
    }
    
    @IBAction func flooractionDown(sender: AnyObject) {
        flooraction.backgroundColor = docketBlue
    }
    @IBAction func flooractionUp(sender: AnyObject) {
        swipe = .left
        flooraction.backgroundColor = UIColor.darkGrayColor()
        performSegueWithIdentifier("flooraction", sender: nil)
    }
    
    @IBAction func rollcallDown(sender: AnyObject) {
        rollcall.backgroundColor = docketBlue
    }
    @IBAction func rollcallUp(sender: AnyObject) {
        swipe = .left
        rollcall.backgroundColor = UIColor.darkGrayColor()
        performSegueWithIdentifier("rollcall", sender: nil)
    }
    
    @IBAction func committeesDown(sender: AnyObject) {
        committees.backgroundColor = docketBlue
    }
    @IBAction func committeesUp(sender: AnyObject) {
        swipe = .left
        committees.backgroundColor = UIColor.darkGrayColor()
        performSegueWithIdentifier("committees", sender: nil)
    }
    
    @IBAction func statesDown(sender: AnyObject) {
        states.backgroundColor = docketBlue
    }
    @IBAction func statesUp(sender: AnyObject) {
        swipe = .left
        states.backgroundColor = UIColor.darkGrayColor()
        performSegueWithIdentifier("states", sender: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        toViewController.transitioningDelegate = transitionManager
    }


}

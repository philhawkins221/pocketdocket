//
//  StatesViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/18/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//

import UIKit

class StatesViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var loadingindicator: UIActivityIndicatorView!
    
    //var leftswipe: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*rightswipe = UISwipeGestureRecognizer(target: self, action: "rightSwipe:")
        rightswipe.direction = .Right
        view.addGestureRecognizer(rightswipe)*/
        
        /*leftswipe = UISwipeGestureRecognizer(target: self, action: "leftSwipe:")
        leftswipe.direction = .Left
        view.addGestureRecognizer(leftswipe)*/
        
        webview.hidden = true
        webview.delegate = self
        webview.loadRequest(NSURLRequest(URL: NSURL(string: "https://www.govtrack.us/start#states")!))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 20/255, green: 154/255, blue: 233/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingindicator.stopAnimating()
        webview.hidden = false
    }
    
    @IBAction func back(sender: AnyObject) {
        webview.goBack()
    }

    @IBAction func forward(sender: AnyObject) {
        webview.goForward()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func leftSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .left
        if sender.state == .Ended {
            performSegueWithIdentifier("stateToCommittee", sender: nil)
        }
    }
    
    /*func rightSwipe(sender: UISwipeGestureRecognizer) {
        swipe = .right
        if sender.state == .Ended {
            performSegueWithIdentifier("committeeToState", sender: nil)
        }
    }*/
    
    @IBAction func menu(sender: AnyObject) {
        swipe = .right
        performSegueWithIdentifier("statesMenu", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        toViewController.transitioningDelegate = transitionManager
    }

}

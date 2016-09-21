//
//  ViewController.swift
//
//  Created by Kurt Jensen on 9/21/16.
//

import UIKit
import Parse

class ViewController: UIViewController, LiveQueryManagerDelegate {
    
    let className = "Object" // make sure this is a live query class name specified in your parse server configuration
    
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var numberUpdatedLabel: UILabel!
    @IBOutlet weak var numberCreatedLabel: UILabel!
    @IBOutlet weak var numberTotalLabel: UILabel!
    
    private var liveQueryManager: LiveQueryManager? {
        didSet {
            toggleButton.setTitle(liveQueryManager == nil ? "START" : "STOP", forState: .Normal)
        }
    }
    private var numberCreated = 0 {
        didSet {
            numberCreatedLabel.text = "CREATED: \(numberCreated)"
        }
    }
    private var numberUpdated = 0 {
        didSet {
            numberUpdatedLabel.text = "UPDATED: \(numberUpdated)"
        }
    }
    private var numberTotal = 0 {
        didSet {
            numberTotalLabel.text = "TOTAL: \(numberTotal)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
        createObject()
    }
    
    func reset() {
        numberCreated = 0
        numberUpdated = 0
        numberTotal = 0
    }
    
    @IBAction func toggle(sender: UIButton) {
        if liveQueryManager == nil {
            startLiveQuery()
        } else {
            stopLiveQuery()
        }
    }
    
    func startLiveQuery() {
        liveQueryManager = LiveQueryManager(className: className)
        liveQueryManager?.delegate = self
    }
    
    func stopLiveQuery() {
        liveQueryManager?.stop()
        liveQueryManager = nil
        reset()
    }
    
    func createObject() {
        let object = PFObject(className: className)
        object["number"] = NSNumber(int: rand())
        object.saveInBackground()
        if rand() % 2 == 0 {
            performSelector(#selector(ViewController.updateObject(_:)), withObject: object, afterDelay: NSTimeInterval(rand() % 10))
        }
        performSelector(#selector(ViewController.createObject), withObject: nil, afterDelay: 5)
    }
    
    func updateObject(object: PFObject?) {
        guard let object = object else {
            return
        }
        object["number"] = NSNumber(int: rand())
        object.saveInBackground()
    }
    
    func objectCreated(object: PFObject) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            print("created", object)
            self.numberCreated += 1
            self.numberTotal += 1
        }
    }
    
    func objectUpdated(object: PFObject) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            print("updated", object)
            self.numberUpdated += 1
        }
    }
    
    func objectsQueried(objects: [PFObject]) {
        print("queried", objects)
        self.numberTotal += objects.count
    }
    
}


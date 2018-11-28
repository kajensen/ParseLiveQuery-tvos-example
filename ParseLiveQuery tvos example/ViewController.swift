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
            toggleButton.setTitle(liveQueryManager == nil ? "START" : "STOP", for: .normal)
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
    
    @objc func createObject() {
        let object = PFObject(className: className)
        object["number"] = NSNumber(value: arc4random())
        object.saveInBackground()
        if arc4random() % 2 == 0 {
            perform(#selector(ViewController.updateObject(object:)), with: object, afterDelay: TimeInterval(arc4random() % 10))
        }
        perform(#selector(ViewController.createObject), with: nil, afterDelay: 5)
    }
    
    @objc func updateObject(object: PFObject?) {
        guard let object = object else {
            return
        }
        object["number"] = NSNumber(value: arc4random())
        object.saveInBackground()
    }
    
    func objectCreated(object: PFObject) {
        DispatchQueue.main.async {
            print("created", object)
            self.numberCreated += 1
            self.numberTotal += 1
        }
    }
    
    func objectUpdated(object: PFObject) {
        DispatchQueue.main.async {
            print("updated", object)
            self.numberUpdated += 1
        }
    }
    
    func objectsQueried(objects: [PFObject]) {
        print("queried", objects)
        self.numberTotal += objects.count
    }
    
}


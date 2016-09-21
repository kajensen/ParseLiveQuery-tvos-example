//
//  LiveQueryManager.swift
//
//  Created by Kurt Jensen on 9/21/16.
//

import UIKit
import Parse
import ParseLiveQuery

protocol LiveQueryManagerDelegate {
    func objectsQueried(objects: [PFObject])
    func objectUpdated(object: PFObject)
    func objectCreated(object: PFObject)
}

class LiveQueryManager: NSObject {
    
    private var subscription: Subscription<PFObject>?
    private var query: PFQuery?
    var delegate: LiveQueryManagerDelegate?
    
    convenience init(className: String) {
        self.init()
        query = PFQuery(className: className)
        query?.whereKeyExists("number")
        subscription = query?.subscribe()
        subscription?.handle(Event.Updated) { [unowned self] query, object in
            self.delegate?.objectUpdated(object)
        }
        subscription?.handle(Event.Created) { [unowned self] query, object in
            self.delegate?.objectCreated(object)
        }
        query?.findObjectsInBackgroundWithBlock({ [unowned self]  (objects, error) in
            if let objects = objects {
                self.delegate?.objectsQueried(objects)
            }
        })
    }
 
    func stop() {
        guard let query = query else {
            return
        }
        Client.shared.unsubscribe(query)
        self.query = nil
        self.subscription = nil
    }
    
}

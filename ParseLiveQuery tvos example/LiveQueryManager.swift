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
    private var query: PFQuery<PFObject>?
    private var client = ParseLiveQuery.Client()
    var delegate: LiveQueryManagerDelegate?
    
    convenience init(className: String) {
        self.init()
        query = PFQuery(className: className)
        query?.whereKeyExists("number")
        subscription = client.subscribe(query!)
        subscription?.handle(Event.updated) { [unowned self] query, object in
            self.delegate?.objectUpdated(object: object)
        }
        subscription?.handle(Event.created) { [unowned self] query, object in
            self.delegate?.objectCreated(object: object)
        }
        query?.findObjectsInBackground(block: { [unowned self]  (objects, error) in
            if let objects = objects {
                self.delegate?.objectsQueried(objects: objects)
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

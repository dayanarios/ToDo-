//
//  Item.swift
//  To Do!
//
//  Created by Dayana on 8/19/19.
//  Copyright © 2019 Dayana Rios. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    
    //creating a one to one relationship with a Category object
    //items is the name of list of a categories items 
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}

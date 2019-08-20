//
//  Category.swift
//  To Do!
//
//  Created by Dayana on 8/19/19.
//  Copyright © 2019 Dayana Rios. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object{
    @objc dynamic var name : String = ""
    
    //creating a one to many relationship to Item objects
    let items = List<Item>()
    
}

//
//  ToDoViewController.swift
//  To Do!
//
//  Created by Dayana on 8/19/19.
//  Copyright © 2019 Dayana Rios. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class ToDoViewController: SwipeTableViewController  {
    
    var toDoItems : Results<Item>?
    
    let realm = try! Realm()
    
    
    //loads corresponding items to selected category
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
       

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return toDoItems?.count ?? 1 //if nil use 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //gets reference from super view controller (swipeTableViewCell)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        // Configure the cell...
        //if an item exist
        if let item = toDoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            //gradient effect for cells
            if let color  = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat( indexPath.row) / CGFloat(toDoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            //toggles checkmark depending on done status
            cell.accessoryType = item.done ? .checkmark : .none
        }
        else{
            cell.textLabel?.text = "No Items Added Yet"
        }
        

        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //toggle the checkmark if the item is not nil
        //update attribute in our realm db
        if let item = toDoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }
            catch{
                print("error updating item, \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)

    }
    

    //MARK: - Add Button Methods

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            //if a category has been set get a reference to it and create a new item
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.done = false
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                }
                catch{
                    print("error adding item, \(error)")
                }
            }
            
            self.tableView.reloadData()

        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add new Item"
            
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Saving and Loading Methods
    
    func loadItems(){
        
        //load the items in the selected category's results container
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        //if an item exist at this location
        if let item = toDoItems?[indexPath.row]{
            do {
                try realm.write {
                    realm.delete(item)
                }
            }
            catch
            {
                print("error deleting item, \(error)")
            }
        }
    }

}



extension ToDoViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { //search bar is no longer being used
            loadItems()
            
            //access the main thread and suspend it
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            
        }
    }
}

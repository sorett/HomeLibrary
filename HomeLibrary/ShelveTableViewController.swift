//
//  ShelveTableViewController.swift
//  HomeLibrary
//
//  Created by 郭明智 on 2020/4/2.
//  Copyright © 2020 郭明智. All rights reserved.
//

import UIKit
import CoreData

class ShelveTableViewController: UITableViewController {

    //Connect core data
    let myEntityName = "Booklists"
    let myContext =
         (UIApplication.shared.delegate as! AppDelegate)
             .persistentContainer.viewContext
    
    @IBSegueAction func showBok(_ coder: NSCoder) -> BookViewController? {
        if let row = tableView.indexPathForSelectedRow?.row {
            // select
            let coreDataConnect = CoreDataConnect(context: myContext)
            let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["title":true]], limit: nil)

            if let result = selectResult?[row] {
                let isbn = result.value(forKey: "isbn")!

                let controller = BookViewController(coder: coder)
                
                controller?.book["isbn"] = isbn as? String
                controller?.book["mode"] = "navigation"
                
                return controller
            } else {
               return nil
           }
        } else {
            return nil
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        //添加刷新
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl?.attributedTitle = NSAttributedString(string: "更新資料", attributes: attributes)
        refreshControl?.tintColor = UIColor.white
        refreshControl?.backgroundColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(getData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func getData() {
         DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let coreDataConnect = CoreDataConnect(context: myContext)
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["title":true]], limit: nil)
        
        if let results = selectResult {
            print(results.count)
            return results.count
        } else {
            print("no record")
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Shelve", for: indexPath) as! BookListTableViewCell

        // Configure the cell...
    
        // select
        let coreDataConnect = CoreDataConnect(context: myContext)
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["title":true]], limit: nil)

        let result = selectResult?[indexPath.row]
        if let title = result?.value(forKey: "title")! {
            cell.bookTitle?.text = title as? String
        }
        if let authors = result?.value(forKey: "authors")! {
            cell.bookAuthors?.text = authors as? String
        }
        if let adddate = result?.value(forKey: "adddate")! {
            cell.bookAddDate?.text = adddate as? String
        }
        if let publisheddate = result?.value(forKey: "publisheddate")! {
            cell.bookPublishDate?.text = publisheddate as? String
        }
        if let cover = result?.value(forKey: "cover")! {
            cell.bookCover.load(url: URL(string: cover as! String)!)
        }

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // select
            let coreDataConnect = CoreDataConnect(context: myContext)
            let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["title":true]], limit: nil)

            let result = selectResult?[indexPath.row]
            if let isbn = result?.value(forKey: "isbn")! {
                // delete
                let sql = "isbn = \(isbn as! String)"
                let deleteResult = coreDataConnect.delete(
                    myEntityName, predicate: sql)
                if deleteResult {
                    print("刪除資料成功")
                }
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

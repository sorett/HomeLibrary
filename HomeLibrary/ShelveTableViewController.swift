//
//  ShelveTableViewController.swift
//  HomeLibrary
//
//  Created by 郭明智 on 2020/4/2.
//  Copyright © 2020 郭明智. All rights reserved.
//

import UIKit
import CoreData

class ShelveTableViewController: UITableViewController, UISearchResultsUpdating {

    //Connect core data
    var records:[[String : String]] = []
    var filterRecords:[[String : String]] = []
    let myEntityName = "Booklists"
    let myContext =
         (UIApplication.shared.delegate as! AppDelegate)
             .persistentContainer.viewContext
    var mySearchController: UISearchController?

    @IBSegueAction func showBok(_ coder: NSCoder) -> BookViewController? {
        if let row = tableView.indexPathForSelectedRow?.row {

            let result = ((mySearchController?.isActive)!) ? filterRecords[row] : records[row]
            
            //let result = records[row]
            
            if let isbn = result["isbn"]{
                let controller = BookViewController(coder: coder)
                    
                controller?.book["idx"] = String(row)
                controller?.book["isbn"] = isbn
                controller?.book["provider"] = result["provider"]
                controller?.book["adddate"] = result["adddate"]
                controller?.book["cover"] = result["cover"]
                controller?.book["title"] = result["title"]
                controller?.book["authors"] = result["authors"]
                controller?.book["publisher"] = result["publisher"]
                controller?.book["publisheddate"] = result["publisheddate"]
                controller?.book["description"] = result["bookdescription"]
                controller?.book["note"] = result["note"]
                
                return controller
            } else {
               return nil
           }
        } else {
            return nil
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //self.navigationController?.isNavigationBarHidden = true
        //self.navigationController?.title = "書目列表"
        
        //reloadData
        DispatchQueue.main.async {
            self.tableView.reloadData()
            //print("reload")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "書目列表"
        
        getData()
        //添加刷新
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        refreshControl?.attributedTitle = NSAttributedString(string: "更新資料", attributes: attributes)
        refreshControl?.tintColor = UIColor.systemGray
        refreshControl?.backgroundColor = UIColor.systemBackground
        refreshControl?.addTarget(self, action: #selector(getRefreshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        //跨頁接收值
        let notificationName = Notification.Name("GetUpdateNotice")
        NotificationCenter.default.addObserver(self, selector: #selector(updateRecord(notice:)), name: notificationName, object: nil)
        
        //Search
        settingSearchController()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        /*
        self.searchTextField!.addTarget(self, action: #selector(self.searchEditBegin(textField:)), for: .editingDidBegin)
        self.searchTextField!.addTarget(self, action: #selector(self.searchEditEnter), for: .primaryActionTriggered)
        self.searchTextField!.addTarget(self, action: #selector(self.searchEditChange), for: .editingChanged)
     */
    }
    
    //Search func start
    func settingSearchController(){
        mySearchController = UISearchController(searchResultsController: nil)
        mySearchController?.searchResultsUpdater = self
        self.navigationItem.searchController = mySearchController
        mySearchController?.searchBar.placeholder = "請輸入書名或ISBN"
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
            searchController.obscuresBackgroundDuringPresentation = false
        }
    }
    
    func filterContent(for searchText: String){
        filterRecords = records.filter({ (filterArray) -> Bool in
           let words = filterArray["title"]!
           let isbn = filterArray["isbn"]!
           let isMach = words.localizedCaseInsensitiveContains(searchText) ||
                        isbn.localizedCaseInsensitiveContains(searchText)
           return isMach
       })
    }
    //Search func end
    
    @objc func updateRecord(notice:Notification){
        
        let action = notice.userInfo!["action"] as! String
        let idx = Int(notice.userInfo!["idx"] as! String)
        //let isbn = notice.userInfo!["isbn"] as? String

        if (mySearchController?.isActive)! {
            //return filterRecords.count
        } else {
            //return records.count
        }
        
        switch action{
            case "CREATE":
                let book:[String:String] = notice.userInfo!["data"] as! [String : String]
                
                let thisBook = [
                    "provider" : book["provider"]!,
                    "isbn" : book["isbn"]!,
                    "title" : book["title"]!,
                    "authors" : book["authors"]!,
                    "note" : book["note"]!,
                    "bookdescription" : book["bookdescription"]!,
                    "publisher" : book["publisher"]!,
                    "publisheddate" : book["publisheddate"]!,
                    "adddate" : book["adddate"]!,
                    "cover" : book["cover"]!,
                ]
                
                //print(thisBook)
                records.insert(thisBook, at: 0)
            break;
            
            case "UPDATE":
                if let note = notice.userInfo!["note"] as? String{
                    records[idx!]["note"] = note
                }
            break;
            
            case "DELETE":
                records.remove(at: idx!)
            break;
            
            default:
                print("nothing")
            break;
        }
   }
    
    @objc func getData() {
        //clear all
        //records.removeAll()
        
        // select
        let coreDataConnect = CoreDataConnect(context: myContext)
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["adddate":false],["title":true]], limit: nil)
        if let results = selectResult {
            for i in 0..<results.count{
                let result = selectResult?[i]
                
                let thisBook = [
                    "provider" : (result!.value(forKey: "provider") as? String)!,
                    "isbn" : (result!.value(forKey: "isbn") as? String)!,
                    "title" : (result!.value(forKey: "title") as? String)!,
                    "authors" : (result!.value(forKey: "authors") as? String)!,
                    "note" : (result!.value(forKey: "note") as? String)!,
                    "bookdescription" : (result!.value(forKey: "bookdescription") as? String)!,
                    "publisher" : (result!.value(forKey: "publisher") as? String)!,
                    "publisheddate" : (result!.value(forKey: "publisheddate") as? String)!,
                    "adddate" : (result!.value(forKey: "adddate") as? String)!,
                    "cover" : (result!.value(forKey: "cover") as? String)!,
                ]
                //print(thisBook)
                records.append(thisBook)
            }
            
            //print(records)
            //print(records[0])
        }
    }
    
    @objc func getRefreshData() {
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
        
        if (mySearchController?.isActive)! {
            return filterRecords.count
        } else {
            return records.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Shelve", for: indexPath) as! BookListTableViewCell

        // Configure the cell...
        let result = ((mySearchController?.isActive)!) ? filterRecords[indexPath.row] : records[indexPath.row]
        
        //let result = records[indexPath.row]
        //print(result)
        if let title = result["title"] {
            cell.bookTitle?.text = title
            
            //去除 textView 左右邊距
            cell.bookTitle?.textContainer.lineFragmentPadding = 0
            
            //去除 textView 上下邊距
            //self.textView.textContainerInset = UIEdgeInsetsZero;
            
            //UITextView Margin
            //cell.bookTitle?.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
            
        }
        if let authors = result["authors"] {
            cell.bookAuthors?.text = authors
        }
        if let adddate = result["adddate"] {
            cell.bookAddDate?.text = adddate
        }
        if let publisheddate = result["publisheddate"] {
            cell.bookPublishDate?.text = publisheddate
        }
        if let cover = result["cover"] {
            cell.bookCover.load(url: URL(string: cover)!, isbn: result["isbn"]!)
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

            let result = ((mySearchController?.isActive)!) ? filterRecords[indexPath.row] : records[indexPath.row]
            //let result = records[indexPath.row]
            if let isbn = result["isbn"] {
                // delete
                let coreDataConnect = CoreDataConnect(context: myContext)
                let sql = "isbn = \(isbn)"
                let deleteResult = coreDataConnect.delete(
                    myEntityName, predicate: sql)
                if deleteResult {
                    print("刪除資料成功")
                }
                records.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "書目列表"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

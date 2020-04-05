//
//  BookViewController.swift
//  HomeLibrary
//
//  Created by 郭明智 on 2020/4/3.
//  Copyright © 2020 郭明智. All rights reserved.
//

import UIKit
import CoreData

extension UIImageView {
   func load(url: URL) {
       DispatchQueue.global().async { [weak self] in
           if let data = try? Data(contentsOf: url) {
               if let image = UIImage(data: data) {
                   DispatchQueue.main.async {
                       self?.image = image
                   }
               }
           }
       }
   }
}

class BookViewController: UIViewController {

    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookAddDate: UILabel!
    @IBOutlet weak var bookTitle: UITextView!
    @IBOutlet weak var bookAuthors: UILabel!
    @IBOutlet weak var bookPublisher: UILabel!
    @IBOutlet weak var bookPublishedDate: UILabel!
    @IBOutlet weak var bookDescription: UITextView!
    @IBOutlet weak var bookAction: UIButton!
    @IBOutlet weak var bookDelete: UIButton!
    @IBOutlet weak var bookDismiss: UIButton!
    @IBOutlet weak var noteText: UITextField!
    
    var book = [
                "isbn":"",
                "title":"",
                "cover":"",
                "adddate":"",
                "authors":"",
                "publisher":"",
                "publisheddate":"",
                "description":"",
                "note": "",
                "action":"CREATE",
                "mode":"present"
                ]
    @objc func backViewBtnFnc(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //default
        bookDelete.isHidden = true
        // Do any additional setup after loading the view.
        if book["mode"] == "present"{
            bookDismiss.isHidden = false
        } else {
            bookDismiss.isHidden = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "回上一頁", style: .plain, target: self,action: #selector(backViewBtnFnc))
        }
        
        //Connect core data
        let myEntityName = "Booklists"
        let myContext =
             (UIApplication.shared.delegate as! AppDelegate)
                 .persistentContainer.viewContext
        
        let coreDataConnect = CoreDataConnect(context: myContext)

        // select
        let sql = "isbn = \(book["isbn"]!)"
        //print(book["isbn"]!)
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: sql, sort: [["title":true]], limit: nil)
        
        if let results = selectResult {
            //print(results.count)
            
            if(results.count > 0){
                bookDelete.isHidden = false
                bookAction.setTitle("更新資料", for: .normal)
                bookAction.setImage(UIImage(systemName: "pencil"), for: .normal)
                
                book["action"] = "UPDATE"
            
                for result in results {
                    book["adddate"] = result.value(forKey: "adddate")! as? String
                    noteText.text = result.value(forKey: "note")! as? String
                    
                    //print("\(result.value(forKey: "isbn")!). \(result.value(forKey: "title")!)")
                    
                    bookTitle.text = result.value(forKey: "title")! as? String
                    bookAuthors.text = result.value(forKey: "authors")! as? String
                    bookPublisher.text = result.value(forKey: "publisher")! as? String
                    bookPublishedDate.text = result.value(forKey: "publisheddate")! as? String
                    bookDescription.text = result.value(forKey: "bookdescription")! as? String

                    if let cover = result.value(forKey: "cover") as? String {
                        bookCover.load(url: URL(string: cover )!)
                    }
                    
                    bookAddDate.text = "加入書櫃日期: "+book["adddate"]!
                }
            } else {
                bookDelete.isHidden = true
                bookAction.setTitle("加入書櫃", for: .normal)
                bookAction.setImage(UIImage(systemName: "plus"), for: .normal)
                book["action"] = "CREATE"
                
                bookTitle.text = book["title"]
                bookAuthors.text = book["authors"]
                bookPublisher.text = book["publisher"]
                bookPublishedDate.text = book["publisheddate"]
                bookDescription.text = book["description"]

                bookCover.load(url: URL(string: book["cover"]!)!)
                
                bookAddDate.isHidden = true
            }
        }
    }
   
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shelveModify(_ sender: UIButton) {
        //Connect core data
        let myEntityName = "Booklists"
        let myContext =
             (UIApplication.shared.delegate as! AppDelegate)
                 .persistentContainer.viewContext
        
        let coreDataConnect = CoreDataConnect(context: myContext)

        if sender == bookDelete{
            book["action"] = "DELETE"
        }
        
        switch book["action"] {
            case "CREATE":
                let today = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let adddate = dateFormatter.string(from: today)
                
                // insert
                let insertResult = coreDataConnect.insert(myEntityName, attributeInfo: [
                        "isbn" : "\(book["isbn"]!)",
                        "title" : "\(book["title"]!)",
                        "cover" : "\(book["cover"]!)",
                        "authors" : "\(book["authors"]!)",
                        "publisher" : "\(book["publisher"]!)",
                        "publisheddate" : "\(book["publisheddate"]!)",
                        "bookdescription" : "\(book["description"]!)",
                        "note" : noteText.text!,
                        "adddate" : "\(adddate)",
                    ])
                 if insertResult {
                    print("新增資料成功")
                    dismiss(animated: true, completion: nil)
                }
                break;
            case "UPDATE":
                // update
                let sql = "isbn = \(book["isbn"]!)"
                let updateResult = coreDataConnect.update(
                    myEntityName,
                    predicate: sql,
                    attributeInfo: ["note":noteText.text!])
                if updateResult {
                    let alert = UIAlertController(title: "", message: "更新資料成功", preferredStyle: .alert)
                     
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                    print("更新資料成功")
                }
                break;
            case "DELETE":
                // delete
                let sql = "isbn = \(book["isbn"]!)"
                let deleteResult = coreDataConnect.delete(
                    myEntityName, predicate: sql)
                if deleteResult {
                    print("刪除資料成功")
                    
                    if book["mode"] == "present"{
                        dismiss(animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }
                break;
            default:
                print("no action")
                dismiss(animated: true, completion: nil)
                break;
        }
        
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


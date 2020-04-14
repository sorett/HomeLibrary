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
    func load(url: URL, isbn: String) {
        let tempDirectory = FileManager.default.temporaryDirectory
        //let imageFileUrl = tempDirectory.appendingPathComponent(url.lastPathComponent)
        let imageFileUrl = tempDirectory.appendingPathComponent(isbn)

        self.image = nil
        //print(imageFileUrl)
        //print(imageFileUrl.path)
        if FileManager.default.fileExists(atPath: imageFileUrl.path) {
            let image = UIImage(contentsOfFile: imageFileUrl.path)
            self.image = image
        } else {
            //背景的queue
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        try? data.write(to: imageFileUrl) //寫入暫存
                        //前景的queue
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
    }
}

class BookViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookAddDate: UILabel!

    @IBOutlet weak var bookISBN: UILabel!
    @IBOutlet weak var bookTitle: UITextView!
    @IBOutlet weak var bookAuthors: UILabel!
    @IBOutlet weak var bookPublisher: UILabel!
    @IBOutlet weak var bookPublishedDate: UILabel!
    @IBOutlet weak var bookDescription: UITextView!
    @IBOutlet weak var bookAction: UIButton!
    @IBOutlet weak var bookDelete: UIButton!
    @IBOutlet weak var bookDismiss: UIButton!
    @IBOutlet weak var bookProvider: UILabel!
    @IBOutlet weak var noteText: UITextField!
    
    var book = [
        "idx" : "",
        "isbn":"",
        "title":"",
        "cover":"",
        "adddate":"",
        "authors":"",
        "publisher":"",
        "publisheddate":"",
        "description":"",
        "provider": "",
        "note": "",
        "action":"CREATE"
    ]
    @objc func backViewBtnFnc(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bookISBN.isUserInteractionEnabled = false
        // Do any additional setup after loading the view.
        if let _ = navigationController{
            //on shelve
            bookDelete.isHidden = false
            bookDismiss.isHidden = true
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "回上一頁", style: .plain, target: self,action: #selector(backViewBtnFnc))
 
            bookAction.setTitle("更新資料", for: .normal)
            bookAction.setImage(UIImage(systemName: "pencil"), for: .normal)
           
            book["action"] = "UPDATE"
            
            if let adddate = book["adddate"]{
                bookAddDate.text = "加入書櫃日期: "+adddate
            } else {
                bookAddDate.text = ""
            }
            noteText.text = book["note"]
        } else {
            //in search
            bookDismiss.isHidden = false
            if book["action"] == "UPDATE"{
                bookDelete.isHidden = false
                
                bookAction.setTitle("更新資料", for: .normal)
                bookAction.setImage(UIImage(systemName: "pencil"), for: .normal)
                
                if let adddate = book["adddate"]{
                    bookAddDate.text = "加入書櫃日期: "+adddate
                } else {
                    bookAddDate.text = ""
                }
                noteText.text = book["note"]
            } else {
                bookDelete.isHidden = true
                bookAddDate.isHidden = true
                
                bookAction.setTitle("加入書櫃", for: .normal)
                bookAction.setImage(UIImage(systemName: "plus"), for: .normal)
            }
        }
 
        bookISBN.text = book["isbn"]
        bookTitle.text = book["title"]
        bookAuthors.text = book["authors"]
        bookPublisher.text = book["publisher"]
        bookPublishedDate.text = book["publisheddate"]
        bookDescription.text = book["description"]
        if book["provider"] == "books"{
            bookProvider.text = "博客來"
        }else{
            bookProvider.text = book["provider"]
        }
        
        if let cover = book["cover"]{
            bookCover.load(url: URL(string: cover)!, isbn: book["isbn"]!)
        }
        //print(book)
        //收鍵盤
        noteText.delegate = self
    }
    
    //收鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
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
            let thisbook = [
                "provider" : "\(book["provider"]!)",
                "isbn" : "\(book["isbn"]!)",
                "title" : "\(book["title"]!)",
                "cover" : "\(book["cover"]!)",
                "authors" : "\(book["authors"]!)",
                "publisher" : "\(book["publisher"]!)",
                "publisheddate" : "\(book["publisheddate"]!)",
                "bookdescription" : "\(book["description"]!)",
                "note" : noteText.text!,
                "adddate" : "\(adddate)",
            ]
            let insertResult = coreDataConnect.insert(myEntityName, attributeInfo: thisbook)
            
            //print(thisbook)
            if insertResult {
                //跨頁傳送值
                let notificationName = Notification.Name("GetUpdateNotice")
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["action":book["action"]!,"idx":"0","data":thisbook])

                dismiss(animated: true, completion: nil)
                
                print("新增資料成功")
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
 
                //跨頁傳送值
                let notificationName = Notification.Name("GetUpdateNotice")
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["action":book["action"]!,"idx":book["idx"]!,"note":noteText.text!,"isbn":book["isbn"]!])
                
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
                //跨頁傳送值
                let notificationName = Notification.Name("GetUpdateNotice")
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["action":book["action"]!,"idx":book["idx"]!,"isbn":book["isbn"]!])

                if let _ = navigationController{
                    self.navigationController?.popViewController(animated: true)
                } else {
                    dismiss(animated: true, completion: nil)
                }
                
                print("刪除資料成功")
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


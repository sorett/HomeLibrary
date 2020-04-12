//
//  SearchBookViewController.swift
//  HomeLibrary
//
//  Created by 郭明智 on 2020/4/2.
//  Copyright © 2020 郭明智. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class SearchBookViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var searchISBN: UITextField!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //searchISBN.text = "9789579072458"
    }
    
    @IBAction func Search(_ sender: Any) {
        self.view.endEditing(true)
        
        if(searchISBN.text!.isEmpty){
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput
             
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
            } else {
                failed()
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            
            view.layer.addSublayer(previewLayer)
   
            //在navigationItem加入關閉按鈕
            //let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SearchBookViewController.backmainboard))
            let exec = UIBarButtonItem(title: "關閉", style: .plain, target: self, action: #selector(SearchBookViewController.backmainboard))

            self.navigationItem.leftBarButtonItem = exec
            self.navigationController?.isNavigationBarHidden = false

            captureSession.startRunning()
        }else{
            findbook(searchISBN.text!)
        }
    }
    
    @objc func backmainboard(){
        //stop capture
        captureSession.stopRunning()
        
        //remove layer
        previewLayer.removeFromSuperlayer()
        
        //clear navigation title & event
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //hide navigation bar
        self.navigationController?.isNavigationBarHidden = true

        //clear input text
        searchISBN.text = ""
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
 
            found(code: stringValue)

            //dismiss(animated: true)
            //因為是layer而不是viewcontroller所以不能用dismiss
            previewLayer.removeFromSuperlayer()
           
            //hide navigation bar
            self.navigationController?.isNavigationBarHidden = true
        }
    }

    func found(code: String) {
        NSLog(code)
        findbook(code)
        
        //clear navigation title & event
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func findbook(_ isbn: String){
        //clear text
        searchISBN.text = ""

        //api exp:
        //https://www.googleapis.com/books/v1/volumes?q=isbn:9789579072458
        //searchISBN.text = code

        //Connect core data
        let myEntityName = "Booklists"
        let myContext =
             (UIApplication.shared.delegate as! AppDelegate)
                 .persistentContainer.viewContext
        
        let coreDataConnect = CoreDataConnect(context: myContext)

        // select
        let sql = "isbn = \(isbn)"
        //print(book["isbn"]!)
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: sql, sort: [["title":true]], limit: nil)
        if let results = selectResult {
            if(results.count > 0){
                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                
                //建立連線並轉型為 BookViewController
                let bookViewController = mainStoryBoard.instantiateViewController(withIdentifier: "showBookDetail") as! BookViewController
                
                //顯示書本資訊
                var i = 0;
                for result in results {
                    //print(isbn)
                    bookViewController.book["idx"] = String(i)
                    bookViewController.book["provider"] = result.value(forKey: "provider")! as? String
                    bookViewController.book["note"] = result.value(forKey: "note")! as? String
                    bookViewController.book["isbn"] = isbn
                    bookViewController.book["adddate"] = result.value(forKey: "adddate")! as? String
                    if let cover = result.value(forKey: "cover") as? String {
                        bookViewController.book["cover"] = cover
                    }
                    
                    bookViewController.book["title"] = result.value(forKey: "title")! as? String
                    bookViewController.book["authors"] = result.value(forKey: "authors")! as? String
                    bookViewController.book["publisher"] = result.value(forKey: "publisher")! as? String
                    bookViewController.book["publisheddate"] = result.value(forKey: "publisheddate")! as? String
                    bookViewController.book["description"] = result.value(forKey: "bookdescription")! as? String
                    bookViewController.book["action"] = "UPDATE"
                    i += 1
                     
                    self.present(bookViewController, animated:true, completion:nil)
                }
            } else {
                //抓取 JSON 將 Data 變成 String 印出
                print(isbn)
                let urlStr = ("https://api.beta.tw/getBook/?isbn="+isbn).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if let urlStr = urlStr, let url = URL(string: urlStr) {
                    URLSession.shared.dataTask(with: url) { (data, response , error) in
                        
                        
                        //解析json
                        guard let data2 = data else {return}
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(Books.self, from: data2)
                            print(result)
                        } catch  {
                            print(error)
                        }
                        
                        
                        if
                            let data = data,
                            let books = try?JSONDecoder().decode(Books.self, from: data)
                        {
                            if(books.totalItems <= 0){
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "", message: "找不到此本書", preferredStyle: .alert)
                                    
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            } else {
                                let book = books.items[0]
                                
                                //UIViewController must run in main thread so
                                //利用 DispatchQueue.main.async，切換到 main thread 執行即可
                                DispatchQueue.main.async {
                                    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                                    
                                    //建立連線並轉型為 BookViewController
                                    let bookViewController = mainStoryBoard.instantiateViewController(withIdentifier: "showBookDetail") as! BookViewController
                                    
                                    //顯示書本資訊
                                    //                            print(isbn)
                                    bookViewController.book["provider"] = books.provider
                                    bookViewController.book["isbn"] = isbn
                                    bookViewController.book["adddate"] = ""
                                    bookViewController.book["cover"] = book.volumeInfo.imageLinks.thumbnail
                                    
                                    bookViewController.book["title"] = book.volumeInfo.title
                                    bookViewController.book["authors"] = book.volumeInfo.authors.joined(separator: ",")
                                    bookViewController.book["publisher"] = book.volumeInfo.publisher
                                    bookViewController.book["publisheddate"] = book.volumeInfo.publishedDate
                                    bookViewController.book["description"] = book.volumeInfo.bookdescription
                                    
                                    
                                    self.present(bookViewController, animated:true, completion:nil)
                                }
                            }
                            
                        } else {
                            NSLog("Decode failed")
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "", message: "找不到此本書", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }.resume()
                }
            }
        }
    }
     
    override var prefersStatusBarHidden: Bool {
        return true
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

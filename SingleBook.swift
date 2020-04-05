//
//  singleBook.swift
//  HomeLibrary
//
//  Created by 郭明智 on 2020/4/3.
//  Copyright © 2020 郭明智. All rights reserved.
//

import Foundation

struct Books: Codable {
    let items: [Book]
    let totalItems: Int
}

struct Book: Codable {
    let kind, id: String
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]
    let publisher, publishedDate, description: String
    let pageCount: Int
    let printType: String
    let categories: [String]
    let contentVersion: String
    let imageLinks: ImageLinks
}

struct ImageLinks: Codable {
    let thumbnail: String
}

/*
 {
  "kind": "books#volumes",
  "totalItems": 1,
  "items": [
   {
    "kind": "books#volume",
    "id": "rZqiDwAAQBAJ",
    "etag": "xFEroW4qiEg",
    "selfLink": "https://www.googleapis.com/books/v1/volumes/rZqiDwAAQBAJ",
    "volumeInfo": {
     "title": "日本小鎮時光：從尾道出發，繞行日本最愛的山城、海濱、小鎮",
     "authors": [
      "張維中"
     ],
     "publisher": "原點出版／大雁出版基地",
     "publishedDate": "2019-07-10",
     "description": "離不開了，日本！ .....",
     "industryIdentifiers": [
      {
       "type": "ISBN_13",
       "identifier": "9789579072458"
      },
      {
       "type": "ISBN_10",
       "identifier": "9579072450"
      }
     ],
     "readingModes": {
      "text": true,
      "image": true
     },
     "pageCount": 320,
     "printType": "BOOK",
     "categories": [
      "Travel"
     ],
     "maturityRating": "NOT_MATURE",
     "allowAnonLogging": true,
     "contentVersion": "1.2.2.0.preview.3",
     "panelizationSummary": {
      "containsEpubBubbles": false,
      "containsImageBubbles": false
     },
     "imageLinks": {
      "smallThumbnail": "http://books.google.com/books/content?id=rZqiDwAAQBAJ&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api",
      "thumbnail": "http://books.google.com/books/content?id=rZqiDwAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
     },
     "language": "zh-TW",
     "previewLink": "http://books.google.com.tw/books?id=rZqiDwAAQBAJ&printsec=frontcover&dq=isbn:9789579072458&hl=&cd=1&source=gbs_api",
     "infoLink": "https://play.google.com/store/books/details?id=rZqiDwAAQBAJ&source=gbs_api",
     "canonicalVolumeLink": "https://play.google.com/store/books/details?id=rZqiDwAAQBAJ"
    },
    "saleInfo": {
     "country": "TW",
     "saleability": "FOR_SALE",
     "isEbook": true,
     "listPrice": {
      "amount": 331.0,
      "currencyCode": "TWD"
     },
     "retailPrice": {
      "amount": 225.0,
      "currencyCode": "TWD"
     },
     "buyLink": "https://play.google.com/store/books/details?id=rZqiDwAAQBAJ&rdid=book-rZqiDwAAQBAJ&rdot=1&source=gbs_api",
     "offers": [
      {
       "finskyOfferType": 1,
       "listPrice": {
        "amountInMicros": 3.31E8,
        "currencyCode": "TWD"
       },
       "retailPrice": {
        "amountInMicros": 2.25E8,
        "currencyCode": "TWD"
       }
      }
     ]
    },
    "accessInfo": {
     "country": "TW",
     "viewability": "PARTIAL",
     "embeddable": true,
     "publicDomain": false,
     "textToSpeechPermission": "ALLOWED",
     "epub": {
      "isAvailable": true,
      "acsTokenLink": "http://books.google.com.tw/books/download/%E6%97%A5%E6%9C%AC%E5%B0%8F%E9%8E%AE%E6%99%82%E5%85%89_%E5%BE%9E%E5%B0%BE%E9%81%93%E5%87%BA%E7%99%BC_%E7%B9%9E-sample-epub.acsm?id=rZqiDwAAQBAJ&format=epub&output=acs4_fulfillment_token&dl_type=sample&source=gbs_api"
     },
     "pdf": {
      "isAvailable": true,
      "acsTokenLink": "http://books.google.com.tw/books/download/%E6%97%A5%E6%9C%AC%E5%B0%8F%E9%8E%AE%E6%99%82%E5%85%89_%E5%BE%9E%E5%B0%BE%E9%81%93%E5%87%BA%E7%99%BC_%E7%B9%9E-sample-pdf.acsm?id=rZqiDwAAQBAJ&format=pdf&output=acs4_fulfillment_token&dl_type=sample&source=gbs_api"
     },
     "webReaderLink": "http://play.google.com/books/reader?id=rZqiDwAAQBAJ&hl=&printsec=frontcover&source=gbs_api",
     "accessViewStatus": "SAMPLE",
     "quoteSharingAllowed": false
    },
    "searchInfo": {
     "textSnippet": "離不開了，日本！ 張維中帶路，看見日本最深處： 「這本書就是給想要『版本再升級』的日本旅人，而我，提供下載！」 • 去過尾道，這裡就成為你最愛的廣島 • ..."
    }
   }
  ]
 }
 */

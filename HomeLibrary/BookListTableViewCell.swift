//
//  BookListTableViewCell.swift
//  HomeLibrary
//
//  Created by 郭明智 on 2020/4/3.
//  Copyright © 2020 郭明智. All rights reserved.
//

import UIKit

class BookListTableViewCell: UITableViewCell {

    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookTitle: UITextView!
    @IBOutlet weak var bookAuthors: UILabel!
    @IBOutlet weak var bookAddDate: UILabel!
    @IBOutlet weak var bookPublishDate: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

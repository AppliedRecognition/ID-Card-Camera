//
//  ResultViewController.swift
//  TestApp
//
//  Created by Jakub Dolejs on 12/11/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import UIKit

class ResultViewController: UITableViewController {
    
    var documentProperties: [(String,String)] = []
    var documentImage: UIImage?
    var imageAspectRatio: CGFloat?

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount: Int = 0
        if self.documentImage != nil {
            sectionCount += 1
        }
        if !self.documentProperties.isEmpty {
            sectionCount += 1
        }
        return sectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && self.documentImage != nil {
            return 1
        } else {
            return self.documentProperties.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == 0, let image = self.documentImage {
            cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath)
            if let imageCell = cell as? ImageCell {
                imageCell.documentImageView.image = image
                if let constraint = imageCell.documentImageView.constraints.first(where: { $0.identifier == "aspectRatio" }) {
                    imageCell.documentImageView.removeConstraint(constraint)
                }
                if let aspectRatio = self.imageAspectRatio {
                    let constraint = NSLayoutConstraint(item: imageCell.documentImageView as Any, attribute: .width, relatedBy: .equal, toItem: imageCell.documentImageView, attribute: .height, multiplier: aspectRatio, constant: 0)
                    constraint.identifier = "aspectRatio"
                    constraint.priority = .defaultHigh
                    imageCell.documentImageView.addConstraint(constraint)
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "property", for: indexPath)
            if #available(iOS 14, *) {
                var content = cell.defaultContentConfiguration()
                content.text = self.documentProperties[indexPath.row].0
                content.secondaryText = self.documentProperties[indexPath.row].1
                cell.contentConfiguration = content
            } else {
                cell.textLabel?.text = self.documentProperties[indexPath.row].0
                cell.detailTextLabel?.text = self.documentProperties[indexPath.row].1
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && self.documentImage != nil {
            return "Photo page"
        } else {
            return "Barcode"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

}

class ImageCell: UITableViewCell {
    
    @IBOutlet var documentImageView: UIImageView!
}

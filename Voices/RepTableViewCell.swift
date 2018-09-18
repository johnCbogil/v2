//
//  RepTableViewCell.swift
//  Voices
//
//  Created by John Bogil on 9/17/18.
//  Copyright © 2018 John Bogil. All rights reserved.
//

import Foundation
import UIKit

class RepTableViewCell: UITableViewCell {

    let repPhoto: UIImageView = {
        let photo = UIImageView()
        return photo
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let actionView: ActionView = {
        let actionView = ActionView()
        return actionView
    }()

}

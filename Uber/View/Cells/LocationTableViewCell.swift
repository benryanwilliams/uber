//
//  LocationTableViewCell.swift
//  Uber
//
//  Created by Ben Williams on 15/01/2021.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    // MARK:- Properties
    
    static let identifier = "locationTableViewCell"
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "123 Main St"
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let addressLabel: UILabel = {
       let label = UILabel()
        label.text = "123 Main St, Washington, DC"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK:- Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        contentView.addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

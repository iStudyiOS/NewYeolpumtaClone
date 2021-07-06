//
//  HomeTimerCell.swift
//  NewYeolpumtaClone
//
//  Created by 김태균 on 2021/07/04.
//

import UIKit

class HomeTimerCell: UITableViewCell {
    // MARK: - Initializer
        
    var objectList = [ObjectForAdd]()
        
    static let cellIdentifier = String(describing: HomeTimerCell.self)
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.systemPurple
        button.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        return button
    }()
    
    let goalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .darkGray
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .darkGray
        return label
    }()
    
    let deleteButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        bt.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        bt.tintColor = .systemGray
        bt.imageView?.snp.makeConstraints({
            $0.width.height.equalTo(20)
        })
        return bt
    }()

    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupUI() {
        selectionStyle = .none
        
        addSubview(playButton)
        
        playButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        playButton.layer.cornerRadius = 40 / 2
        
        addSubview(goalLabel)
        goalLabel.snp.makeConstraints {
            $0.leading.equalTo(playButton.snp.trailing).offset(12)
            $0.centerY.equalTo(playButton)
            $0.top.bottom.greaterThanOrEqualToSuperview().inset(20)
        }
        
        addSubview(timerLabel)
        timerLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-40)
            $0.centerY.equalTo(playButton)
        }
        
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalTo(playButton)
            $0.width.height.equalTo(20)
        }
    }
    
    // MARK: - Actions
    
    @objc func didTapPlayButton() {
 
    }
    
    @objc func didTapDeleteButton() {

    }
}

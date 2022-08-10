//
//  SongCell.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import UIKit


class SongCell: UITableViewCell {
    
    static let reuseIdentifier = "Song"
    
    let musicImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        return image
    }()
    
    let albulmNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .gray
        return label
        
    }()
    let musicNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
        
    }()
    
    let priceButton = UIButton().priceButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(musicImage)
        addSubview(musicNameLabel)
        addSubview(albulmNameLabel)
        addSubview(priceButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        musicImage.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 70,
                                     height: 70)
        
        albulmNameLabel.frame = CGRect(x: musicImage.frame.size.width + musicImage.frame.origin.x + 10,
                                        y: contentView.frame.midY - 13,
                                        width: contentView.frame.size.width - 50 - musicImage.frame.size.width - priceButton.frame.size.width,
                                       height: 50)
        musicNameLabel.frame = CGRect(x: musicImage.frame.size.width + musicImage.frame.origin.x + 10,
                                      y: 5,
                                      width: contentView.frame.size.width - 50 - musicImage.frame.size.width - priceButton.frame.size.width,
                                     height: 50)
        
        priceButton.frame = CGRect(x: contentView.frame.size.width - 100, y: contentView.frame.midY - 17.5, width: 80, height: 35)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func configure(with model: Music) {

        musicNameLabel.text = model.artistName

    }
}

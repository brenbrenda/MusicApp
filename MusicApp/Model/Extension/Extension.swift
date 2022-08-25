//
//  Extension.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import UIKit

//MARK: UIImageView
let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    
    func loadPreviewUrl(_ urlString: String) {
        
        self.image = nil
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
            })
        }).resume()
    }
}


//MARK: UIButton
extension UIButton {
    
    func nextButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: "forward.fill"), for: .normal)
        return button
    }
    
    func playButton() -> UIButton {
        let button = UIButton()
        button.setImage(AudioHelper.shared.getPlayStatusImage(), for: .normal)
        return button
    }
    
    func priceButton() -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        return button
    }
}


//MARK: Label

extension UILabel {
    func setNormalLabel(textColor: UIColor?, size: CGFloat) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = textColor
        label.font = UIFont.systemFont(ofSize: size)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func setSemiboldLabel(textColor: UIColor?) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = textColor
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

//MARK: UIStackView
extension UIStackView {
    func floatViewStack_settingLayout(view: UIView)  {
        self.distribution = .fill
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: 3),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)])
    }
}




//
//  ContentCell.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 08.04.2024.
//

import UIKit

final class ContentCell: UICollectionViewCell {
    
    static let cellName = "contentCell"
    
    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "Placeholder")
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        
        return imageView
    }()
    private lazy var kindLAbel = CustomLabel()
    private lazy var durationLabel = CustomLabel()
    private lazy var nameLabel = CustomLabel(numberOfLines: 2)
    private lazy var costLabel = CustomLabel()
    
    private var contentService = ContentService.shared
    
    func configureCell(contentItem: ContentModel) {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "CellBorderColor")?.cgColor
        
        if let artworkUrl100 = contentItem.artworkUrl100 {
            contentService.fetchImage(urlString: artworkUrl100) { [weak self] result in
                guard let self = self else {return }
                
                switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self.previewImageView.image = image
                        }
                    case .failure(let error):
                        //TODO: вывод ошибки
                        print(error)
                }
            }
        }
        
        kindLAbel.text = (contentItem.kind == "feature-movie" ? "MOVIE" : contentItem.kind)?.uppercased()
        nameLabel.text = contentItem.trackName
        costLabel.text = "\(contentItem.trackPrice ?? 0)$"
        durationLabel.text = convertMillis(contentItem.trackTimeMillis ?? 0, contentKind: kindLAbel.text)
        
        addSubviews()
        configureConstraints()
    }
}

private extension ContentCell {
    func convertMillis(_ trackTimeMillis: Int, contentKind: String?) -> String {
        var result = ""
        
        let totalSeconds = Double(trackTimeMillis) / 1000
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if contentKind == "MOVIE" {
            result = "\(hours) h. \(minutes) min."
        } else if contentKind == "PODCAST" {
            if hours > 0 {
                result = "\(hours) h. \(minutes) min."
            } else if minutes > 0 {
                result = "\(hours) h. \(minutes) min."
            }
        } else if contentKind == "SONG" {
            result = "\(minutes) min. \(seconds) sec."
        }
        
        return result
    }
    
    func addSubviews() {
        addSubview(previewImageView)
        addSubview(kindLAbel)
        addSubview(durationLabel)
        addSubview(nameLabel)
        addSubview(costLabel)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewImageView.widthAnchor.constraint(equalToConstant: contentView.bounds.width),
            previewImageView.heightAnchor.constraint(equalToConstant: contentView.bounds.width),
            
            kindLAbel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            kindLAbel.widthAnchor.constraint(equalToConstant: 70),
            kindLAbel.topAnchor.constraint(equalTo: previewImageView.bottomAnchor),
            
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            durationLabel.topAnchor.constraint(equalTo: kindLAbel.topAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: kindLAbel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.topAnchor.constraint(equalTo: kindLAbel.bottomAnchor, constant: 4),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width),
            
            costLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            costLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
    }
}

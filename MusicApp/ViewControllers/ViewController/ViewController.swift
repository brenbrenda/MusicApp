//
//  ViewController.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import UIKit
import AsyncDisplayKit


class ViewController: ASDKViewController<ASDisplayNode> {
    
    
    private var hasRes: Bool = false
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "enter music name, albums or "
        return search
    }()
    
    let array = ["musicVideo", "allArtist", "album", "song"]
    
    lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: array)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    var musicData: MusicData?
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(SongCell.self, forCellReuseIdentifier: "reuseIdentifier")
        return table
    }()
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "please enter key word"
        label.isHidden = true
        return label
    }()
    var imageView: UIImageView = {
        let image = UIImageView(image:UIImage(named: "music"))
        image.contentMode = .scaleAspectFit
        return image
    }()
    let currentPlayLabel = UILabel()
    var playButton = UIButton().playButton()
    let nextButton = UIButton().nextButton()
    var indexPath: IndexPath?
    
    
    lazy var floatingPlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        let stackView = UIStackView(arrangedSubviews: [imageView, currentPlayLabel, playButton, nextButton])
        imageView.widthAnchor.constraint(equalToConstant: 55).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentPlayLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 100 - 110 - 30).isActive = true
        stackView.floatViewStack_settingLayout(view: view)
        view.alpha = 0
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitial()
        setupIndex()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        noResultLabel.frame = CGRect(x: 50, y: view.bounds.midY, width: view.frame.width-20, height: 60)
        floatingPlayView.frame = CGRect(x: 0, y: view.bounds.height - 100, width: view.frame.width, height: 100)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    private func setUpInitial() {
        
        //segment
        view.addSubview(segmentControl)
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 50)
        ])
        segmentControl.addTarget(self, action: #selector(segmentValueChange(_ :)), for: .valueChanged)
        
        
        //table
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor), tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor), tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)])
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(noResultLabel)
        
        //search bar setting
//        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissAction))
        navigationController?.navigationBar.topItem?.titleView = searchBar
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        //floatView setting
        view.addSubview(floatingPlayView)
        let singleTouch = UITapGestureRecognizer(target: self, action: #selector(singleTap(recognizer:)))
        floatingPlayView.addGestureRecognizer(singleTouch)
        
        playButton.addTarget(self, action: #selector(playPressByFloatView(sender:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(playNext), for: .touchUpInside)
    }
    
    private func setupIndex() {
        guard let indexPath = self.indexPath, let resultCount = musicData?.resultCount else { return }
        print("indexPath row \(indexPath.row)   result \(resultCount)")
       
        //addedIndexPath.row >= 0超過tableview的indexpath 就不在繼續disabled nextbutton
        if resultCount == indexPath.row {
            print("setting button next diabled")
            nextButton.tintColor = .black
            nextButton.isEnabled = false
        } else if resultCount > indexPath.row {
            nextButton.isEnabled = true
            nextButton.tintColor = .blue
        }
    }
    
    @objc private func dismissAction(){
        dismiss(animated: true)
    }
   
    @objc func singleTap(recognizer: UITapGestureRecognizer) {
        /*if resultCount == addedIndexPath.row {
         print("setting button next diabled")
         nextButton.tintColor = .black
         nextButton.isEnabled = false
     } else if resultCount > addedIndexPath.row {*/
        //TODO: replace with animation and not using present modal
        if let indexPath = self.indexPath, let resultCount = musicData?.resultCount, indexPath.row <= resultCount, let music = musicData?.results[indexPath.row] {
            
            let detailViewModel = DetailViewModel(music: music)
            let vc = PlayAudioViewController(detailViewModel: detailViewModel)
            vc.delegate = self
            vc.modalPresentationStyle = .popover//.pageSheet//.overFullScreen
            present(vc, animated: true)
        }
        
    }
    
    @objc func segmentValueChange(_ sender: UISegmentedControl) {
        
        print("Value segment trigger")
        guard searchBar.text?.isEmpty == false,let text = searchBar.text else { return }
        searchHandler(term: text, entity: array[sender.selectedSegmentIndex])
    }
    
    func UIHandler(empty: Bool?, text: String) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if empty == true {
                self.tableView.isHidden = true
                self.noResultLabel.isHidden = false
                self.noResultLabel.text = "there is no result about \"\(text)\" "
            } else {
                self.tableView.isHidden = false
                self.noResultLabel.isHidden = true
            }
        }
    }
    
    func searchHandler(term: String, entity: String?) {
        LoadingView.addToast(message: "Loading...")
        Network.shared.fetchData(term: term, entity: entity) { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .success(let data):
                self.musicData = data
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    LoadingView.removeToast(message: "end Loading")
                }

                self.UIHandler(empty: data.results.isEmpty, text: term)

            case .failure(let err):
                if err == .noData {
                    DispatchQueue.main.async {
                        self.tableView.isHidden = true
                        LoadingView.removeToast(message: "error")
                        self.noResultLabel.isHidden = false
                        self.noResultLabel.text = "there is no result about \"\(term)\" "
                    }

                } else if err == .offLine {
                    DispatchQueue.main.async {
                        self.tableView.isHidden = true
                        LoadingView.removeToast(message: "error")
                        self.noResultLabel.isHidden = false
                        self.noResultLabel.text = "you seem to disconnect from the server"
                    }
                } else if err == .failedToRequest {
                    DispatchQueue.main.async {
                        self.tableView.isHidden = true
                        LoadingView.removeToast(message: "error")
                        self.noResultLabel.isHidden = false
                        self.noResultLabel.text = "an error has occurred"
                    }
                }
            }
        }
    }
}


extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }//字不可以為空(包含空白)
        
        searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard let text = searchBar.text else { return }
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        guard searchBar.text?.isEmpty == false, let text = searchBar.text else { return }
        print("searchbar trigger")
        let searchEntity = array[segmentControl.selectedSegmentIndex]
        searchHandler(term: text, entity: searchEntity)
    }
}

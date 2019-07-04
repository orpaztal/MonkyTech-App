//
//  ViewController.swift
//  codableApp
//
//  Created by Or paz tal on 02/07/2019.
//  Copyright © 2019 Or paz tal. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var searchData: SearchResultsMetaData?
    
    var searches = [SearchResultsMetaData]() // keep track of all the searches made in the app
    let giphyManager = GiphyManager() //reference to the object that will do the searching
    var itemsPerRow: CGFloat = 3
    var paging: PaginationMetaData?
    var loadMore: Bool = false
    let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewSetup()
        setMusicImage()
        searchBar.delegate = self
    }
    
    func collectionViewSetup() {
        let nib = UINib(nibName: GifCollectionViewCell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: GifCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let imageView : UIImageView = {
            let iv = UIImageView()
            iv.image = #imageLiteral(resourceName: "bananas")
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        collectionView.backgroundView = imageView
    }
    
    func setMusicImage() {
        let img = MusicManager.shared.isMusicPlaying ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play")
        musicButton.setImage(img, for: .normal)
    }
    
    func shouldDisplayIndicator(shouldDisplay: Bool) {
        if shouldDisplay {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
        indicator.isHidden = !shouldDisplay
    }
    
    func showHideNoResultsView(noResults: Bool) {
        DispatchQueue.main.async {
            self.collectionView.isHidden = noResults
            self.noResultsView.isHidden = !noResults
        }
    }
    
    func showAlert(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullImageVCSegue", let vc = segue.destination as? FullImageViewController {
            vc.itemData = searchData?.data[selectedIndex]
        }
    }
    
    @IBAction func displayOptionsButtonTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Gif Search App", message: "Choose number of Images per row", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(cancelActionButton)
        
        let option1 = UIAlertAction(title: "2", style: .default) { _ in
            self.itemsPerRow = 2
            self.collectionView.reloadData()
        }
        actionSheetController.addAction(option1)
        
        let option2 = UIAlertAction(title: "3", style: .default) { _ in
            self.itemsPerRow = 3
            self.collectionView?.reloadData()
        }
        actionSheetController.addAction(option2)
        
        let option3 = UIAlertAction(title: "4", style: .default) { _ in
            self.itemsPerRow = 4
            self.collectionView?.reloadData()
        }
        actionSheetController.addAction(option3)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func musicButtonTapped(_ sender: Any) {
        if MusicManager.shared.isMusicPlaying {
            MusicManager.shared.stopBackgroundMusic()
        } else {
            MusicManager.shared.startBackgroundMusic()
        }
        setMusicImage()
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchData?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCollectionViewCell.identifier, for: indexPath) as? GifCollectionViewCell {
            if let data = searchData?.data[indexPath.row] {
                cell.configureCell(withData: data, indexPath: indexPath)
            }
            return cell
        }
        
        // should not get here
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "fullImageVCSegue", sender: self)
    }
}


extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // there will be n + 1 evenly sized spaces, where n is the number of items in the row
        // the space size can be taken from the left section inset
        // subtracting this from the view's width and dividing by the number of items in a row gives you the width for each item
        let paddingSpace: CGFloat = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / (itemsPerRow + 1)

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    // return the spacing between the cells, headers, and footers. Used a constant for that
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // controls the spacing between each line in the layout. this should be matched the padding at the left and right
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.loadMore {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.paging = nil
        self.loadMore = true
        
        guard let searchText = searchBar.text, searchText.count > 0 else {
            GifDownloadManager.shared.cancelAll()
            //            self.searches.//.removeAll()
            self.collectionView.reloadData()
            self.loadMore = false
            showAlert(title: "Oops", text: "You didn't typed anything\n Please enter a value to search")
            return
        }
        
        self.searchData = nil
        GifDownloadManager.shared.cancelAll()
        self.collectionView.reloadData()
        callSearchApi(searchText: searchText, pageNo: 0)
    }
    
    func callSearchApi (searchText: String, pageNo: Int) {
        giphyManager.giphySearchQuery(query: searchText, page: pageNo) { results, error in
            //stop indicator
            
            //            if let paging = results.pagination, paging.offset == 0 {
            //                ImageDownloadManager.shared.cancelAll()
            //                self.searches.searchResults.removeAll()
            //                self.collectionView?.reloadData()
            //            }
            
            if let error = error {
                print("Error searching: \(error)")
                self.showHideNoResultsView(noResults: true)
                return
            }
            
            if let results = results {
                //                // results get logged and added to the front of the searches array
                ////                print("Found \(results.data.count) matching \(results.searchTerm)")
                //                self.searches.searchResults.append(contentsOf: results.searchResults)
                //                for photo in self.searches.searchResults {
                //                    print("URL: \(photo.flickrImageURL()?.absoluteString ?? "")")
                //                }
                //                self.paging = paging
                //                self.collectionView?.reloadData()
                self.searchData = results
                self.collectionView.reloadData()
            }
            
            else {
               self.showHideNoResultsView(noResults: true)
            }
            self.loadMore = false
        }
    }
}


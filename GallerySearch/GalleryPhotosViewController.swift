//
//  GalleryPhotosViewControllerCollectionViewController.swift
//  GallerySearch
//
//  Created by Pedro Caridade on 06/12/2021.
//

import UIKit

final class GalleryPhotosViewController: UICollectionViewController {
    //MARK: - Properties
    private let reuseIdentifier = "GalleryCell"
    
    private let sectionInsets = UIEdgeInsets(
        top: 50.0,
        left: 20.0,
        bottom: 50.0,
        right: 20.0)
    //Keeps track of all searches made
    private var searches: [GallerySearchResults] = []
    //Reference to the object that searches
    private let gallery = Gallery()
    private let itemsPerRow: CGFloat = 3
}

private extension GalleryPhotosViewController {
    //Gets a specific photo related to an index path in your collection view
    func photo(for indexPath: IndexPath) -> GalleryPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
}

//MARK: - Text Field Delegate

extension GalleryPhotosViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard
            let text = textField.text,
            !text.isEmpty
        else { return true }
        //I use the Gallery wrapper class to search photos that match the given search term
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        gallery.searchGallery(for: text) { searchResults in
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                
                switch searchResults {
                case .failure(let error) :
                    //Log any error to the console
                    print("Error Searching: \(error)")
                case .success(let results):
                    //Log the results and add them at the beginning of searches array
                    print("""
                        Found \(results.searchResults.count) \
                        matching \(results.searchTerm)
                        """)
                    self.searches.insert(results, at: 0)
                    //Refresh to show the new data
                    self.collectionView?.reloadData()
                }
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - UICollectionViewDataSource

extension GalleryPhotosViewController {
    //One search per section, the number of sections is the count of searches
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }
    //The number of items in a section is the count of searchResults
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    //Placeholder method to return GalleryPhotoCell, if i didin't register a cell with reuseIdentifier it will cause a runtime error
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryPhotoCell
        //GalleryPhoto is representing the photo that will display
        let galleryPhoto = photo(for: indexPath)
        cell.backgroundColor = .white
        //Populate the image view with thumbnail
        cell.imageView.image = galleryPhoto.thumbnail
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailsPhotoViewController = self.storyboard?.instantiateViewController(
            withIdentifier: "DetailsPhotoViewControllerID") as! DetailsPhotoViewController
        detailsPhotoViewController.selectedPhoto = photo(for: indexPath)
        
        self.navigationController?.pushViewController(detailsPhotoViewController, animated: true)
//        self.navigationController?.present(detailsPhotoViewController, animated: true)
        
        
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension GalleryPhotosViewController: UICollectionViewDelegateFlowLayout {
    //Size of a given cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Total amount of space taken up by padding
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
      }
      
    //Returns the spacing between the cells, headers and footers
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
      
    //Controling the space between each line in the layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

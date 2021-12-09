//
//  DetailsPhotoViewController.swift
//  GallerySearch
//
//  Created by Pedro Caridade on 07/12/2021.
//

import UIKit

class DetailsPhotoViewController: UIViewController {
    
    @IBOutlet weak var largeImage: UIImageView!
    var selectedPhoto: GalleryPhoto!
    private let gallery = Gallery()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedPhoto.loadLargeImage { result in
            switch result {
            case .success(let galleryPhoto):
                self.largeImage.image = galleryPhoto.largeImage
            case .failure(let error):
                print(error)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

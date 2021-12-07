//
//  Gallery.swift
//  GallerySearch
//
//  Created by Pedro Caridade on 06/12/2021.
//

import UIKit

let apiKey = "b494c955b5c8efa2ef303824f5ceaca9"

class Gallery {
    enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
    }
    
    func searchGallery(for searchTerm: String, completion: @escaping (Result<GallerySearchResults, Swift.Error>) -> Void) {
        guard let searchURL = gallerySearchURL(for: searchTerm) else {
            completion(.failure(Error.unknownAPIResponse))
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: searchURL)) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                (response as? HTTPURLResponse) != nil,
                let data = data
            else {
                completion(.failure(Error.unknownAPIResponse))
                return
            }
            
            do {
                guard
                    let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String
                else {
                    completion(.failure(Error.unknownAPIResponse))
                    return
                }
                
                switch stat {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    completion(.failure(Error.generic))
                    return
                default:
                    completion(.failure(Error.unknownAPIResponse))
                    return
                }
                
                guard
                    let photosContainer = resultsDictionary["photos"] as? [String: AnyObject],
                    let photosReceived = photosContainer["photos"] as? [[String: AnyObject]]
                else {
                    completion(.failure(Error.unknownAPIResponse))
                    return
                }
                
                let galleryPhotos = self.getPhotos(photoData: photosReceived)
                let searchResults = GallerySearchResults(searchTerm: searchTerm, searchResults: galleryPhotos)
                completion(.success(searchResults))
            } catch {
                completion(.failure(error))
                return
            }
        }
        .resume()
    }
    
    private func getPhotos(photoData: [[String: AnyObject]]) -> [GalleryPhoto] {
        let photos: [GalleryPhoto] = photoData.compactMap { photoObject in
            guard
                let photoID = photoObject["id"] as? String,
                let farm = photoObject["farm"] as? Int,
                let server = photoObject["server"] as? String,
                let secret = photoObject["secret"] as? String
            else {
                return nil
            }
            
            let galleryPhoto = GalleryPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
            
            guard
                let url = galleryPhoto.galleryImageURL(),
                let imageData = try? Data(contentsOf: url as URL)
            else {
                return nil
            }
            
            if let image = UIImage(data: imageData) {
                galleryPhoto.thumbnail = image
                return galleryPhoto
            } else {
                return nil
            }
        }
        return photos
    }
    
    private func gallerySearchURL(for searchTerm: String) -> URL? {
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1"
        return URL(string: URLString)
    }
}

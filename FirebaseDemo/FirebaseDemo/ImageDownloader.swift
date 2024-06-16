//
//  ImageDownloader.swift
//  FirebaseDemo
//
//  Created by Jinali Chavda on 11/06/24.
//

import Foundation
import UIKit


final class ImageDownloader {
    
    static var shared = ImageDownloader()
    
    private init() {
        
    }
    
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    func downloadImage(imgstr:String,success:@escaping(UIImage?)->Void) {
        // retrieves image if already available in cache
        if imgstr == "" { success(nil) }
        if let imageFromCache = ImageDownloader.shared.imageCache.object(forKey: imgstr as AnyObject) as? UIImage {
            success(imageFromCache)
        } else {
            let storageRef = Helper.shared.firestorage.reference().child(imgstr)
            storageRef.getData(maxSize: (1024*1024)) { data, error in
                if error == nil {
                    if let image = UIImage(data: data!) {
                        // setup image cache if not already available in cache
                        if let imageData = data {
                            if let unwrappedData = data, let imageToCache = UIImage(data: unwrappedData) {
                                ImageDownloader.shared.imageCache.setObject(imageToCache, forKey: imgstr as AnyObject)
                            }
                            success(UIImage(data: imageData))
                        } else {
                            success(nil)
                        }
                    }
                }
            }
        }
    }
    
}

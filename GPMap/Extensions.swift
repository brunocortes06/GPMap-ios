//
//  Extensions.swift
//  GPMap
//
//  Created by MAC MINI on 28/12/16.
//  Copyright © 2016 Change Logic. All rights reserved.
//

import UIKit

let imgCache = NSCache<AnyObject, AnyObject>()

//Cache para foto de perfil
extension UIImageView {
    
    func loadImgUsingCache(url: URL) {
        
        self.image = nil
        
        if let cachedImg = imgCache.object(forKey: url as AnyObject) as? UIImage{
            self.image = cachedImg
            return
        }
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                let pinImage = UIImage(data: data!)
                let size = CGSize(width: 143, height: 128)
                UIGraphicsBeginImageContext(size)
                let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: size.width, height: size.height))
                pinImage!.draw(in: rect)
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.image = resizedImage
                
                if let downloadedImage = self.image {
                    imgCache.setObject(downloadedImage, forKey: url as AnyObject)
                    self.image = downloadedImage
                }
                
                
                
                
                self.layer.cornerRadius = 20
                self.layer.masksToBounds = true
                
            }
        }
        
    }
}

//Cache para annotations no mapa
extension CustomAnnotation{
    
    func loadImgUsingCache(url: URL) {
        
        self.image = nil
        
        if let cachedImg = imgCache.object(forKey: url as AnyObject) as? UIImage{
            self.image = cachedImg
            return
        }
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        
        //        DispatchQueue.global().async {
        //            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        //            DispatchQueue.main.async {
        //                let pinImage = UIImage(data: data!)
        //                let size = CGSize(width: 143, height: 128)
        //                UIGraphicsBeginImageContext(size)
        //                let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: size.width, height: size.height))
        //                pinImage!.draw(in: rect)
        //                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        //                UIGraphicsEndImageContext()
        //                self.image = resizedImage
        //
        //                if let downloadedImage = self.image {
        //                    imgCache.setObject(downloadedImage, forKey: url as AnyObject)
        //                    self.image = downloadedImage
        //                }
        //            }
        //        }
        //        
    }
    
}

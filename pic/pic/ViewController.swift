//
//  ViewController.swift
//  pic
//
//  Created by Adrian Lim on 25/8/15.
//  Copyright © 2015 Adrian Lim. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBAction func click(sender: AnyObject) {
        let image = imgView.image
        let edge = TestOpenCV.DetectEdgeWithImage(image)
        imgView.image = edge as UIImage
        
    }

    @IBAction func manipulatePixels(sender: AnyObject) {
        var img = convertUIImageToCGImage(imgView.image!)
        let pix = PixelExtractor(img: img)
        let grayImg = pix.getGrayScale()
        imgView.image = grayImg
        /*
        print (pix.width)
        print (pix.height)
        for var j = 0; j < pix.height; ++j {
            for var i = 0; i < pix.width; ++i {
                print (pix.color_at(x: i, y: j))
            }
        }
        */

    }
    
    
    @IBAction func saveImg(sender: AnyObject) {

    }
    
    func convertUIImageToCGImage(inputImage: UIImage) -> CGImage {
        let ciImage = CIImage(image: inputImage)
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage!, fromRect: ciImage!.extent)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//https://github.com/kNeerajPro/ImagePixelFun/blob/master/ImageFun/ImageFun/UIImageExtension.swift
class PixelExtractor {
    // taken from http://stackoverflow.com/questions/24049313/
    // and adapted to swift 1.2
    
    let image: CGImage
    let context: CGContextRef
    
    var width: Int {
        get {
            return CGImageGetWidth(image)
        }
    }
    
    var height: Int {
        get {
            return CGImageGetHeight(image)
        }
    }
    
    typealias RawColorType = (newRedColor:UInt8, newgreenColor:UInt8, newblueColor:UInt8,  newalphaValue:UInt8)
    
    init(img: CGImage) {
        image = img
        context = PixelExtractor.create_bitmap_context(img)
    }
    
    private class func create_bitmap_context(img: CGImage)->CGContextRef {
        
        // Get image width, height
        let pixelsWide = CGImageGetWidth(img)
        let pixelsHigh = CGImageGetHeight(img)
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        let bitmapBytesPerRow = pixelsWide * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(bitmapByteCount)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        // draw the image onto the context
        let rect = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)
        CGContextDrawImage(context, rect, img)
        
        return context!
    }
    
    func color_at(x x: Int, y: Int)->UIColor {
        
        assert(0<=x && x<width)
        assert(0<=y && y<height)
        
        let uncasted_data = CGBitmapContextGetData(context)
        let data = UnsafePointer<UInt8>(uncasted_data)
        
        let offset = 4 * (y * width + x)
        
        let alpha = data[offset]
        let red = data[offset+1]
        let green = data[offset+2]
        let blue = data[offset+3]
        
        let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
        
        return color
    }
    
    func getGrayScale() -> UIImage? {
       let data = CGBitmapContextGetData(context)
        var dataType = UnsafeMutablePointer<UInt8>(data)
        
        for var x = 0; x < Int(width) ; x++ {
            for var y = 0; y < Int(height) ; y++ {
                let offset = 4*((Int(width) * Int(y)) + Int(x))
                let alpha = dataType[offset]
                let red = dataType[offset+1]
                let green = dataType[offset+2]
                let blue = dataType[offset+3]
                
                let avg = (UInt32(red) + UInt32(green) + UInt32(blue))/3
                
                dataType[offset + 1] = UInt8(avg)
                dataType[offset + 2] = UInt8(avg)
                dataType[offset + 3] = UInt8(avg)
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let bitmapBytesPerRow = width * 4
        
        let finalcontext = CGBitmapContextCreate(data, width, height, 8,  bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)
        return UIImage(CGImage: imageRef!)
    }
    
    func setPixelColorAtPoint(point:CGPoint, color: RawColorType) -> UIImage? {
        var data = CGBitmapContextGetData(context)
        var dataType = UnsafeMutablePointer<UInt8>(data)
        let rect = CGRect(x:0, y:0, width:Int(width), height:Int(height))
    
        
        let offset = 4*((Int(width) * Int(point.y)) + Int(point.x))
        dataType[offset]   = color.newalphaValue
        dataType[offset+1] = color.newRedColor
        dataType[offset+2] = color.newgreenColor
        dataType[offset+3] = color.newblueColor
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let bitmapBytesPerRow = Int(width) * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(height)
        
        let finalcontext = CGBitmapContextCreate(data, width, height, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)
        return UIImage(CGImage: imageRef!)
        
    }
}

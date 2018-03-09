//
//  CFExtensions.swift
//  ConvertFox
//
//  Created by Bharath Ravindran on 09/03/18.
//

import UIKit
import AVKit
import MobileCoreServices
import Photos

extension String {
    
    func isEmptyText() -> Bool {
        let trimmedText = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedText.isEmpty ? true : false
    }
    
    /**UTI, MIME & file extension helper methods*/
    func utiString() -> String {
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)
        return (uti?.takeRetainedValue() as String?)!
    }
    
    func fileExtensionToUti() -> String? {
        guard let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self as CFString, nil) else { return nil }
        return contentType.takeRetainedValue() as String
    }
    
    func fileExtensionToMime() -> String? {
        guard let uti = fileExtensionToUti(), let mime = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType) else { return nil }
        return mime.takeRetainedValue() as String
    }
    
    func mimeToUti() -> String? {
        guard let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil) else { return nil }
        return contentType.takeRetainedValue() as String
    }
    
    func utiToFileExtension(_ utiType: String) -> String? {
        guard let ext = UTTypeCopyPreferredTagWithClass(utiType as CFString, kUTTagClassFilenameExtension) else { return nil }
        return ext.takeRetainedValue() as String
    }
    
    func mimeToFileExtension() -> String? {
        guard let uti = mimeToUti() else { return nil }
        return utiToFileExtension(uti)
    }
    
    func utiToMime(_ uti: String) -> String? {
        guard let mime = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType) else { return nil }
        return mime.takeRetainedValue() as String
    }
    
    /**Extracts extenstion from file name*/
    func fileExtension() -> String? {
        let extensionName = (self as NSString).pathExtension
        
        if extensionName.isEmpty {
            return nil
        }
        
        return extensionName
    }
    
    /**Extracts file name without extension*/
    func fileName() -> String? {
        let name = (self as NSString).deletingPathExtension
        
        if name.isEmpty {
            return nil
        }
        
        return name
    }
    
    /**Extracts the substring within limits*/
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
    
}

extension AVPlayer {
    
    var isPlaying: Bool {
        return rate != 0 && error == nil // Find the playing state using rate(The current playback rate) & error for handling error cases also.
    }
    
}

extension Date {
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(String(describing: CFHelper.userPropertiesDate(date: date, format: kUserPropertiesFullDateFormat) ?? ""))" }
        if months(from: date)  > 0 { return "\(String(describing: CFHelper.userPropertiesDate(date: date, format: kUserPropertiesDateFormat) ?? ""))"  }
        if weeks(from: date)   > 0 { return "\(String(describing: CFHelper.userPropertiesDate(date: date, format: kUserPropertiesDateFormat) ?? ""))" }
        if days(from: date)    > 0 { return "\(days(from: date))d ago"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h ago"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m ago" }
        if seconds(from: date) > 0 { return "Just now" }
        return ""
    }
    
}

extension PHAsset {
    
    var originalFilename: String? {
        var fname:String?
        let resources = PHAssetResource.assetResources(for: self)
        
        if let resource = resources.first {
            fname = resource.originalFilename
        }
        
        return fname
    }
    
}

extension UIImage {
    
    /**Returns image by applying the specified color*/
    func createImageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        let rect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        context.draw(self.cgImage!, in: rect)
        context.setBlendMode(CGBlendMode.sourceIn)
        context.addRect(rect)
        context.drawPath(using: CGPathDrawingMode.fill)
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return coloredImage!
    }
    
}

extension Int {
    
    func degreesToRads() -> Double {
        return (Double(self) * .pi / 180)
    }
    
}

extension CGPoint {
    
    func opposite() -> CGPoint {
        // Create New Point
        var oppositePoint = CGPoint()
        // Get Origin Data
        let originXValue = self.x
        let originYValue = self.y
        // Convert Points and Update New Point
        oppositePoint.x = 1.0 - originXValue
        oppositePoint.y = 1.0 - originYValue
        return oppositePoint
    }
    
}

extension UIView {
    
    func applyGradientColor(inAngle: Int, withColors: [CGColor]) {
        
        if withColors.count > 1 { // If multiple colors are there add gradient
            // Create New Gradient Layer
            let gradientBaseLayer: CAGradientLayer = CAGradientLayer()
            // Feed in Our Parameters
            gradientBaseLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            gradientBaseLayer.colors = withColors
            gradientBaseLayer.startPoint = startAndEndPointsFrom(angle: inAngle).startPoint
            gradientBaseLayer.endPoint = startAndEndPointsFrom(angle: inAngle).endPoint
            // Add Our Gradient Layer to the Background
            self.layer.insertSublayer(gradientBaseLayer, at: 0)
        } else if let color = withColors.first { // If only one color is added set as background color
             self.backgroundColor = UIColor(cgColor: color)
        } else { // If no color apply default color
            self.backgroundColor = UIColor.cfAppTheme
        }
        
    }
    
    func startAndEndPointsFrom(angle: Int) -> (startPoint:CGPoint, endPoint:CGPoint) {
        
        // Set default points for angle of 0°
        var startPointX:CGFloat = 0.5
        var startPointY:CGFloat = 1.0
        
        // Define point objects
        var startPoint:CGPoint
        var endPoint:CGPoint
        
        // Define points
        switch true {
        // Define known points
        case angle == 0:
            startPointX = 0.5
            startPointY = 1.0
        case angle == 45:
            startPointX = 0.0
            startPointY = 1.0
        case angle == 90:
            startPointX = 0.0
            startPointY = 0.5
        case angle == 135:
            startPointX = 0.0
            startPointY = 0.0
        case angle == 180:
            startPointX = 0.5
            startPointY = 0.0
        case angle == 225:
            startPointX = 1.0
            startPointY = 0.0
        case angle == 270:
            startPointX = 1.0
            startPointY = 0.5
        case angle == 315:
            startPointX = 1.0
            startPointY = 1.0
        // Define calculated points
        case angle > 315 || angle < 45:
            startPointX = 0.5 - CGFloat(tan(angle.degreesToRads()) * 0.5)
            startPointY = 1.0
        case angle > 45 && angle < 135:
            startPointX = 0.0
            startPointY = 0.5 + CGFloat(tan(90.degreesToRads() - angle.degreesToRads()) * 0.5)
        case angle > 135 && angle < 225:
            startPointX = 0.5 - CGFloat(tan(180.degreesToRads() - angle.degreesToRads()) * 0.5)
            startPointY = 0.0
        case angle > 225 && angle < 359:
            startPointX = 1.0
            startPointY = 0.5 - CGFloat(tan(270.degreesToRads() - angle.degreesToRads()) * 0.5)
        default: break
        }
        // Build return CGPoints
        startPoint = CGPoint(x: startPointX, y: startPointY)
        endPoint = startPoint.opposite()
        // Return CGPoints
        return (startPoint, endPoint)
    }
    
}

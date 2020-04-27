import UIKit

private var animStyle: Int = 7
private var duration: Double = 0.5
private var animateAlways: Bool = false

@objc public class Cask: NSObject {

    @objc public static func animatedTable(_ result: UITableViewCell, hasMovedToWindow : Bool) -> UITableViewCell {
    
        if hasMovedToWindow && !animateAlways {
            return result
        }
        
        switch animStyle {
            case 1:
                DispatchQueue.main.async(execute: {
                    let original = result.alpha
                    result.alpha = 0.0
                    UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.alpha = original
                    })
                })
            case 2:
                DispatchQueue.main.async(execute: {
                    let original = result.layer.transform;
                    result.layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
                    UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.layer.transform = original
                    })
                })
            case 3:
                DispatchQueue.main.async(execute: {
                    let original = result.transform
                    result.transform = CGAffineTransform(scaleX: 0.01, y: 1.0)
                    UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.transform = original
                    })
                })
            case 4:
                DispatchQueue.main.async(execute: {
                    let original = result.backgroundColor
                    let red = CGFloat((arc4random() % 256)) / 255.0
                    let green = CGFloat((arc4random() % 256)) / 255.0
                    let blue = CGFloat((arc4random() % 256)) / 255.0
                    result.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                    UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.backgroundColor = original
                    })
                })
            case 5:
                DispatchQueue.main.async(execute: {
                    let original = result.transform
                    result.transform = CGAffineTransform(scaleX: 0.3, y: 0.5)
                    UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 10.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.transform = original
                    })
                })
            case 6:
                DispatchQueue.main.async(execute: {
                    let original = result.transform
                    result.transform = CGAffineTransform(rotationAngle: 360)
                    UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                    result.transform = original
                    })
                })
            case 7:
                DispatchQueue.main.async(execute: {
                    let original = result.transform
                    result.transform = CGAffineTransform(scaleX: 0.01, y: 1.0)
                    UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.transform = original
                    })
                })
            case 8:
                DispatchQueue.main.async(execute: {
                    let original = result.frame
                    var newFrame = original
                    newFrame.origin.x += original.size.width
                    result.frame = newFrame
                    UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.frame = original
                    })
                })
            default:
                break;
            }

        return result;
    }
    
    @objc public static func loadPrefs() {
        if let prefs = NSDictionary(contentsOfFile:"/User/Library/Preferences/com.ryannair05.caskprefs.plist") {
                animStyle = prefs["style"] as! Int
                duration = prefs["duration"] as! Double
                animateAlways = prefs["animateAlways"] as! Bool
        }
        else {
            let path = "/User/Library/Preferences/com.ryannair05.caskprefs.plist"
            let pathDefault = "/Library/PreferenceBundles/caskprefs.bundle/defaults.plist"
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.copyItem(atPath: pathDefault, toPath: path)
                } catch {
                }
            }
        }
    }
}

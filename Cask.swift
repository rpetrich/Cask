import UIKit

private var animStyle: Int = 11
private var duration: Double = 0.5
private var animateAlways: Bool = false

@objc(Cask) public class Cask: NSObject {

    @objc public static func animatedTable(_ result: UITableViewCell, hasMovedToWindow : Bool) -> UITableViewCell {
    
        if hasMovedToWindow && !animateAlways {
            return result
        }

        if animStyle < 6 {
            switch animStyle {
                case 1: // Fade
                    DispatchQueue.main.async(execute: {
                        let original = result.alpha
                        result.alpha = 0.0
                        UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                            result.alpha = original
                        })
                    })
                case 2: // Flip
                    DispatchQueue.main.async(execute: {
                        let original = result.layer.transform
                        result.layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
                        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                            result.layer.transform = original
                        })
                    })
                case 3: // Bounce
                    DispatchQueue.main.async(execute: {
                        let original = result.transform
                        result.transform = CGAffineTransform(scaleX: 0.01, y: 1.0)
                        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                            result.transform = original
                        })
                    })
                case 4: // Color
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
                case 5: // Permanent Color
                    DispatchQueue.main.async(execute: {
                        let original = result.backgroundColor
                        let red = CGFloat((arc4random() % 256)) / 255.0
                        let green = CGFloat((arc4random() % 256)) / 255.0
                        let blue = CGFloat((arc4random() % 256)) / 255.0
                        result.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                        UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut, .repeat, .autoreverse], animations: {
                            result.backgroundColor = original
                        })
                    })
                default: // None
                    break
            }
        }
        else {
            switch animStyle {
                case 6: // Glitch
                    DispatchQueue.main.async(execute: {
                        let original = result.transform
                        result.transform = CGAffineTransform(scaleX: 0.3, y: 0.5)
                        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 10.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                            result.transform = original
                        })
                    })
                case 7: // Helix
                    DispatchQueue.main.async(execute: {
                        let original = result.layer.transform
                        let layer = result.layer
                        result.layer.transform = CATransform3DIdentity
                        result.layer.transform = CATransform3DTranslate(result.layer.transform, 0.0, layer.bounds.size.height/2.0, 0.0)
                        result.layer.transform = CATransform3DRotate(result.layer.transform, CGFloat(Double.pi), 0.0, 1.0, 0.0)
                        result.layer.transform = CATransform3DTranslate(result.layer.transform, 0.0, -layer.bounds.size.height/2.0, 0.0)
                        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                            result.layer.transform = original
                        })
                    })
                case 8: // Rotate
                    DispatchQueue.main.async(execute: {
                        let original = result.transform
                        result.transform = CGAffineTransform(rotationAngle: 360)
                        UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.transform = original
                        })
                    })
                case 9: // Zoom
                    DispatchQueue.main.async(execute: {
                        let original = result.transform
                        result.transform =  CGAffineTransform(scaleX: 5, y : 5)
                        UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveLinear], animations: {
                            result.transform = original
                        })
                    })
                case 10: // Drop
                    DispatchQueue.main.async(execute: {
                        let original = result.transform
                        result.transform = CGAffineTransform(translationX: 0, y: -150)
                        UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                            result.transform = original
                        })
                    })
                case 11: // Stretch
                    DispatchQueue.main.async(execute: {
                        let original = result.transform
                        result.transform = CGAffineTransform(scaleX: 0.01, y: 1.0)
                        UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                            result.transform = original
                        })
                    })
                default: // Slide
                    DispatchQueue.main.async(execute: {
                        let original = result.frame
                        var newFrame = original
                        newFrame.origin.x += original.size.width
                        result.frame = newFrame
                        UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                            result.frame = original
                        })
                    })
            }
        }
        return result
    }
    
    @objc public static func loadPrefs() {
        if let prefs = NSDictionary(contentsOfFile:"/User/Library/Preferences/com.ryannair05.caskprefs.plist") {
            animStyle = prefs["style"] as? Int ?? 11
            duration = prefs["duration"] as? Double ?? 0.5
            animateAlways = prefs["animateAlways"] as? Bool ?? false

            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                if let appSettings = prefs[bundleIdentifier] as? NSDictionary {
                    animStyle = appSettings["style"] as? Int ?? animStyle
                    duration = appSettings["duration"] as? Double ?? duration
                    animateAlways = appSettings["animateAlways"] as? Bool ?? animateAlways
                }
            }
        }
        else {
            let path = "/User/Library/Preferences/com.ryannair05.caskprefs.plist"
            let pathDefault = "/Library/PreferenceBundles/caskprefs.bundle/defaults.plist"
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.copyItem(atPath: pathDefault, toPath: path)
                } catch {
                    do {
                        try fileManager.removeItem(atPath: path)
                    }
                    catch {
                            var prefs = NSDictionary(contentsOfFile: path) as Dictionary?
                            prefs?.removeAll()
                            (prefs as NSDictionary?)?.write(toFile: path, atomically: true)
                        }
                    }
                loadPrefs()
            }
        }
    }
}

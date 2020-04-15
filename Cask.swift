import UIKit

@objc (Cask) public class Cask : NSObject {
    @objc func animatedTable(_ result: UITableViewCell, style : Int, duration : TimeInterval) -> UITableViewCell {
        switch style {
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
                    result.layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
                    UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.layer.transform = CATransform3DIdentity
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
                    let original = result.transform
                    result.transform = CGAffineTransform(scaleX: 0.3, y: 0.5)
                    UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 10.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.transform = original
                    })
                })
            case 5:
                DispatchQueue.main.async(execute: {
                    result.transform = CGAffineTransform(rotationAngle: 360)
                    UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                    result.transform = CGAffineTransform(rotationAngle: 0.0)
                    })
                })
            case 6:
                DispatchQueue.main.async(execute: {
                    let original = result.transform
                    result.transform = CGAffineTransform(scaleX: 0.01, y: 1.0)
                    UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .allowAnimatedContent, .curveEaseOut], animations: {
                        result.transform = original
                    })
                })
            case 7:
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
}

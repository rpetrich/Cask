class CaskTwitterCell: PSTableCell {
    private var user: String!

    private(set) var avatarView: UIView!
    private(set) var avatarImageView: UIImageView!

    private var _avatarImage: UIImage!
    private var avatarImage: UIImage! {
        get {
            _avatarImage
        }
        set(avatarImage) {
            avatarImageView.image = avatarImage

            if avatarImageView.alpha == 0 {
                UIView.animate(
                    withDuration: 0.15,
                    animations: {
                        self.avatarImageView.alpha = 1
                    })
            }
        }
    }

    convenience required init?(coder aDecoder: NSCoder) { 
        self.init(coder: aDecoder) 
    }

    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String!, specifier: PSSpecifier!) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier!)

        selectionStyle = UITableViewCell.SelectionStyle.blue
        accessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))

        detailTextLabel!.numberOfLines = 1
        detailTextLabel!.textColor = UIColor.gray

        textLabel!.textColor = UIColor.black
        
        if #available(iOS 13, *) {
            tintColor = UIColor.label
        } else {
            tintColor = UIColor.black
        }

        let size: CGFloat = 29.0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, UIScreen.main.scale)
        specifier?.properties["iconImage"] = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        avatarView = UIView(frame: imageView!.bounds)
        avatarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        avatarView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        avatarView.isUserInteractionEnabled = false
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = CGFloat(size / 2)
        avatarView.layer.borderWidth = 2

        if #available(iOS 13, *) {
            avatarView.layer.borderColor = UIColor.tertiaryLabel.cgColor
        } else {
            avatarView.layer.borderColor = UIColor(white: 1, alpha: 0.3).cgColor
        }

        imageView!.addSubview(avatarView)

        avatarImageView = UIImageView(frame: avatarView.bounds)
        avatarImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.avatarImageView.alpha = 0
        avatarImageView.layer.minificationFilter = .trilinear
        avatarView.addSubview(avatarImageView)

        user = (specifier?.properties["accountName"]! as AnyObject).copy() as? String
        assert(user != nil, "User name not provided")

        specifier?.properties["url"] = _url(forUsername: user)

        detailTextLabel!.text = user

        DispatchQueue.global(qos: .default).async(execute: {

            let size = UIScreen.main.scale > 2 ? "original" : "bigger"
            var err: Error? = nil
            var data = Data()
            var reqProcessed = false
            var request: URLRequest? = nil

            if let url = URL(string: "https://mobile.twitter.com/\(self.user!)/profile_image?size=\(size)") {
                request = URLRequest(url: url)
            }

            if let request = request {
                URLSession.shared.dataTask(with: request, completionHandler: { _data, _response, _error in
                    err = _error
                    if let _data = _data {
                        data = _data
                    }
                    reqProcessed = true
                }).resume()
            }

            while !reqProcessed {
                Thread.sleep(forTimeInterval: 0)
            }

            if err != nil {
                return
            }

            DispatchQueue.main.async(execute: {
                self.avatarImage = UIImage(data: data)
            })
         })
    }

    private func _url(forUsername user: String) -> URL {
        if let url = URL(string: "tweetbot://") {
            if UIApplication.shared.canOpenURL(url) {
                return URL(string: "tweetbot:///user_profile/" + (user))!
            } else if let url = URL(string: "twitterrific://") {
                if UIApplication.shared.canOpenURL(url) {
                    return URL(string: "twitterrific:///profile?screen_name=" + (user))!
                } else if let url = URL(string: "tweetings://") {
                    if UIApplication.shared.canOpenURL(url) {
                        return URL(string: "tweetings:///user?screen_name=" + (user))!
                    }
                }
            }
        }
        return URL(string: "https://mobile.twitter.com/" + (user))!
    }

    override func setSelected(_ arg1: Bool, animated arg2: Bool) {
        if arg1 {
            UIApplication.shared.open(_url(forUsername: user), options: [:], completionHandler: nil)
        }
    }
}
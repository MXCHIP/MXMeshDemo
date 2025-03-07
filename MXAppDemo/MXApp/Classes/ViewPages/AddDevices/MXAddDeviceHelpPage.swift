
import Foundation
import SDWebImage


class MXAddDeviceHelpPage: MXBaseViewController {
    var stepList = Array<String>()
    
    public var imageUrl : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"帮助")
        
        self.contentView.addSubview(self.mxScrollView)
        self.mxScrollView.pin.all()
        
        self.mxScrollView.addSubview(self.imageView)
        self.imageView.pin.all()
        if let imgUrl = self.imageUrl {
            self.imageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: imgUrl)) { (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                if let newImage = image {
                    self.imageView.frame = CGRect(x: 0, y: 0, width: self.mxScrollView.frame.size.width, height: newImage.size.height*(self.mxScrollView.frame.size.width/newImage.size.width))
                    self.mxScrollView.contentSize = self.imageView.frame.size
                    self.imageView.image = image
                }
            }
        }
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mxScrollView.pin.all()
    }
    
    lazy var mxScrollView : UIScrollView = {
        let _mxScrollView = UIScrollView()
        _mxScrollView.showsVerticalScrollIndicator = false
        _mxScrollView.showsHorizontalScrollIndicator = false
        _mxScrollView.backgroundColor = .clear
        return _mxScrollView
    }()
    
    lazy var imageView : UIImageView = {
        let _imageView = UIImageView()
        _imageView.backgroundColor = .clear
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()
}

extension MXAddDeviceHelpPage: MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAddDeviceHelpPage()
        controller.imageUrl = params["imageUrl"] as? String
        return controller
    }
}

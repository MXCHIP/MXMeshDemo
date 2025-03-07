
import Foundation
import UIKit

class MXBaseViewController: UIViewController {
    
    lazy public var mxNavigationBar:MXNavigationBar = {
        let bar = MXNavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH))
        return bar
    }()
    
    public var backBtn: UIButton?
    
    public var contentView : UIView = UIView()
    public var hideMXNavigationBar : Bool = false {
        didSet {
            if self.hideMXNavigationBar {
                self.mxNavigationBar.isHidden = true
                self.contentView.pin.all()
            } else {
                self.mxNavigationBar.isHidden = false
                self.contentView.pin.left().top(AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH).right().bottom()
            }
        }
    }
    
    override var title: String? {
        didSet {
            self.mxNavigationBar.titleLB.text = title
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.view.backgroundColor = AppUIConfiguration.NeutralColor.background
        self.navigationController?.navigationBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        self.mxNavigationBar.setupViews()
        self.createNavigationBack()
        
        self.contentView.backgroundColor = UIColor.clear
        self.view.addSubview(self.contentView)
        
        if self.hideMXNavigationBar {
            self.contentView.pin.all()
        } else {
            self.contentView.pin.left().top(AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH).right().bottom()
        }
        
        self.view.addSubview(self.mxNavigationBar)
        self.mxNavigationBar.isHidden = self.hideMXNavigationBar
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
    }
    
    
    deinit {
        print("页面释放了")
    }
    
    override func viewWillLayoutSubviews() {
        if !self.hideMXNavigationBar {
            self.mxNavigationBar.layoutSubviews()
            self.contentView.pin.left().top(AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH).right().bottom()
        } else {
            self.contentView.pin.all()
        }
    }
    
    func createNavigationBack()  {
        let leftBtn = UIButton(type: .custom)
        leftBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        leftBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4)
        leftBtn.titleLabel?.textAlignment = .left
        leftBtn.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .normal)
        leftBtn.setTitle("\u{e6de}", for: .normal)
        leftBtn.addTarget(self, action: #selector(gotoBack), for: .touchUpInside)
        self.mxNavigationBar.leftView.addSubview(leftBtn)
        self.backBtn = leftBtn
        leftBtn.pin.left().top(0).width(44).height(44)
    }
    
    public func hideBackItem() {
        for v in self.mxNavigationBar.leftView.subviews {
            v.removeFromSuperview()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func gotoBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

class MXNavigationBar : UIView {
    
    lazy public var itemView : UIView = {
        let _itemView = UIView(frame: CGRect.zero)
        _itemView.backgroundColor = UIColor.clear
        return _itemView
    }()
    
    lazy public var titleLB : UILabel = {
        let _titleLB = UILabel(frame: CGRect.zero)
        _titleLB.backgroundColor = UIColor.clear
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H2)
        _titleLB.textColor = AppUIConfiguration.NeutralColor.title
        _titleLB.textAlignment = .center
        _titleLB.isUserInteractionEnabled = true
        return _titleLB
    }()
    
    lazy public var leftView : UIView = {
        let _leftView = UIView(frame: CGRect.zero)
        _leftView.backgroundColor = UIColor.clear
        return _leftView
    }()
    
    lazy public var rightView : UIView = {
        let _rightView = UIView(frame: CGRect.zero)
        _rightView.backgroundColor = UIColor.clear
        return _rightView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.itemView)
        self.itemView.pin.left().top(AppUIConfiguration.statusBarH).right().bottom()
        
        self.itemView.addSubview(self.leftView)
        self.leftView.pin.top().bottom().left(10).width(50)
        
        self.itemView.addSubview(self.rightView)
        self.rightView.pin.top().bottom().right(10).width(50)
        
        self.itemView.addSubview(self.titleLB)
        self.titleLB.pin.top().bottom().right(60).left(60)
        
        self.layer.shadowColor = AppUIConfiguration.MXAssistColor.shadow.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.itemView.pin.left().top(AppUIConfiguration.statusBarH).right().bottom()
        var left_x: CGFloat = 0
        for v in self.leftView.subviews {
            v.pin.left(left_x).minWidth(44).maxWidth(80).height(AppUIConfiguration.navBarH).sizeToFit(.height)
            left_x = left_x + v.frame.size.width
        }
        self.leftView.pin.left(10).width(left_x).top().bottom()
        var right_x: CGFloat = 0
        for v in self.rightView.subviews {
            v.pin.right(right_x).minWidth(44).maxWidth(80).height(AppUIConfiguration.navBarH).sizeToFit(.height)
            right_x = right_x + v.frame.size.width
        }
        self.rightView.pin.top().bottom().right(10).width(right_x)
        var  offset_x = max(self.leftView.frame.size.width, self.rightView.frame.size.width) + 10
        if offset_x < 60 {
            offset_x = 60
        }
        self.titleLB.pin.top().bottom().right(offset_x).left(offset_x)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.titleLB.text = nil
        for v in self.titleLB.subviews {
            v.removeFromSuperview()
        }
        for v in self.leftView.subviews {
            v.removeFromSuperview()
        }
        self.leftView.pin.top().bottom().left(10).width(50)
        for v in self.rightView.subviews {
            v.removeFromSuperview()
        }
        self.rightView.pin.top().bottom().right(10).width(50)
        
        self.layoutSubviews()
    }
}

//
//  BXLoadMoreControl.swift
//
//  Created by Haizhen Lee on 15/6/19.
//

import UIKit
import PinAuto

public struct BXLoadMoreSettings{
  public static var pageSize = 20
  public static var pullingString = "上拉显示下\(pageSize)条"
  public static var pulledString = "释放显示下\(pageSize)条"
  public static var loadingString = "正在加载..."
  public static var loadedString = "加载完成"
  public static var loadFailedString = "加载失败"
  public static var nomoreString = "没有更多了"
  public static var triggerPullDistance:CGFloat = 80
}

public enum BXLoadMoreState:Int{
    case preparing
    case pulling
    case pulled
    case loading
    case loaded
    case loadFailed
    case nomore
    
    public var tipLabel:String{
        if self == .pulling || self == .preparing{
            return BXLoadMoreSettings.pullingString
        }else if self == .pulled{
            return BXLoadMoreSettings.pulledString
        }else if self == .loading{
            return BXLoadMoreSettings.loadingString
        }else if self == .loaded{
            return  BXLoadMoreSettings.loadedString
        }else if self == .loadFailed{
            return BXLoadMoreSettings.loadFailedString
        }else if self == .nomore{
          return BXLoadMoreSettings.nomoreString
        }
        return ""
    }
}

open class BXLoadMoreControl: UIControl{

    
    fileprivate var loadMoreState = BXLoadMoreState.preparing
    
    open let titleLabel  = UILabel(frame: CGRect.zero)
    var controlHelper:BXLoadMoreControlHelper? // retain reference to Helper
    open let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
   
    open var onLoadingHandler: ( () -> Void)?
    
    /* The designated initializer
    * This initializes a UIRefreshControl with a default height and width.
    * Once assigned to a UITableViewController, the frame of the control is managed automatically.
    * When a user has pulled-to-refresh, the UIRefreshControl fires its UIControlEventValueChanged event.
    *
    */
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        backgroundColor = UIColor(white: 0.937, alpha: 1.0)
        addSubview(titleLabel)
        addSubview(activityIndicator)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.tintColor = tintColor
        activityIndicator.pa_centerY.install()
        titleLabel.pac_center()
        activityIndicator.pa_before(titleLabel, offset: 8).install()
      
    }
  
  open override func tintColorDidChange() {
    super.tintColorDidChange()
    activityIndicator.tintColor = tintColor
  }


    fileprivate func transitionToState(_ loadMoreState:BXLoadMoreState){
        self.loadMoreState = loadMoreState
        if loadMoreState == .loading{
            activityIndicator.startAnimating()
        }else{
           activityIndicator.stopAnimating()
        }
        titleLabel.text = loadMoreState.tipLabel
    }
    
    open var isPulling: Bool{ return loadMoreState == .pulling }
    open var isPulled: Bool{ return loadMoreState == .pulled }
    open var isPreparing: Bool{ return loadMoreState == .preparing }
    open var isLoading: Bool{ return loadMoreState == .loading }
    open var isNomore: Bool{ return loadMoreState == .nomore }
   
    open func startPull(){
       transitionToState(.pulling)
    }
    
    
    open func pulled(){
        transitionToState(.pulled)
    }
  
  open func nomore(_ shouldShow:Bool = true){
      transitionToState(.nomore)
      if !shouldShow{
        UIView.animate(withDuration: 0.25, animations: {
          self.isHidden = true
        })
      }
    }
  
    open func reset(){
        transitionToState(.preparing)
    }
    
    
    open func canceled(){
        transitionToState(.preparing)
    }
    
    open func startLoad(){
        transitionToState(.loading)
        sendActions(for: UIControlEvents.valueChanged)
        self.onLoadingHandler?()
    }
    
    open func loaded(){
        transitionToState(.loaded)
        self.prepareForNextPull()
    }
   
    fileprivate func prepareForNextPull(){
        delay(2){[weak self] in
            self?.transitionToState(.preparing)
        }
    }
    
    open func loadFailed(){
        transitionToState(.loadFailed)
        self.prepareForNextPull()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func delay(_ delay:TimeInterval, block:@escaping ()->()){
        let when = DispatchTime.now() + Double(Int64(delay * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: when,execute: block)
    }
}

// Behavior lik UIRefreshControl
extension BXLoadMoreControl{

    
    public var loading: Bool {
        return isLoading
    }
  
    
    public var attributedTitle: NSAttributedString?{
        get{
            return titleLabel.attributedText
        }set{
            titleLabel.attributedText = newValue
        }
    }
    
    // May be used to indicate to the refreshControl that an external event has initiated the load action
    public func beginLoading(){
        startLoad()
    }
    // Must be explicitly called when the loading has completed
    public func endLoading(){
        loaded()
    }
}

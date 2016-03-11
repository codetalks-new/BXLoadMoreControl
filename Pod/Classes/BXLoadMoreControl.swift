//
//  BXLoadMoreControl.swift
//
//  Created by Haizhen Lee on 15/6/19.
//

import UIKit
import PinAutoLayout

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
    case Preparing
    case Pulling
    case Pulled
    case Loading
    case Loaded
    case LoadFailed
    case Nomore
    
    public var tipLabel:String{
        if self == .Pulling || self == .Preparing{
            return BXLoadMoreSettings.pullingString
        }else if self == .Pulled{
            return BXLoadMoreSettings.pulledString
        }else if self == .Loading{
            return BXLoadMoreSettings.loadingString
        }else if self == .Loaded{
            return  BXLoadMoreSettings.loadedString
        }else if self == .LoadFailed{
            return BXLoadMoreSettings.loadFailedString
        }else if self == .Nomore{
          return BXLoadMoreSettings.nomoreString
        }
        return ""
    }
}

public class BXLoadMoreControl: UIControl{

    
    private var loadMoreState = BXLoadMoreState.Preparing
    
    public let titleLabel  = UILabel(frame: CGRectZero)
    var controlHelper:BXLoadMoreControlHelper? // retain reference to Helper
    public let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
   
    public var onLoadingHandler: ( () -> Void)?
    
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
        titleLabel.font = UIFont.systemFontOfSize(17)
        titleLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.tintColor = tintColor
        activityIndicator.pinCenterY()
        titleLabel.pinCenterY()
        titleLabel.pinCenterX()
        activityIndicator.pinTrailingToSibing(titleLabel, margin: 8)
      
    }
  
  public override func tintColorDidChange() {
    super.tintColorDidChange()
    activityIndicator.tintColor = tintColor
  }


    private func transitionToState(loadMoreState:BXLoadMoreState){
        self.loadMoreState = loadMoreState
        if loadMoreState == .Loading{
            activityIndicator.startAnimating()
        }else{
           activityIndicator.stopAnimating()
        }
        titleLabel.text = loadMoreState.tipLabel
    }
    
    public var isPulling: Bool{ return loadMoreState == .Pulling }
    public var isPulled: Bool{ return loadMoreState == .Pulled }
    public var isPreparing: Bool{ return loadMoreState == .Preparing }
    public var isLoading: Bool{ return loadMoreState == .Loading }
    public var isNomore: Bool{ return loadMoreState == .Nomore }
   
    public func startPull(){
       transitionToState(.Pulling)
    }
    
    
    public func pulled(){
        transitionToState(.Pulled)
    }
  
  public func nomore(shouldShow:Bool = true){
      transitionToState(.Nomore)
      if !shouldShow{
        UIView.animateWithDuration(0.25){
          self.hidden = true
        }
      }
    }
  
    public func reset(){
        transitionToState(.Preparing)
    }
    
    
    public func canceled(){
        transitionToState(.Preparing)
    }
    
    public func startLoad(){
        transitionToState(.Loading)
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
        self.onLoadingHandler?()
    }
    
    public func loaded(){
        transitionToState(.Loaded)
        self.prepareForNextPull()
    }
   
    private func prepareForNextPull(){
        delay(2){[weak self] in
            self?.transitionToState(.Preparing)
        }
    }
    
    public func loadFailed(){
        transitionToState(.LoadFailed)
        self.prepareForNextPull()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func delay(delay:NSTimeInterval, block:dispatch_block_t){
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(when,dispatch_get_main_queue(),block)
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

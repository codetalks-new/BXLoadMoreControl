//
//  BXLoadMoreControl.swift
//
//  Created by Haizhen Lee on 15/6/19.
//

import UIKit
import PinAutoLayout

public enum BXLoadMoreState:Int{
    case Preparing
    case Pulling
    case Pulled
    case Loading
    case Loaded
    case LoadFailed
    
    public var tipLabel:String{
        if self == .Pulling || self == .Preparing{
            return "上拉显示下20条"
        }else if self == .Pulled{
            return "释放显示下20条"
        }else if self == .Loading{
            return "正在加载..."
        }else if self == .Loaded{
            return "加载完成"
        }else if self == .LoadFailed{
            return "加载失败"
        }
        return ""
    }
}

public class BXLoadMoreControl: UIControl{

    
    private var loadMoreState = BXLoadMoreState.Preparing
    
    public let titleLabel  = UILabel(frame: CGRectZero)
    var controlHelper:BXLoadMoreControlHelper? // retain reference to Helper
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
   
    public var onLoadingHandler: ( () -> Void)?
    
    /* The designated initializer
    * This initializes a UIRefreshControl with a default height and width.
    * Once assigned to a UITableViewController, the frame of the control is managed automatically.
    * When a user has pulled-to-refresh, the UIRefreshControl fires its UIControlEventValueChanged event.
    *
    */
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        backgroundColor = UIColor.lightGrayColor()
        addSubview(titleLabel)
        addSubview(activityIndicator)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor(white: 0.3, alpha: 1.0)
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.textColor = UIColor.darkGrayColor()
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.pinCenterY()
        activityIndicator.pinLeading(15)
        titleLabel.pinCenterY()
        titleLabel.pinLeadingToSibling(activityIndicator, margin: 8)
        
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
   
    public func startPull(){
       transitionToState(.Pulling)
    }
    
    
    public func pulled(){
        transitionToState(.Pulled)
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
    
    public override var tintColor: UIColor!{
        get{
            return activityIndicator.tintColor
        }set{
            activityIndicator.tintColor = newValue
        }
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

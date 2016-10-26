//
//  BXLoadMoreControl.swift
//
//  Created by Haizhen Lee on 15/6/19.
//

import UIKit

extension UIScrollView{
    
    var minPulledDistance: CGFloat{
        return BXLoadMoreSettings.triggerPullDistance
    }
    
    var overflowY:CGFloat{
         // 在 初始时会有 ，所以需要加以判断后再处理
//        (lldb) e scrollView.contentSize
//        (CGSize) $R0 = (width = 600, height = 0)
//        (lldb) e scrollView.frame
//        (CGRect) $R1 = (origin = (x = 0, y = 0), size = (width = 320, height = 568))
//        (lldb) e scrollView.contentOffset
//        (CGPoint) $R2 = (x = 0, y = 0)
        if contentSize.height > 0 && contentOffset.y > 0 {
            return contentOffset.y + frame.height - contentSize.height
        }else{
            return 0
        }
    }
    
    var isPullingUp: Bool{
        return overflowY > 1
    }
    
    var isPulledUp: Bool{
        return overflowY > minPulledDistance
    }
}

class BXLoadMoreControlHelper:NSObject{
    weak var control:BXLoadMoreControl?
    weak var scrollView:UIScrollView?
    


    
    init(control:BXLoadMoreControl,scrollView:UIScrollView){
        self.control = control
        self.scrollView = scrollView
        super.init()
        control.controlHelper = self
        scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .initial, context: &KVOContext)
    }
   
    // MARK: KVO
    fileprivate var KVOContext = "bx_kvo_context"
    fileprivate let contentOffsetKeyPath = "contentOffset"
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == contentOffsetKeyPath && (object as? UIScrollView == scrollView)){
            guard let scrollView = scrollView else{
                return
            }
            if scrollView.isDragging{
                scrollViewDidScroll(scrollView)
            }else{
                if scrollView.isPullingUp{
                  #if DEBUG
                    NSLog("overflowY = \(scrollView.overflowY)")
                  #endif
                    scrollViewDidEndDragging(scrollView, willDecelerate: scrollView.isDecelerating)
                }
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
    }
    
    deinit{
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
    }
    
    //MARK: Hook UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let overflowY = scrollView.frame.height + contentOffset.y - scrollView.contentSize.height
        #if DEBUG
        NSLog("\(#function) contentoffset=\(contentOffset) overflowY=\(overflowY)")
        #endif
        guard let bx_control = control else{
            return
        }
        if bx_control.isNomore{
          return
        }
      
        if bx_control.isLoading{
        #if DEBUG
            NSLog("isLoading return")
            return
        #endif
        }
        if scrollView.isPulledUp && !bx_control.isPreparing {
            if !bx_control.isPulled{
                bx_control.pulled()
                NSLog("startPull")
            }
            // overflowY 有两次达到此状态,一些上上拉,一次是加弹,所以需要判断一下
        }else if scrollView.isPullingUp{
            if !bx_control.isPulling{
                NSLog("startPull")
                bx_control.startPull()
            }
        }
    }
    
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      #if DEBUG
        NSLog("\(#function) willDecelerate?=\(decelerate)")
      #endif
        guard let bx_control = control else{
            return
        }
      
        if bx_control.isNomore{
          return
        }
      
        if !bx_control.isLoading{
            if scrollView.isPulledUp{
                NSLog("\(#function) beginLoading")
                bx_control.beginLoading()
            }else{
                bx_control.canceled()
            }
        }
    }
}

public extension UITableViewController{
    fileprivate struct AssociatedKeys{
        static let LoadMoreControlKey = "bx_LoadMoreControlKey"
    }
    
    public var bx_loadMoreControl:BXLoadMoreControl?{
        get{
            if let bx_control = objc_getAssociatedObject(self, AssociatedKeys.LoadMoreControlKey) as? BXLoadMoreControl{
               return bx_control
            }else{
                return nil
            }
        }set{
            if let bx_control = newValue{
                objc_setAssociatedObject(self, AssociatedKeys.LoadMoreControlKey, bx_control, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                // helper is retained by bx_control
                let _ = BXLoadMoreControlHelper(control: bx_control, scrollView: tableView)
            }else{
                objc_setAssociatedObject(self, AssociatedKeys.LoadMoreControlKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            }
            tableView.tableFooterView = newValue
        }
    }
    

    
}


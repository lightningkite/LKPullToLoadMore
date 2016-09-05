//
//  LKPullToLoadMore.swift
//  LKPullToLoadMore
//
//  Created by Erik Sargent on 5/4/15.
//  Copyright (c) 2015 Lightning Kite. All rights reserved.
//

import UIKit

public protocol LKPullToLoadMoreDelegate {
    /**
    Called when the control has triggered the load more action
    */
    func loadMore()
}

public class LKPullToLoadMore: NSObject {
    lazy var loadMoreView = UIView()
    lazy var loadMoreIndicator = UIImageView()
    lazy var loadMoreText = UILabel()
    lazy var image = UIImage()

    var loadingMore = false
    var pulledUp = false
    var enabled = false

    var height: CGFloat = 40.0

    var topPadding: CGFloat = 10.0

    var backgroundColor = UIColor.whiteColor()
    
    var pullUpText = "Pull up to load more results" {
        didSet {
            if !pulledUp {
                loadMoreText.text = pullUpText
            }
        }
    }
    var pullDownText = "Release to load more results" {
        didSet {
            if pulledUp {
                loadMoreText.text = pullDownText
            }
        }
    }

    var scrollView: UIScrollView!

    /**
    Delegate method
    */
    public var delegate: LKPullToLoadMoreDelegate?
    
    private static var context = 0

    
    /**
    Initialize the control
    
    - parameter imageHeight:  Height of the image that will be passed in
    - parameter viewWidth:  Width of the view the scroll view is shown in (no longer needed, and thus ignored)
    - parameter scrollView:  scrollView for the control
    */
    public init(imageHeight: CGFloat, viewWidth: CGFloat, scrollView: UIScrollView) {
        super.init()
        height = imageHeight
		
        loadMoreText.text = pullUpText
        loadMoreText.font = UIFont.systemFontOfSize(14)
        loadMoreText.textColor = UIColor.blackColor()

        loadMoreView.addSubview(loadMoreIndicator)
        loadMoreView.addSubview(loadMoreText)

        loadMoreView.hidden = true

        self.scrollView = scrollView
		
		setFrames()

        scrollView.addSubview(loadMoreView)
        scrollView.addObserver(self, forKeyPath: "contentSize", options: .New, context: &LKPullToLoadMore.context)
    }

    //MARK: - Accessors
    /**
    Set the image to use for the animation and progress wedge
    */
    public func setIndicatorImage(image: UIImage) {
        self.image = image
    }
    
    /**
    Set the font for the text
    By default, uses System size 14
    */
    public func setFont(font: UIFont) {
        loadMoreText.font = font
    }

    
    /**
    Set the text color for the control
    */
    public func setTextColor(color: UIColor) {
        loadMoreText.textColor = color
    }

    
    /**
    Set whether the control should be animating or not
    */
    public func loading(loading: Bool) {
        loadingMore = loading
        animateLoadingIndicator()
    }

    
    /**
    Enable or disable the load more control
    disabeling will hide it in the scroll view
    */
    public func enable(enable: Bool) {
        enabled = enable
    }


    //MARK: - Scrolling
    /**
    Forward the delegate method from the scroll view
    */
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !loadingMore && enabled {
            var angle = ((scrollView.contentOffset.y + scrollView.frame.height) - scrollView.contentSize.height - 15) / (height + 10) * 360

            if angle > 360 {
                angle = 360
                loadMoreText.text = pullDownText
                pulledUp = true
            }
            else {
                loadMoreText.text = pullUpText
                pulledUp = false
            }

            if angle < 1 {
                angle = 1
            }

            loadMoreIndicator.image = drawReloadIndicator(wedgeAngle: angle)

            if scrollView.contentInset.bottom != 0 {
                scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 0, scrollView.contentInset.right)
            }
        }
    }

    /**
    Forward the delegate method from the scroll view
    */
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let offset = (scrollView.contentOffset.y + scrollView.frame.height) - scrollView.contentSize.height - 15
		if !loadingMore && enabled && (offset > height + 10) {
            delegate?.loadMore()

            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height + height + topPadding * 2)

            let offset = (height + topPadding * 2) + 5
            let newOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.height + offset)
            targetContentOffset.initialize(newOffset)
        }
    }


    //MARK: - LoadMore
    func loadMore() {
        if !loadingMore {
            loadingMore = true

            loadMoreIndicator.image = image

            animateLoadingIndicator()

            delegate?.loadMore()
        }
    }


    //MARK: - Drawing Methods
	/**
	Set the frames of the loadMoreView, loadMoreIndicator, and loadMoreText to the current positions
	*/
	func setFrames() {
		let width = scrollView.frame.width
		loadMoreView.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: width, height: height + topPadding * 2)
		loadMoreIndicator.frame = CGRect(x: width / 2 - 100, y: topPadding, width: height, height: height)
		loadMoreText.frame = CGRect(x: width / 2 - 50, y: topPadding, width: 200, height: height)
	}
	
	/**
    Resets the vertical position
    Call this method after any change in scroll view height
    */
    func resetPosition() {
        if scrollView.contentSize.height > scrollView.frame.height && enabled {
            loadMoreView.hidden = false
			setFrames()
		}
        else {
            loadMoreView.hidden = true
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        resetPosition()
    }

    func animateLoadingIndicator() {
        if loadingMore {
            UIView.animateWithDuration(
                0.4,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveLinear,
                animations: {
                    self.loadMoreIndicator.transform = CGAffineTransformRotate(self.loadMoreIndicator.transform, CGFloat(-M_PI_2))
                },
                completion: { finished in
                    self.animateLoadingIndicator()
                }
            )
        }
        else {
            self.loadMoreIndicator.transform = CGAffineTransformIdentity
        }
    }


    /**
    Reload indicator image
    */
    func drawReloadIndicator(wedgeAngle wedgeAngle: CGFloat) -> UIImage {
        let size = CGSize(width: height, height: height)

        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)

        let context = UIGraphicsGetCurrentContext()

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRectMake(0, 0, height, height), cornerRadius: height / 2)
        CGContextSaveGState(context)
        rectanglePath.addClip()
        CGContextScaleCTM(context, 1, -1)
        CGContextDrawTiledImage(context, CGRectMake(0, 0, height, height), image.CGImage)
        CGContextRestoreGState(context)


        //// Oval Drawing
        let ovalRect = CGRectMake(0, 0, height, height)
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPointMake(ovalRect.midX, ovalRect.midY), radius: ovalRect.width / 2, startAngle: 0 * CGFloat(M_PI)/180, endAngle: -wedgeAngle * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLineToPoint(CGPointMake(ovalRect.midX, ovalRect.midY))
        ovalPath.closePath()

        backgroundColor.setFill()
        ovalPath.fill()

        // Drawing complete, retrieve the finished image and cleanup
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

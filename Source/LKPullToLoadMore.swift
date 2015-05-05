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

public class LKPullToLoadMore {
    lazy var loadMoreView = UIView()
    lazy var loadMoreIndicator = UIImageView()
    lazy var loadMoreText = UILabel()
    lazy var image = UIImage()

    var loadingMore = false
    var pulledUp = false
    var enabled = false

    var height: CGFloat = 40.0
    var width: CGFloat = 320.0

    var topPadding: CGFloat = 10.0

    var pullUpText = "Pull up to load more results"
    var pullDownText = "Release to load more results"

    var tableView: UITableView!

    /**
    Delegate method
    */
    public var delegate: LKPullToLoadMoreDelegate?

    
    /**
    Initialize the control
    
    :param: imageHeight  Height of the image that will be passed in
    :param: viewWidth  Width of the view the table is shown in
    :param: tableView  tableView for the control
    */
    public init(imageHeight: CGFloat, viewWidth: CGFloat, tableView: UITableView) {
        height = imageHeight
        width = viewWidth

        loadMoreView.frame = CGRect(x: 0, y: 0, width: width, height: height + topPadding * 2)
        loadMoreIndicator.frame = CGRect(x: width / 2 - 100, y: topPadding, width: height, height: height)
        loadMoreText.frame = CGRect(x: width / 2 - 50, y: topPadding, width: 200, height: height)

        loadMoreText.text = pullUpText
        loadMoreText.font = UIFont.systemFontOfSize(14)
        loadMoreText.textColor = UIColor.blackColor()

        loadMoreView.addSubview(loadMoreIndicator)
        loadMoreView.addSubview(loadMoreText)

        loadMoreView.hidden = true

        self.tableView = tableView

        tableView.addSubview(loadMoreView)
    }


    //MARK: - Accessors
    /**
    Set the image to use for the animation and progress wedge
    */
    public func setIndicatorImage(image: UIImage) {
        self.image = image
    }

    
    /**
    Set the text for when the control is being pulled down
    */
    public func setPullUpText(text: String) {
        pullUpText = text

        if !pulledUp {
            loadMoreText.text = pullUpText
        }
    }

    
    /**
    Set the text for when the control is pulled out all the way, and ready to be released
    */
    public func setPullDownText(text: String) {
        pullDownText = text

        if pulledUp {
            loadMoreText.text = pullDownText
        }
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
    disabeling will hide it in the table view
    */
    public func enable(enable: Bool) {
        enabled = enable
    }


    //MARK: - Scrolling
    /**
    Forward the delegate method from the table view
    */
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !loadingMore && enabled {
            var angle = ((scrollView.contentOffset.y + tableView.frame.height) - scrollView.contentSize.height - 15) / (height + 10) * 360

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

            if tableView.contentInset.bottom != 0 {
                tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top, tableView.contentInset.left, 0, tableView.contentInset.right)
            }
        }
    }

    /**
    Forward the delegate method from the table view
    */
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !loadingMore && enabled && ((scrollView.contentOffset.y + tableView.frame.height) - scrollView.contentSize.height - 15) > (height + 10) {
            delegate?.loadMore()

            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height + height + topPadding * 2)

            let offset = (height + topPadding * 2) + 5
            let newOffset = CGPoint(x: 0, y: scrollView.contentSize.height - tableView.frame.height + offset)
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
    Resets the vertical position
    Call this method after any change in table view height
    */
    public func resetPosition() {
        if tableView.contentSize.height > tableView.frame.height && enabled {
            loadMoreView.hidden = false
            loadMoreView.frame = CGRect(x: 0, y: tableView.contentSize.height, width: self.width, height: self.height + self.topPadding * 2)
        }
        else {
            loadMoreView.hidden = true
        }
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
    func drawReloadIndicator(#wedgeAngle: CGFloat) -> UIImage {
        let size = CGSize(width: height, height: height)
        let bounds = CGRect(origin: CGPoint.zeroPoint, size: size)

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
        var ovalRect = CGRectMake(0, 0, height, height)
        var ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPointMake(ovalRect.midX, ovalRect.midY), radius: ovalRect.width / 2, startAngle: 0 * CGFloat(M_PI)/180, endAngle: -wedgeAngle * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLineToPoint(CGPointMake(ovalRect.midX, ovalRect.midY))
        ovalPath.closePath()

        UIColor.whiteColor().setFill()
        ovalPath.fill()

        // Drawing complete, retrieve the finished image and cleanup
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

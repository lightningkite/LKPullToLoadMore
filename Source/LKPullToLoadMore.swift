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

open class LKPullToLoadMore {
    lazy var loadMoreView = UIView()
    lazy var loadMoreIndicator = UIImageView()
    lazy var loadMoreText = UILabel()
    lazy var image = UIImage()

    var loadingMore = false
    var pulledUp = false
    var enabled = false

    var height: CGFloat = 40.0

    var topPadding: CGFloat = 10.0

    var backgroundColor = UIColor.white
    
    var pullUpText = "Pull up to load more results"
    var pullDownText = "Release to load more results"

    var tableView: UITableView!

    /**
    Delegate method
    */
    open var delegate: LKPullToLoadMoreDelegate?

    
    /**
    Initialize the control
    
    - parameter imageHeight:  Height of the image that will be passed in
    - parameter viewWidth:  Width of the view the table is shown in (no longer needed, and thus ignored)
    - parameter tableView:  tableView for the control
    */
    public init(imageHeight: CGFloat, viewWidth: CGFloat, tableView: UITableView) {
        height = imageHeight
		
        loadMoreText.text = pullUpText
        loadMoreText.font = UIFont.systemFont(ofSize: 14)
        loadMoreText.textColor = UIColor.black

        loadMoreView.addSubview(loadMoreIndicator)
        loadMoreView.addSubview(loadMoreText)

        loadMoreView.isHidden = true

        self.tableView = tableView
		
		setFrames()

        tableView.addSubview(loadMoreView)
    }

    //MARK: - Accessors
    /**
    Set the image to use for the animation and progress wedge
    */
    open func setIndicatorImage(_ image: UIImage) {
        self.image = image
    }

    
    /**
    Set the text for when the control is being pulled down
    */
    open func setPullUpText(_ text: String) {
        pullUpText = text

        if !pulledUp {
            loadMoreText.text = pullUpText
        }
    }

    
    /**
    Set the text for when the control is pulled out all the way, and ready to be released
    */
    open func setPullDownText(_ text: String) {
        pullDownText = text

        if pulledUp {
            loadMoreText.text = pullDownText
        }
    }

    
    /**
    Set the font for the text
    By default, uses System size 14
    */
    open func setFont(_ font: UIFont) {
        loadMoreText.font = font
    }

    
    /**
    Set the text color for the control
    */
    open func setTextColor(_ color: UIColor) {
        loadMoreText.textColor = color
    }

    
    /**
    Set whether the control should be animating or not
    */
    open func loading(_ loading: Bool) {
        loadingMore = loading
        animateLoadingIndicator()
    }

    
    /**
    Enable or disable the load more control
    disabeling will hide it in the table view
    */
    open func enable(_ enable: Bool) {
        enabled = enable
    }


    //MARK: - Scrolling
    /**
    Forward the delegate method from the table view
    */
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let offset = (scrollView.contentOffset.y + tableView.frame.height) - scrollView.contentSize.height - 15
		if !loadingMore && enabled && (offset > height + 10) {
            delegate?.loadMore()

            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height + height + topPadding * 2)

            let offset = (height + topPadding * 2) + 5
            let newOffset = CGPoint(x: 0, y: scrollView.contentSize.height - tableView.frame.height + offset)
            targetContentOffset.initialize(to: newOffset)
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
		let width = tableView.frame.width
		loadMoreView.frame = CGRect(x: 0, y: tableView.contentSize.height, width: width, height: height + topPadding * 2)
		loadMoreIndicator.frame = CGRect(x: width / 2 - 100, y: topPadding, width: height, height: height)
		loadMoreText.frame = CGRect(x: width / 2 - 50, y: topPadding, width: 200, height: height)
	}
	
	/**
    Resets the vertical position
    Call this method after any change in table view height
    */
    open func resetPosition() {
        if tableView.contentSize.height > tableView.frame.height && enabled {
            loadMoreView.isHidden = false
			setFrames()
		}
        else {
            loadMoreView.isHidden = true
        }
    }

    func animateLoadingIndicator() {
        if loadingMore {
            UIView.animate(
                withDuration: 0.4,
                delay: 0.0,
                options: UIViewAnimationOptions.curveLinear,
                animations: {
                    self.loadMoreIndicator.transform = self.loadMoreIndicator.transform.rotated(by: CGFloat(-M_PI_2))
                },
                completion: { finished in
                    self.animateLoadingIndicator()
                }
            )
        }
        else {
            self.loadMoreIndicator.transform = CGAffineTransform.identity
        }
    }


    /**
    Reload indicator image
    */
    func drawReloadIndicator(wedgeAngle: CGFloat) -> UIImage {
        let size = CGSize(width: height, height: height)

        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)

        let context = UIGraphicsGetCurrentContext()

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: height, height: height), cornerRadius: height / 2)
        context?.saveGState()
        rectanglePath.addClip()
        context?.scaleBy(x: 1, y: -1)
        if let cgImage = image.cgImage {
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: height), byTiling: true)
        }
        context?.restoreGState()
        

        //// Oval Drawing
        let ovalRect = CGRect(x: 0, y: 0, width: height, height: height)
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: 0 * CGFloat(M_PI)/180, endAngle: -wedgeAngle * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLine(to: CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.close()

        backgroundColor.setFill()
        ovalPath.fill()

        // Drawing complete, retrieve the finished image and cleanup
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

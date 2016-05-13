//
//  MasterViewController.swift
//  Example
//
//  Created by Erik Sargent on 5/4/15.
//  Copyright (c) 2015 Lightning Kite. All rights reserved.
//

import UIKit
import LKPullToLoadMore

class MasterViewController: UITableViewController, LKPullToLoadMoreDelegate {
    //MARK: - Properties
    var numCells = 20

    var loadMoreControl: LKPullToLoadMore!


    //MARK: - View Lifecycle
    override func viewDidLoad() {
        tableView.reloadData()
        
        loadMoreControl = LKPullToLoadMore(imageHeight: 40, tableView: tableView)
        loadMoreControl.setIndicatorImage(UIImage(named: "LoadingImage")!)
        loadMoreControl.enable(true)
        loadMoreControl.delegate = self
        loadMoreControl.resetPosition()
    }


    //MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numCells
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row + 1)"
        return cell
    }


    //MARK: Load More Control
    func loadMore() {
        loadMoreControl.loading(true)

        numCells += 20

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.loadMoreControl.loading(false)
            self.loadMoreControl.resetPosition()
        }
    }


    //MARK: - Scroll View
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        loadMoreControl.scrollViewDidScroll(scrollView)
    }

    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        loadMoreControl.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}


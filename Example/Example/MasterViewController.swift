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
        
        loadMoreControl = LKPullToLoadMore(imageHeight: 40, viewWidth: tableView.frame.width, tableView: tableView)
        loadMoreControl.setIndicatorImage(UIImage(named: "LoadingImage")!)
        loadMoreControl.enable(true)
        loadMoreControl.delegate = self
        loadMoreControl.resetPosition()
    }


    //MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numCells
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row + 1)"
        return cell
    }


    //MARK: Load More Control
    func loadMore() {
        loadMoreControl.loading(true)

        numCells += 20

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.tableView.reloadData()
            self.loadMoreControl.loading(false)
            self.loadMoreControl.resetPosition()
        }
    }


    //MARK: - Scroll View
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreControl.scrollViewDidScroll(scrollView)
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        loadMoreControl.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}


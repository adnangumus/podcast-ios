//
//  FollowerFollowingViewController.swift
//  Podcast
//
//  Created by Drew Dunne on 9/10/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

/**
 * This view controller is for both displaying your followers and whom you follow.
 */

import UIKit
import NVActivityIndicatorView

class FollowerFollowingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "searchUsersCell"
    
    var usersTableView: UITableView!
    var loadingActivityIndicator: NVActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    
    var users: [User] = []
    var followersOrFollowings: UserFollowsType!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .podcastWhiteDark
        title = followersOrFollowings == .Followers ? "Followers" : "Following"

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // Do any additional setup after loading the view.
        usersTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        usersTableView.contentInset.bottom = appDelegate.tabBarController.tabBarHeight
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.backgroundColor = .clear
        usersTableView.separatorStyle = .none
        usersTableView.showsVerticalScrollIndicator = false
        usersTableView.register(SearchPeopleTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        usersTableView.reloadData()
        view.addSubview(usersTableView)
        
        loadingActivityIndicator = createLoadingAnimationView()
        loadingActivityIndicator.center = view.center
        view.addSubview(loadingActivityIndicator)
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .podcastTeal
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        usersTableView.addSubview(refreshControl)
        
        fetchEpisodes()
    }
    
    func handleRefresh() {
        fetchEpisodes()
    }
    
    func fetchEpisodes() {
        let endpointRequest = FetchUserFollowsByIDRequest(userId: System.currentUser!.id, type: followersOrFollowings)
        endpointRequest.success = { request in
            guard let follows = request.processedResponseValue as? [User] else { return }
            self.users = follows
            self.refreshControl.endRefreshing()
            self.loadingActivityIndicator.stopAnimating()
            self.usersTableView.reloadSections([0] , with: .automatic)
            
        }
        System.endpointRequestQueue.addOperation(endpointRequest)
    }
    
    //
    // MARK: TableView Delegate & DataSource Methods
    //

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Bring up user profile
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchPeopleTableViewCell else {
            let cell = SearchPeopleTableViewCell()
            cell.configure(for: users[indexPath.row], index: indexPath.row)
            return cell
        }
        cell.configure(for: users[indexPath.row], index: indexPath.row)
        return cell
    }

}

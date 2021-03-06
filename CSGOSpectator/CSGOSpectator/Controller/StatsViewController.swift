//
//  StatsViewController.swift
//  CSGOSpectator
//
//  Created by Adam Wienconek on 25.03.2018.
//  Copyright © 2018 intive. All rights reserved.
//

import UIKit
import CSGOSpectatorKit

final class StatsViewController: UIViewController {
    
    @IBOutlet weak var tableView: FadedTableView!

    weak var parentLiveViewController: LiveViewController?
    weak var detailsViewController: PlayerDetailsViewController?

    var gameState: Game! {
        didSet {
            players = gameState.players.sorted(by: { $0.statistics.score > $1.statistics.score })
            detailsViewController?.gameState = gameState
        }
    }
    private var players = [Player]() {
        didSet {
            if oldValue != players {
                tableView.reloadData()
            }
        }
    }
    var profiles = [String: SteamProfile]() {
        didSet {
            detailsViewController?.profiles = profiles
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 10, right: 0)
    }

}

extension StatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as? PlayerCell else { return UITableViewCell() }
        if let gameState = gameState {
            let player = players[indexPath.row]
            cell.setup(player: player, team: gameState.team(for: player))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.parentLiveViewController?.blurBackground.alpha = 1.0
        })
        guard let playerDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "details") as? PlayerDetailsViewController else { return }
        detailsViewController = playerDetailsViewController
        playerDetailsViewController.dismissDelegate = self
        playerDetailsViewController.gameState = gameState
        playerDetailsViewController.players = players
        playerDetailsViewController.profiles = profiles
        playerDetailsViewController.modalTransitionStyle = .coverVertical
        playerDetailsViewController.modalPresentationStyle = .overFullScreen
        playerDetailsViewController.pickedPlayerIndex = indexPath.row
        present(playerDetailsViewController, animated: true, completion: nil)
    }
    
}

extension StatsViewController: PlayerDetailsViewControllerDelegate {
    
    func viewDismissed() {
        UIView.animate(withDuration: 0.5, animations: {
            self.parentLiveViewController?.blurBackground.alpha = 0.0
            UIApplication.shared.statusBarStyle = .default
        })
    }
    
}

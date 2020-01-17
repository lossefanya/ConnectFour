//
//  ViewController.swift
//  ConnectFour
//
//  Created by Yeongweon Park on 21.12.19.
//  Copyright © 2019 young1park. All rights reserved.
//

import UIKit
import RxSwift

final class BoardViewController: UIViewController {
  let viewModel = BoardViewModel(network: NetworkService())
  private let bag = DisposeBag()

  @IBOutlet var board: UICollectionView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Rotate 270 degree clockwise. So that (0,0) can be left bottom.
    board.transform = CGAffineTransform(rotationAngle: .pi / 2 * 3)
    bind()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    update(state: viewModel.gameState.value)
  }

  func bind() {
    viewModel.cellViewModels.asDriver()
      .drive(onNext: { _ in self.board.reloadData() })
      .disposed(by: bag)
    viewModel.gameState.asDriver()
      .skip(1).distinctUntilChanged()
      .drive(onNext: update)
      .disposed(by: bag)
  }
}

extension BoardViewController {
  func update(state: GameState) {
    switch state {
    case .configuring: askCountOfPlayers()
    case .redWon, .blueWon: showWinner()
    default: break
    }
  }

  func askCountOfPlayers() {
    UIAlertController.alert(
      message: "How many players?",
      context: self,
      actions: [(title: "1P", action: { self.askMoveFirst() }),
                (title: "2P", action: { self.viewModel.startGame(mode: .vs) })]
    )
  }

  func askMoveFirst() {
    UIAlertController.alert(
      message: "Do you wanna move first?",
      context: self,
      actions: [(title: "YES", action: { self.viewModel.startGame(mode: .soloRed) }),
                (title: "NO", action: { self.viewModel.startGame(mode: .soloBlue) })]
    )
  }

  func showWinner() {
    UIAlertController.alert(
      message: viewModel.winningMessage,
      context: self,
      actions: [(title: "OK", action: { self.viewModel.initializeGame() })]
    )
  }
}

extension BoardViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.width * viewModel.height
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardCell", for: indexPath) as! BoardCell
    cell.viewModel = viewModel.cellViewModels.value[indexPath.row]
    return cell
  }
}

extension BoardViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard viewModel.isPlayersTurn else { return }
    viewModel.select(index: indexPath.row)
  }
}

extension BoardViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // `board` will be rotated 270 degrees.
    let width = collectionView.frame.size.width / CGFloat(viewModel.height)
    let height = collectionView.frame.size.height / CGFloat(viewModel.width)
    return CGSize(width: width, height: height)
  }
}

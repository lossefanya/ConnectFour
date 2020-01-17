//
//  BoardViewModel.swift
//  ConnectFour
//
//  Created by Yeongweon Park on 21.12.19.
//  Copyright © 2019 young1park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class BoardViewModel {
  let width = 7
  let height = 6
  let gameState = BehaviorRelay<GameState>(value: .configuring)
  let cellViewModels = BehaviorRelay<[BoardCellViewModel]>(value: [])
  private let gameMode = BehaviorRelay<GameMode>(value: .vs)
  private let gameSetting = BehaviorRelay<GameSetting>(value: GameSetting.offline)
  private let matrix = BehaviorRelay<[[CellState]]>(value: [])
  private let directions = [Direction(dx: -1, dy: 1), Direction(dx: 0, dy: 1), Direction(dx: 1, dy: 1), Direction(dx: 1, dy: 0)]
  private let bag = DisposeBag()
  private let network: Networkable

  var winningMessage: String {
    switch gameState.value {
    case .redWon: return "\(gameSetting.value.name1) won!"
    case .blueWon: return "\(gameSetting.value.name2) won!"
    default: return "No one has won yet."
    }
  }
  var isPlayersTurn: Bool {
    switch gameMode.value {
    case .vs: return true
    case .soloRed: return gameState.value == .redTurn
    case .soloBlue: return gameState.value == .blueTurn
    }
  }
  private var isPlaying: Bool {
    switch gameState.value {
    case .redTurn, .blueTurn: return true
    default: return false
    }
  }

  init(network: Networkable) {
    self.network = network
    initializeGame()
    gameState.asObservable()
      .subscribe(onNext: playByAI)
      .disposed(by: bag)
  }

  func initializeGame() {
    matrix.accept([[CellState]](repeating: [CellState](), count: width))
    gameState.accept(.configuring)
    cellViewModels.accept([BoardCellViewModel](repeating: BoardCellViewModel(color: .systemBackground), count: width * height))
  }

  func startGame(mode: GameMode) {
    gameMode.accept(mode)
    gameState.accept(.setting)
    network.gameSetting().subscribe(onNext: {
      self.gameSetting.accept($0)
      self.gameState.accept(.redTurn)
    }).disposed(by: bag)
  }

  private func playByAI(state: GameState) {
    guard (state == .blueTurn && gameMode.value == .soloRed) || (state == .redTurn && gameMode.value == .soloBlue) else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.select(index: Int.random(in: 0...(self.width * self.height - 1)))
    }
  }

  func select(index: Int) {
    guard isPlaying else { return }
    let column = index / height
    var _matrix = matrix.value
    var stack = _matrix[column]
    guard stack.count < height else { return }

    let position = Position(x: column, y: stack.count)
    var _changes: (cellState: CellState, color: UIColor, nextState: GameState)?
    switch gameState.value {
    case .redTurn: _changes = (.red, gameSetting.value.firstColor ?? .systemRed, .blueTurn)
    case .blueTurn: _changes = (.blue, gameSetting.value.secondColor ?? .systemBlue, .redTurn)
    default: break
    }

    guard let changes = _changes else { return }
    stack.append(changes.cellState)
    _matrix[column] = stack
    matrix.accept(_matrix)
    changeColor(at: position, color: changes.color)
    check()

    guard isPlaying else { return }
    gameState.accept(changes.nextState)
  }

  private func changeColor(at position: Position, color: UIColor) {
    let index = position.x * height + position.y
    var viewModels = cellViewModels.value
    viewModels[index] = BoardCellViewModel(color: color)
    cellViewModels.accept(viewModels)
  }

  private func check() {
    for column in 0...(matrix.value.count - 1) {
      let stack = matrix.value[column]
      guard stack.count > 0 else { continue }
      for index in 0...(stack.count - 1) {
        let state = stack[index]
        directions.forEach { find(from: Position(x: column, y: index), cellState: state, direction: $0, count: 1) }
      }
    }
  }

  private func find(from: Position, cellState: CellState, direction: Direction, count: Int) {
    let column = from.x + direction.dx
    guard column > -1, column < width else { return }
    let index = from.y + direction.dy
    guard matrix.value[column].indices.contains(index) else { return }
    let state = matrix.value[column][index]
    guard state == cellState else { return }
    guard count == 3 else {
      find(from: Position(x: column, y: index), cellState: cellState, direction: direction, count: count + 1)
      return
    }

    switch cellState {
    case .red: gameState.accept(.redWon)
    case .blue: gameState.accept(.blueWon)
    }
  }  
}

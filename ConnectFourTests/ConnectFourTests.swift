//
//  ConnectFourTests.swift
//  ConnectFourTests
//
//  Created by Yeongweon Park on 21.12.19.
//  Copyright © 2019 young1park. All rights reserved.
//

import XCTest
@testable import ConnectFour

class ConnectFourTests: XCTestCase {
  private var viewModel: BoardViewModel!
  private var mockNetwork: MockNetworkService!

  override func setUp() {
    super.setUp()
    let mockSetting = GameSetting(id: 0, color1: "#dd0000", color2: "#0000dd", name1: "Jane", name2: "John")
    mockNetwork = MockNetworkService(mockSetting: mockSetting)
    viewModel = BoardViewModel(network: mockNetwork)
  }

  override func tearDown() {
    super.tearDown()
    viewModel = nil
    mockNetwork = nil
  }

  func testInitialize() {
    viewModel.initializeGame()
    XCTAssertEqual(viewModel.gameState.value, GameState.configuring)
    XCTAssertEqual(viewModel.cellViewModels.value.count, viewModel.width * viewModel.height)
  }

  func testStart() {
    viewModel.initializeGame()
    viewModel.startGame(mode: .vs)
    XCTAssertEqual(viewModel.gameState.value, GameState.redTurn)
  }

  func testRedWon() {
    let redMoves = [0, 0, 0, 0]
    let blueMoves = [6, 6, 6]
    viewModel.initializeGame()
    viewModel.startGame(mode: .vs)
    viewModel.select(index: redMoves[0])
    viewModel.select(index: blueMoves[0])
    viewModel.select(index: redMoves[1])
    viewModel.select(index: blueMoves[1])
    viewModel.select(index: redMoves[2])
    viewModel.select(index: blueMoves[2])
    viewModel.select(index: redMoves[3])
    XCTAssertEqual(viewModel.gameState.value, GameState.redWon)
    XCTAssertEqual(viewModel.winningMessage, "Jane won!")
  }

  func testPlayersTurnAndMoveByAI() {
    viewModel.initializeGame()
    viewModel.startGame(mode: .soloBlue)
    XCTAssertEqual(viewModel.isPlayersTurn, false)
    let expectation = XCTestExpectation(description: "AI made move. And it's the player's turn.")
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
      guard let red = self.mockNetwork.mockSetting.firstColor else {
        XCTFail("It failed to parse color from setting.")
        return
      }
      let countOfRed = self.viewModel.cellViewModels.value.filter { $0.color == red }.count
      XCTAssertEqual(countOfRed, 1)
      XCTAssertEqual(self.viewModel.isPlayersTurn, true)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }
}

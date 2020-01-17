//
//  MockNetworkService.swift
//  ConnectFourTests
//
//  Created by Yeongweon Park on 21.12.19.
//  Copyright © 2019 young1park. All rights reserved.
//

import Foundation
@testable import ConnectFour
import RxSwift

struct MockNetworkService: Networkable {
  let mockSetting: GameSetting
  
  func gameSetting() -> Observable<GameSetting> {
    return Observable.just(mockSetting)
  }
}

//
//  NetworkService.swift
//  ConnectFour
//
//  Created by Yeongweon Park on 21.12.19.
//  Copyright © 2019 young1park. All rights reserved.
//

import Foundation
import RxSwift

protocol Networkable {
  func gameSetting() -> Observable<GameSetting>
}

struct NetworkService: Networkable {
  let decoder = JSONDecoder()
  func gameSetting() -> Observable<GameSetting> {
    return Observable.create { observer in
      let url = URL(string: "")!
      let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else {
          observer.onNext(GameSetting.offline) // Let user play offline in case of error.
          observer.onCompleted()
          return
        }
        do {
          let settings = try self.decoder.decode([GameSetting].self, from: data)
          observer.onNext(settings.first!)
          observer.onCompleted()
        } catch {
          observer.onNext(GameSetting.offline) // Let user play offline in case of error.
          observer.onCompleted()
        }
      }
      task.resume()

      return Disposables.create()
    }
  }
}

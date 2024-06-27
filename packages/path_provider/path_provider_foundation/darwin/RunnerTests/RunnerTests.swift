// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import path_provider_foundation

#if os(iOS) || os(tvOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

class RunnerTests: XCTestCase {
  var plugin: PathProviderPlugin!
  var isTvOS: Bool!

  override func setUp() {
    super.setUp()
    plugin = PathProviderPlugin()
    #if os(tvOS)
      isTvOS = true
    #else
      isTvOS = false
    #endif
  }

  func testGetTemporaryDirectory() throws {
    let path = plugin.getDirectoryPath(type: .temp)
    XCTAssertEqual(
      path,
      NSTemporaryDirectory().removingPercentEncoding
    )
  }

  func testGetApplicationDocumentsDirectory() throws {
    let path = plugin.getDirectoryPath(type: .applicationDocuments)
    if isTvOS {
      XCTAssertEqual(
        path,
        NSSearchPathForDirectoriesInDomains(
          FileManager.SearchPathDirectory.cachesDirectory,
          FileManager.SearchPathDomainMask.userDomainMask,
          true
        ).first
      )
    } else {
      XCTAssertEqual(
        path,
        NSSearchPathForDirectoriesInDomains(
          FileManager.SearchPathDirectory.documentDirectory,
          FileManager.SearchPathDomainMask.userDomainMask,
          true
        ).first
      )
    }
  }

  func testGetApplicationSupportDirectory() throws {
    let path = plugin.getDirectoryPath(type: .applicationSupport)
    #if os(iOS) || os(tvOS)
      // On iOS and tvOS, the application support directory path should be just the system application
      // support path.
      XCTAssertEqual(
        path,
        NSSearchPathForDirectoriesInDomains(
          FileManager.SearchPathDirectory.applicationSupportDirectory,
          FileManager.SearchPathDomainMask.userDomainMask,
          true
        ).first
      )
    #else
      // On macOS, the application support directory path should be the system application
      // support path with an added subdirectory based on the app name.
      XCTAssert(
        path!.hasPrefix(
          NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.applicationSupportDirectory,
            FileManager.SearchPathDomainMask.userDomainMask,
            true
          ).first!
        )
      )
      XCTAssert(path!.hasSuffix("Example"))
    #endif
  }

  func testGetLibraryDirectory() throws {
    let path = plugin.getDirectoryPath(type: .library)
    XCTAssertEqual(
      path,
      NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.libraryDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first
    )
  }

  func testGetDownloadsDirectory() throws {
    if isTvOS {
      XCTAssertNil(plugin.getDirectoryPath(type: .downloads))
    } else {
      let path = plugin.getDirectoryPath(type: .downloads)
      XCTAssertEqual(
        path,
        NSSearchPathForDirectoriesInDomains(
          FileManager.SearchPathDirectory.downloadsDirectory,
          FileManager.SearchPathDomainMask.userDomainMask,
          true
        ).first
      )
    }
  }
}
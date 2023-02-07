//
// AppError.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

enum AppError: Error {
    case connectionError(String)
    case initializationError(String)
    case operationError(String)
}

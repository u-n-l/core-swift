//
//  UnlCoreError.swift
//  core
//
//  Created by Bogdan Simon on 28/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

enum UnlCoreError: Error {
    case illegalArgument(messsage: String)
    case jsonDecodingError(message: String)
    case httpRequestError(message: String)
}

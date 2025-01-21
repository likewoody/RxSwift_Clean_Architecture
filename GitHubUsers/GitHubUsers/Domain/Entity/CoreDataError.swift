//
//  CorDataError.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation

public enum CoreDataError: Error {
    case entityNotFound(String)
    case saveError(String)
    case readError(String)
    case deleteError(String)
    
    public var description: String {
        switch self {
        case .entityNotFound(let objectName):
            "객체를 찾을 수 없습니다 : \(objectName)"
        case .saveError(let message):
            "객체 저장 실패 : \(message)"
        case .readError(let message):
            "객체 읽기 실패 : \(message)"
        case .deleteError(let message):
            "객체 삭제 실패 : \(message)"
        }
    }
}

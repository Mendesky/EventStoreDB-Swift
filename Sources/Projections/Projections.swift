//
//  Projection.swift
//
//
//  Created by Grady Zhuo on 2023/10/17.
//
import Foundation
import KurrentCore
import GRPCCore
import GRPCEncapsulates
import GRPCNIOTransportHTTP2Posix
import SwiftProtobuf

public typealias UnderlyingService = EventStore_Client_Projections_Projections
public struct Service: GRPCConcreteClient {
    public typealias Transport = HTTP2ClientTransport.Posix
    public typealias UnderlyingClient = UnderlyingService.Client<Transport>
    
    public private(set) var settings: ClientSettings
    public var callOptions: CallOptions
    
    public init(settings: ClientSettings, callOptions: CallOptions = .defaults){
        self.settings = settings
        self.callOptions = callOptions
    }
}

extension Service {
    public func create(name: String, query: String, options: ContinuousCreate.Options = .init()) async throws -> ContinuousCreate.Response {
        let usecase = ContinuousCreate(name: name, query: query, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func delete(name: String, options: Delete.Options = .init()) async throws -> Delete.Response {
        let usecase = Delete(name: name, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func disable(name: String, writeCheckpoint: Bool = false) async throws -> Disable.Response {
        let options = Disable.Options().writeCheckpoint(enabled: false)
        let usecase = Disable(name: name, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func enable(name: String) async throws -> Enable.Response {
        let usecase = Enable(name: name, options: .init())
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func reset(name: String, writeCheckpoint: Bool = false) async throws -> Reset.Response {
        let options = Reset.Options().writeCheckpoint(enable: writeCheckpoint)
        let usecase = Reset(name: name, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func state(name: String, partition: String? = nil) async throws -> State.Response {
        let options = State.Options(partition: partition)
        let usecase = State(name: name, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func statistics(name: String, mode: Statistics.ModeOptions = .all) async throws -> Statistics.Responses {
        let options = Statistics.Options().set(mode: mode)
        let usecase = Statistics(name: name, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func update(name: String, query: String?, emit emitOption: Update.EmitOption = .noEmit) async throws -> Update.Response {
        let options = Update.Options(emitOption: emitOption)
        let usecase = Update(name: name, query: query, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
}

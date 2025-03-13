//
//  Projections.swift
//  KurrentProjections
//
//  Created by Grady Zhuo on 2023/10/17.
//
import Foundation
import GRPCCore
import GRPCEncapsulates
import GRPCNIOTransportHTTP2Posix
import Logging
import NIO

public struct Projections<Target: ProjectionTarget>: GRPCConcreteService {
    package typealias UnderlyingClient = EventStore_Client_Projections_Projections.Client<HTTP2ClientTransport.Posix>

    private(set) var settings: ClientSettings
    var callOptions: CallOptions
    let eventLoopGroup: EventLoopGroup
    private(set) var target: Target

    public init(target: Target, settings: ClientSettings, callOptions: CallOptions = .defaults, eventLoopGroup: EventLoopGroup = .singletonMultiThreadedEventLoopGroup) {
        self.target = target
        self.settings = settings
        self.callOptions = callOptions
        self.eventLoopGroup = eventLoopGroup
    }
}

extension Projections where Target == ContinuousProjectionTarget {
    var name: String {
        target.name
    }
    
    public func create(query: String, options: ContinuousCreate.Options = .init()) async throws {
        let usecase = ContinuousCreate(name: name, query: query, options: options)
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func delete(options: Delete.Options = .init()) async throws {
        let usecase = Delete(name: name, options: options)
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func delete(deleteCheckpointStream: Bool = false, deleteEmittedStreams: Bool = false, deleteStateStream: Bool = false) async throws {
        let options = Delete.Options()
            .deleteCheckpointStream(enabled: deleteCheckpointStream)
            .deleteEmittedStreams(enabled: deleteEmittedStreams)
            .deleteStateStream(enabled: deleteStateStream)
        let usecase = Delete(name: name, options: .init())
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func update(query: String?, emit emitOption: Update.EmitOption = .noEmit) async throws {
        let options = Update.Options(emitOption: emitOption)
        let usecase = Update(name: name, query: query, options: options)
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }

    public func disable(writeCheckpoint: Bool = true) async throws {
        let options = Disable.Options().writeCheckpoint(enabled: writeCheckpoint)
        let usecase = Disable(name: name, options: options)
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }

    public func enable() async throws {
        let usecase = Enable(name: name, options: .init())
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }

    public func reset(writeCheckpoint: Bool = false) async throws {
        let options = Reset.Options().writeCheckpoint(enable: writeCheckpoint)
        let usecase = Reset(name: name, options: options)
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }

    public func getResult(partition: String? = nil) async throws -> Result.Response {
        let options = Result.Options(partition: partition)
        let usecase = Result(name: name, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public var details: Statistics.Details? {
        get async throws {
            let usecase = Statistics(options: .specified(name: name))
            let response = try await usecase.perform(settings: settings, callOptions: callOptions).first{ _ in true }
            return response?.details
        }
    }

    public func getState(partition: String? = nil) async throws -> State.Response {
        let options = State.Options(partition: partition)
        let usecase = State(name: name, options: options)
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }

}

extension Projections where Target == AllProjectionTarget {
    
    public var mode: Projection.Mode {
        get {
            target.mode
        }
    }
    
    public func list() async throws -> Statistics.Responses {
        let usecase = Statistics(options: .listAll(mode: mode))
        return try await usecase.perform(settings: settings, callOptions: callOptions)
    }
}

extension Projections where Target == ContinuousProjectionTarget {
    public func create(name: String, query: String, options: ContinuousCreate.Options = .init()) async throws {
        let usecase = ContinuousCreate(name: name, query: query, options: options)
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }
}

extension Projections where Target == PredefinedProjection {
    
    var name: String {
        get {
            target.name.rawValue
        }
    }
    
    public func disable(writeCheckpoint _: Bool = false) async throws {
        let options = Disable.Options().writeCheckpoint(enabled: false)
        let usecase = Disable(name: name, options: options)
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }

    public func enable() async throws {
        let usecase = Enable(name: name, options: .init())
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }
    
    public func reset(writeCheckpoint: Bool = false) async throws {
        let options = Reset.Options().writeCheckpoint(enable: writeCheckpoint)
        let usecase = Reset(name: name, options: options)
        _ = try await usecase.perform(settings: settings, callOptions: callOptions)
    }
}

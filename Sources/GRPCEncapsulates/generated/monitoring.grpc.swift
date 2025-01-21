// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the gRPC Swift generator plugin for the protocol buffer compiler.
// Source: monitoring.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/grpc/grpc-swift

import GRPCCore
import GRPCProtobuf

// MARK: - event_store.client.monitoring.Monitoring

/// Namespace containing generated types for the "event_store.client.monitoring.Monitoring" service.
public enum EventStore_Client_Monitoring_Monitoring {
    /// Service descriptor for the "event_store.client.monitoring.Monitoring" service.
    public static let descriptor = GRPCCore.ServiceDescriptor(fullyQualifiedService: "event_store.client.monitoring.Monitoring")
    /// Namespace for method metadata.
    public enum Method {
        /// Namespace for "Stats" metadata.
        public enum Stats {
            /// Request type for "Stats".
            public typealias Input = EventStore_Client_Monitoring_StatsReq
            /// Response type for "Stats".
            public typealias Output = EventStore_Client_Monitoring_StatsResp
            /// Descriptor for "Stats".
            public static let descriptor = GRPCCore.MethodDescriptor(
                service: GRPCCore.ServiceDescriptor(fullyQualifiedService: "event_store.client.monitoring.Monitoring"),
                method: "Stats"
            )
        }
        /// Descriptors for all methods in the "event_store.client.monitoring.Monitoring" service.
        public static let descriptors: [GRPCCore.MethodDescriptor] = [
            Stats.descriptor
        ]
    }
}

extension GRPCCore.ServiceDescriptor {
    /// Service descriptor for the "event_store.client.monitoring.Monitoring" service.
    public static let event_store_client_monitoring_Monitoring = GRPCCore.ServiceDescriptor(fullyQualifiedService: "event_store.client.monitoring.Monitoring")
}

// MARK: event_store.client.monitoring.Monitoring (server)

extension EventStore_Client_Monitoring_Monitoring {
    /// Streaming variant of the service protocol for the "event_store.client.monitoring.Monitoring" service.
    ///
    /// This protocol is the lowest-level of the service protocols generated for this service
    /// giving you the most flexibility over the implementation of your service. This comes at
    /// the cost of more verbose and less strict APIs. Each RPC requires you to implement it in
    /// terms of a request stream and response stream. Where only a single request or response
    /// message is expected, you are responsible for enforcing this invariant is maintained.
    ///
    /// Where possible, prefer using the stricter, less-verbose ``ServiceProtocol``
    /// or ``SimpleServiceProtocol`` instead.
    public protocol StreamingServiceProtocol: GRPCCore.RegistrableRPCService {
        /// Handle the "Stats" method.
        ///
        /// - Parameters:
        ///   - request: A streaming request of `EventStore_Client_Monitoring_StatsReq` messages.
        ///   - context: Context providing information about the RPC.
        /// - Throws: Any error which occurred during the processing of the request. Thrown errors
        ///     of type `RPCError` are mapped to appropriate statuses. All other errors are converted
        ///     to an internal error.
        /// - Returns: A streaming response of `EventStore_Client_Monitoring_StatsResp` messages.
        func stats(
            request: GRPCCore.StreamingServerRequest<EventStore_Client_Monitoring_StatsReq>,
            context: GRPCCore.ServerContext
        ) async throws -> GRPCCore.StreamingServerResponse<EventStore_Client_Monitoring_StatsResp>
    }

    /// Service protocol for the "event_store.client.monitoring.Monitoring" service.
    ///
    /// This protocol is higher level than ``StreamingServiceProtocol`` but lower level than
    /// the ``SimpleServiceProtocol``, it provides access to request and response metadata and
    /// trailing response metadata. If you don't need these then consider using
    /// the ``SimpleServiceProtocol``. If you need fine grained control over your RPCs then
    /// use ``StreamingServiceProtocol``.
    public protocol ServiceProtocol: EventStore_Client_Monitoring_Monitoring.StreamingServiceProtocol {
        /// Handle the "Stats" method.
        ///
        /// - Parameters:
        ///   - request: A request containing a single `EventStore_Client_Monitoring_StatsReq` message.
        ///   - context: Context providing information about the RPC.
        /// - Throws: Any error which occurred during the processing of the request. Thrown errors
        ///     of type `RPCError` are mapped to appropriate statuses. All other errors are converted
        ///     to an internal error.
        /// - Returns: A streaming response of `EventStore_Client_Monitoring_StatsResp` messages.
        func stats(
            request: GRPCCore.ServerRequest<EventStore_Client_Monitoring_StatsReq>,
            context: GRPCCore.ServerContext
        ) async throws -> GRPCCore.StreamingServerResponse<EventStore_Client_Monitoring_StatsResp>
    }

    /// Simple service protocol for the "event_store.client.monitoring.Monitoring" service.
    ///
    /// This is the highest level protocol for the service. The API is the easiest to use but
    /// doesn't provide access to request or response metadata. If you need access to these
    /// then use ``ServiceProtocol`` instead.
    public protocol SimpleServiceProtocol: EventStore_Client_Monitoring_Monitoring.ServiceProtocol {
        /// Handle the "Stats" method.
        ///
        /// - Parameters:
        ///   - request: A `EventStore_Client_Monitoring_StatsReq` message.
        ///   - response: A response stream of `EventStore_Client_Monitoring_StatsResp` messages.
        ///   - context: Context providing information about the RPC.
        /// - Throws: Any error which occurred during the processing of the request. Thrown errors
        ///     of type `RPCError` are mapped to appropriate statuses. All other errors are converted
        ///     to an internal error.
        func stats(
            request: EventStore_Client_Monitoring_StatsReq,
            response: GRPCCore.RPCWriter<EventStore_Client_Monitoring_StatsResp>,
            context: GRPCCore.ServerContext
        ) async throws
    }
}

// Default implementation of 'registerMethods(with:)'.
extension EventStore_Client_Monitoring_Monitoring.StreamingServiceProtocol {
    public func registerMethods<Transport>(with router: inout GRPCCore.RPCRouter<Transport>) where Transport: GRPCCore.ServerTransport {
        router.registerHandler(
            forMethod: EventStore_Client_Monitoring_Monitoring.Method.Stats.descriptor,
            deserializer: GRPCProtobuf.ProtobufDeserializer<EventStore_Client_Monitoring_StatsReq>(),
            serializer: GRPCProtobuf.ProtobufSerializer<EventStore_Client_Monitoring_StatsResp>(),
            handler: { request, context in
                try await self.stats(
                    request: request,
                    context: context
                )
            }
        )
    }
}

// Default implementation of streaming methods from 'StreamingServiceProtocol'.
extension EventStore_Client_Monitoring_Monitoring.ServiceProtocol {
    public func stats(
        request: GRPCCore.StreamingServerRequest<EventStore_Client_Monitoring_StatsReq>,
        context: GRPCCore.ServerContext
    ) async throws -> GRPCCore.StreamingServerResponse<EventStore_Client_Monitoring_StatsResp> {
        let response = try await self.stats(
            request: GRPCCore.ServerRequest(stream: request),
            context: context
        )
        return response
    }
}

// Default implementation of methods from 'ServiceProtocol'.
extension EventStore_Client_Monitoring_Monitoring.SimpleServiceProtocol {
    public func stats(
        request: GRPCCore.ServerRequest<EventStore_Client_Monitoring_StatsReq>,
        context: GRPCCore.ServerContext
    ) async throws -> GRPCCore.StreamingServerResponse<EventStore_Client_Monitoring_StatsResp> {
        return GRPCCore.StreamingServerResponse<EventStore_Client_Monitoring_StatsResp>(
            metadata: [:],
            producer: { writer in
                try await self.stats(
                    request: request.message,
                    response: writer,
                    context: context
                )
                return [:]
            }
        )
    }
}

// MARK: event_store.client.monitoring.Monitoring (client)

extension EventStore_Client_Monitoring_Monitoring {
    /// Generated client protocol for the "event_store.client.monitoring.Monitoring" service.
    ///
    /// You don't need to implement this protocol directly, use the generated
    /// implementation, ``Client``.
    public protocol ClientProtocol: Sendable {
        /// Call the "Stats" method.
        ///
        /// - Parameters:
        ///   - request: A request containing a single `EventStore_Client_Monitoring_StatsReq` message.
        ///   - serializer: A serializer for `EventStore_Client_Monitoring_StatsReq` messages.
        ///   - deserializer: A deserializer for `EventStore_Client_Monitoring_StatsResp` messages.
        ///   - options: Options to apply to this RPC.
        ///   - handleResponse: A closure which handles the response, the result of which is
        ///       returned to the caller. Returning from the closure will cancel the RPC if it
        ///       hasn't already finished.
        /// - Returns: The result of `handleResponse`.
        func stats<Result>(
            request: GRPCCore.ClientRequest<EventStore_Client_Monitoring_StatsReq>,
            serializer: some GRPCCore.MessageSerializer<EventStore_Client_Monitoring_StatsReq>,
            deserializer: some GRPCCore.MessageDeserializer<EventStore_Client_Monitoring_StatsResp>,
            options: GRPCCore.CallOptions,
            onResponse handleResponse: @Sendable @escaping (GRPCCore.StreamingClientResponse<EventStore_Client_Monitoring_StatsResp>) async throws -> Result
        ) async throws -> Result where Result: Sendable
    }

    /// Generated client for the "event_store.client.monitoring.Monitoring" service.
    ///
    /// The ``Client`` provides an implementation of ``ClientProtocol`` which wraps
    /// a `GRPCCore.GRPCCClient`. The underlying `GRPCClient` provides the long-lived
    /// means of communication with the remote peer.
    public struct Client<Transport>: ClientProtocol where Transport: GRPCCore.ClientTransport {
        private let client: GRPCCore.GRPCClient<Transport>

        /// Creates a new client wrapping the provided `GRPCCore.GRPCClient`.
        ///
        /// - Parameters:
        ///   - client: A `GRPCCore.GRPCClient` providing a communication channel to the service.
        public init(wrapping client: GRPCCore.GRPCClient<Transport>) {
            self.client = client
        }

        /// Call the "Stats" method.
        ///
        /// - Parameters:
        ///   - request: A request containing a single `EventStore_Client_Monitoring_StatsReq` message.
        ///   - serializer: A serializer for `EventStore_Client_Monitoring_StatsReq` messages.
        ///   - deserializer: A deserializer for `EventStore_Client_Monitoring_StatsResp` messages.
        ///   - options: Options to apply to this RPC.
        ///   - handleResponse: A closure which handles the response, the result of which is
        ///       returned to the caller. Returning from the closure will cancel the RPC if it
        ///       hasn't already finished.
        /// - Returns: The result of `handleResponse`.
        public func stats<Result>(
            request: GRPCCore.ClientRequest<EventStore_Client_Monitoring_StatsReq>,
            serializer: some GRPCCore.MessageSerializer<EventStore_Client_Monitoring_StatsReq>,
            deserializer: some GRPCCore.MessageDeserializer<EventStore_Client_Monitoring_StatsResp>,
            options: GRPCCore.CallOptions = .defaults,
            onResponse handleResponse: @Sendable @escaping (GRPCCore.StreamingClientResponse<EventStore_Client_Monitoring_StatsResp>) async throws -> Result
        ) async throws -> Result where Result: Sendable {
            try await self.client.serverStreaming(
                request: request,
                descriptor: EventStore_Client_Monitoring_Monitoring.Method.Stats.descriptor,
                serializer: serializer,
                deserializer: deserializer,
                options: options,
                onResponse: handleResponse
            )
        }
    }
}

// Helpers providing default arguments to 'ClientProtocol' methods.
extension EventStore_Client_Monitoring_Monitoring.ClientProtocol {
    /// Call the "Stats" method.
    ///
    /// - Parameters:
    ///   - request: A request containing a single `EventStore_Client_Monitoring_StatsReq` message.
    ///   - options: Options to apply to this RPC.
    ///   - handleResponse: A closure which handles the response, the result of which is
    ///       returned to the caller. Returning from the closure will cancel the RPC if it
    ///       hasn't already finished.
    /// - Returns: The result of `handleResponse`.
    public func stats<Result>(
        request: GRPCCore.ClientRequest<EventStore_Client_Monitoring_StatsReq>,
        options: GRPCCore.CallOptions = .defaults,
        onResponse handleResponse: @Sendable @escaping (GRPCCore.StreamingClientResponse<EventStore_Client_Monitoring_StatsResp>) async throws -> Result
    ) async throws -> Result where Result: Sendable {
        try await self.stats(
            request: request,
            serializer: GRPCProtobuf.ProtobufSerializer<EventStore_Client_Monitoring_StatsReq>(),
            deserializer: GRPCProtobuf.ProtobufDeserializer<EventStore_Client_Monitoring_StatsResp>(),
            options: options,
            onResponse: handleResponse
        )
    }
}

// Helpers providing sugared APIs for 'ClientProtocol' methods.
extension EventStore_Client_Monitoring_Monitoring.ClientProtocol {
    /// Call the "Stats" method.
    ///
    /// - Parameters:
    ///   - message: request message to send.
    ///   - metadata: Additional metadata to send, defaults to empty.
    ///   - options: Options to apply to this RPC, defaults to `.defaults`.
    ///   - handleResponse: A closure which handles the response, the result of which is
    ///       returned to the caller. Returning from the closure will cancel the RPC if it
    ///       hasn't already finished.
    /// - Returns: The result of `handleResponse`.
    public func stats<Result>(
        _ message: EventStore_Client_Monitoring_StatsReq,
        metadata: GRPCCore.Metadata = [:],
        options: GRPCCore.CallOptions = .defaults,
        onResponse handleResponse: @Sendable @escaping (GRPCCore.StreamingClientResponse<EventStore_Client_Monitoring_StatsResp>) async throws -> Result
    ) async throws -> Result where Result: Sendable {
        let request = GRPCCore.ClientRequest<EventStore_Client_Monitoring_StatsReq>(
            message: message,
            metadata: metadata
        )
        return try await self.stats(
            request: request,
            options: options,
            onResponse: handleResponse
        )
    }
}
//
//  SwiftUIView.swift
//  
//
//  Created by lxthyme on 2023/9/8.
//

#if os(iOS) || os(macOS)

import AuthenticationServices
import SwiftUI
import Combine
import os

// MARK: - 👀
public extension Logger {
    static let authorization = Logger(subsystem: "FoodTruck", category: "Food Truck accounts")
}

public enum AuthorizationHandlingError: Error {
    case unknownAuthorizationResult(ASAuthorizationResult)
    case otherError
}

// MARK: - 👀
extension AuthorizationHandlingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownAuthorizationResult:
            return NSLocalizedString("Received an unknown authorization result.",
                                     comment: "Human readable description of receiving an unknown authorization result.")
        case .otherError:
            return NSLocalizedString("Encountered an error handling the authorization result.",
                                     comment: "Human readable description of an unknown error while handling the authorization result.")
        }
    }
}

@MainActor
public final class AccountStore: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published public private(set) var currentUser: User? = .default
    public weak var presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?

    public var isSignedIn: Bool {
        currentUser != nil
    }

    public func signIntoPasskeyAccount(authorizationController: AuthorizationController,
                                       options: ASAuthorizationController.RequestOptions = []) async {
        do {
            let authorizationResult = try await authorizationController.performRequests(signInRequests(), options: options)
            try await handleAuthorizationResult(authorizationResult)
        } catch let authorizationError as ASAuthorizationError where authorizationError.code == .canceled {
            Logger.authorization.log("The user cancelled passkey authorization.")
        } catch let authorizationError as ASAuthorizationError {
            Logger.authorization.error("Passkey authorization failed. Error: \(authorizationError.localizedDescription)")
        } catch AuthorizationHandlingError.unknownAuthorizationResult(let authorizationResult) {
            Logger.authorization.error("""
            Passkey authorization handling failed. \
            Received an unknown result: \(String(describing: authorizationResult))
            """)
        } catch {
            Logger.authorization.error("""
            Passkey authorization handling failed. \
            Caught an unknown error during passkey authorization or handling: \(error.localizedDescription)
            """)
        }
    }
    public func createPasskeyAccount(authorizationController: AuthorizationController, username: String, options: ASAuthorizationController.RequestOptions = []) async {
        do {
            let authorizationResult = try await authorizationController.performRequests([passkeyRegistrationRequest(username: username)], options: options)
            try await handleAuthorizationResult(authorizationResult, username: username)
        } catch let authorizationError as ASAuthorizationError where authorizationError.code == .canceled {
            Logger.authorization.log("The user cancelled passkey registration.")
        } catch let authorizationError as ASAuthorizationError {
            Logger.authorization.error("Passkey registration failed. Error: \(authorizationError.localizedDescription)")
        } catch AuthorizationHandlingError.unknownAuthorizationResult(let authorizationResult) {
            Logger.authorization.error("""
            Passkey registration handling failed. \
            Received an unknown result: \(String(describing: authorizationResult))
            """)
        } catch {
            Logger.authorization.error("""
            Passkey registration handling failed. \
            Caught an unknown error during passkey registration or handling: \(error.localizedDescription)
            """)
        }
    }

    public func createPasswordAccount(username: String, password: String) async {
        currentUser = .authenticated(username: username)
    }

    public func signOut() {
        currentUser = nil
    }

    private static let relyingPartyIdentifier = "example.com"
    private func passkeyChallenge() async -> Data {
        Data("passkey challenge".utf8)
    }

    private func passkeyAssertionRequest() async -> ASAuthorizationRequest {
        await ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: Self.relyingPartyIdentifier)
            .createCredentialAssertionRequest(challenge: passkeyChallenge())
    }

    private func passkeyRegistrationRequest(username: String) async -> ASAuthorizationRequest {
        await ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: Self.relyingPartyIdentifier)
            .createCredentialRegistrationRequest(challenge: passkeyChallenge(),
                                                 name: username,
                                                 userID: Data(username.utf8))
    }
    private func signInRequests() async -> [ASAuthorizationRequest] {
        await [passkeyAssertionRequest(), ASAuthorizationPasswordProvider().createRequest()]
    }
    private func handleAuthorizationResult(_ authorizationResult: ASAuthorizationResult, username: String? = nil) async throws {
        switch authorizationResult {
        case .password(let passwordCredential):
            Logger.authorization.log("Password authorization succeeded: \(passwordCredential)")
            currentUser = .authenticated(username: passwordCredential.user)
        // case .appleID(let authorizationAppleIDCredential):
        case .passkeyAssertion(let authorizationPlatformPublicKeyCredentialAssertion):
            Logger.authorization.log("Passkey authorization succeeded: \(authorizationPlatformPublicKeyCredentialAssertion)")
            guard let username = String(bytes: authorizationPlatformPublicKeyCredentialAssertion.userID, encoding: .utf8) else {
                fatalError("Invalid credential: \(authorizationPlatformPublicKeyCredentialAssertion)")
            }
            currentUser = .authenticated(username: username)
        case .passkeyRegistration(let authorizationPlatformPublicKeyCredentialRegistration):
            Logger.authorization.log("Passkey registration succeeded: \(authorizationPlatformPublicKeyCredentialRegistration)")
            if let username {
                currentUser = .authenticated(username: username)
            }
        // case .securityKeyAssertion(let authorizationSecurityKeyPublicKeyCredentialAssertion):
        //     <#code#>
        // case .securityKeyRegistration(let authorizationSecurityKeyPublicKeyCredentialRegistration):
        //     <#code#>
        // case .customMethod(let authorizationCustomMethod):
        //     <#code#>
        default:
            Logger.authorization.error("Received an unknown authorization result.")
            throw AuthorizationHandlingError.unknownAuthorizationResult(authorizationResult)
        }
    }
}

#endif

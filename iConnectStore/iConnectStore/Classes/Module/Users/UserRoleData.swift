//
//  UserRoleData.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/9.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Foundation
import PromiseKit

class UserRoleData: ConnectDataManager {
    
    func listAllUsers() -> Promise<[User]> {
        
        let p = Promise<[User]> { resolver in
            
            let endpoint = APIEndpoint.users()
            provider!.request(endpoint) {
                switch $0 {
                case .success(let response):
                    let users = response.data as [User]
                    resolver.fulfill(users)
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong list users: \(error)")
                }
            }
        }
        
        return p
    }
    
    func listAllUserInvitations() -> Promise<[UserInvitation]> {
        
        let p = Promise<[UserInvitation]> { resolver in
            
            let endpoint = APIEndpoint.invitedUsers()
            provider!.request(endpoint) {
                switch $0 {
                case .success(let response):
                    let invitedUsers = response.data as [UserInvitation]
                    resolver.fulfill(invitedUsers)
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong list userInvitations: \(error)")
                }
            }
        }
        
        return p
    }
    
    func listAllApps() -> Promise<[App]> {
        
        let p = Promise<[App]> { resolver in
            
            let endpoint = APIEndpoint.apps()
            provider!.request(endpoint) {
                switch $0 {
                case .success(let response):
                    let users = response.data as [App]
                    resolver.fulfill(users)
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong list Apps: \(error)")
                }
            }
        }
        
        return p
    }
    
    func listUserApps(userId: String) -> Promise<[App]> {
        
        let p = Promise<[App]> { resolver in
            
            let endpoint = APIEndpoint.apps(visibleToUserWithId: userId)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let response):
                    let users = response.data as [App]
                    resolver.fulfill(users)
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong list apps to user: \(error)")
                }
            }
        }
        
        return p
    }
    
    func modifyUserAccount(userWithId id: String,
                           allAppsVisible: Bool? = nil,
                           provisioningAllowed: Bool? = nil,
                           roles: [UserRole]? = nil,
                           appsVisibleIds: [String]? = nil) -> Promise<User> {
        
        let p = Promise<User> { resolver in
            
            let endpoint = APIEndpoint.modify(userWithId: id, allAppsVisible:allAppsVisible, provisioningAllowed:provisioningAllowed, roles:roles, appsVisibleIds:appsVisibleIds)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let response):
                    let users = response.data as User
                    resolver.fulfill(users)
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong modifyUserAccount: \(error)")
                }
            }
        }
        
        return p
    }
    
    func inviteUser(email: String,
                    firstName: String,
                    lastName: String,
                    allAppsVisible: Bool,
                    provisioningAllowed: Bool,
                    roles: [UserRole],
                    appsVisibleIds: [String]) -> Promise<UserInvitation> {
        
        let p = Promise<UserInvitation> { resolver in
            
            let endpoint = APIEndpoint.invite(userWithEmail: email, firstName: firstName, lastName: lastName, roles: roles, allAppsVisible: allAppsVisible, provisioningAllowed: provisioningAllowed, appsVisibleIds: appsVisibleIds)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let response):
                    let users = response.data as UserInvitation
                    resolver.fulfill(users)
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong inviteUser: \(error)")
                }
            }
        }
        
        return p
    }
    
    func deleteInviteUser(id: String) -> Promise<Bool> {
        
        let p = Promise<Bool> { resolver in
            
            let endpoint = APIEndpoint.cancel(userInvitationWithId: id)
            provider!.request(endpoint) {
                switch $0 {
                case .success(_):
                    resolver.fulfill(true)
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong deleteInviteUser: \(error)")
                }
            }
        }
        
        return p
    }
}

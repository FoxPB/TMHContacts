//
//  User.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 13/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation

class Usuario {
    
    var email: String
    var nome: String
    var userId: String
    
    init(email: String, nome: String, userId: String ) {
        self.email = email
        self.nome = nome
        self.userId = userId
    }
}

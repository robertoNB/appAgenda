//
//  Agenda.swift
//  AppAgenda
//
//  Created by HP on 5/8/20.
//  Copyright © 2020 HP. All rights reserved.
//

import Foundation
class Agenda{
    var idAge : String
    var temaAge: String
    var tituloAge: String
    var notaAge: String
    init (idAgenda: String, tituloAgenda: String,temaAgenda: String, notaAgenda:String){
        self.idAge = idAgenda
        self.temaAge = temaAgenda
        self.tituloAge = tituloAgenda
        self.notaAge = notaAgenda
    }
    
}

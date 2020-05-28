//
//  ViewController.swift
//  AppAgenda
//
//  Created by HP on 4/23/20.
//  Copyright © 2020 HP. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
    var db : OpaquePointer?
    var Agendas = [Agenda]()
    
    let dataJsonUrlClass = JsonClass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) .appendingPathComponent("BDSQLiteAgendas.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            showAlerta(Titulo: "Error", Mensaje: "Nose pudo abrir la base de datos")
            return
        }
        let createTable = "CREATE TABLE  IF NOT EXISTS agenda(idAgenda INTEGER PRIMARY KEY autoincrement, titulo TEXT, nomTema TEXT, nota TEXT)"
        if sqlite3_exec(db, createTable, nil, nil, nil) != SQLITE_OK{
            showAlerta(Titulo: "Error", Mensaje: "No se pudo crear la tabla")
            return
            
        }
        //showAlerta(Titulo: "Creacion Base de Datos", Mensaje: "DB Creada")
        
    }
    
//---------------------------Tarea-------------------------------------------
    @IBAction func btnTarea(_ sender: UIButton)
    {
        Agendas.removeAll()
        let query = "select * from agenda where nomTema = 'Tarea' "
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK{
            let error = String (cString: sqlite3_errmsg(db)!)
            showAlerta(Titulo: "Error", mensaje: "Error en la BD: \(error)")
            return
            
        }
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            let idAg = sqlite3_column_int(stmt, 0)
            let tit = String (cString: sqlite3_column_text(stmt, 1))
            let nomT = String (cString: sqlite3_column_text(stmt, 2))
            let not = String (cString: sqlite3_column_text(stmt, 3))
            Agendas.append(Agenda(idAgenda: String (idAg), tituloAgenda: tit, temaAgenda: nomT, notaAgenda: not))
        }
        //-------------------------------web service---------------------------------------------------
        Agendas.removeAll()
        let datos_a_enviar = ["id": ""] as NSMutableDictionary
        
        //ejecutamos la función arrayFromJson con los parámetros correspondientes (url archivo .php / datos a enviar)
        
        dataJsonUrlClass.arrayFromJson(url:"/getTare.php",datos_enviados:datos_a_enviar){ (array_respuesta) in
            
            DispatchQueue.main.async {//proceso principal
                
                /*
                 recibimos un array de tipo:
                 (
                 [0] => Array
                 (
                 [success] => 200
                 [message] => Producto encontrado
                 [idProd] => 1
                 [nomProd] => Desarmador plus
                 [existencia] => 10
                 [precio] => 80
                 )
                 )
                 object(at: 0) as! NSDictionary -> indica que el elemento 0 de nuestro array lo vamos a convertir en un diccionario de datos.
                 */
                let cuenta = array_respuesta?.count
                
                for indice in stride(from: 0, to: cuenta!, by: 1){
                    let tarea = array_respuesta?.object(at: indice) as! NSDictionary
                    let idAgenda = tarea.object(forKey: "idAgenda") as! String?
                    let titulo = tarea.object(forKey: "titulo") as! String?
                    let nota = tarea.object(forKey: "nota") as! String?
                    let nomTema = tarea.object(forKey: "nomTema") as! String?
                    self.Agendas.append(Agenda(idAgenda: idAgenda!, tituloAgenda: titulo!, temaAgenda: nomTema!, notaAgenda: nota!))
                    //.append(Producto(idProd: idprod, nomProd: nomprod, Existencia: existe, Precio: pre) )
                }
                self.performSegue(withIdentifier: "segueTarea", sender: self)
            }
        }
        
        self.performSegue(withIdentifier: "segueTarea", sender: self)
    }
    //-------------------------------Deporte------------------------------
    @IBAction func btnDeporte(_ sender: UIButton)
    {
        Agendas.removeAll()
        let query = "select * from agenda where nomTema = 'Deporte' "
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK{
            let error = String (cString: sqlite3_errmsg(db)!)
            showAlerta(Titulo: "Error", mensaje: "Error en la BD: \(error)")
            return
            
        }
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            let idAg = sqlite3_column_int(stmt, 0)
            let tit = String (cString: sqlite3_column_text(stmt, 1))
            let nomT = String (cString: sqlite3_column_text(stmt, 2))
            let not = String (cString: sqlite3_column_text(stmt, 3))
            Agendas.append(Agenda(idAgenda: String (idAg), tituloAgenda: tit, temaAgenda: nomT, notaAgenda: not))
        }
        //-------------------------------web service---------------------------------------------------
        Agendas.removeAll()
        let datos_a_enviar = ["id": ""] as NSMutableDictionary
        
        //ejecutamos la función arrayFromJson con los parámetros correspondientes (url archivo .php / datos a enviar)
        
        dataJsonUrlClass.arrayFromJson(url:"/getDep.php",datos_enviados:datos_a_enviar){ (array_respuesta) in
            
            DispatchQueue.main.async {//proceso principal
                
                /*
                 recibimos un array de tipo:
                 (
                 [0] => Array
                 (
                 [success] => 200
                 [message] => Producto encontrado
                 [idProd] => 1
                 [nomProd] => Desarmador plus
                 [existencia] => 10
                 [precio] => 80
                 )
                 )
                 object(at: 0) as! NSDictionary -> indica que el elemento 0 de nuestro array lo vamos a convertir en un diccionario de datos.
                 */
                let cuenta = array_respuesta?.count
                
                for indice in stride(from: 0, to: cuenta!, by: 1){
                    let tarea = array_respuesta?.object(at: indice) as! NSDictionary
                    let idAgenda = tarea.object(forKey: "idAgenda") as! String?
                    let titulo = tarea.object(forKey: "titulo") as! String?
                    let nota = tarea.object(forKey: "nota") as! String?
                    let nomTema = tarea.object(forKey: "nomTema") as! String?
                    self.Agendas.append(Agenda(idAgenda: idAgenda!, tituloAgenda: titulo!, temaAgenda: nomTema!, notaAgenda: nota!))
                    //.append(Producto(idProd: idprod, nomProd: nomprod, Existencia: existe, Precio: pre) )
                }
                self.performSegue(withIdentifier: "segueDeporte", sender: self)
            }
        }
        
        
        self.performSegue(withIdentifier: "segueDeporte", sender: self)
    }
    //--------------------------Compra--------------------------------------------------
    @IBAction func btnCompra(_ sender: UIButton)
    {
        Agendas.removeAll()
        let query = "select * from agenda where nomTema = 'Compras' "
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK{
            let error = String (cString: sqlite3_errmsg(db)!)
            showAlerta(Titulo: "Error", mensaje: "Error en la BD: \(error)")
            return
            
        }
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            let idAg = sqlite3_column_int(stmt, 0)
            let tit = String (cString: sqlite3_column_text(stmt, 1))
            let nomT = String (cString: sqlite3_column_text(stmt, 2))
            let not = String (cString: sqlite3_column_text(stmt, 3))
            Agendas.append(Agenda(idAgenda: String (idAg), tituloAgenda: tit, temaAgenda: nomT, notaAgenda: not))
        }
        
        //-------------------------------web service---------------------------------------------------
        Agendas.removeAll()
        let datos_a_enviar = ["id": ""] as NSMutableDictionary
        
        //ejecutamos la función arrayFromJson con los parámetros correspondientes (url archivo .php / datos a enviar)
        
        dataJsonUrlClass.arrayFromJson(url:"/getComp.php",datos_enviados:datos_a_enviar){ (array_respuesta) in
            
            DispatchQueue.main.async {//proceso principal
                
                /*
                 recibimos un array de tipo:
                 (
                 [0] => Array
                 (
                 [success] => 200
                 [message] => Producto encontrado
                 [idProd] => 1
                 [nomProd] => Desarmador plus
                 [existencia] => 10
                 [precio] => 80
                 )
                 )
                 object(at: 0) as! NSDictionary -> indica que el elemento 0 de nuestro array lo vamos a convertir en un diccionario de datos.
                 */
                let cuenta = array_respuesta?.count
                
                for indice in stride(from: 0, to: cuenta!, by: 1){
                    let tarea = array_respuesta?.object(at: indice) as! NSDictionary
                    let idAgenda = tarea.object(forKey: "idAgenda") as! String?
                    let titulo = tarea.object(forKey: "titulo") as! String?
                    let nota = tarea.object(forKey: "nota") as! String?
                    let nomTema = tarea.object(forKey: "nomTema") as! String?
                    self.Agendas.append(Agenda(idAgenda: idAgenda!, tituloAgenda: titulo!, temaAgenda: nomTema!, notaAgenda: nota!))
                    //.append(Producto(idProd: idprod, nomProd: nomprod, Existencia: existe, Precio: pre) )
                }
                self.performSegue(withIdentifier: "segueCompra", sender: self)
            }
        }
        
        self.performSegue(withIdentifier: "segueCompra", sender: self)
    }
    //--------------------------DevCas--------------------------------
    @IBAction func btnDevCas(_ sender: UIButton)
    {
        Agendas.removeAll()
        let query = "select * from agenda where nomTema = 'Deberes Casa' "
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK{
            let error = String (cString: sqlite3_errmsg(db)!)
            showAlerta(Titulo: "Error", mensaje: "Error en la BD: \(error)")
            return
            
        }
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            let idAg = sqlite3_column_int(stmt, 0)
            let tit = String (cString: sqlite3_column_text(stmt, 1))
            let nomT = String (cString: sqlite3_column_text(stmt, 2))
            let not = String (cString: sqlite3_column_text(stmt, 3))
            Agendas.append(Agenda(idAgenda: String (idAg), tituloAgenda: tit, temaAgenda: nomT, notaAgenda: not))
        }
        //-------------------------------web service---------------------------------------------------
        Agendas.removeAll()
        let datos_a_enviar = ["id": ""] as NSMutableDictionary
        
        //ejecutamos la función arrayFromJson con los parámetros correspondientes (url archivo .php / datos a enviar)
        
        dataJsonUrlClass.arrayFromJson(url:"/getDevCas.php",datos_enviados:datos_a_enviar){ (array_respuesta) in
            
            DispatchQueue.main.async {//proceso principal
                
                /*
                 recibimos un array de tipo:
                 (
                 [0] => Array
                 (
                 [success] => 200
                 [message] => Producto encontrado
                 [idProd] => 1
                 [nomProd] => Desarmador plus
                 [existencia] => 10
                 [precio] => 80
                 )
                 )
                 object(at: 0) as! NSDictionary -> indica que el elemento 0 de nuestro array lo vamos a convertir en un diccionario de datos.
                 */
                let cuenta = array_respuesta?.count
                
                for indice in stride(from: 0, to: cuenta!, by: 1){
                    let tarea = array_respuesta?.object(at: indice) as! NSDictionary
                    let idAgenda = tarea.object(forKey: "idAgenda") as! String?
                    let titulo = tarea.object(forKey: "titulo") as! String?
                    let nota = tarea.object(forKey: "nota") as! String?
                    let nomTema = tarea.object(forKey: "nomTema") as! String?
                    self.Agendas.append(Agenda(idAgenda: idAgenda!, tituloAgenda: titulo!, temaAgenda: nomTema!, notaAgenda: nota!))
                    //.append(Producto(idProd: idprod, nomProd: nomprod, Existencia: existe, Precio: pre) )
                }
                self.performSegue(withIdentifier: "segueDevCas", sender: self)
            }
        }
        self.performSegue(withIdentifier: "segueDevCas", sender: self)
    }
    //--------------------------btnRegistro----------------------------
    @IBAction func btnRegistro(_ sender: UIButton)
    {
        self.performSegue(withIdentifier: "segueAgregar", sender: self)
        //segueHome
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueTarea")
        {
            let Lista = segue.destination as! TableViewControllerTarea
            Lista.Agendas = Agendas
        }
        
        if (segue.identifier == "segueDeporte")
        {
            let deporte = segue.destination as! TableViewControllerDeporte
            deporte.Agendas = Agendas
        }
        if (segue.identifier == "segueCompra")
        {
            let compra = segue.destination as! TableViewControllerCompra
            compra.Agendas = Agendas
        }
        if (segue.identifier == "segueDevCas")
        {
            let devcas = segue.destination as! TableViewControllerDevcas
            
            devcas.Agendas = Agendas
        }
        
    }
    
    func showAlerta(Titulo: String, mensaje: String)
    {
        // crear alerta
        let alert = UIAlertController(title: Titulo, message: mensaje, preferredStyle: UIAlertController.Style.alert)
        //Agregar boton
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler: nil))
        //mensaje de alerta
        self.present(alert, animated: true, completion: nil)
        
    }
    func showAlerta (Titulo: String, Mensaje: String)
    {
        //crea un alerta
        let alert = UIAlertController(title: Titulo, message: Mensaje, preferredStyle: UIAlertController.Style.alert)
        //agreaga un boton
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler: nil))
        //Muestra la alerta
        self.present(alert, animated: true, completion: nil)
        
    }
        

}


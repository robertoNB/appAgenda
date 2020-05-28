//
//  ViewControllerEdit.swift
//  AppAgenda
//
//  Created by HP on 5/22/20.
//  Copyright © 2020 HP. All rights reserved.
//

import UIKit
import SQLite3
class ViewControllerEdit: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource
{
    
    var db : OpaquePointer?
    var Agendas = [Agenda]()
    
    let dataJsonUrlClass = JsonClass()
    
    var vcEdit: Agenda?
    @IBOutlet weak var txtIdAgenda: UITextField!
    @IBOutlet weak var txtTema: UITextField!
    @IBOutlet weak var txtTitulo: UITextField!
    @IBOutlet weak var txtNota: UITextView!
    
    let Temas = ["Tarea","Deporte","Compra","Deveres Casa"]
    
    let pickerView = UIPickerView()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //---------rellema ----------------------------
        txtIdAgenda.text = vcEdit?.idAge
        txtTitulo.text = vcEdit?.tituloAge
        txtTema.text = vcEdit?.temaAge
        txtNota.text = vcEdit?.notaAge
        
        //--------------------dropdown---------------------------------
        pickerView.delegate = self
        pickerView.dataSource = self
        
        txtTema.inputView = pickerView
        txtTema.textAlignment = .center
        txtTema.placeholder = "Select of Tema"
        
        //-----------------------sqlite----------------------------------
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
        showAlerta(Titulo: "Creacion Base de Datos", Mensaje: "DB Creada")
    }
    
    @IBAction func btnEdita(_ sender: UIButton)
    {
        //----------------------------sqlite---------------------------------
        if txtTitulo.text!.isEmpty || txtTema.text!.isEmpty || txtNota.text!.isEmpty || txtIdAgenda.text!.isEmpty
        {
            let alertView = UIAlertController(title:"Faltandatos ",message: "completar", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alertView,animated: true,completion: nil)
            txtTitulo.becomeFirstResponder()
        }else
        {
            let tit = txtTitulo.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            let tem = txtTema.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            let not = txtNota.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            let idAg = txtIdAgenda.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            
            var stmt: OpaquePointer?
            let sentencia = "UPDATE agenda SET titulo=?,nomTema=?,nota=? WHERE idAgenda=? "
            
            if sqlite3_prepare(db, sentencia, -1, &stmt, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "Error al lugar sentencia")
                return
            }
            if sqlite3_bind_text(stmt, 1, tit.utf8String, -1, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "En el 1er parametro titulo")
                return
            }
            if sqlite3_bind_text(stmt, 2, tem.utf8String, -1, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "En el 2do parametro Tema")
                return
            }
            if sqlite3_bind_text(stmt, 3, not.utf8String, -1, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "En el 3er parametro nota")
                return
            }
            
            if sqlite3_bind_int(stmt, 4, (idAg as NSString).intValue) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "En el 1 er parametro cve")
                return
            }
            if sqlite3_step(stmt) == SQLITE_DONE{
                showAlerta(Titulo: "Actualizando", Mensaje: "Agenda actualizada en la DB")
            }else{
                showAlerta(Titulo: "Error", Mensaje: "Agenda no actualizada")
                return
            }
            txtNota.text = ""
            txtTema.text = ""
            txtTitulo.text = ""
            txtIdAgenda.text = ""
            self.performSegue(withIdentifier: "segueHome", sender: self)
            
        }//else
        //----------------------------web sevice-----------------------------
        if txtIdAgenda.text!.isEmpty || txtTitulo.text!.isEmpty || txtTema.text!.isEmpty || txtNota.text!.isEmpty
        {
            showAlerta(Titulo: "Validacion de Entrada", Mensaje: "Error faltan de ingresar datos")
            txtIdAgenda.becomeFirstResponder()
            return
        }else
        {
            let idAg = txtIdAgenda.text!
            let tit = txtTitulo.text!
            let tem = txtTema.text!
            let not = txtNota.text!
            
            let datos_a_enviar = ["idAgenda":idAg, "titulo": tit,"nomTema":tem,"nota":not] as NSMutableDictionary
            
            dataJsonUrlClass.arrayFromJson(url:"/updateAgenda.php",datos_enviados:datos_a_enviar){ (array_respuesta) in
                
                DispatchQueue.main.async {//proceso principal
                    
                    
                    let diccionario_datos = array_respuesta?.object(at: 0) as! NSDictionary
                    
                    //ahora ya podemos acceder a cada valor por medio de su key "forKey"
                    if let msg = diccionario_datos.object(forKey: "message") as! String?{
                        self.showAlerta(Titulo: "Guardando", Mensaje: msg)
                    }
                    
                    self.txtIdAgenda.text=""
                    self.txtTitulo.text = ""
                    self.txtTema.text = ""
                    self.txtNota.text = ""
                }
            }
        }
        
        self.performSegue(withIdentifier: "segueHome", sender: self)
    }
    @IBAction func btnElimina(_ sender: UIButton)
    {
        //----------------------------sqlite---------------------------------
        if (txtIdAgenda.text?.isEmpty)! {
            let alertView = UIAlertController(title:"Faltandatos ",message: "completar", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alertView,animated: true,completion: nil)
            txtIdAgenda.becomeFirstResponder()
        }else
        {
            let idAg = txtIdAgenda.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! NSString
            
            var stmt: OpaquePointer?
            let sentencia = "DELETE FROM agenda WHERE idAgenda= ?"
            
            if sqlite3_prepare(db, sentencia, -1, &stmt, nil) != SQLITE_OK{
                showAlerta(Titulo: "Error", Mensaje: "Error al lugar sentencia")
                return
            }
            if sqlite3_bind_int(stmt, 1, (idAg as NSString).intValue) != SQLITE_OK
            {
                showAlerta(Titulo: "Error", Mensaje: "En el 1 er parametro cve")
                return
            }
            if sqlite3_step(stmt) == SQLITE_DONE{
                showAlerta(Titulo: "Eliminando", Mensaje: "Agenda Elimindada de la DB")
            }else{
                showAlerta(Titulo: "Error", Mensaje: "Agenda no Eliminada")
                return
            }
            
            txtNota.text = ""
            txtTema.text = ""
            txtTitulo.text = ""
            txtIdAgenda.text = ""
           self.performSegue(withIdentifier: "segueHome", sender: self)
            
        }//else
        //----------------------------web sevice-----------------------------
        
        if txtIdAgenda.text!.isEmpty{
            showAlerta(Titulo: "Validacion de Entrada", Mensaje: "Error faltan de ingresar datos")
            txtIdAgenda.becomeFirstResponder()
            return
        }
        else
        {
            let idAg = txtIdAgenda.text!
            
            //Creamos un array (diccionario) de datos para ser enviados en la petición hacia el servidor remoto, aqui pueden existir N cantidad de valores
            let datos_a_enviar = ["idAgenda":idAg] as NSMutableDictionary
            
            //ejecutamos la función arrayFromJson con los parámetros correspondientes (url archivo .php / datos a enviar)
            
            dataJsonUrlClass.arrayFromJson(url:"/deleteAgenda.php",datos_enviados:datos_a_enviar){ (array_respuesta) in
                
                DispatchQueue.main.async
                    {//proceso principal
                        
                        /*
                         recibimos un array de tipo:
                         (
                         [0] => Array
                         (
                         [success] => 200
                         [message] => Producto Actualizado
                         )
                         )
                         object(at: 0) as! NSDictionary -> indica que el elemento 0 de nuestro array lo vamos a convertir en un diccionario de datos.
                         */
                        let diccionario_datos = array_respuesta?.object(at: 0) as! NSDictionary
                        
                        //ahora ya podemos acceder a cada valor por medio de su key "forKey"
                        if let msg = diccionario_datos.object(forKey: "message") as! String?
                        {
                            
                            self.showAlerta(Titulo: "Eliminando", Mensaje: msg)
                            
                        }
                        
                        self.txtIdAgenda.text = ""
                        self.txtTitulo.text = ""
                        self.txtTema.text = ""
                        self.txtNota.text = ""
                        
                }
            }
        }//rlse
        
        self.performSegue(withIdentifier: "segueHome", sender: self)
    }
    
    
func showAlerta(Titulo: String, Mensaje: String )
{
    // Crea la alerta
    let alert = UIAlertController(title: Titulo, message: Mensaje, preferredStyle: UIAlertController.Style.alert)
    // Agrega un boton
    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler: nil))
    // Muestra la alerta
    self.present(alert, animated: true, completion: nil)
}
    
    //-----------------------------dropdown-----------------------------------------
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return Temas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Temas[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        txtTema.text = Temas[row]
        txtTema.resignFirstResponder()
    }
    
}//clase

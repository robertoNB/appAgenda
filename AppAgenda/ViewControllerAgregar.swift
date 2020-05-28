//
//  ViewControllerAgregar.swift
//  AppAgenda
//
//  Created by HP on 5/7/20.
//  Copyright © 2020 HP. All rights reserved.
//

import UIKit
import SQLite3
class ViewControllerAgregar: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource  {
    var db : OpaquePointer?
    var Agendas = [Agenda]()
    
    let dataJsonUrlClass = JsonClass()
    //--------llenado dropdown------------
    let Temas = ["Tarea","Deporte","Compras","Deberes Casa"]
    let pickerView = UIPickerView()
    
    @IBOutlet weak var txtTema: UITextField!
    @IBOutlet weak var txtTitulo:UITextField!
    @IBOutlet weak var txtNota: UITextView!
    
    @IBAction func btnGuardar(_ sender: UIButton)
    {
        //----------------------------sqlite-----------------------------
        if txtTitulo.text!.isEmpty || txtTema.text!.isEmpty || txtNota.text!.isEmpty
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
                
                var stmt: OpaquePointer?
                let sentencia = "INSERT INTO agenda(titulo,nomTema,nota) values (?,?,?)"
                if sqlite3_prepare(db, sentencia, -1, &stmt, nil) != SQLITE_OK{
                    showAlerta(Titulo: "Error", Mensaje: "Error al ligar sentencias")
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
                if sqlite3_step(stmt) == SQLITE_DONE{
                    showAlerta(Titulo: "Guardado", Mensaje: "Agenda guardada en la DB")
                }else{
                    showAlerta(Titulo: "Error", Mensaje: "Agenda no guardada")
                    return
                }
                txtNota.text = ""
                txtTema.text = ""
                txtTitulo.text = ""
                
            }//else
        //----------------------------web sevice-----------------------------
        if txtNota.text!.isEmpty || txtTema.text!.isEmpty || txtTitulo.text!.isEmpty
            
        {
            showAlerta(Titulo: "Validacion de datos", Mensaje: "Falta llenar campos")
            txtTitulo.becomeFirstResponder()
        }
        else
        {
            let Titulo = txtTitulo.text
            let Tema = txtTema.text
            let Nota = txtNota.text
            
            let datos_a_enviar = ["titulo": Titulo!,"nota": Nota,"nomTema":Tema] as NSMutableDictionary
            
            dataJsonUrlClass.arrayFromJson(url:"/insertAgenda.php",datos_enviados:datos_a_enviar){ (array_respuesta) in
                
                DispatchQueue.main.async {//proceso principal
                    
                    /*
                     recibimos un array de tipo:
                     (
                     [0] => Array
                     (
                     [success] => 200
                     [message] => Producto Insertado
                     )
                     )
                     object(at: 0) as! NSDictionary -> indica que el elemento 0 de nuestro array lo vamos a convertir en un diccionario de datos.
                     */
                    let diccionario_datos = array_respuesta?.object(at: 0) as! NSDictionary
                    
                    //ahora ya podemos acceder a cada valor por medio de su key "forKey"
                    if let msg = diccionario_datos.object(forKey: "message") as! String?
                    {
                        self.showAlerta(Titulo: "Guardando", Mensaje: msg)
                    }
                    self.txtTitulo.text = ""
                    self.txtTema.text = ""
                    self.txtNota.text = ""
                }
            }
            
        }//else
        self.performSegue(withIdentifier: "segueHome", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        //showAlerta(Titulo: "Creacion Base de Datos", Mensaje: "DB Creada")
        
        
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
    

}

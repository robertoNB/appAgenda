//
//  TableViewControllerDeporte.swift
//  AppAgenda
//
//  Created by HP on 5/7/20.
//  Copyright © 2020 HP. All rights reserved.
//

import UIKit

class TableViewControllerDeporte: UITableViewController {
    var Agendas = [Agenda]()
    @IBOutlet var Tabla: UITableView!
    
    var agEdit : Agenda?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tabla.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Agendas.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda") as! TableViewCellDeporte
        let cte : Agenda
        cte = Agendas[indexPath.row]
        
        cell.lblTitulo.text = String(cte.tituloAge)
        cell.lblSubTitle.text = String(cte.notaAge)
        // Configure the cell...
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        agEdit = Agendas[indexPath.row]
        self.performSegue(withIdentifier: "segueEditar", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditar"{
            let vce = segue.destination as! ViewControllerEdit
            vce.vcEdit = self.agEdit
        }
    }


}

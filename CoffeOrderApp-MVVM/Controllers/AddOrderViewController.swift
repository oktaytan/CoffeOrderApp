//
//  AddOrderViewController.swift
//  CoffeOrderApp-MVVM
//
//  Created by Oktay Tanrıkulu on 25.11.2020.
//

import UIKit

protocol AddCoffeeOrderDelegate {
    func addCoffeeOrderViewControllerDidSave(order: Order, controller: UIViewController)
}

final class AddOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: AddCoffeeOrderDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    private var vm = AddCoffeeOrderViewModel()
    private var coffeeSizeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.tableView.dataSource = self
        // self.tableView.delegate = self
        
        setupUI()
    }
    
    private func setupUI() {
        
        self.coffeeSizeSegmentedControl = UISegmentedControl(items: self.vm.sizes)
        self.coffeeSizeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.coffeeSizeSegmentedControl)
        self.coffeeSizeSegmentedControl.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 20).isActive = true
        self.coffeeSizeSegmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    // MARK: - Order save
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        guard let name = self.nameField.text, let email = self.emailField.text else { return }
        
        guard let selectedSize = self.coffeeSizeSegmentedControl.titleForSegment(at: self.coffeeSizeSegmentedControl.selectedSegmentIndex) else { return }
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            fatalError("Error in selecting coffee!")
        }
        
        self.vm.name = name
        self.vm.email = email
        self.vm.selectedSize = selectedSize
        self.vm.selectedType = self.vm.types[indexPath.row]
    
        WebService().load(resource: Order.create(vm: self.vm)) { result in
            
            switch result {
            case .success(let order):
                
                if let order = order, let delegate = self.delegate {
                    DispatchQueue.main.async {
                        delegate.addCoffeeOrderViewControllerDidSave(order: order, controller: self)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
            
        }
        
    }
}

// MARK: - TableView methods

extension AddOrderViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeTypeTableViewCell", for: indexPath)
        cell.textLabel?.text = self.vm.types[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

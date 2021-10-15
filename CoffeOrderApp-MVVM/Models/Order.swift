//
//  Order.swift
//  CoffeOrderApp-MVVM
//
//  Created by Oktay Tanrıkulu on 25.11.2020.
//

import Foundation

enum CoffeeType: String, Codable, CaseIterable {
    case capuccino
    case latte
    case espresso
    case cortado
}

enum CoffeeSize: String, Codable, CaseIterable {
    case small, medium, large
}

struct Order: Codable {
    let name: String
    let email: String
    let type: CoffeeType
    let size: CoffeeSize
}

extension Order {
    
    init?(_ vm: AddCoffeeOrderViewModel) {
        
        guard let name = vm.name,
              let email = vm.email,
              let size = CoffeeSize(rawValue: vm.selectedSize!.lowercased()),
              let type = CoffeeType(rawValue: vm.selectedType!.lowercased()) else {
            return nil
        }
        
        self.name = name
        self.email = email
        self.type = type
        self.size = size
    }
    
}

extension Order {
    
    static var all: Resource<[Order]> = {
        
        guard let url = URL(string: "https://guarded-retreat-82533.herokuapp.com/orders") else {
            fatalError("URL is incorrect!")
        }
        
        return Resource<[Order]>(url: url)
    }()
    
    static func create(vm: AddCoffeeOrderViewModel) -> Resource<Order?> {
        
        let order = Order(vm)
        
        guard let url = URL(string: "https://guarded-retreat-82533.herokuapp.com/orders") else {
            fatalError("URL is incorrect!")
        }
        
        guard let data = try? JSONEncoder().encode(order) else {
            fatalError("Error encoding order!")
        }
        
        var resource = Resource<Order?>(url: url)
        resource.httpMethod = .post
        resource.body = data
        
        return resource
    }
    
}

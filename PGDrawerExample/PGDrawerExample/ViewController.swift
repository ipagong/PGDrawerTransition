//
//  ViewController.swift
//  PGDrawerExample
//
//  Created by ipagong on 2017. 3. 14..
//  Copyright © 2017년 ipagong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DrawerTransitionDelegate {

    private var drawerTransition:DrawerTransition!
    private let menu = MenuViewController()
    private let button = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        
        self.button.addTarget(self, action: #selector(click), for: .touchUpInside)
        self.view.addSubview(self.button)
        
        self.drawerTransition = DrawerTransition(target: self, drawer: menu)
        self.drawerTransition.setPresentCompletion { print("present...") }
        self.drawerTransition.setDismissCompletion { print("dismiss...") }
    }

    override func viewWillAppear(_ animated: Bool) {
        let left = UIBarButtonItem(title: "MENU", style: .done, target: self, action: #selector(open))
        self.navigationItem.leftBarButtonItem = left
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.button.frame = self.view.bounds
    }
    
    func click() { button.backgroundColor = (button.backgroundColor == .red ? .blue : .red) }
    func open() { self.drawerTransition.presentDrawerViewController(animated: true) }

}


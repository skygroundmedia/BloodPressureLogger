//
//  DetailViewController.swift
//  BloodPressureLogger
//
//  Created by tommy trojan on 6/10/15.
//  Copyright (c) 2015 Chris Mendez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: BloodPressureItem? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: BloodPressureItem = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description as String
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  InputViewController.swift
//  CPEDataExample
//
//  Created by Alec Ananian on 2/1/16.
//  Copyright © 2016 Warner Bros. All rights reserved.
//

import UIKit
import CPEData

class InputViewController: UIViewController {

    @IBOutlet weak private var manifestXMLTextField: UITextField!
    @IBOutlet weak private var appDataXMLTextField: UITextField!
    @IBOutlet weak private var cpeStyleXMLTextField: UITextField!

    private var startTime: UInt64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Load XML Files"

        manifestXMLTextField.text = "https://cpe-manifest.s3.amazonaws.com/xml/urn:dece:cid:eidr-s:EE48-FE4D-B363-71AF-A3AB-G/FantasticBeasts_V1.2_Manifest.xml"
        appDataXMLTextField.text = "https://cpe-manifest.s3.amazonaws.com/xml/urn:dece:cid:eidr-s:EE48-FE4D-B363-71AF-A3AB-G/FantasticBeasts_V1.1_AppData.xml"
        cpeStyleXMLTextField.text = "https://cpe-manifest.s3.amazonaws.com/xml/urn:dece:cid:eidr-s:EE48-FE4D-B363-71AF-A3AB-G/FantasticBeasts_V1.1_style.xml"
    }

    @IBAction private func onLoad() {
        startTime = DispatchTime.now().uptimeNanoseconds

        if let manifestXMLURLString = manifestXMLTextField.text, let manifestXMLURL = URL(string: manifestXMLURLString) {
            var appDataXMLURL: URL?
            var cpeStyleXMLURL: URL?
            if let appDataXMLURLString = appDataXMLTextField.text {
                appDataXMLURL = URL(string: appDataXMLURLString)
            }

            if let cpeStyleXMLURLString = cpeStyleXMLTextField.text {
                cpeStyleXMLURL = URL(string: cpeStyleXMLURLString)
            }

            DispatchQueue.global(qos: .userInitiated).async {
                CPEXMLSuite.load(manifestXMLURL: manifestXMLURL, appDataXMLURL: appDataXMLURL, cpeStyleXMLURL: cpeStyleXMLURL) { [weak self] (error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Error parsing files", message: "\(error)", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self?.navigationController?.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.performSegue(withIdentifier: "ShowResults", sender: nil)
                        }
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Error parsing files", message: "The specified Manifest XML file could not be found.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.navigationController?.present(alertController, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultsTableViewController = segue.destination as? ResultsTableViewController {
            let endTime = DispatchTime.now().uptimeNanoseconds
            resultsTableViewController.loadTimeInSeconds = Double(endTime - startTime) / 1_000_000_000
        }
    }

}

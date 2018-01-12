//
//  tableViewController.swift
//  Doors Open Ottawa
//
//  Created by Eric Moolenbeek on 2018-01-02.
//  Copyright © 2018 Eric M. All rights reserved.
//
//  URL REQUEST:
//  "https://algonquin.instructure.com/courses/822915/pages/simple-url-request?module_item_id=14925629"
//

import UIKit

class tableViewController: UITableViewController {
    

    // Define an optionl object to store the JSON response data.  In this case the buildings JSON data has an array of dictionaries
    var jsonObjects: [[String:Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update navbar title to show loading status
        self.title = "Loading"
        
        // Define the url that you want to send a request to
        let requestUrl: URL = URL(string: "https://doors-open-ottawa.mybluemix.net/buildings")!
        
        // Create the request object and pass in your url
        let myRequest: URLRequest = URLRequest(url: requestUrl)
        
        // Create the URLSession object that will make the request
        let mySession: URLSession = URLSession.shared
        
        // Make the specific task from the session by passing in your request, and the function that will be use to handle the request
        let myTask = mySession.dataTask(with: myRequest, completionHandler: requestTask )
        
        // Tell the task to run
        myTask.resume()
    }
    
    // Define a function that will handle the request which will need to recieve the data send back, the respinse status, and an error object to handle any errors returned
    func requestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        // If the error object has been set then an error occured
        if serverError != nil {
            
            // Send en empty string as the data, and the error to the callback function
            self.myCallback("", error: serverError?.localizedDescription)
            
        }else{
            // If no error was generated then the server responce has been recieved
            // Stringify the response data
            let result = String(data: serverData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            // Send the response string data, and nil for the error tot he callback
            self.myCallback(result, error: nil)
            
        }
    }
    
    // Define the callback function to be triggered when the response is received
    func myCallback(_ responseString: String, error: String?) {
        
        // If the server request generated an error then handle it
        if error != nil {
            print("DATA LIST LOADING ERROR: " + error!)
        }else{
            // Else take the data recieved from the server and process it
            print("DATA RECEIVED: " + responseString)
            
            // Take the response string and turn it back into raw data
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    // Try to convert response data into a JSON dictionary to be saved into the optional dictionary
                    jsonObjects = try JSONSerialization.jsonObject(with: myData, options: []) as? [[String:Any]]
                    
                } catch let convertError {
                    // If converting the string back into data fails catch the error info
                    print(convertError.localizedDescription)
                }
            }
            
            // UI updates need to be made on the main thread
            DispatchQueue.main.async {
                // Update the tableView with the data in the JSON dictionary
                self.tableView!.reloadData()
                // Update navbar title to show loading is done
                self.title = "Buildings"
            }
        }
    }

    // TABLE VIEW SETUP
    // Create a table cell for each item in the array if it is not nil, otherwise return 0
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var cellCount = 0
        
        // Use optional binding to return the count of the jsonObjects array
        if let jsonObj = jsonObjects {
            cellCount = jsonObj.count
        }
        return cellCount
    }

    // For each dictionary in the JSON array add the info to each table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        // Use optional binding to access the JSON dictionary if it exists
        if let jsonObj = jsonObjects{
            
            // For the current tableCell row get the corresponding building's dictionary of info
            let dictionaryRow = jsonObj[indexPath.row] as [String:Any]
            
            // Get the name and overview for the current building
            let name = dictionaryRow["nameEN"] as? String
            let overview = dictionaryRow["addressEN"] as? String
            
            // Add the name and overview to the cell's textLabel
            cell.textLabel?.text = name! + " - " + overview!
        }
        return cell
    }
    
    // Pass the current building id to the next view when a cell is clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSecondView" {
            // Get a reference to the next viewController class
            let nextVC = segue.destination as? ViewController
            
            // Get a reference to the cell that was clicked
            let thisCell = sender as? UITableViewCell
            
            // Set the buildingId value of the next viewController
            let buildingID = tableView.indexPath(for: thisCell!)!.row
            
            // Use optional binding to access the JSON dictionary if it exists
            if let jsonObj = jsonObjects{
                nextVC?.jsonObj = jsonObj[buildingID] as [String:Any]
            }
        }
    }
}

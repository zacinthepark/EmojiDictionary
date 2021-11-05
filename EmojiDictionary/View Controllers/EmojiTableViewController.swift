//
//  EmojiTableViewController.swift
//  EmojiDictionary
//
//  Created by zac on 2021/10/15.
//

import UIKit

class EmojiTableViewController: UITableViewController {
    var emojis: [Emoji] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.leftBarButtonItem = editButtonItem
        //This tells the table view that it needs to calculate the cell height
        tableView.rowHeight = UITableView.automaticDimension
        //Gives a sensible estimation for how tall the average cell will be (this improves performance!)
        tableView.estimatedRowHeight = 44.0
        
        //Load!!
        if Emoji.loadFromFile().count > 0 {
            emojis = Emoji.loadFromFile()
        } else {
            emojis = Emoji.loadSampleEmojis()
        }
    }
    
    //UITableView에서는 수동으로 edit button 만들어 IBAction 연결
    /*Example 1
     @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        let tableViewEditingMode = tableView.isEditing
        tableView.setEditing(!tableViewEditingMode, animated: true)
     }
     */
    /*Example 2
     @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if !tableView.isEditing {
            sender.title = "Edit"
            tableView.setEditing(true, animated: true)
        } else {
            sender.title = "Done"
            tableView.setEditing(false, animated: true)
     }
     */

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return emojis.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Step 1: Dequeue cell
        //EmojiCell이라는 cell type의 cell을 주고
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell
        //Step 2: Fetch model object to display
        //cell 넣을 데이터 모델 인스턴스를 정의하고
        let emoji = emojis[indexPath.row]
        
        //Step 3: Configure cell
        //가져온 cell에 해당 데이터를 configure
        cell.update(with: emoji)
        //moveRowAt을 구현해야 Editing Mode에서 드러남
        cell.showsReorderControl = true
        
        //Step 4: Return cell
        return cell
    }
    
    //Reorder Cells
    //moveRowAt 추가 시 editing mode에서 table cell을 옮길 수 있음, 내부 코드에서 옮길 데이터 관련 코드 작성
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedEmoji = emojis.remove(at: sourceIndexPath.row)
        emojis.insert(movedEmoji, at: destinationIndexPath.row)
        Emoji.saveToFile(emojis: emojis)
        tableView.reloadData()
    }
    
    //Delete Cells
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //데이터 삭제
            emojis.remove(at: indexPath.row)
            Emoji.saveToFile(emojis: emojis)
            //테이블에서 삭제
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    //Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEmoji" {
            //전달할 Object 정의
            let indexPath = tableView.indexPathForSelectedRow!
            let emoji = emojis[indexPath.row]
            //Destination VC 정의
            let navController = segue.destination as! UINavigationController
            let addEditEmojiTableViewController = navController.topViewController as! AddEditEmojiTableViewController
            //Object 전달
            addEditEmojiTableViewController.emoji = emoji
        }
    }
    
    @IBAction func unwindToEmojiTableView(segue: UIStoryboardSegue) {
        //Segue 정의
        guard segue.identifier == "saveUnwind" else {return}
        
        //해당 Segue의 Source VC 정의
        let sourceViewController = segue.source as! AddEditEmojiTableViewController
        
        if let emoji = sourceViewController.emoji {
            //만약 add가 아닌 셀 선택을 통해 edit하고자 했으면 indexPathForSelectedRow가 남아있을 것
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //해당 셀에 새로운 정보를 넣어주고
                emojis[selectedIndexPath.row] = emoji
                Emoji.saveToFile(emojis: emojis)
                //그 새로운 정보를 해당 셀이 보여주도록 reload
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: emojis.count, section: 0)
                emojis.append(emoji)
                Emoji.saveToFile(emojis: emojis)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}

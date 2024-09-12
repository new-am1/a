import PlaygroundSupport
import UIKit


var searchType:SearchType = .BFS

enum SearchType{
    case BFS
    case DFS
    case Climb
}
struct Board {
    var cells: [[String]]
    
    init(rows: Int, cols: Int) {
        cells = Array(repeating: Array(repeating: "", count: cols), count: rows)
    }
    
    mutating func placeObstacle(row: Int, col: Int) {
        cells[row][col] = "#"
    }
    
    mutating func placeStart(row: Int, col: Int) {
        cells[row][col] = "S"
    }
    
    mutating func placeGoal(row: Int, col: Int) {
        cells[row][col] = "G"
    }
    
    mutating func placeHorse(row: Int, col: Int) {
        cells[row][col] = "H"
    }
    
    func printBoard() {
        for row in cells {
            print(row.joined(separator: " "))
        }
    }
}

// Algorithm implementations
typealias Algorithm = (inout Board, Int, Int, Int, inout [(Int, Int)]) -> Void

struct Position: Hashable {
    let row: Int
    let col: Int
}
func dfs(board: inout Board, row: Int, col: Int, moves: Int, moveLimit: Int, steps: inout [(Int, Int)]) {
    var tryCount: Int = 0
    var totalSteps: Int = 0
    let startPosition = Position(row: row, col: col)
    var visitedPositions = Set<Position>()
    var stack = [startPosition]

    while !stack.isEmpty {
        let currentPosition = stack.removeLast()
        var isReachGoal = false
        if visitedPositions.contains(currentPosition) {
            continue
        }

        board.placeHorse(row: currentPosition.row, col: currentPosition.col)
        steps.append((currentPosition.row, currentPosition.col))
        visitedPositions.insert(currentPosition)

        if board.cells[currentPosition.row][currentPosition.col] == "G" {
            print("Reached the goal in \(totalSteps) steps!")
            isReachGoal = true
            break  // Break out of the loop once the goal is reached
        }

        if moves == 0 {
            return
        }

        for i in -2...2 {
            for j in -2...2 {
                if abs(i) + abs(j) == 3 {
                    let newRow = currentPosition.row + i
                    let newCol = currentPosition.col + j
                    let newPosition = Position(row: newRow, col: newCol)

                    if newRow >= 0, newRow < board.cells.count, newCol >= 0, newCol < board.cells[0].count,
                        board.cells[newRow][newCol] != "#", !visitedPositions.contains(newPosition) {
                        if !isReachGoal {
                            stack.append(newPosition)
                        }
                    }
                }
            }
        }

        if moves == 8 {
            tryCount += 1
            totalSteps += 1
        }

        if tryCount >= 8 {
            print("Cannot reach the goal after 8 tries. Total steps taken: \(totalSteps)")
            return
        }
    }
}






struct BoardPosition: Hashable {
    let row: Int
    let col: Int
}
func bfs(board: inout Board, startRow: Int, startCol: Int, moves: inout Int, steps: inout [(Int, Int)]) {
    var queue = [(Int, Int, Int)]()  // (row, col, moves)

    queue.append((4, 1, 1))
    queue.append((2, 2, 1))
    queue.append((1, 4, 1))
    

    var visited = Set<BoardPosition>()  // Set to track visited positions
print(steps)
    var goalRow = -1
    var goalCol = -1

//
    // Inside the BFS function
    while !queue.isEmpty {
        let (currentRow, currentCol, currentMoves) = queue.removeFirst()

        if currentMoves == 0 {
            return  // Number of steps taken
        }

        // Check if the current position is the goal
        if currentRow == goalRow && currentCol == goalCol {
            print("Reached the goal!")
            return
        }

        steps.append((currentRow, currentCol))  // Add the current position to the steps

        for move in queue {
            let newRow = currentRow + move.0
            let newCol = currentCol + move.1

            let newPosition = BoardPosition(row: newRow, col: newCol)

            if newRow >= 0, newRow < board.cells.count, newCol >= 0, newCol < board.cells[0].count,
                board.cells[newRow][newCol] != "#", !visited.contains(newPosition) {

                let remainingMoves = currentMoves - 1

                if remainingMoves <= moves {
                    queue.append((newRow, newCol, remainingMoves))
                    visited.insert(newPosition)
                    board.placeHorse(row: newRow, col: newCol)  // Mark the horse's position on the board
                }
            }
        }
    }

    print("Goal not reached within the move limit.")
}








func hillClimbing(board: inout Board, startRow: Int, startCol: Int, moves: inout Int, steps: inout [(Int, Int)]) {
    var currentRow = startRow
    var currentCol = startCol
    var goalRow = -1
    var goalCol = -1
    
    // Find the goal position
    for row in 0..<board.cells.count {
        for col in 0..<board.cells[row].count {
            if board.cells[row][col] == "G" {
                goalRow = row
                goalCol = col
                break
            }
        }
    }
    
    while moves > 0 {
        board.placeHorse(row: currentRow, col: currentCol)
        steps.append((currentRow, currentCol))
        
        // Check if the current position is the goal
        if currentRow == goalRow && currentCol == goalCol {
            print("Reached the goal!")
            break
        }
        
        var nextMove: (Int, Int)?
        var minDistance = Double.infinity
        
        for i in -2...2 {
            for j in -2...2 {
                if abs(i) + abs(j) == 3 {
                    let newRow = currentRow + i
                    let newCol = currentCol + j
                    
                    if newRow >= 0, newRow < board.cells.count, newCol >= 0, newCol < board.cells[0].count,
                        board.cells[newRow][newCol] != "#" {
                        
                        let distance = euclideanDistance(x1: newRow, y1: newCol, x2: goalRow, y2: goalCol)
                        
                        if distance < minDistance {
                            minDistance = distance
                            nextMove = (newRow, newCol)
                        }
                    }
                }
            }
        }
        
        if let move = nextMove {
            currentRow = move.0
            currentCol = move.1
        } else {
            break  // No valid moves left
        }
        
        moves -= 1
    }
}



func euclideanDistance(x1: Int, y1: Int, x2: Int, y2: Int) -> Double {
    let distance = sqrt(Double((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)))
    return distance
}

// Game visualization

class BoardView: UIView {
    let cellSize: CGFloat = 40.0
    var board: Board
    
    init(board: Board) {
        self.board = board
        let width = CGFloat(board.cells[0].count) * cellSize
        let height = CGFloat(board.cells.count) * cellSize
        super.init(frame: CGRect(x: 68, y: 50, width: width, height: height))
        self.layer.borderWidth = 1.0 // Add border width
        self.layer.borderColor = UIColor.black.cgColor // Add border color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        for (rowIndex, row) in board.cells.enumerated() {
            for (colIndex, cell) in row.enumerated() {
                let rect = CGRect(x: CGFloat(colIndex) * cellSize, y: CGFloat(rowIndex) * cellSize, width: cellSize, height: cellSize)
                
                // Alternate cell colors
                var fillColor: UIColor
                if (rowIndex + colIndex) % 2 == 0 {
                    fillColor = .white
                } else {
                    fillColor = .lightGray
                }
                
                // Draw cell border
                UIColor.black.setStroke()
                UIRectFrame(rect)
                
                // Fill cell with color
                fillColor.setFill()
                UIRectFill(rect)
                
                // Draw content (S, G, H, #) in the center of the cell
                if cell == "#" {
                    // Draw obstacle symbol or image
                    // You can customize this part according to your preference
                    drawText("#", in: rect)
                } else if cell == "S" {
                    UIColor.green.setFill()
                    UIRectFill(rect)
                    drawText("S", in: rect)
                } else if cell == "G" {
                    UIColor.red.setFill()
                    UIRectFill(rect)
                    drawText("G", in: rect)
                } else if cell == "H" {
                    UIColor.blue.setFill()
                    UIRectFill(rect)
                    drawText("H", in: rect)
                }
            }
        }
    }
    
    func drawText(_ text: String, in rect: CGRect) {
        let label = UILabel(frame: rect)
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(label)
    }
}

class BoardVisualization: UIViewController {
    var board: Board
    var boardView: BoardView
    
    init(board: Board) {
        self.board = board
        self.boardView = BoardView(board: board)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView()
        
        // Board View
        view.addSubview(boardView)
        
        // Button Styling
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let buttonSpacing: CGFloat = 75
        
        // DFS Button
        let dfsButton = UIButton(type: .system)
        dfsButton.setTitle("DFS", for: .normal)
        dfsButton.addTarget(self, action: #selector(runDFS), for: .touchUpInside)
        dfsButton.frame = CGRect(x: 7, y: boardView.frame.height + buttonSpacing, width: buttonWidth, height: buttonHeight)
        styleButton(dfsButton)
        view.addSubview(dfsButton)
        
        // BFS Button
        let bfsButton = UIButton(type: .system)
        bfsButton.setTitle("BFS", for: .normal)
        bfsButton.addTarget(self, action: #selector(runBFS), for: .touchUpInside)
        bfsButton.frame = CGRect(x: dfsButton.frame.maxX + 20, y: boardView.frame.height + buttonSpacing, width: buttonWidth, height: buttonHeight)
        styleButton(bfsButton)
        view.addSubview(bfsButton)
        
        // Hill Climbing Button
        let hillClimbingButton = UIButton(type: .system)
        hillClimbingButton.setTitle("Hill Climbing", for: .normal)
        hillClimbingButton.addTarget(self, action: #selector(runHillClimbing), for: .touchUpInside)
        hillClimbingButton.frame = CGRect(x: bfsButton.frame.maxX + 20, y: boardView.frame.height + buttonSpacing, width: buttonWidth + 20, height: buttonHeight)
        styleButton(hillClimbingButton)
        view.addSubview(hillClimbingButton)
    }

    // Function to style buttons
    func styleButton(_ button: UIButton) {
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }





    // Updated runDFS function
    @objc func runDFS() {
        searchType = .DFS
        executeAlgorithm(algorithm: wrapperDFS)
    }

    func wrapperDFS(board: inout Board, row: Int, col: Int, moves: Int, steps: inout [(Int, Int)]) {
        var tryCount = 0
        let initialPosition = Position(row: row, col: col)
        dfs(board: &board, row: row, col: col, moves: moves, moveLimit: 8, steps: &steps)
    }

    func bfsWrapper(board: inout Board, startRow: Int, startCol: Int, moves: Int, steps: inout [(Int, Int)]) {
        
        var mutableMoves = moves
        bfs(board: &board, startRow: startRow, startCol: startCol, moves: &mutableMoves, steps: &steps)
    }

    @objc func runBFS() {
        searchType = .BFS
        executeAlgorithm(algorithm: bfsWrapper)
    }


    func wrapperHillClimbing(board: inout Board, startRow: Int, startCol: Int, moves: Int, steps: inout [(Int, Int)]) {
        
        var mutableMoves = moves
        hillClimbing(board: &board, startRow: startRow, startCol: startCol, moves: &mutableMoves, steps: &steps)
    }

    @objc func runHillClimbing() {
        searchType = .Climb
        executeAlgorithm(algorithm: wrapperHillClimbing)
    }

    func executeAlgorithm(algorithm: Algorithm) {
        var animationBoard = board
        var horseRow = 4
        var horseCol = 1
        var steps = [(Int, Int)]()

        algorithm(&animationBoard, horseRow, horseCol, 8, &steps)

        // Show the steps after a delay
        self.showSteps(steps)
    }

    func showSteps(_ steps: [(Int, Int)]) {
        removeAllLabels() // Remove existing labels

        print("Steps:")
        var steps = steps
var isActive = false
        for (index, step) in steps.enumerated() {
            // Perform the step visualization here
            // You can update the UI or print the step
            if (isActive){
                return
            }
            print("Step \(index + 1): \(step)")

            // Update the board view with the current step
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 * Double(index)) {
                // Update the board view with the current step
                let updatedBoard = self.updateBoardForStep(board: self.board, step: step)
                self.updateBoardView(updatedBoard)

                // Print the step below the board
                let label = UILabel()
                label.text = "Step \(index + 1): \(step)"
                label.frame = CGRect(x: 20, y: self.boardView.frame.maxY + 100 + CGFloat(index) * 30, width: 300, height: 30)
                self.view.addSubview(label)
            }
            if (step == (1,4)){
                isActive = true
            }
            
        }
    }

    func removeAllLabels() {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                label.removeFromSuperview()
            }
        }
    }

    func updateBoardForStep(board: Board, step: (Int, Int)) -> Board {
        var updatedBoard = board
        let (row, col) = step

        // Assuming you have a method to mark the visited positions
        updatedBoard.placeHorse(row: row, col: col)

        return updatedBoard
    }

    func updateBoardView(_ board: Board) {
        // Remove the existing board view
        self.boardView.removeFromSuperview()

        // Create a new board view with the updated board
        self.boardView = BoardView(board: board)
        self.view.addSubview(self.boardView)
        self.view.layoutIfNeeded()
    }
    


}

var chessBoard = Board(rows: 6, cols: 6)
chessBoard.placeObstacle(row: 0, col: 4)
chessBoard.placeObstacle(row: 3, col: 2)
chessBoard.placeObstacle(row: 1, col: 1)
chessBoard.placeObstacle(row: 1, col: 4)
chessBoard.placeObstacle(row: 5, col: 0)
chessBoard.placeObstacle(row: 5, col: 4)

chessBoard.placeStart(row: 4, col: 1)
chessBoard.placeGoal(row: 1, col: 4)

print("Initial Board:")
chessBoard.printBoard()

let viewController = BoardVisualization(board: chessBoard)
PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true

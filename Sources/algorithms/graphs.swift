// implementing a very simple, no bells and whistles, graph in Swift so as to
// compare it to my fuller implementation in C. Lot's of inprecisions: because
// no set of vertices defined certain actions are taken on entire adjacency list

// Also refusing to use classes here, next pointer is stored in an array.
// Because structs don't allow recursive definitions - the size of the struct
// would not be well defined. Is well defined within an array as arrays i'm
// guessing must be well defined in size in structs, regardless of what's in them.
// AND, notice that with a dynamic variable, we can recreate the C functionality!
// The next dynamic variable is really a couple of functions, so their size is
// presumably just the size of a word.

// See limitations of using structs in this way when data structure requiring
// multiple "pointer" properties to said struct - in elementaryDataStructs.swift.
// example is a queue. You can't implement head/tail with linked list if your
// nodes are structs - they must be classes. Here I used an array queue instead.
// Works because head/tail are just integers into the array, not the structs.
//
// I tried implementing the linked list queue with inout enqueue and still the
// problem persisted: the passed in inout queue node struct had different address
// then did the head/tail which was just set to it! Does Swift duplicate the
// struct in memory (deep copy) rather then passing the same reference around?
// I don't think so, I think the head/tail are just storing the VALUE of the struct
// at the inout position you provided. This problem won't go away until those
// properties can store the REFERENCE or location directly of the desired node.


public struct Vertex {
    let id:     Int
    var weight: Int
    private var _next:  [Vertex?] = [nil]  // for the adjacency list
    private var _nextL: [Vertex?] = [nil]  // for linked list of vertices
    fileprivate var heap_pos: Int = 0

    fileprivate var next: Vertex? {
        get {
            return self._next[0]
        }
        set {
            self._next[0] = newValue
        }
    }

    var nextL: Vertex? {
        get {
            return self._nextL[0]
        }
        set {
            self._nextL[0] = newValue
        }
    }

    init(_ id: Int, _ weight: Int = 1) {
        self.id = id
        self.weight = weight
    }
}


public struct Graph {
    var adjList: [Vertex?] = Array(repeating: nil, count: 8)
    var vertex_head: Vertex? = nil

    private struct BFSQueue {
        var head: Int = 0
        var tail: Int = 0
        var queue: [Vertex?]

        init(size: Int)
        {
            self.queue = Array(repeating: nil, count: size)
        }

        var isEmpty: Bool {
            return self.head == self.tail
        }

        mutating func enqueue(_ vertex: Vertex)
        {
            self.queue[self.tail] = vertex
            self.tail += 1
        }

        mutating func dequeue() -> Vertex
        {
            let to_dequeue = self.queue[self.head]
            self.head += 1
            return to_dequeue!
        }
    }

    private mutating func _growAdjList(_ size: Int)
    {
        var new_adjList: [Vertex?] = Array(repeating: nil, count: size * 2)

        for i in 0..<self.adjList.count {
            new_adjList[i] = self.adjList[i]
        }
        self.adjList = new_adjList
    }

    // lazy implementation: we should expand adjList for both vertices.
    // the way it is, DFS will not explore second vertex in addEdgeDir(1, 4000)
    public mutating func addEdgeDir(_ one: Int, _ two: Int, weight: Int = 1)
    {
        var v1 = Vertex(one)
        var v2 = Vertex(two, weight)

        // add vertices to graph's linked list of vertices if not already there
        var found1 = false;  var found2 = false
        var curr = self.vertex_head
        while curr != nil {
            if curr!.id == v1.id { found1 = true }
            if curr!.id == v2.id { found2 = true }
            curr = curr!.nextL
        }
        if !found1 { v1.nextL = self.vertex_head;  self.vertex_head = v1}
        if !found2 { v2.nextL = self.vertex_head;  self.vertex_head = v2}

        // adj list already has slot for source vertex
        if self.adjList.count > one {
            v2.next = self.adjList[one]
            self.adjList[one] = v2
        } else {
            _growAdjList(one)
            self.adjList[one] = v2            
        }
    }

    public func breadthFirstSearch(source: Int) -> [Int: (depth: Int, pred: Int)]
    {
        var seen: [Int: (depth: Int, pred: Int)] = [:]
        seen[source] = (0, -1)

        var queue = BFSQueue(size: self.adjList.count)
        queue.enqueue(Vertex(source))  // dummy vertex added to get started

        while !queue.isEmpty {

            let curr_vertex = queue.dequeue()
            var edge = self.adjList[curr_vertex.id]
            while edge != nil {

                if seen[edge!.id] == nil {    
                    seen[edge!.id] = (depth: seen[curr_vertex.id]!.depth + 1,
                                      pred: curr_vertex.id)
                    queue.enqueue(edge!)
                }
                edge = edge!.next
            }
        }
        return seen
    }

    public func shortestUnweightedPath(source: Int, dest: Int)
    {
        func _recursive_traversal(_ dest: Int)
        {
            if bfs_tree[dest]!.pred == -1 {
                print("\(dest)->", terminator: "")
            } else {
                _recursive_traversal(bfs_tree[dest]!.pred)
                print("\(dest)->", terminator: "")
            }
        }

        let bfs_tree = self.breadthFirstSearch(source: source)

        if bfs_tree[dest] == nil {
            print("destination not reachable"); return
        } else {
            _recursive_traversal(dest); print()
        }
    }

    public func depthFirstApply(function: (Int)->() )
    {
        func _DFS_visit(_ vertex: Int)
        {
            var edge = self.adjList[vertex]
            while edge != nil {
                if forests[edge!.id] == nil {
                    forests[edge!.id] = vertex
                    function(edge!.id)
                    _DFS_visit(edge!.id)
                }
                edge = edge!.next
            }
        }

        var forests: [Int: Int] = [:]

        for each_vert in 0..<self.adjList.count {
            let curr = self.adjList[each_vert]
            if curr != nil && forests[each_vert] == nil {
                forests[each_vert] = -1
                function(each_vert)
                _DFS_visit(each_vert)
            }
        }
    }
}



extension Graph: CustomStringConvertible {
    public var description: String {
        var string = ""
        for vertex in 0..<adjList.count {
            string += "[\(vertex)]->"

            var curr = self.adjList[vertex]
            while curr != nil {
                string += "\(curr!.id)->"
                curr = curr!.next
            }
            string += "\n"
        }
        return string
    }
}


extension Vertex: CustomStringConvertible {
    public var description: String {
        return "(Id: \(self.id); heap_pos: \(self.heap_pos))"
    }
}

/*
 Important note for Swift:
 If you are building structs that need have two or more properties that refer to
 other objects (class instances or other structs), for example, vertices for
 graphs, nodes for queues, etc. you need those objects to be class instances,
 not structs.
 The reason is that structs are value-types and two properties (head/tail, for 
 example) that refer to them do not refer to the same struct, but different 
 instances of it. In C, these properties hold pointers to the SAME struct, in
 Swift, two value-type objects exists, in different places in memory.
 The elements are like twins seperated at birth and are differently affected by
 the mutating operations they experiance.

 This is not solved by using inout as the properties (i.e. head/tail) still
 store values that are copies of the struct at the inout position. 

 (this could be worked around if you were willing to work with UnsafeRawPointer) 
 This is not a problem if there is only one property, such as head or root. 
 Also, in the case of a single property, the struct elements can have multiple 
 fields, such as next/prev, left/right, etc., the problem is with the data
 structure which needs to refer to the structs.
*/


/*
 Heap - an optimal implementation of a Priority Queue
 A heap, or binary heap, data structure is an array implementation of a nearly
 complete binary tree. Binary because elements have at most two children, left
 and right. Nearly complete as the tree is complete at all levels except perhaps
 at the lowest. The members are at the array indices and we compute an arbitrary
 member's parent, left/right child, by simple arithmatic with member's position.
 
 In addition to priority queues, heaps are used in wide variety of ways, such as
 order statistics. Their invariant and tree structure, and constant-time array
 index access make them very fast at what they can do. Many other data strucutres
 and algorithms use heaps to achieve their ends.

 The heapSize attribute is the number of members in the heap. When a member is
 removed, it is merely moved to the end of the array, and the heapSize is decre-
 mented and all methods know not to access the array beyond this point.
 Normally a second property is maintained, heap length. This records the length
 of the array. This is needed in a language like C, not in Swift, where we can
 just request that knowledge from built-in methods. Also Swift can dynamically
 add to the length of an array, no need to be careful in same way as in C.

 Heap Property:
 Max-Heap: heap[parent(i)] >= heap[i]  // parents are least as large as children
 Min-Heap: heap[parent(i)] <= heap[i]  // children are least as large as parents

 Performance:
 buildHeap  : O(N)     // would seem like O(N lg N) but not in fact right
 heapify    : O(lg N)
 insert     : O(lg N)
 extractMax : O(lg N)
 increaseKey: O(lg N)
 max        : O(1)

*/

public struct MaxHeap {

	public private(set) var heap: [Int] = []
	public private(set) var heapSize = 0

	private let parent = { (i: Int) in return (i-1)/2}
	private let left   = { (i: Int) in return i*2+1}
	private let right  = { (i: Int) in return i*2+2}

	public init() {}

	public init(_ arr: [Int]) {
		self.init()
		var arr = arr
		self.heapSize = arr.count
		buildHeap(&arr)
		self.heap = arr	
	}

	private func buildHeap(_ array: inout Array<Int>) {

		// in binary tree each level contains twice as many nodes
		// bottom half of array are all lowest level elements (no children)
		for i in (0...array.count/2).reversed() {
			heapify(&array, self.heapSize, i)
		}
	}

	private func heapify(_ array: inout Array<Int>, _ heapSize: Int, _ i: Int) {
		let l = left(i)
		let r = right(i)
		var largest = i

		if l < heapSize && array[l] > array[i] 		 {largest = l}
		if r < heapSize && array[r] > array[largest] {largest = r}
		if largest != i {
			array.swapAt(i, largest)
			heapify(&array, self.heapSize, largest)
		}
	}

	public mutating func insert(_ x: Int) {
		self.heapSize += 1
		self.heap.insert(x, at: 0)
		heapify(&self.heap, self.heapSize, 0)
	}

	public mutating func remove(at i: Int) {
		increaseKey(at: i, Int.max)
		_ = extractMax()
	}

	public var max: Int {
		get {
			if self.heapSize == 0 { return Int.min }
			return self.heap[0]
		}
	}

	public mutating func extractMax() -> Int {
		if self.heapSize == 0 {return Int.min}

		let max = self.max
		self.heap[0] = self.heap[self.heapSize-1]
		self.heapSize -= 1
		heapify(&self.heap, self.heapSize, 0)
		return max
	}

	public mutating func increaseKey(at tree_index: Int, _ new_val: Int) {
		var tree_index = tree_index
		self.heap[tree_index] = new_val

		while self.heap[parent(tree_index)] < self.heap[tree_index] {
			heapify(&self.heap, self.heapSize, parent(tree_index))
			tree_index = parent(tree_index)
		}
	}
}


public struct MinHeap {

	public private(set) var heap: [Int] = []
	public private(set) var heapSize = 0

	public let parent = { (i: Int) in return (i-1)/2}
	public let left   = { (i: Int) in return i*2+1}
	public let right  = { (i: Int) in return i*2+2}

	public init() {}

	public init(_ arr: [Int]) {
		self.init()
		var arr = arr
		self.heapSize = arr.count
		buildHeap(&arr)
		self.heap = arr	
	}

	private func buildHeap(_ array: inout Array<Int>) {

		for i in (0...array.count/2).reversed() {
			heapify(&array, self.heapSize, i)
		}
	}

	private func heapify(_ array: inout Array<Int>, _ heapSize: Int, _ i: Int) {
		let l = left(i)
		let r = right(i)
		var smallest = i

		if l < heapSize && array[l] < array[i] 		  {smallest = l}
		if r < heapSize && array[r] < array[smallest] {smallest = r}
		if smallest != i {
			array.swapAt(i, smallest)
			heapify(&array, self.heapSize, smallest)
		}
	}

	public mutating func insert(_ x: Int) {
		self.heapSize += 1
		self.heap.insert(x, at: 0)
		heapify(&self.heap, self.heapSize, 0)
	}

	public mutating func remove(at i: Int) {
		decreaseKey(at: i, Int.min)
		_ = extractMin()
	}

	public var min: Int {
		get {
			if self.heapSize == 0 { return Int.max }
			return self.heap[0]
		}
	}

	public mutating func extractMin() -> Int {
		if self.heapSize == 0 {return Int.max}

		let min = self.min
		self.heap[0] = self.heap[self.heapSize-1]
		self.heapSize -= 1
		heapify(&self.heap, self.heapSize, 0)
		return min
	}

	public mutating func decreaseKey(at tree_index: Int, _ new_val: Int) {
		var tree_index = tree_index
		self.heap[tree_index] = new_val

		while self.heap[parent(tree_index)] > self.heap[tree_index] {
			heapify(&self.heap, self.heapSize, parent(tree_index))
			tree_index = parent(tree_index)
		}
	}
}


/*
 A stack is a container data structure that organizes and handles its data
 following the LIFE method (or Last-In, First-out).
 Think of a stack as a stack of books. You place a new book at the top of the
 stack and must take books off from the top as well. So the oldest item is at the
 bottom and must be removed very last.
 
 A stack can be implemented in an array or as an linked list. Below I implement
 both: first with an array.
 The central methods are push and pop. Push adds a new value to the top of the
 stack if the stack is not already full. Pop returns the value at the top of the
 stack if the stack is not empty and removes it.
 
 Notice that in the array implementation elements are not actually removed, the
 top attribute maintains the index within the array that corresponds to the top
 of the stack. The push function may overwrite old (previously pop'ed) values.

 Performance:
 All functions run in O(1) time.
 perhaps the init may be slower depending on how Swift implemented the Array()

*/

public struct Stack {

	public private(set) var stack: [Int] = []
	public private(set) var capacity = 0
	public private(set) var top = -1

	public init(capacity: Int) {
		self.stack = Array(repeating: 0, count: capacity)
		self.capacity = capacity
	}

	public var is_empty: Bool {
		return self.top < 0
	}

	public var is_full: Bool {
		return self.top == self.capacity-1
	}

	public mutating func push(_ value: Int) {
		if self.is_full {return}

		self.top += 1
		self.stack[self.top] = value
	}

	public mutating func pop() -> Int {
		if self.is_empty {return Int.min}

		self.top -= 1
		return self.stack[self.top+1]
	}

	public func peek() -> Int {
		if self.is_empty {return Int.min}
		return self.stack[self.top]
	}
}


/*
 A queue is a container data structure that organizes and handles its data
 following the FIFO method (or First-in, First-Out).
 Just like a queue in real life, the person who arrives first has been waiting
 the longest and gets to leave the queue first. Also, new arrivals have to be
 added to the end of the queue. Therefore we need attributes for head and tail.

 A queue can be implemented with an array or with a linked list (both below). A
 Priority Queue is a queue that is sorted by a priority, some value that discrim-
 inates between the members to give a priviledge in the ordering. The best way
 to implement that is a Min or Max Heap, but a linked list or array works too.

 The central methods on a queue are Enqueue (add a memeber to the back of queue)
 and Dequeue (retrieve the member at the head of the queue).

 Realize that in an array implementation, when enough members have been added
 to the queue to reach the index corresponding to the queue's capacity no new
 members may be added, even though many members may have been dequeued and the 
 front of the array is unused! This either prevents us from continuing to use
 the array at the same capacity or requires us to make a new larger array, or
 overwrite the array with the values still "live".
 A better approach was taken here, to make the queue CIRCULAR!
 The head and tail attributes are allowed to wrap around the array. We use the
 modulus (%) operator to calculate indexes that wrap around.
 (This is not a problem with a linked list implementation.)

 Performance: (standard queue)
 Like the operations of a stack, all are O(1)

*/

public struct Queue {

	public private(set) var queue: [Int] = []
	public private(set) var capacity = 0
	public private(set)	var size = 0
	public private(set) var head = 0
	public private(set) var tail = 0

	public init(capacity: Int) {
		self.queue = Array(repeating: 0, count: capacity)
		self.capacity = capacity
	}

	public var is_full: Bool {
		return self.size == self.capacity
	}

	public var is_empty: Bool {
		return self.size == 0
	}

	public var front: Int {
		if self.is_empty {return Int.min}
		return self.queue[self.head]
	}

	public var rear: Int {
		if self.is_empty {return Int.min}
		return self.queue[(self.tail + self.capacity-1) % self.capacity]
	}

	public mutating func enqueue(_ value: Int) {
		if self.is_full {return}

		self.queue[self.tail] = value
		self.size += 1
		self.tail = (self.tail+1) % self.capacity
	}

	public mutating func dequeue() -> Int {
		if self.is_empty {return Int.min}

		let to_dequeue = self.queue[self.head]
		self.size -= 1
		self.head = (self.head+1) % self.capacity
		return to_dequeue
	}
}


public class Node<Element> {

	var key:  Element
	var next: Node<Element>?
	var prev: Node<Element>?

	public init(key: Element) {
		self.key = key
	}
}


/*
 A linked list is an data structure where class objects or structs (called nodes)
 are connected in linear order by embodying them with a pointer to the next in 
 the sequence.
 Unlike an array, these are not contigious in memory and you can add to them
 without limit! The drawback is that you cannot access members in constant time
 (you have to traverse the list looking for the node that matches the desired).

 A list can be Doubly-Linked, this means that in addition to the next pointer,
 there is a pointer from each node pointing to the previous node.
 This allows us to delete nodes from the linked list in constant time!

 The mutating operations, insert and delete, work by manipulating these pointers.

 Here I've implemented a CIRCULAR linked list. These have pointers from the tail
 back to the head and from the head back to the tail. Rare that you'll need this
 but some applications/problems you run into may benefit from being modelled in
 this way. None of the below structures relies on this being circular.

 Performance:
 Insert: O(1)
 Search: O(N)
 Delete: O(1)  -> When the list is Doubly-Linked (otherwise, O(N))

*/

public struct LinkedList<Element: Equatable> {

	public private(set) var head: Node<Element>?
	public private(set) var tail: Node<Element>?

	public var is_empty: Bool {
		return self.head == nil
	}

	// insert nodes at head of list
	public mutating func insert(node: Node<Element>) {
		if self.head == nil {
			node.next = node
			node.prev = node
			self.head = node
			self.tail = node
		} else {
			node.next = self.head
			node.prev = self.tail
			self.head!.prev = node
			self.tail!.next = node
			self.head = node
		}
	}

	public func search(key: Element) -> Node<Element>? {
		var head = self.head
		if head == nil {return head}
		repeat {
			if head!.key == key {return head}
			head = head!.next
		} while (head !== self.head)
		return nil
	}

	// delete given node from list
	public mutating func delete(node: Node<Element>) {
		if self.head == nil {return}
		
		if node === self.head {
			if node === self.tail {deleteAll(); return}
			self.head = node.next
			self.head!.prev = self.tail
			self.tail!.next = self.head
			return
		}
		if node === self.tail {self.tail = node.prev}

		node.prev!.next = node.next
		node.next!.prev = node.prev
	}

	public mutating func deleteAll() {
		self.head = nil
		self.tail = nil
	}
}

extension LinkedList: CustomStringConvertible {
	public var description: String {
		var string = ""
		var head = self.head
		if head == nil {return string}
		repeat {
			string += "\(head!.key) -> "
			head = head!.next
		} while (head !== self.head)
		return string
	}
}


/*
 Here I show a stack implemented with a linked list.
 Its cool that you can use it without caring or realizing there is a linked
 list under the hood. This allows us to bypass giving the stack a capacity.
 In this implementation the push method builds the object from the input key,
 it is likely that we would want to have caller build it and pass it in as there
 may be complicated sattelite data to go with it.
 Likewise, probably want pop to return the struct, not just the key.

*/

public struct Stack_LinkedList<Element: Equatable> {

	public private(set) var list = LinkedList<Element>()

	public var is_empty: Bool {
		return self.list.is_empty
	}

	public mutating func push(_ value: Element) {
		let node = Node(key: value)
		self.list.insert(node: node)
	}

	public mutating func pop() -> Element? {
		if self.list.is_empty {return nil}

		let tmp = self.list.head
		self.list.delete(node: tmp!)
		return tmp!.key
	}

	public func peek() -> Element? {
		if self.list.is_empty {return nil}

		return self.list.head!.key
	}
}


/*
 Here I show a queue implemented with a linked list.
 No need to concern ourselves with capacity or making anything circular.
 It is required that the linked list we're building on top of has both head and
 tail attributes. Since insertions in linked list happen at head, this will be
 the back of the queue; the linked list tail attribute corresponds to the front
 of the queue.
 My comments above about the struct returning only the key and creating its own 
 Node apply here as well. The problem you need to solve will be the judge.

*/

public struct Queue_LinkedList<Element: Equatable> {

	public private(set) var list = LinkedList<Element>()

	public var is_empty: Bool {
		return self.list.is_empty
	}

	public var front: Element? {
		return self.list.tail?.key
	}

	public var rear: Element? {
		return self.list.head?.key
	}

	public mutating func enqueue(_ value: Element) {
		let node = Node(key: value)
		self.list.insert(node: node)
	}

	public mutating func dequeue() -> Element? {
		if self.list.is_empty {return nil}

		let tmp = self.list.tail
		self.list.delete(node: tmp!)
		return tmp!.key
	}
}


// Rooted trees
//
// Binary trees are built by linking nodes with pointers to:
// parent, left, and right child. Set to nil if don't exist.
// tree has attribute for root which is nil if tree is empty.
// key is that there is at most two children.
// how tree is structured depends on the type of binary tree.
// heaps (above) are a special case of binary trees (even though
// built from an array).
//
// trees with Unbounded branching (unknown/arbitrary number of children)
// can't have nodes built with all pointer attributes specified in
// advance. One solution is to have parent point to only the left child.
// That child will then have pointer to the sibling to its immediate right,
// and that child will have pointer to its right sibling, and so on.
// all children will have pointer to his parent.
//
// There are many other tree representation schemes. The use will determine
// which is most appropriate.


// Heap-property: parent is >= (<= if MinHeap) children, recursively
// building a heap out of an n size array takes O(n) time
// the heapify function takes O(lg n) time
// so insert and extractMax is lg(n)
//
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


// a circular queue
//
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


// Doubly-linked list
// made Circular here with constant insertion time using tail attribute
//
public struct LinkedList<Element: Equatable> {

	public private(set) var head: Node<Element>?
	public private(set) var tail: Node<Element>?

	public var is_empty: Bool {
		return self.head == nil
	}

	// insert nodes as head of list
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

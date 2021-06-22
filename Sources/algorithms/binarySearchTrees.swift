// Like a linked list, Binary Search Trees are chained together nodes
// that are objects or struct instances. The difference is that each node
// has 3 pointers - parent, left child, right child.
// The other big difference is that a strong invariant is maintained which
// imbues the structure with an architecture that allow us to traverse it
// very very quickly.
//
// binary-search-tree property:
//   if y is left  child of x, y.key is <  x.key
//   if y is right child of x, y.key is >= x.key (one must carry equal values)
//
// supported operations:
// Search, Max, Min, Predecessor, Successor, Insert, Delete
// they can be used therefore also as:
// dictionaries (req: search, insert, delete), priority queue.
// performance depends on the height of the tree, which in turn
// depends on how well the tree is balanced.
//
// All the operations above run in O(tree height), or O(h)
// (issue is, how well is the tree balanced)
//
// A randomly built binary search tree has expected height of lg n.
// The position that nodes take in the tree depend on the order in which they
// are inserted. This in turn effects how well the ultimate balance is.
// Generally, trees are not build with random insertion orders, but I did
// implement one such init below. Instead special BSTs are used, see below.
//
//
// Speciallized BSTs, discussed in other files, such as Red-Black trees and
// AVL trees exit that ensure a well balanced tree and therefore operations
// are all O(Lg N)
// (this is achieved for we only ever need to traverse the height of the tree
// (because of the BST property). The height of a balanced tree is Lg N because
// at every level the size of the tree doubles! That is a tree with a height of 
// 10 has double the nodes that a tree with height 9 has. Yet we only need to
// traverse one extra level to cut through all of the extra nodes!!).
//
// 

// no need to inherit here, but thought it was cool
public class NodeBT<Element>: Node<Element> {

	var parent: NodeBT<Element>?
	var left:   NodeBT<Element>?
	var right:  NodeBT<Element>?

	public init(_ value: Element) {
		super.init(key: value)
	}
}


public struct BinarySearchTree<Element: Comparable> {

	public private(set) var root: NodeBT<Element>?
	
	// certainly not the standard way
	public var count: Int {
		let counter = incrementer()
		return size(from: self.root, counter)
	}

	public init() {}

	public init(_ arr: [Element]) {
		self.init()
		arr.shuffled().forEach { each in self.insert(node: NodeBT(each)) }
	}

	public var is_empty: Bool {
		return self.root == nil
	}

	private func incrementer() -> (Int) -> Int {
		var total = 0
		return { (by: Int) -> Int in total += by; return total }
	}

	public func size(from node: NodeBT<Element>?, _ counter: (Int) -> Int) -> Int {

		if node != nil {
			_ = size(from: node?.left, counter)
			_ = counter(1)
			_ = size(from: node?.right, counter)
		}
		return counter(0)
	}

	public func min(from node: NodeBT<Element>?) -> NodeBT<Element>? {
		var node = node
		while node?.left != nil { node = node!.left }
		return node
	}

	public func max(from node: NodeBT<Element>?) -> NodeBT<Element>? {
		var node = node
		while node?.right != nil { node = node!.right }
		return node
	}

	public func traverseInOrder(from node: NodeBT<Element>?) {

		if node != nil {
			traverseInOrder(from: node?.left)
			print(node!.key, terminator:", ")
			traverseInOrder(from: node?.right)
		}
	}

	// prints root first, then tree from top to bottom, left before right
	public func traversePreOrder(from node: NodeBT<Element>?) {

		if node != nil {
			print(node!.key, terminator:", ")
			traversePreOrder(from: node?.left)
			traversePreOrder(from: node?.right)
		}
	}

	// prints root last, prints tree from bottom up, left before right
	public func traversePostOrder(from node: NodeBT<Element>?) {

		if node != nil {
			traversePostOrder(from: node?.left)
			traversePostOrder(from: node?.right)
			print(node!.key, terminator:", ")
		}
	}

	public func depth(node: NodeBT<Element>?) -> Int? {
		if node == nil {return nil}

		var current = self.root
		var level = 0

		while current != nil {
			if current === node {return level}
			level += 1
			if node!.key < current!.key {current = current?.left}
			else 					    {current = current?.right}
		}
		return nil
	}

	// returns the first node with given key
	public func search(key: Element) -> NodeBT<Element>? {
		var node = self.root

		while node != nil && node!.key != key {
			if key < node!.key {node = node?.left}
			else 			   {node = node?.right}
		}
		return node
	}

	public func successor(node: NodeBT<Element>) -> NodeBT<Element>? {
		if node.right != nil { return self.min(from: node.right) }

		var node: 	NodeBT<Element>? = node
		var parent: NodeBT<Element>? = node?.parent
		while parent != nil && node === parent?.right {
			node = parent
			parent = parent?.parent
		}
		return parent
	}

	public func predecessor(node: NodeBT<Element>) -> NodeBT<Element>? {
		if node.left != nil { return self.max(from: node.left) }

		var node: 	NodeBT<Element>? = node
		var parent: NodeBT<Element>? = node?.parent
		while parent != nil && node === parent?.left {
			node = parent
			parent = parent?.parent
		}
		return parent
	}

	// insertions are made to bottom of tree
	public mutating func insert(node: NodeBT<Element>) {
		var parent: NodeBT<Element>? = nil
		var place = self.root

		while place != nil {
			parent = place
			if node.key < place!.key {place = place!.left}
			else 					 {place = place!.right}
		}
		node.parent = parent

		if parent == nil 			   {self.root     = node}
		else if node.key < parent!.key {parent!.left  = node}
		else 					 	   {parent!.right = node}
	}

	public mutating func delete(node: NodeBT<Element>) {

		func transplant(replace: NodeBT<Element>, by: NodeBT<Element>?) {
			
			if replace.parent == nil {
				self.root = by
			} else if replace.parent?.left === replace {
				replace.parent!.left = by
			} else {
				replace.parent!.right = by
			}
			if by != nil {by!.parent = replace.parent}
		}

		if node.left == nil {
			transplant(replace: node, by: node.right)
		}
		else if node.right == nil {
			transplant(replace: node, by: node.left)
		}
		else {
			let next = self.min(from: node.right)
			if next !== node.right {
				transplant(replace: next!, by: next!.right) // free up next's right slot
				next?.right = node.right
				next?.right!.parent = next
			}
			transplant(replace: node, by: next)
			next!.left = node.left
			next!.left!.parent = next
		}
	}
}




func example_tree() -> BinarySearchTree<Int> {

	// builds the following tree:
	//
	//				8
	//			   / \ 
	//			  3	  14
	//			 / \  / \
	//			2  4 9  16	
	//		   /    \ \
	//		  1		 7 10

	var a = BinarySearchTree<Int>()

	let n1 = NodeBT(1)
	let n2 = NodeBT(2)
	let n3 = NodeBT(3)
	let n4 = NodeBT(4)
	let n5 = NodeBT(7)
	let n6 = NodeBT(8)
	let n7 = NodeBT(9)
	let n8 = NodeBT(10)
	let n9 = NodeBT(14)
	let n10 = NodeBT(16)

	a.insert(node: n6)
	a.insert(node: n3)
	a.insert(node: n4)
	a.insert(node: n5)
	a.insert(node: n2)
	a.insert(node: n1)
	a.insert(node: n9)
	a.insert(node: n7)
	a.insert(node: n8)
	a.insert(node: n10)

	return a
}

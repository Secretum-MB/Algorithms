// Red-Black Trees
//
// Modified form of a Binary Search Tree. A binary color attribute is added
// to the nodes and tree is structured in such a way to ensure it is approximately
// balanced. (No path can be more than twice as long as another.)
// 
// Properties of Red-Black Trees:
// 1. Every node is either red or black
// 2. The root is black
// 3. The leaves are black (these are the nil pointers, do we actually instantiate nodes for these?)
// 4. If a node is red, then each of its children are black
// 5. For each node, all simple paths from it to descendant leaves contains the 
// 	  the same number of black nodes.
//
// The black-height of a node x, bh(x), is the number of black nodes along a 
// simple path from node x down to a leaf (end of tree), exclusive of node x.
// (well defined per property 5 above).
// (the black-height of a Red-Black Tree is the black-height of its root).
// 
// Properties ensure that the black-height of tree is at most 2 lg(n + 1)
// The trees themselves have height O(lg n)
//
// all operations: Search, Min, Max, Predecessor, Successor, Insert, Delete
// can be performed in O(lg n)
//


public class NodeRBT<Element> {
	
	var key:	Element
	var parent: NodeRBT<Element>?
	var left:	NodeRBT<Element>?
	var right:	NodeRBT<Element>?
	var color = "Black"

	public init(key: Element) {
		self.key = key
	}
}

extension NodeRBT: CustomStringConvertible {
	public var description: String {
		return "Key: \(key); Parent: \(parent?.key);Left: \(left?.key); Right: \(right?.key);"
	}
}


struct RedBlackTree<Element: Comparable> {

	private(set) public var root: NodeRBT<Element>?

	public init() {}

	// insertion and deletion can break properties of tree;
	// rotations restructure the tree locally by rotating around input node
	// this is one part of getting the tree back in comformaty with properties
	// // // assumes node's right child is not nil (investigate this)
	public mutating func rotateLeft(on node: NodeRBT<Element>) {
		let R = node.right
		node.right = R!.left
		if R!.left != nil {R!.left!.parent = node}
		R!.parent = node.parent

		if node.parent == nil 			   {self.root = R}
		else if node === node.parent!.left {node.parent!.left = R}
		else 							   {node.parent!.right = R}

		R!.left = node
		node.parent = R
	}

	// symmetric to above: assumes node has a left child
	public mutating func rotateRight(on node: NodeRBT<Element>) {
		let L = node.left
		node.left = L!.right
		if L!.right != nil {L!.right!.parent = node}
		L!.parent = node.parent

		if node.parent == nil 			   {self.root = L}
		else if node === node.parent!.left {node.parent!.left = L}
		else 							   {node.parent!.right = L}

		L!.right = node
		node.parent = L
	}

	public func search(key: Element) -> NodeRBT<Element>? {
		var node = self.root

		while node != nil && node!.key != key {
			if key < node!.key {node = node?.left}
			else 			   {node = node?.right}
		}
		return node
	}

	public mutating func insert_BT(_ node: NodeRBT<Element>) {
		var parent: NodeRBT<Element>? = nil
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

	public func traverse(_ node: NodeRBT<Element>?) {
		if node != nil {
			traverse(node?.left)
			traverse(node?.right)
			print(node)
		}
	}
}




func test_rotations() -> RedBlackTree<Int> {

	// builds: tree from textbook page 331
	var a = RedBlackTree<Int>()
	
	let n2 =  NodeRBT(key: 2)
	let n3 =  NodeRBT(key: 3)
	let n4 =  NodeRBT(key: 4)
	let n6 =  NodeRBT(key: 6)
	let n7 =  NodeRBT(key: 7)
	let n9 =  NodeRBT(key: 9)
	let n11 = NodeRBT(key: 11)
	let n12 = NodeRBT(key: 12)
	let n14 = NodeRBT(key: 14)
	let n17 = NodeRBT(key: 17)
	let n18 = NodeRBT(key: 18)
	let n19 = NodeRBT(key: 19)
	let n20 = NodeRBT(key: 20)
	let n22 = NodeRBT(key: 22)

	a.insert_BT(n7)
	a.insert_BT(n4)
	a.insert_BT(n6)
	a.insert_BT(n3)
	a.insert_BT(n2)
	a.insert_BT(n11)
	a.insert_BT(n9)
	a.insert_BT(n18)
	a.insert_BT(n14)
	a.insert_BT(n12)
	a.insert_BT(n17)
	a.insert_BT(n19)
	a.insert_BT(n22)
	a.insert_BT(n20)

	return a
}

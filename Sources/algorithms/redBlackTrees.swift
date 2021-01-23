// Red-Black Trees
//
// Modified form of a Binary Search Tree. A binary color attribute is added
// to the nodes and tree is structured in such a way to ensure it is approximately
// balanced. (No path can be more than twice as long as another.)
// 
// Properties of Red-Black Trees:
// 1. Every node is either red or black
// 2. The root is black
// 3. If a node is red, then each of its children are black
// 4. For each node, all simple paths from it to descendant leaves contains the 
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

private enum RBTnodeColor {
	case red, black 
} 


public class NodeRBT<Element> {
	var 	 key:	 Element?
	var 	 left:	 NodeRBT<Element>?
	var 	 right:	 NodeRBT<Element>?
	weak var parent: NodeRBT<Element>?
	fileprivate var color: RBTnodeColor = .black

	public init(key: Element? = nil) {
		self.key = key
	}
}

// for debugging tree
extension NodeRBT: CustomStringConvertible {
	public var description: String {
		return "Key: \(key);\t Parent: \(parent?.key);\t Left: \(left?.key);\t Right: \(right?.key);\t Color: \(color);"
	}
}


public struct RedBlackTree<Element: Comparable> {

	private var nil_node = NodeRBT<Element>()
	private(set) public var root: NodeRBT<Element>?

	public init() {
		self.root = nil_node
	}

	// insertion and deletion can break properties of tree;
	// rotations restructure the tree locally by rotating around input node
	// this is one part of getting the tree back in comformaty with properties
	//
	// called such that node's right child is not nil
	private mutating func rotateLeft(on node: NodeRBT<Element>) {
		let R = node.right
		node.right = R!.left
		if R!.left !== self.nil_node { R!.left!.parent = node }
		R!.parent = node.parent

		if node.parent == nil 			   {self.root = R}
		else if node === node.parent!.left {node.parent!.left = R}
		else 							   {node.parent!.right = R}

		R!.left = node
		node.parent = R
	}

	// symmetric to above: called such that node has a left child
	private mutating func rotateRight(on node: NodeRBT<Element>) {
		let L = node.left
		node.left = L!.right
		if L!.right !== self.nil_node { L!.right!.parent = node }
		L!.parent = node.parent

		if node.parent == nil 			   {self.root = L}
		else if node === node.parent!.left {node.parent!.left = L}
		else 							   {node.parent!.right = L}

		L!.right = node
		node.parent = L
	}

	// called at the end of insert to correct colors and rotate tree
	private mutating func insertFixup(_ node: NodeRBT<Element>) {
		var z = node
		// z is always red at top of loop, if parent too, then violation 3
		while z.parent != nil && z.parent!.color == .red {

			// structure one: parent is left child of grandparent
			if z.parent === z.parent!.parent!.left {
				let uncle = z.parent!.parent!.right

				// red uncle allows for simple color swapping and moving up tree
				if uncle!.color == .red {
					uncle!.color 			= .black
					z.parent!.color 		= .black
					z.parent!.parent!.color = .red
					z = z.parent!.parent!
					continue

				// uncle is black or nil_node, simple color change breaks rule 4
				} else if z === z.parent!.right {
					z = z.parent!
					self.rotateLeft(on: z)
				}
				z.parent!.color 		= .black
				z.parent!.parent!.color = .red
				self.rotateRight(on: z.parent!.parent!)

			// structure two: parent is right child of grandparent: just reverse
			} else {
				let uncle = z.parent!.parent!.left
				if uncle!.color == .red {
					uncle!.color 			= .black
					z.parent!.color 		= .black
					z.parent!.parent!.color = .red
					z = z.parent!.parent!
					continue
				} else if z === z.parent!.left {
					z = z.parent!
					self.rotateRight(on: z)
				}
				z.parent!.color 		= .black
				z.parent!.parent!.color = .red
				self.rotateLeft(on: z.parent!.parent!)
			}
		}
		// make root black in case above changed it or node is root
		self.root!.color = .black
	}

	public mutating func insert(node: NodeRBT<Element>) {
		if node.key == nil { return }

		var parent: NodeRBT<Element>? = nil
		var place = self.root

		while place !== self.nil_node {
			parent = place
			if node.key! < place!.key! {place = place!.left}
			else 					   {place = place!.right}
		}
		node.parent = parent

		if parent == nil 			     {self.root 	= node}
		else if node.key! < parent!.key! {parent!.left  = node}
		else 						     {parent!.right = node}

		node.color = .red
		node.left = self.nil_node 
		node.right = self.nil_node
		insertFixup(node)
	}

	public func search(key: Element) -> NodeRBT<Element>? {
		var node = self.root

		while node !== self.nil_node {
			if node!.key == key { return node }

			if key < node!.key! {node = node?.left}
			else 			    {node = node?.right}
		}
		return nil
	}

	public func min(from node: NodeRBT<Element>?) -> NodeRBT<Element>? {
		var node =  node
		while node?.left !== self.nil_node { node = node!.left }
		return node
	}

	public mutating func delete(node: NodeRBT<Element>) {

		// links old's parent to new and new to parent
		func transplant(replace: NodeRBT<Element>, by: NodeRBT<Element>) {
			
			if replace.parent == nil {
				self.root = by
			} else if replace.parent!.left === replace {
				replace.parent!.left = by
			} else {
				replace.parent!.right = by
			}
			by.parent = replace.parent  // connects nil_node.parent to tree 
		}

		let z = node
		var z_color = z.color
		var child: NodeRBT<Element>

		// if node has less than 2 children same as normal binary tree
		if node.left === self.nil_node {
			child = node.right!  // may be the nil_node
			transplant(replace: node, by: child)
		} else if node.right === self.nil_node {
			child = node.left!
			transplant(replace: node, by: child)

		} else {
			// next is successor node and it has at most right child (from min)
			let next = self.min(from: z.right)
			child = next!.right!
			z_color = next!.color

			// case where successor is child of z
			if next === z.right {
				child.parent = next  // connects nil_node.parent to tree
			
			// connect child to tree independent from next to free next's right
			} else {
				transplant(replace: next!, by: child)
				next!.right = z.right
				next!.right!.parent = next
			}
			transplant(replace: z, by: next!)
			next!.left = z.left
			next!.left!.parent = next
			next!.color = z.color
		}
		// check if delete/moved node was black, requiring fix-up
		if z_color == .black {
			deleteFixup(child)
		}
	}

	// performs necessary colorings and rotations after delete operation
	private mutating func deleteFixup(_ node: NodeRBT<Element>) {
		var x = node
		while x !== self.root && x.color == .black {

			if x === x.parent!.left {
				var sibling = x.parent!.right!  // logically cannot be nil_node

				// case 1: sibling is red: makes sibling black for cases 2-4
				if sibling.color == .red {
					sibling.color   = .black
					x.parent!.color = .red
					rotateLeft(on: x.parent!)
					sibling = x.parent!.right!
				}
				// case 2: both of sibling's children are black
				if sibling.left!.color == .black && sibling.right!.color == .black {
					sibling.color = .red
					x = x.parent!
				
				} else {
					// case 3: only sibling's right child is black
					if sibling.right!.color == .black {
						sibling.color 	    = .red
						sibling.left!.color = .black
						rotateRight(on: sibling)
						sibling = x.parent!.right!
					}
					// case 4: sibling's right child is red or was made red by case 3
					sibling.color = x.parent!.color
					x.parent!.color 	 = .black
					sibling.right!.color = .black
					rotateLeft(on: x.parent!)
					x = self.root!
				}
			// x is its parent's right child (identical to above but reverse left/right)
			} else {
				var sibling = x.parent!.left!

				if sibling.color == .red {
					sibling.color   = .black
					x.parent!.color = .red
					rotateRight(on: x.parent!)
					sibling = x.parent!.left!
				}
				if sibling.left!.color == .black && sibling.right!.color == .black {
					sibling.color = .red
					x = x.parent!
				
				} else {
					if sibling.left!.color == .black {
						sibling.color 	     = .red
						sibling.right!.color = .black
						rotateLeft(on: sibling)
						sibling = x.parent!.left!
					}
					sibling.color = x.parent!.color
					x.parent!.color 	= .black
					sibling.left!.color = .black
					rotateRight(on: x.parent!)
					x = self.root!
				}
			}
		}
		x.color = .black
	}

	public func traverse(_ node: NodeRBT<Element>?) {
		if node !== self.nil_node {
			traverse(node?.left)
			traverse(node?.right)
			print(node!)
		}
	}
}




func sample_tree1() -> RedBlackTree<Int> {

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

	a.insert(node: n7)
	a.insert(node: n4)
	a.insert(node: n6)
	a.insert(node: n3)
	a.insert(node: n2)
	a.insert(node: n11)
	a.insert(node: n9)
	a.insert(node: n18)
	a.insert(node: n14)
	a.insert(node: n12)
	a.insert(node: n17)
	a.insert(node: n19)
	a.insert(node: n22)
	a.insert(node: n20)

	return a
}

func sample_tree2() -> RedBlackTree<Int> {

	//builds tree from textbook page 334
	var a = RedBlackTree<Int>()

	let n1 = NodeRBT(key: 11)
	let n2 = NodeRBT(key: 14)
	let n3 = NodeRBT(key: 15)
	let n4 = NodeRBT(key: 2)
	let n5 = NodeRBT(key: 1)
	let n6 = NodeRBT(key: 7)
	let n7 = NodeRBT(key: 5)
	let n8 = NodeRBT(key: 8)
	let n9 = NodeRBT(key: 4)

	a.insert(node: n1)
	a.insert(node: n2)
	a.insert(node: n3)
	a.insert(node: n4)
	a.insert(node: n5)
	a.insert(node: n6)
	a.insert(node: n7)
	a.insert(node: n8)
	a.insert(node: n9)

	a.insert(node: NodeRBT(key: 9))
	a.insert(node: NodeRBT(key: 8))
	a.delete(node: n6)

	return a
}

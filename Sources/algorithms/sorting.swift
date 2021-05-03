import Foundation


/* 
 There are two broad classes of sorting algorithms: the more common comparison
 sorters and non-comparison sorting. Comparison sorters compare values in the
 input to determine where they ought relatively belong. The other class does not
 perform this comparison between members.
 The best worst-case run time of comparison sort algorithms is O(N Lg N).
 The other class can break this and achieve O(N). 

 Speed is the most important consideration when choosing an algorithm.
 Algorithms from the fist class are often used, even though they have worse
 asymptotic performance, because they do not need to make assumptions to be valid 
 that the other class needs to make.

 Another important consideration is choosing an algorithm is whether it sorts
 in-place or not. Algorithms that sort in-place do not requrie more than a constant
 number of members stored outside of the input. Otherwise, the amount of memory
 the algorithm requires grows with the input size - becoming expensive.

 Another consideration is stability. Stability refers to the algorithm leaving 
 the ordering of equal-valued members unchanged upon sorting. That is, if x and
 y are of the same value, and appear in that order in the input, the sorted
 output will preserve the ordering of x and y. 
*/



/* insertion sort is an in-place sorting algorithm, it mutates the input array
 * In this implementation I chose to pass the input by value rather than reference.
 * Worst-case run time is "theta" O(n^2)
 * Realize that the time required depends on how out-of-sort the array is: if it
 * is already sorted, it would finish in linear time in the size of the input.
 * The average run time then is somewhere between N and N^2.
 * Stable sort - equal values are not swapped.
 * This algorithm is efficient for small inputs: used in practice when appropriate.
 */
func insertionSort( _ lst: [Int]) -> [Int] {
	var lst = lst

	for cur in 1..<lst.count {
		let anchor = lst[cur]
		var bef = cur - 1

		// for reversed sort: change > to < in second half of line below
		while bef >= 0 && lst[bef] > anchor {
			lst[bef+1] = lst[bef] // move item low in array forward
			bef -= 1
		}
		lst[bef+1] = anchor //move anchor all the way back
	}
	return lst
}


/* Bubble sort can also sort the array in-place, requring no additional memory.
 * Each completion of the inner for-loop guarantees the largest value moves to 
 * its correct position at the top of the array. While any swapping occured,
 * we must go through the entire for loop again. If the smallest value was
 * initially at the top of the array, we would need as many times through the
 * for loop as there are elements in the input, so: O(N^2)
 * Although a perfectly sorted input will be processed in linear time,
 * partially sorted input will not benefit as insertionSort did. Because each
 * pass through its for-loop achieves less, getting values nearer their
 * correct position, not all the way to it (except the highest value).
 * Stable sort - equal values are not swapped.
 * This algorithm is just inferior, simple, and not used in practice.
 */
func bubbleSort( _ lst: [Int]) -> [Int] {
	var lst = lst
	var swapped = true
	var tmp: Int

	while swapped == true {
		swapped = false

		for each in 0..<lst.count-1 {
			if lst[each] > lst[each+1] {
				tmp = lst[each]
				lst[each] = lst[each+1]
				lst[each+1] = tmp
				swapped = true
			}
		}
	}
	return lst
}

/* This is just a toy sorting algorithm that I made to capture an intuitive
 * sorting procedure. It requires a new array be constructed that will capture
 * the sorted array, so not in-place. It works by identifying the smallest value
 * from the input, placing it into the new array, removing it from the input.
 * Then the function is called recursively until the input array is empty.
 * Performance is aweful: we have to recurse as many times as there are elements
 * in the input; and in each iterate over the array to find the smallest. Since
 * the array we iterate over in last step shrinks, performance is probably a bit
 * better than O(N^2). This algorithm is stable - inner function sequential. 
 */
func humanSort( _ lst: [Int]) -> [Int] {
	func _smallest( _ lst: [Int]) -> Int {
		var value: Int?
		var index = 0

		for each in 0..<lst.count {
			if value == nil || lst[each] < value! {
				value = lst[each]
				index = each
			}
		}
		return index
	}

	var lst = lst

	var lst_new: [Int] = []

	if lst == [] {return lst_new}

	let smallest = _smallest(lst)
	lst_new.append(lst[smallest])
	lst.remove(at: smallest)

	return lst_new + humanSort(lst)
}


/* An example of a Divide-and-Conquer algorithm. The sorting problem is
 * broken down into smaller and smaller sorting problems until you are asked
 * to sort an array of size 1, which is trivial. This is done by breaking the
 * input into a left half and right half, over and over again. Small but
 * increasingly large sorted arrays are constructed by merging the sorted left
 * and right parts - merely by comparing their leftmost elements. (This is a
 * simplified account of what happens, in reality mutations are to the same
 * array, we merely restrict the range of the indexes upon consideration.)
 * Asymptoticly optimal - O(N lg N)  lg N divisions, N comparisons inside merge
 * Does not sort in-place: merge requires construction of two new arrays,
 *   each which is half as large as portion of input under consideration: O(N).
 * Stable sort - merge's comparison between left/right prioritizes left (<=)
 */
func mergeSort( _ lst: inout [Int], _ start: Int, _ end: Int) {

	func merge() {

		let L = Array(lst[start...mid])
		let R = Array(lst[mid+1...end])
		
		let L_end = L.count - 1
		let R_end = R.count - 1

		var L_i = 0
		var R_i = 0
		var i = start

		while L_i <= L_end && R_i <= R_end {

			if L[L_i] <= R[R_i] {
				lst[i] = L[L_i]
				L_i += 1; i += 1
			} else {
				lst[i] = R[R_i]
				R_i += 1; i += 1
			}
		}
		while L_i <= L_end {
			lst[i] = L[L_i]
			L_i += 1; i += 1
		}
		while R_i <= R_end {
			lst[i] = R[R_i]
			R_i += 1; i += 1
		}
	}

	if start >= end {

		return
	}

	let mid = (start + end) / 2

	mergeSort(&lst, start, mid)
	mergeSort(&lst, mid+1, end)
	merge()
}


/* Utilizes the max-heap data structure to sort the input array.
 * First, a max-heap is constructed out of the input array - O(N)
 * The heap is then iterated over in reverse order - we swap the very end of the
 * heap array with the value in the 0th position (must be the largest value),
 * then we decrease the heap size and run heapify to get the next largest value
 * to bubble up to the head of the heap. O (lg N)
 * We continue iterating until we have sorted the array from the high-end down 
 * to the smallest element. O(N)
 * Asymptotically optimal - O(N Lg N)   // high constant factor, not often used
 * This implementation not withstanding, can be made to sort in-place (use inout)
 * Not a Stable sorting algorithm - but can be made so with modifications
 */
func heapSort(_ arr: [Int]) -> [Int] {
	var arr = arr

	func maxHeapify(_ heap_size: Int, _ i: Int) {

		let l = left(i)
		let r = right(i)
		var largest = i

		if l < heap_size && arr[l] > arr[i] 	  {largest = l}
		if r < heap_size && arr[r] > arr[largest] {largest = r}
		if largest != i {
			arr.swapAt(i, largest)
			maxHeapify(heap_size, largest)
		}
	}

	func buildHeap() {
		for i in (0...arr.count/2).reversed() {
			maxHeapify(arr.count, i)
		}
	}
	
	let left  = { (i: Int) in return i*2+1}
	let right = { (i: Int) in return i*2+2}

	buildHeap()
	for i in (1..<arr.count).reversed() {
		arr.swapAt(0, i)
		maxHeapify(i, 0)
	}

	return arr
}


/* Although Quick-sort has a poor worst-case time O(n^2), its expected running
 * time is O(N Lg N). Further, it has a very low constant factor which makes it
 * in practice very fast, usually outperforming other comparison sorters.
 * It is an in-place sort as well. It does not provide Stable sorting by default,
 * but can be modified to provide that.
 * Another Divide-and-Conquer algorithm. Like Merge-sort it divides the input up
 * into two halves and calls itself on these sub-arrays. Here though, the
 * partition function determines where to make the split. It is also what does
 * the "sorting".
 * The partition function picks, somewhat arbitrarily, the end value in the array
 * to be the value that will descriminate the left and right sides of the partition.
 * It then iterates over the array and values less than this pivot value is moved
 * to the left side of the array and the partition location is pushed up. This is
 * continued for the entire array and the final partition location is returned.
 * when this partition function finishes, all values to the left of the partition
 * will be less than the pivot value, all on the right equal or larger. This is
 * not sorted, but a weaker state. But Quick-sort accomplishes sorting by doing
 * this on smaller and smaller parts of the input array until array is sorted.
 *
 * The performance depends on how balanced the partitioning is, which depends on
 * how suitable the pivot value is. The standard implementation just picks the
 * last value in the array (sub-array under consideration). This is fine when
 * the input array is random, no reason any other value would be better.
 */
func quickSort(_ arr: inout [Int], _ start: Int, _ end: Int) {

	func partition() -> Int {
		let pivot = arr[end] 
		var q = start - 1  // q will be the demarcation between partitions

		for each in start..<end {
			if arr[each] < pivot {
				q += 1
				arr.swapAt(q, each)
			}
		}
		arr.swapAt(q+1, end) // moves pivot from end to between partitions
		return q + 1
	}

	if start < end {
		let q = partition()
		quickSort(&arr, start, q-1)
		quickSort(&arr, q + 1, end)
	}
} 


/* If we have reason to believe that the input array's values are not random,
 * but distributed in some way not known to us, or just too hard to find,
 * or that a malevalant actor wishes to construct the inputs so as to illicit
 * from our Quick-sort O(N^2), we can modify Quick-sort so that no input can
 * illicit poor performance from us. The function below is the same as above
 * except that another helper function is added that swaps the last element
 * in the array under consideration with a random element in said array. Then
 * partition is allowed to process as usual, taking the last array value as the
 * pivot.
 * Realize that this version has a higher constant factor.
 */
func quickSort_random(_ arr: inout [Int], _ start: Int, _ end: Int) {

	func partition_random() -> Int {
		let random_i = Int.random(in: start...end)
		arr.swapAt(random_i, end)
		return partition()
	}

	func partition() -> Int {
		let pivot = arr[end]
		var q = start - 1

		for each in start..<end {
			if arr[each] < pivot {
				q += 1
				arr.swapAt(q, each)
			}
		}
		arr.swapAt(q+1, end)
		return q + 1
	}

	if start < end {
		let q = partition_random()
		quickSort_random(&arr, start, q-1)
		quickSort_random(&arr, q + 1, end)
	}
}


// The below algorithms do not use comparison to sort! They are therefore not
// bound to the best case running time of n lg n. They can run in linear time!
// at the cost that some conditions must be met by the data to be sorted.


// Counting-Sort requires that we're sorting integers. As the implementation makes
// clear, its critical that the data is discrete and have fixed space between them.
// Will sort in linear time if the largest value, k, is not enormous.
// Simplest if values are >= 0. Ideally, we know the value of k going into it, otherwise
// we'll overestimate it (won't work if underestimated) and waste memory.
// This will slow it down very little.
//
// If data can be negative integers: add parameter for lowest value. Size of storage
// is now k-smallest+1. To map values into storage: arr[i] - smallest.
//
// Does not sort in-place: new arrays need to be created to perform the work.
// It is also Stable: duplicates appear in results in same order as they do in input array.
//
func countingSort(_ arr: [Int], _ k: Int) -> [Int] {

	var storage = Array(repeating: 0, count: k+1)
	var results = Array(repeating: 0, count: arr.count)

	// storage will contain the count of the value of i at i
	// as in, storage[0] will contain number of 0s in input
	for i in 0..<arr.count {
		storage[arr[i]] = storage[arr[i]] + 1
	}

	// storage will contain at i the number of values <= i
	for i in 1..<storage.count {
		storage[i] = storage[i] + storage[i-1]
	}

	// values in input array are placed in results based on number
	// of values storage says are lower than it.
	// as in: if arr[i] = 7 and storage says there are 4 values less,
	// then 7 gets placed in results in position 5.
	// The second line updates storage so duplicate values are placed after
	for i in (0..<arr.count).reversed() {
		results[storage[arr[i]]-1] = arr[i]
		storage[arr[i]] -= 1
	}
	return results
}


// re-implementing counting sort such that it can sort an array of objects.
// Below ADT has key property that is integer >= 0 which will be used to sort.

// generic sorting function uses a property of the node, not all generic types 
// have this propety, and would therefore not work. Solution: require that the 
// generic type comform to a protocol that requires the needed property.
protocol NodeContainer_p {

	var key: Int { get }
}


// as an aside, if we inherit from NSObject we can use its CustomStringConvertible
// or debugDescription property to retrieve instance's memory address. no need
// to call super.init(). Maybe this okay for debugging complex classes?
//
class Node_t: NodeContainer_p {
	public private(set) static var running_ids = 0

	public private(set) var key: Int  		// unique int >= 0 for sorting
	public let field_one: 		 String
	public let field_two: 		 Double
	public let field_three: 	 Character

	public init(field_one: String, field_two: Double, field_three: Character) {
		self.field_one   = field_one
		self.field_two   = field_two
		self.field_three = field_three
		
		self.key = Node_t.running_ids
		Node_t.running_ids += 1
	}
}

extension Node_t: CustomStringConvertible {
	public var description: String {
		return "key: \(key); \(field_one); \(field_two); \(field_three)\n"
	}
}


func countingSort_obj<T: NodeContainer_p>(_ arr: [T], _ k: Int) -> [T] {
	
	var storage = Array(repeating: 0, count: k+1)
	var results = arr

	for i in 0..<arr.count {
		storage[arr[i].key] = storage[arr[i].key] + 1
	}

	for i in 1..<storage.count {
		storage[i] = storage[i] + storage[i-1]
	}

	for i in (0..<arr.count).reversed() {
		results[storage[arr[i].key] - 1]  = arr[i]
		storage[arr[i].key] -= 1
	}

	return results
}


// another sorting algorithm, with expected running time of O(n) is bucketSort
// This one requires that all values in array be between [0 and 1). And ideally,
// the values are uniformely distributed (otherwise some slow-down)
// it loops over values and places them in a linked list. each i of list
// contains values beginning with .1, .2, .3, etc. 
// so one branch could have: .123, .1456, .100, etc.
// insetionSort is then used to sort each chain.
// then each chain is looped over populating result array

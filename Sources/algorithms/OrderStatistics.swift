// Medians and Order Statistics
// as in, find the i'th smallest/largest value in an collection
// One approach is to sort the array:
// we can use a heap and the logic used in heapSort to do this in n lg n.
// we could also use mergeSort, also n lg n.
// Below we will discuss faster solutions.
// Although they compare elements they are not capped at n lg n because
// they do not sort the sequence. 
// Also, unlike the linear sorting algorithms, the below does not need to 
// make assumptions about the data under analysis!
// (Below I discuss other, faster ways of solving this than O(N))

// easy to loop over array and find min or max in linear time.
// If you compare values in pairs you can find both simultaneously
// with fewer than two comparisons per element; 3 comparisons per 2 elements!
//
func minMax_simultaneously(_ arr: [Int]) -> (Int, Int) {

	var min: Int
	var max: Int
	var start: Int

	if arr.count == 1 {return (arr[0], arr[0])}

	if arr.count % 2 != 0 {
		min = arr[0]; max = arr[0]
		start = 1} 
	else {
		start = 2
		if arr[0] < arr[1] {min = arr[0]; max = arr[1]} 
		else {min = arr[1]; max = arr[0]}
	}

	var tmp_min, tmp_max: Int

	for i in stride(from: start, to: arr.count-1, by: 2) {
		if arr[i] < arr[i+1] {tmp_min = arr[i]; tmp_max = arr[i+1]}
		else {tmp_min = arr[i+1]; tmp_max = arr[i]}

		if tmp_min < min {min = tmp_min}
		if tmp_max > max {max = tmp_max}
	}
	return (min, max)
}


// The Selection Problem
// finding the i'th smallest element in collection
// although the worst case running time is n^2 like quickSort,
// the EXPECTED running time is faster: here it is O(n).
// when randomizing, no input array illicits the worst case performance
// in below: i is the i'th smallest. i.e. i=1 requests the smallest in sequence
// 
// in order to find the median of sequence let i = arr.count/2 + 1 for odd seq.
// if sequence is even length, above is right median; remove +1 to find left.
//
func randomizedSelect(_ arr: [Int], start: Int, end: Int, at i: Int) -> Int {
	var arr = arr

	// these subfunction come straight out of quickSort (random variant)
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

	if start == end {		// recursive base case
		return arr[start]
	}

	let q = partition_random()
	let num_smaller = q - start + 1
	if num_smaller == i {	// x are smaller and we want x'th smallest
		return arr[q]		// so: value in pivot is our answer
	}

	// if pivot does not contain answer, repeat for the correct partition
	if i < num_smaller {
		return randomizedSelect(arr, start: start, end: q-1, at: i)
	} else {
		return randomizedSelect(arr, start: q + 1, end: end, at: i-num_smaller)
	}
}


// Selection can be made more efficient if the set you're searching through is
// structured in some rational way. Obviously, if set is sorted you could select
// in O(1) time. If set is in a balanced binary search tree, selection and
// rank can be achieved in O(lg n) time (see Red-Black trees).
// There is another divide and conquer approach that can reliably achieve O(n).
// It also uses the quick-sort method above but q is not chosen randomly but by
// finding the medium of mediums from a 2-dimensional array of the input array,
// where each column of 5 numbers is sorted. Look it up if you're interested.
//
// Below is highly creative: we're using two Heaps (one augmented):
// Below we can see that selection can be made from a Min Heap (Max also if we know n).
// If we seek the k'th item from the set, the running time of the heap is O(k lg k).
// This is also an example of an Augmented Data Structure.
// (not all methods have been implemented)
//
// The insight for solving the problem is realizing that the min heap invariant 
// allows us to scan down the heap, level for level, comparing the values in order
// to find the local min, which will be the global min, after you remove on each
// iteration the prior minimum. After an item is removed as the prior min, its
// left/right children take its place for consideration.
// The data structure we use for the considerations is an Augmented MinHeap.
//
// The only change to the data structure is that it now consists of an array of
// tuples. One value is the value, the other is an integer that we will use when
// inserting an element from the regular heap input into our augmented structure.
// The methods that before returned only a value now return this tuple. 
//
// We begin by inserting into our new Heap the root or min of the input heap. We
// insert a tuple, the second value of which is the index from the ORIGINAL heap.
// This is of course the rank one item. As we desire the k_th item, we loop that
// many times: first removing the min item from our new Heap, then inserting its
// two children (we use the index value from the extracted tuple to find them).
// At the end of the loop, the min element in our Augmented Heap is the answer.
//


public struct MinHeap_Augmented {

	public typealias tuple = (val: Int, i: Int)
	public private(set) var heap: [tuple] = []
	public private(set) var heapSize = 0

	public let parent = { (i: Int) in return (i-1)/2}
	public let left   = { (i: Int) in return i*2+1}
	public let right  = { (i: Int) in return i*2+2}

	public init() {}

	private func heapify(_ array: inout [tuple], _ heapSize: Int, _ i: Int) {
		let l = left(i)
		let r = right(i)
		var smallest = i

		if l < heapSize && array[l].val < array[i].val 		  {smallest = l}
		if r < heapSize && array[r].val < array[smallest].val {smallest = r}
		if smallest != i {
			array.swapAt(i, smallest)
			heapify(&array, self.heapSize, smallest)
		}
	}

	public mutating func insert(_ x: tuple) {
		self.heapSize += 1
		self.heap.insert(x, at: 0)
		heapify(&self.heap, self.heapSize, 0)
	}

	public var min: tuple {
		return self.heap[0]
	}

	public mutating func extractMin() -> tuple {
		if self.heapSize == 0 { return (val: Int.max, i: Int.max) }

		let min = self.min
		self.heap[0] = self.heap[self.heapSize-1]
		self.heapSize -= 1
		heapify(&self.heap, self.heapSize, 0)
		return min
	}
}


// The size of the augmented heap is k elements.
// Its invariant maintains that its min is the k'th smallest element in 
// the input heap! (because we're extracting min each time in loop)
// Augmentation needed because when we remove the min from the 
// augmented structure, we need its address in the original heap in order to add
// the correct children to take its place.
// (notice no method calls on input heap - that's how we avoid incurring 
// expensive computations on large data structure. Also why we need index in
// in orig data structure - we use that instead to find next smallest to add
// to our augmented structure)
//
// extractMin and insert take O(lg(size of array)) = O(lg(k)). There are k needed
// extraction/insertions, so: algorithm: O(k lg k)
//
func heapSelect(heap: MinHeap, at: Int) -> Int {

	var smallest_seen = MinHeap_Augmented()
	smallest_seen.insert( (val: heap.min, i: 0) )

	for _ in 1..<at {

		// remove min from helper and store its value and index
		let prev_min = smallest_seen.extractMin()

		// add the previous min's children (and their index) to helper heap
		let left_add  = heap.left(prev_min.i)
		let right_add = heap.right(prev_min.i)

		if left_add < heap.heapSize {
			smallest_seen.insert( (val: heap.heap[left_add],  i: left_add))
		}
		if right_add < heap.heapSize {
			smallest_seen.insert( (val: heap.heap[right_add], i: right_add))
		}
	}
	return smallest_seen.min.val
}

// regarding above, realize that the more brute force algorithm would simply call
// extractMin on the input heap k number of times in order to retrieve the k'th
// smallest value from the heap (likely done on a copy of the heap so as not to
// mutate the structure [doubling memory needed!]). The performance of this 
// algorithm would be O(k lg n), a difference probably not noticable for reasonable
// values of n. 

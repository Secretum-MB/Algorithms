import Foundation


// insertionSort, bubbleSort, humanSort are examples of Incremental algorithms

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


// mergeSort is an example of a Divide-and-conquer approach

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

			if L[L_i] < R[R_i] {
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


// heap sort runs in n lg n like mergeSort but does so by mutating 
// the input array in place, 'no' extra memory required!
//
func heapSort(_ arr: inout [Int]) {

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
}


// quickSort operates in n^2 in the worst case but averages n lg n and 
// is very often faster than heapSort/mergeSort for its small constant factor
//
// partitions input array into values < pivot, pivot, and >= pivot
// sorts the two edge partitions by calling itself on smaller subarrays
//
func quickSort(_ arr: inout [Int], _ start: Int, _ end: Int) {

	func partition(_ arr: inout [Int], _ start: Int, _ end: Int) -> Int {
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
		let q = partition(&arr, start, end)
		quickSort(&arr, start, q-1)
		quickSort(&arr, q + 1, end)
	}
} 


// quickSort with random pivoting
//
func quickSort_random(_ arr: inout [Int], _ start: Int, _ end: Int) {

	func partition_random(_ arr: inout [Int], _ start: Int, _ end: Int) -> Int {
		let random_i = Int.random(in: start...end)
		arr.swapAt(random_i, end)
		return partition(&arr, start, end)
	}

	func partition(_ arr: inout [Int], _ start: Int, _ end: Int) -> Int {
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
		let q = partition_random(&arr, start, end)
		quickSort(&arr, start, q-1)
		quickSort(&arr, q + 1, end)
	}
}



// The below algorithms do not use comparison to sort! They are therefore not
// bound to the worst case running time of n lg n. They can run in linear time!
// at the cost that some conditions must be met by the data to be sorted.



// countingSort requires that all values in input array are non-negative
// between 0 and k, and that we know the value of k going into it.
// it will work if you overestimate value for k, but not the other way.
// this slow it down very little. but realize this is LINEAR time sorting!!
// it is also Stable: duplicates appear in results in same order as they
// do in input array.
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


// another sorting algorithm, with expected running time of O(n) is bucketSort
// This one requires that all values in array be between [0 and 1). And ideally,
// the values are uniformely distributed (otherwise some slow-down)
// it loops over values and places them in a linked list. each i of list
// contains values beginning with .1, .2, .3, etc. 
// so one branch could have: .123, .1456, .100, etc.
// insetionSort is then used to sort each chain.
// then each chain is looped over populating result array

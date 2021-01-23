// Medians and Order Statistics
// as in, find the i'th smallest/largest value in an collection
// we can use a heap and the logic used in heapSort to do this in n lg n.
// we could also use mergeSort, also n lg n.
// Below we will discuss faster solutions.
// Although they compare elements they are not capped at n lg n because
// they do not sort the sequence. 
// Also, unlike the linear sorting algorithms, the below does not need to 
// make assumptions about the data under analysis!


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
// the expected running time is faster: here it is O(n).
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


// A more sophisticated version of the below called select() exists.
// this algorithm has worst case running time of O(n).
// it uses a modified version of the partition function from quicSort
// it performs this well by guaranteeing a good split in partitioning.
// textbook did not provide code and said it was more of theoretical interest.

// functions for comparing the performance of our various algorighms
//

import Foundation

// generate matrices of varying size and compare performance of above
//
// the memo algorithm hard coded because different input paramters
func matrix_performance_test(n: Int, dims: Array<Int>, max_element: Int) {

	// test parameters
	let sample_size = n				// number of random matrices of each size 
	let test_dim = dims				// the dimensions of matrices tested
	let max_element = max_element	// cap on largest element in matrix
	let algorithms = [matrixDeterminant,
					  matrixDeterminant_selective,
					  matrixDeterminant_triangle]

	var test_matrix: Matrix = []
	var temp: Array<Int> = []

	var results: [Int: Array<Double>] = [:]
	for each in 0..<algorithms.count {results[each] = []}
	results[3] = []	// notice hard coding for memo algorithm

	for dim in test_dim {
		for _ in 0..<sample_size {

			// seems like a necessary evil
			var start = DispatchTime.now()
			var end = DispatchTime.now()
			var nanotime: UInt64

			// create test matrix
			for _ in 0..<dim {
				for _ in 0..<dim{
					temp.append(Int.random(in: 0...max_element))
				}; test_matrix.append(temp); temp = []
			}

			// testing algorithms in array (taking one input param)
			for (i, algorithm) in algorithms.enumerated() {
				start = DispatchTime.now()
				_ = algorithm(test_matrix)
				end = DispatchTime.now()
				nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
				results[i]?.append(Double(nanotime) / 1_000_000_000)
			}

			// test memo algorithm which had different signature
			var memo: [Matrix: Int] = [:]
			start = DispatchTime.now()
			_ = matrixDeterminant_memo(matrix: test_matrix, memo: &memo)
			end = DispatchTime.now()
			nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
			results[3]?.append(Double(nanotime) / 1_000_000_000)

			test_matrix = []
		}

		// analyze results for this dimension
		var total_time = 0.0
		for (algo, _ ) in results {
			for each in results[algo]! {
				total_time += each
			}
			results[algo]?.append(total_time / Double(sample_size))
			total_time = 0.0
		}

		// display results for this dimension of matrices
		for (algo, values) in results.sorted(by: {$0.key < $1.key}) {
			print("Algorithm \(algo) solved \(sample_size) \(dim)X\(dim)",
				  "matrices in an average of \(values.last!) seconds")
		}
		// clear results from this dimension to prep for next
		for (key, _) in results {results[key] = []}
		print()
	}
}


// tests whether input array is sorted
func _isSorted( _ lst: [Int]) -> Bool {

	for each in 0..<max(0, lst.count-1) {
		if !(lst[each] <= lst[each+1]) {
			return false
		}
	}
	return true
}


func sorting_performance_test(n: Int, dims: Array<Int>) {

	// test parameters
	let sample_size = n			// number of random tests of each size 
	let test_dim = dims			// the dimensions of arrays tested

	let algorithms: [Any] = [insertionSort, bubbleSort, humanSort,
							heapSort, mergeSort,
							quickSort, quickSort_random,
							countingSort]

	var results: [Int: Array<Double>] = [:]
	for each in 0..<algorithms.count {results[each] = []}

	// seems like a necessary evil
	var start = DispatchTime.now()
	var end = DispatchTime.now()
	var nanotime: UInt64

	for dim in test_dim {
		for _ in 0..<sample_size {

			let test_array = _randomArray(dim, 0, 999)
			var copy_test_array = test_array

			for (i, algorithm) in algorithms.enumerated() {
				
				start = DispatchTime.now()
				
				// first three algos and heapSort
				if let algo = algorithm as? ([Int]) -> [Int] {
					_ = algo(test_array)

				// mergeSort and quickSort
				} else if let algo = algorithm as? (inout [Int], Int, Int) -> () {
					copy_test_array = test_array
					algo(&copy_test_array, 0, copy_test_array.count-1)

				// countingSort
				} else if let algo = algorithm as? ([Int], Int) -> [Int] {
					_ = algo(test_array, 999)
				}

				end = DispatchTime.now()
				nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
				results[i]?.append(Double(nanotime) / 1_000_000_000)
			}
		}

		// analyze results for this dimension
		var total_time = 0.0
		for (algo, _ ) in results {
			for each in results[algo]! {
				total_time += each
			}
			results[algo]?.append(total_time / Double(sample_size))
			total_time = 0.0
		}

		// display results for this dimension of matrices
		for (algo, values) in results.sorted(by: {$0.key < $1.key}) {
			print("Algorithm \(algo) sorted \(sample_size) arrays of size",
				  "\(dim) in an average of \(values.last!) seconds")
		}
		// clear results from this dimension to prep for next
		for (key, _) in results {results[key] = []}
		print()
	}
}

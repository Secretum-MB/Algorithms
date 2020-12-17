// recursive algorithms for determining Determinant of square matrix

import Foundation
import Fractions


typealias Matrix = Array<Array<Int>>


// plain recursive implementation of determinant algorithm
//
func matrixDeterminant (matrix: Matrix) -> Int {

	// not adequate but showing feature here only
	precondition(matrix.count == matrix[0].count, "matrix wrong size")

	// determinant of 2x2 matrix is elements a*d-b*c
	if matrix.count == 2 {
		return (matrix[0][0] * matrix[1][1]) - (matrix[0][1] * matrix[1][0])
	}

	// matrix is greater than 2x2:

	// we're just using the first row of matrix for computation
	let row_choice = 0

	var result: Int = 0
	for coef in 0..<matrix[row_choice].count {

		// no need to solve determinants that will be scaled by zero
		if matrix[row_choice][coef] == 0 {continue}
		
		// find minor matrix
		var minor: Matrix = []
		var temp: Array<Int> = []
		for row in 0..<matrix.count {
			if row == row_choice {continue}
			for element in 0..<matrix[row].count {
				if element != coef {temp.append(matrix[row][element])}
			}; minor.append(temp); temp = []
		}

		result += Int(pow(-1, Double(coef + row_choice)))
				* matrix[row_choice][coef]
				* matrixDeterminant(matrix: minor)
	}
	return result
}


// smarter: will pick which row/column to perform computations with
//
// sadly, this is slower. reason is there are not often enough
// rows/col that have a great number of 0s and this function does extra
// work every time it recurses down. Larger matrices: the worse it compares
func matrixDeterminant_selective(matrix: Matrix) -> Int {

	// determinant of 2x2 matrix is elements a*d-b*c
	if matrix.count == 2 {
		return (matrix[0][0] * matrix[1][1]) - (matrix[0][1] * matrix[1][0])
	}

	// matrix is greater than 2x2:

	// instead of seperate algorithms for rows/columns, transpose matrix
	var transpose: Matrix = []
	var temp: Array<Int> = []
	for col in 0..<matrix.count {
		for row in 0..<matrix.count {
			temp.append(matrix[row][col])
		}; transpose.append(temp); temp = []
	}

	// determine which row or column saves on computation
	var best_strat = (matrix: matrix, row: 0, num_zeros: 0)
	for each in [matrix, transpose] {
		for row in 0..<each.count {
			if each[row].filter({$0 == 0}).count > best_strat.num_zeros {
				best_strat = (each, row, each[row].filter{$0 == 0}.count)
			}
		}
	}

	// matrix and row we'll use for computation
	let comp_matrix = best_strat.matrix
	let row_choice = best_strat.row

	var result: Int = 0
	for coef in 0..<comp_matrix[row_choice].count {
		
		// no need to solve determinants that will be scaled by zero
		if comp_matrix[row_choice][coef] == 0 {continue}

		// find minor matrix
		var minor: Matrix = []
		var temp: Array<Int> = []
		for row in 0..<comp_matrix.count {
			if row == row_choice {continue}
			for element in 0..<comp_matrix[row].count {
				if element != coef {temp.append(comp_matrix[row][element])}
			}; minor.append(temp); temp = []
		}

		result += Int(pow(-1, Double(coef + row_choice)))
				* comp_matrix[row_choice][coef]
				* matrixDeterminant_selective(matrix: minor)
	}
	return result
}


// Building off the original algorithm we add memmoization
//
// Much much faster. Can do much larger matrices than above two.
// for a 9x9: recursive dept is 500 vs. ~25,000 for above two
// importantly: grows much slower: at 10x10: 1000 vs ~260,000!
// 11x11: 2000 vs 15million and 7million (max_element=9)
// 
// solved 11x11 in 0.04 sec; first took 14.3; second = 27.7

func matrixDeterminant_memo(matrix: Matrix, memo: inout [Matrix: Int]) -> Int {

	// determinant of 2x2 matrix is elements a*d-b*c
	if matrix.count == 2 {
		return (matrix[0][0] * matrix[1][1]) - (matrix[0][1] * matrix[1][0])
	}

	// matrix is greater than 2x2:

	// we're just using the first row of matrix for computation
	let row_choice = 0

	var result: Int = 0
	for coef in 0..<matrix[row_choice].count {

		// no need to solve determinants that will be scaled by zero
		if matrix[row_choice][coef] == 0 {continue}
		
		// find minor matrix
		var minor: Matrix = []
		var temp: Array<Int> = []
		for row in 0..<matrix.count {
			if row == row_choice {continue}
			for element in 0..<matrix[row].count {
				if element != coef {temp.append(matrix[row][element])}
			}; minor.append(temp); temp = []
		}

		// check if minor is already in the memo dictionary
		if let stored = memo[minor] {
			result += Int(pow(-1, Double(coef + row_choice)))
					* matrix[row_choice][coef]
					* stored
		} else {
			memo[minor] = matrixDeterminant_memo(matrix: minor, memo: &memo)
			result += Int(pow(-1, Double(coef + row_choice)))
					* matrix[row_choice][coef]
					* memo[minor]!
		}
	}
	return result
}


// constructs a upper triangle matrix to facilitate solution 
// basic row operations to create reduced row echelon form,
// then multiply the values down the main diagonal, ans is det()
// i'm using my own algorithm to reduce to traingle matrix..
//
// fastest by far! solved 14x14 in 0.00043 sec. Memo took 0.523 secs
// issue is precision, it will have rounding errors as det grows
func matrixDeterminant_triangle(matrix: Matrix) -> Int {

	typealias MatrixF = Array<Array<Float80>>

	func helper_rowSwap( _ matrix: inout MatrixF, _ row: Int, _ col: Int,
		_ scalars: inout Array<Float80>) -> Bool {

		var swap_row = false
		for i in row..<matrix.count {
			if matrix[i][col] != 0.0 {
				matrix.swapAt(row, i)
				scalars.append(-1)
				swap_row = true
				break
			}
		}
		return swap_row
	}

	// scales/subtracts/both the values in row vector
	func helper_scalSub( _ matrix: inout MatrixF, _ row: Int, _ col: Int,
		_ scalars: inout Array<Float80>, _ operation: String) {
		
		if operation == "scale" {
			scalars.append(1 / matrix[row][col])
			matrix[row].enumerated().forEach {index, _ in
				matrix[row][index] *= scalars[scalars.count - 1]
			}
		} else if operation == "sub" {
			matrix[row].enumerated().forEach {index, _ in
				matrix[row][index] -= matrix[col][index]
			}
		} else if operation == "both" {
			scalars.append(1 / matrix[row][col])
			matrix[row].enumerated().forEach {index, _ in
				matrix[row][index] *= scalars[scalars.count - 1]
				matrix[row][index] -= matrix[col][index]
			}
		}
	}

	var row: Int = 0
	var col: Int = 0
	var swap: Bool
	var scalars: [Float80] = []
	var result: Float80 = 1.0

	var matrixF: MatrixF = []
	for row in 0..<matrix.count {
		matrixF.append([])
		for each in matrix[row] {
			matrixF[row].append(Float80(each))
		}
	}

	repeat {

		var element = matrixF[row][col]

		// sets right the first row vector
		if row == 0 {
			if element == 1.0 {
				row += 1
			} else if element == 0.0 {
				swap = helper_rowSwap(&matrixF, row, col, &scalars)
				if !swap {return 0}
			} else {
				helper_scalSub(&matrixF, row, col, &scalars, "scale")
				row += 1
			}; continue
		}

		// transform row vectors 2 through end
		// each iteration here is for a seperate column in row vector
		// this makes row lead with proper number of zeros
		for _ in 0..<row {

			element = matrixF[row][col]

			if element == 0.0 {
				col += 1
			} else if element == 1.0 {
				helper_scalSub(&matrixF, row, col, &scalars, "sub")
				col += 1
			} else {
				helper_scalSub(&matrixF, row, col, &scalars, "both")
				col += 1
			}
		}

		// set number after leading zeros to be 1
		element = matrixF[row][col]

		if element == 1.0 {
			row += 1; col = 0
		} else if element == 0.0 {
			swap = helper_rowSwap(&matrixF, row, col, &scalars)
			if !swap {return 0}
			col = 0
		} else {
			helper_scalSub(&matrixF, row, col, &scalars, "scale")
			row += 1; col = 0
		}

	} while (row < matrix.count)

	scalars.forEach { scalar in
		result *= 1 / scalar
	}

	return Int(round(result))
}


// here I'm utilizing my Fractins library and instead of my crappy attempt
// at trianglization where I make 1's down the diagonal, 
// here I use what I think is the Gauss elimination algorithm
//
func matrixDeterminant_triangle_Gauss(matrix: Matrix) -> Int {

	typealias MatrixF = Array<Array<Fraction>>

	func swapRows() -> Bool {
		for i in pivot.pos..<matrixF.count {
			if matrixF[i][pivot.pos].numerator != 0 {
				matrixF.swapAt(pivot.pos, i)
				scalars.append(Fraction(-1))
				return true
			}
		}
		return false
	}

	// mutate row to conform with upper triangular matrix
	func scale_subtract(_ row: Int, _ bad_term: Fraction) {
		
		let scalar: Fraction = pivot.val / bad_term
		scalars.append(scalar.reciprocal)

		for col in pivot.pos..<matrixF.count {
			matrixF[row][col] *= scalar
			matrixF[row][col] -= matrixF[pivot.pos][col]
		}
	}

	var pivot = (pos: 0, val: Fraction(0))
	var scalars: [Fraction] = []

	var matrixF: MatrixF = []
	for row in 0..<matrix.count {
		matrixF.append([])
		for each in matrix[row] {
			matrixF[row].append(Fraction(each))
		}
	}

	while pivot.pos < matrixF.count {

		if matrixF[pivot.pos][pivot.pos].numerator == 0 {
			if !swapRows() {return 0}
		}

		pivot.val = matrixF[pivot.pos][pivot.pos]
		scalars.append(pivot.val)

		for row in pivot.pos+1..<matrixF.count {
			if matrixF[row][pivot.pos].numerator == 0 {continue}

			let bad_term = matrixF[row][pivot.pos]
			scale_subtract(row, bad_term)
		}

		pivot.pos += 1
	}

	var result: Fraction = 1
	scalars.forEach { scalar in
		result *= scalar
	}

	return Int(result)
}



func run_matrixDeterminant() {

	//performance_test(n: 30, dims: [5,6,7], max_element: 25)

	let test_matrix = _randomMatrix(size: 10)

	//let simp = [[3,5,1,2], [1,2,0,3], [2,4,1,2], [0,1,1,1]]


	//print(matrixDeterminant(matrix: test_matrix))
	//print(matrixDeterminant_selective(matrix: test_matrix))

	// must create an dict in memory to pass by reference
	var memo: [Matrix: Int] = [:]
	print("memo says:", matrixDeterminant_memo(matrix: test_matrix, memo: &memo))
	
	print("triangle :", matrixDeterminant_triangle_Gauss(matrix: test_matrix))
}

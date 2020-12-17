// implement data structures here that will be used throughout the module
//

func _randomArray(_ size: Int, _ min: Int, _ max: Int) -> [Int] {

	return (0..<size).map { _ in .random(in: min...max)}
}


// create random square matrix for use in testing our algorithms
//
func _randomMatrix(size: Int) -> Matrix {

	var matrix: Matrix = []
	var temp: Array<Int> = []

	for _ in 0..<size {
		for _ in 0..<size{
			temp.append(Int.random(in: -1...4))
		}; matrix.append(temp); temp = []
	}
	return matrix
}


// This fuction can be used to retrive the memory address of structs
// Usage: print( String(format: "%p", address(&obj)) )
// The object must be a var, not a let constant.. not sure why.
//
func address(_ ptr: UnsafeRawPointer) -> Int
{
    return Int(bitPattern: ptr)
}


// For measuring the badness of right justifying text in a block.
// Allegedly the function used by LaTeX for this purpose.
// Goal is to minimize sum of this value across all lines in block.
//
func badness(of block: [String], _ i: Int, _ j: Int) -> Int
{
    let PAGE_WIDTH = 95

    // spaces between words: this is the number of words on line minus 1
    let num_spaces = j - i

    var width = num_spaces
    for word in i...j {
        width += block[word].count
    }

    if width > PAGE_WIDTH { return Int.max }

    let utilized = PAGE_WIDTH - width

    return utilized * utilized * utilized
}


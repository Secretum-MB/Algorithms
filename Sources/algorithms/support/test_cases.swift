
// opens a text file and pulls the text into an array, split on whitespace
//
func test_DP_textJustify() -> [String]
{
    let path: String
    path = 
        "/home/mathias/Documents/Projects/Swift/algorithms/Resources/txt_file.txt"

    let import_string = try? String(contentsOfFile: path)

    let improv_string = import_string?.replacingOccurrences(of: "\n", with: "")

    let txt_array = improv_string?.split(separator: " ").map(String.init)
    guard txt_array != nil else { 
        return [""]
    }

    return txt_array!
}

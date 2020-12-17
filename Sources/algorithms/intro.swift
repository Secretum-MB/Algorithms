import Foundation


func maxProfit(_ lst: [Int]) -> (Int, Int, Int) {

	var buy_hope = 0
	var decision = (buy: 0, sell: 1, profit: lst[1] - lst[0])
	
	for price in 1..<lst.count {

		if lst[price] < lst[buy_hope] {
			buy_hope = price
		} else if lst[price] - lst[buy_hope] > decision.profit {
			decision.buy = buy_hope
			decision.sell = price
			decision.profit = lst[price] - lst[buy_hope]
		}
	}
	return decision
}


// correct and linear, but slightly slower then second version
func maxSubArray(_ nums: [Int]) -> Int {

	var best_sum = 0
	var hope_sum = 0
	var start_wanted = true

	for (i, num) in nums.enumerated() {

		if i == 0 {
			best_sum = num
			hope_sum = num
			if num >= 0 {start_wanted = false}
		} else if best_sum < 0 && num > best_sum {
			best_sum = num
			hope_sum = num
			start_wanted = num > 0 ? false : true
		} else if num < 0 && hope_sum + num < 0 {
			start_wanted = true
		} else if num < 0 && hope_sum + num >= 0 {
			hope_sum += num
		} else if num >= 0 {
			if !start_wanted {
				hope_sum += num
			} else {
				hope_sum = num
				start_wanted = false
			}
			if hope_sum >= best_sum {
				best_sum = hope_sum
			}
		}
	}
	return best_sum
}


func maxSubArray2(_ nums: [Int]) -> Int {

	var current_best = nums[0]
	var best = nums[0]

	for num in nums[1...] {

		current_best = max(current_best + num, num)
		best = max(best, current_best)
	}
	return best
}


func longestSubString(_ str: String) -> Int {

	var dict: [Character: Int] = [:]
	var longest = 0
	var anchor = 0

	for (i, char) in str.enumerated() {

		if let duplicate = dict[char] {
			longest = max(longest, i-anchor)
			anchor = max(anchor, duplicate + 1)
			dict[char] = i
		} else {
			dict[char] = i
		}
	}
	return max(longest, str.count - anchor)
}

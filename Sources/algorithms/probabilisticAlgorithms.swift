// various prbabilistic algorighms
import Foundation

// how many people need to be in a room for even odds that two people share birthdays?
func same_birthday(start_guess: Int = 10, trials: Int = 50, goal: Double = 0.5) -> Int {
	
	var group_size = start_guess - 1
	var average_probability = 0.0

	while average_probability < goal {

		group_size += 1
		var num_matches_in_trials = 0

		for _ in 1...trials {

			let group = _randomArray(group_size, 1, 365)
			var help_set = Set<Int>()

			for each in group {
				if help_set.contains(each) {
					num_matches_in_trials += 1
					break
				} else {
					help_set.insert(each)
				}
			}
		}
		average_probability = Double(num_matches_in_trials) / Double(trials)
	}

	return group_size
}


// how many coupons to collect before you have at least one of each in collection
// or, how many ball throws until you have at least one ball in each bin
//
// as the number of bins/coupons to collect increases we approach theoretical result
func coupon_collectors_problem() {

	let bin_count = [100, 500, 1_000, 5_000]
	let sample_size = 200

	for bin in bin_count {

		var trial_results: [Int] = []

		for _ in 1...sample_size {

			var needed_tries = 0
			var bins_hit = 0
			var bins = Array(repeating: 0, count: bin)

			while bins_hit < bin {
				needed_tries += 1
				let rand_choice = Int.random(in: 0...bin-1)

				if bins[rand_choice] == 0 {
					bins[rand_choice] = 1
					bins_hit += 1
				}
			}
			trial_results.append(needed_tries)
		}

		var sum_of_results = 0
		trial_results.forEach { each in
			sum_of_results += each
		}
		let average_tries = Double(sum_of_results) / Double(sample_size)
		let expected_result = Double(bin) * log(Double(bin))
		let delta = abs(average_tries - expected_result) / expected_result

		print("Averaged \(average_tries) tries to collect all \(bin).", 
			  "n x ln(n) = \(expected_result). Delta% = \(delta)")
		print()
	}
}


// given random coin flips, what is the longest streak of Heads we can expect
//
// like coupon_collectors_problem solution approaches theory as inputs increase
func longest_streak_of_heads() {

	func _longestStreak(_ lst: [Int]) -> Int {
		var best_streak = 0
		var current = 0

		for flip in lst {
			if flip == 1 {current += 1}
			if flip == 0 {current = 0}

			if current > best_streak {best_streak = current}
		}
		return best_streak
	}

	let bin_count = [500, 1_000, 5_000]
	let sample_size = 250

	for bin in bin_count {

		var trial_results: [Int] = []

		for _ in 1...sample_size {

			let random_flips = _randomArray(bin, 0, 1)
			let streak = _longestStreak(random_flips)

			trial_results.append(streak)
		}

		var sum_of_results = 0
		trial_results.forEach { each in
			sum_of_results += each
		}
		let average_streak = Double(sum_of_results) / Double(sample_size)
		let expected_result = log2(Double(bin))
		let delta = abs(average_streak - expected_result) / expected_result

		print("Averaged streak of \(average_streak) Heads in \(bin) flips.", 
			  "lg(n) = \(expected_result). Delta% =\(delta)")
		print()	
	}
}


// you'd like to hire the best person, but must decide after each interview whether to
// hire the person or pass on them. you could interview all and hire best but this is 
// expensive for the firm. You believe the distribution of candidates to be random.
// This solution interviews k people, sets the bar after the best of them. Then interviews
// the rest and hires the first person who exceeds that treshold, or if none do, the last.
//
// at what value k is the probability of hiring the best person maximized?
func hiring_problem() {

	// array's values are candidate's rank
	func best_hire(_ candidates: [Int], _ k: Int) -> Int {
		var best = candidates.count+1

		for bar_setter in 0..<k {
			if candidates[bar_setter] < best {best = candidates[bar_setter]}
		}
		for candidate in k..<candidates.count {
			if candidates[candidate] < best {return candidates[candidate]}
		}
		return candidates[candidates.count-1]	
	}

	let interview_pool = [10, 50, 200]
	let sample_size = 250

	for pool in interview_pool {

		var k_result: [Int: Double] = [:]

		for each_k in 1...pool-1 {

			var num_successes = 0

			for _ in 1...sample_size {

				let candidates = Array(1...pool).shuffled()
				let hired = best_hire(candidates, each_k)
				
				if hired == 1 {num_successes += 1}
			}
			k_result[each_k] = Double(num_successes) / Double(sample_size)
		}

		let best_prob = k_result.values.max() ?? 0.0
		var best_k: Int = 0
		for (key, _) in k_result {
			if k_result[key] == best_prob {
				best_k = key; break
			}
		}
		print("with \(pool) candidates: best results are to initially interview",
			  "\(best_k) candidates; probability of hiring the best: \(best_prob)")
		let k_theory = Double(pool) / 2.71828182846
		let success_theory = Double(1) / 2.71828182846
		print("Calculus says k ought be n/e, or, \(k_theory); And, that the probability",
			  "of hiring the best candidate ought to be 1/e, or, \(success_theory).")
		print()
	}
}

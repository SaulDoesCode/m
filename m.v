import os
import os.cmdline
import strconv
import math
/*
import io
import net
import crypto.rand
*/

type FN = fn (mut SR, ...string) ?string
type ESC = map[string]FN

struct SR {
pub mut:
	wok string
	op string
	buf []u8
	args []string
	skip bool
	replacing bool
	replacement []u8
	otherwise bool
	quoting bool /*mode u8 subm u8*/
	std ESC
	bounds map[string]u8
	scripts map[string]string
	esc map[string]ESC
	state map[string]string
	lists map[string][]string
	numbers map[string]f64
}

fn (mut s SR) ub() string { // unbuf 
	str := s.buf.bytestr()
	s.buf.clear()
	return str
}

fn (mut s SR) chwok() {
	w := s.ub()
	if w.len == 0 { return } else { s.wok = w.trim_space() }
	if s.wok in s.std {
		s.op = s.wok  // println("found op ${s.op}")
	} else if s.wok != " " && s.wok != "" {
		s.args << s.wok // println("found arg ${s.args.last()}")
		if s.op == "" { // println("args ${s.args}")
			if s.args.len == 2 { // s.numbers[s.args.pop()] = strconv.atof64(s.args.pop()) or { 0 }
				if s.args[1][0] == `#` {
					s.numbers[s.args[1].trim_left("#")] = strconv.atof64(s.args[0]) or { 0 } // println("delared number ${s.args[1]} as ${s.args[0]}")
				} else {
					s.state[s.args[1]] = s.args[0] // println("delared ${s.args[1]} as ${s.args[0]}")
				}
				s.args.clear()
			}
		} else if s.bounds[s.op] == s.args.len { //println("op ${s.op} with ${s.args}")
			args := s.args.clone()
			s.args.clear()
			op := s.op
			s.op = ""
			mut suspend_quoting := false
			if s.quoting {
				s.quoting = false
				suspend_quoting = true
			}
			if out := s.std[op](mut s, ...args) {
				s.munch(out)
			}
			if suspend_quoting {
				s.quoting = true
			}
		}
	}
	s.wok = ""
}

fn (mut s SR) interpret(t u8) { // caduca
	if s.quoting {
		if t == `\`` {
			s.quoting = false
			s.args << s.ub() //println("\tend quote ${s.args.last()}")
			if s.op != "" && s.bounds[s.op] == s.args.len { //println("op ${s.op} with ${s.args}")
				args := s.args.clone()
				s.args.clear()
				op := s.op
				s.op = ""
				mut suspend_quoting := false
				if s.quoting {
					s.quoting = false
					suspend_quoting = true
				}
				if out := s.std[op](mut s, ...args) { s.munch(out) }
				if suspend_quoting {
					s.quoting = true
				}
			}
		} else if t == `^` {
			s.buf << `\``
		} else {
			if t == `~` {
				s.replacing = true
			} else {
				if s.replacing { // if t == ` ` || t == `\n` {}
					s.replacement << t
					if s.replacement.bytestr() in s.state {
						s.ingest(s.state[s.replacement.bytestr()])
						s.replacement.clear()
						s.replacing = false
					} else if s.replacement.bytestr() in s.numbers {
						s.ingest(s.numbers[s.replacement.bytestr()].str())
						s.replacement.clear()
						s.replacing = false
					}
				} else {
					s.buf << t
				}
			}
		}
	} else {
		match t {
			`\`` {
				s.quoting = true // print("\nstart quote")
			}
			` `, `\n` { s.chwok() }
			else { s.buf << t }
		}
	}
}

fn (mut s SR) ingest(loaf string) {
	for crumb in loaf {
		s.buf << crumb
	}
}

fn (mut s SR) munch(src string) { // println("i monch ${src}")
	for t in src { s.interpret(t) }
	s.chwok()
}

fn (mut s SR) routine(moniker string, f FN, bounds u8) {
	s.std[moniker] = f
	s.bounds[moniker] = bounds
}

fn main() {
	mut s := SR {}
	s.routine("i", fn(mut s SR, args ...string) ?string {
		os.write_file(args[0], args[1]) or { panic(err) }
		return none
	}, 2)
	s.routine("+i", fn(mut s SR, args ...string) ?string {
		mut p := os.open_append(args[0]) or { panic(err) } 
		p.write(args[1].bytes()) or { panic(err) }
		p.close()
		return none
	}, 2)
	s.routine("m", fn(mut s SR, args ...string) ?string {
		os.mv(args[0], args[1], os.MvParams{
			overwrite: true
		}) or { panic(err) }
		return none
	}, 2)
	s.routine("o", fn(mut s SR, args ...string) ?string {
		s.state[args[0]] = os.read_file(args[0]) or { panic(err) }
		return none
	}, 1)
	s.routine(">", fn(mut s SR, args ...string) ?string {
		println(args[0])
		return none
	}, 1)
	s.routine("n", fn(mut s SR, args ...string) ?string {
		s.numbers[args[1]] = strconv.atof64(args[0]) or { 0 }
		return none
	}, 2)
	s.routine("+", fn(mut s SR, args ...string) ?string {
		if args[0].contains_only("0123456789.") && args[0].contains_only("0123456789.") {
			n := strconv.atof64(args[0]) or { panic(err) }
			n1 := strconv.atof64(args[1]) or { panic(err) }
			s.numbers["="] = n + n1
		} else {
			n := s.numbers[args[0]]
			n1 := s.numbers[args[1]]
			s.numbers["="] = n + n1
		}
		return none
	}, 2)
	s.routine("-", fn(mut s SR, args ...string) ?string {
		if args[0].contains_only("0123456789.") && args[0].contains_only("0123456789.") {
			n := strconv.atof64(args[0]) or { panic(err) }
			n1 := strconv.atof64(args[1]) or { panic(err) }
			s.numbers["="] = n - n1
		} else {
			n := s.numbers[args[0]]
			n1 := s.numbers[args[1]]
			s.numbers["="] = n - n1
		}
		return none
	}, 2)
	s.routine("*", fn(mut s SR, args ...string) ?string {
		if args[0].contains_only("0123456789.") && args[0].contains_only("0123456789.") {
			n := strconv.atof64(args[0]) or { panic(err) }
			n1 := strconv.atof64(args[1]) or { panic(err) }
			s.numbers["="] = n * n1
		} else {
			n := s.numbers[args[0]]
			n1 := s.numbers[args[1]]
			s.numbers["="] = n * n1
		}
		return none
	}, 2)
	s.routine("/", fn(mut s SR, args ...string) ?string {
		if args[0].contains_only("0123456789.") && args[0].contains_only("0123456789.") {
			n := strconv.atof64(args[0]) or { panic(err) }
			n1 := strconv.atof64(args[1]) or { panic(err) }
			s.numbers["="] = n / n1
		} else {
			n := s.numbers[args[0]]
			n1 := s.numbers[args[1]]
			s.numbers["="] = n / n1
		}
		return none
	}, 2)
	s.routine("**", fn(mut s SR, args ...string) ?string {
		if args[0].contains_only("0123456789.") && args[0].contains_only("0123456789.") {
			n := strconv.atof64(args[0]) or { panic(err) }
			n1 := strconv.atof64(args[1]) or { panic(err) }
			s.numbers["="] = math.pow(n, n1)
		} else {
			n := s.numbers[args[0]]
			n1 := s.numbers[args[1]]
			s.numbers["="] = math.pow(n, n1)
		}
		return none
	}, 2)
	s.routine("#", fn(mut s SR, args ...string) ?string {
		s.numbers[args[0]] = s.numbers["="] // println("declared number result ${s.numbers["="]} into variable ${args[0]}")
		s.numbers.delete("=")
		return none
	}, 1)	
	s.routine("~", fn(mut s SR, args ...string) ?string {
		s.scripts[args[0]] = args[1].replace("__", "`").replace("##", "__")
		// return "> `stored script ${args[0]}`"
		return none
	}, 2)
	s.routine(".", fn(mut s SR, args ...string) ?string {
		s.munch(s.scripts[args[0]])
		// return "> `ran script ${args[0]}`"
		return none
	}, 1)
	s.routine("%", fn(mut s SR, args ...string) ?string {
		s.otherwise = !s.otherwise
		return none
	}, 0)
	s.routine("=", fn(mut s SR, args ...string) ?string {
		s.otherwise = args[0] == args[1]
		return none
	}, 2)
	s.routine("!=", fn(mut s SR, args ...string) ?string {
		s.otherwise = args[0] != args[1]
		return none
	}, 2)
	s.routine(";", fn(mut s SR, args ...string) ?string {
		if s.otherwise {
			s.otherwise = args[0] != args[1]
		}
		return none
	}, 2)
	s.routine("?", fn(mut s SR, args ...string) ?string {
		if s.otherwise { s.munch(args[0]) } return none
	}, 1)
	s.routine("!", fn(mut s SR, args ...string) ?string {
		if !s.otherwise { s.munch(args[0]) } return none
	}, 1)
	s.routine("r", fn(mut s SR, args ...string) ?string {
		mut reps := strconv.atoi(args[0]) or { panic(err) }
		mut script := ""
		if reps > 0 {
			for {
				script += ". " + args[1] + " "
				reps--
				if reps == 0 { break }
			}
		}
		return script
	}, 2)
	s.routine("<", fn(mut s SR, args ...string) ?string {
		r := os.execute(args[0])
		s.state["r"] = r.output
		return none
	}, 1)
	mut src := cmdline.option(os.args, 'src', "./main.m").str()
	s.munch(os.read_file(src) or { panic(err) })
}

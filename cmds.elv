use re
use str
use path

################################################ Utils
fn if-external { |prog lambda|
	if (has-external $prog) { $lambda }
}
fn is-path { |p|
	path:is-dir &follow-symlink $p
}
fn is-file { |p|
	path:is-regular &follow-symlink $p
}
fn append-to-path { |@path|
	each {|p| set paths = [ $@paths $p ] } $path
}
fn prepend-to-path { |path|
	set paths = [ $path $@paths ]
}
fn newelves { 
	var sep = "----------------------------"
	curl "https://api.github.com/repos/elves/elvish/commits?per_page=8" |
	from-json |
	all (one) |
	each {|issue| echo $sep; echo (styled $issue[sha][0..12] bold): (styled (re:replace "\n" "  " $issue[commit][message]) yellow) }
}
fn repeat-each {|n f|
	range $n | each {|_| $f }
}
fn hexstring {|@n|
	if (is-empty $n) {
		put (repeat-each 32 { printf '%X' (randint 0 16) })
	} else {
		put (repeat-each $@n { printf '%X' (randint 0 16) })
	}
}
################################################ filtering functions
# var colors = [red orange yellow green blue purple]
# var cond = {|s| str:has-suffix $s 'e' }
# all $colors | filter-pipe { |in| re:match "e$" $in }
fn match {|in re| re:match $re $in }
fn filter {|re @in| 
	if (eq $in []) {
		each {|item| if ($match~ $item $re) { put $item } } 
	} else {
		each {|item| if ($match~ $item $re) { put $item } } $@in
	}
}
fn filterp {|re @in| 
	if (eq $in []) {
		peach {|item| if ($match~ $item $re) { put $item } } 
	} else {
		peach {|item| if ($match~ $item $re) { put $item } } $@in
	}
}
fn filterc {|cond re @in| 
	if (eq $in []) {
		each {|item| if ($cond $item $re) { put $item } } 
	} else {
		each {|item| if ($cond $item $re) { put $item } } $@in
	}
}

# see https://github.com/crinklywrappr/rivendell 
fn is-zero {|n| == 0 $n }
fn is-empty {|li| is-zero (count $li) }
fn is-one {|n| == 1 $n }
fn is-even {|n| == (% $n 2) 0 }
fn is-odd {|n| == (% $n 2) 1 }
fn is-fn {|x| eq (kind-of $x) fn }
fn is-map {|x| eq (kind-of $x) map }
fn is-list {|x| eq (kind-of $x) list }
fn is-string {|x| eq (kind-of $x) string }
fn is-bool {|x| eq (kind-of $x) bool }
fn is-number {|x| eq (kind-of $x) !!float64 }
fn is-nil {|x| eq $x $nil }

fn check-pipe {|@li| # use when taking @args
	if (is-empty $li) { all } else { all $li }
}
fn test {|@in| # test to take either stdin or pipein
	var list = $nil
	if (is-empty $in) { set list = (all) } else { set list = $in[0] }
	put $list
}
fn flatten {|@in| # use when taking @args
	var list = $nil
	if (is-empty $in) { set list = (all) } else { set list = $in[0] }
	if (eq (kind-of $list) list) {
		for e $list { flatten $e }
	} else {
		put $list
	}
}

fn dec {|n| - $n 1 }
fn inc {|n| + $n 1 }
fn pos {|n| > $n 0 }
fn neg {|n| < $n 0 }

fn prepend {|li @args| put [(put $@args (all $li))] }
fn append  {|li @args| put [(put (flatten $li) $@args)] }
fn concat2 {|l1 l2| put [(flatten $l1) (flatten $l2)] }
fn pluck {|li n| put [(flatten $li[:$n]) (flatten $li[(inc $n):])] }
fn get {|li n| put $li[$n] } 
fn first {|li| put $li[0] }
fn ffirst {|li| first (first $li) }
fn second {|li| put $li[1] }
fn rest {|li| put $li[1:] }
fn end {|li| put $li[-1] }
fn butlast {|li| put $li[:(dec (count $li))] }

fn min2 {|a b|
	if (< $a $b) {
		put $a
	} else {
		put $b
	}
}

fn max2 {|a b|
	if (> $a $b) {
		put $a
	} else {
		put $b
	}
}

fn nth {|li n &not-found=$false|
	if (and $not-found (> $n (count $li))) {
		put $not-found
	} else {
		drop $n $li | take 1
	}
}
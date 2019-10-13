# One-Liner to show how to save some typing
Get-Verb | Where Group -eq "Diagnostic"
# No brackets and no pesky $_.

# That was CLI and has value but it opens another topic
# V4 introduced built-in methods for the Where and ForEach process
# Doesn't reduce typing but this is more about efficiency and 
# scripting
(get-verb).Where{$_.Group -eq "Diagnostic"}
# So with the parenthesis we store the object returned from the 
# get-verb cmdlet. The we call the Where method. 
# Why? Consider the law of filtering... since this is inline it 
# reduces the amount of hops


$cliWhere = measure-command -Expression {Get-Verb | Where Group -eq "Diagnostic"}
$methodWhere = Measure-Command -Expression {(get-verb).Where{$_.Group -eq "Diagnostic"}}

"Using the CLI the desired results were returned in {0} milliseconds" -f $cliWhere.TotalMilliseconds
"Using the Inline method the desired results were returned in {0} milliseconds" -f $methodWhere.TotalMilliseconds

# Quick way to compare performance
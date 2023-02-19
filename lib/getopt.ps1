if ($__importedGetopt__ -eq $true) {
    return
} else {
    Write-Verbose 'Importing getopt'
}
$__importedGetopt__ = $false

# adapted from http://hg.python.org/cpython/file/2.7/Lib/getopt.py
# argv:
#    array of arguments
# shortopts:
#    string of single-letter options. options that take a parameter
#    should be follow by ':'
# longopts:
#    array of strings that are long-form options. options that take
#    a parameter should end with '='
# returns @(opts hash, remaining_args array, error string)
# TODO: Add support for -vv => $opt.$name++
function Resolve-GetOpt($argv, $shortopts, $longopts) {
    $opts = @{ }
    $rem = @()

    function err($msg) { return $opts, $rem, $msg }

    function regex_escape($str) { return [System.Text.RegularExpressions.Regex]::Escape($str) }

    # Ensure these are arrays
    $argv = @($argv)
    $longopts = @($longopts)

    for ($i = 0; $i -lt $argv.Length; $i++) {
        $arg = $argv[$i]
        if ($null -eq $arg) { continue }
        # Don't try to parse array arguments
        if ($arg -is [Array]) { $rem += , $arg; continue }
        if ($arg -is [Int]) { $rem += $arg; continue }
        if ($arg -is [Decimal]) { $rem += $arg; continue }
        if ($arg -is [Boolean]) { $rem += $arg; continue }
        if ($arg -is [System.Collections.Hashtable]) { $rem += $arg; continue }

        if ($arg.startswith('--')) {
            $name = $arg.Substring(2)
            $longopt = $longopts | Where-Object { $_ -match "^$name=?$" }

            if (!$longopt) { return err "Option --$name not recognized." }

            if ($longopt.EndsWith('=')) {
                # Requires arg
                if ($i -eq $argv.Length - 1) { return err "Option --$name requires an argument." }

                if ($opts.$name) {
                    if ($opts.$name -is [String]) {
                        $opts.$name = @($opts.$name)
                    }
                    $opts.$name += $argv[++$i]
                } else {
                    $opts.$name = $argv[++$i]
                }
            } else {
                $opts.$name = $true
            }
        } elseif ($arg.StartsWith('-') -and $arg -ne '-') {
            for ($j = 1; $j -lt $arg.Length; $j++) {
                $letter = $arg[$j].ToString()

                if ($shortopts -notmatch "$(regex_escape $letter):?") { return err "Option -$letter not recognized." }

                $shortopt = $Matches[0]
                if ($shortopt[1] -eq ':') {
                    if ($j -ne $arg.Length - 1 -or $i -eq $argv.Length - 1) {
                        return err "Option -$letter requires an argument."
                    }
                    if ($opts.$letter) {
                        if ($opts.$letter -is [String]) {
                            $opts.$letter = @($opts.$letter)
                        }
                        $opts.$letter += $argv[++$i]
                    } else {
                        $opts.$letter = $argv[++$i]
                    }
                } else {
                    $opts.$letter = $true
                }
            }
        } else {
            $rem += $arg
        }
    }

    return $opts, $rem
}

$__importedGetopt__ = $true

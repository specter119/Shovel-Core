if ($__importedGit__ -eq $true) {
    return
} else {
    Write-Verbose 'Importing Git'
}
$__importedGit__ = $false

'core' | ForEach-Object {
    . (Join-Path $PSScriptRoot "${_}.ps1")
}

function Invoke-GitCmd {
    <#
    .SYNOPSIS
        Git execution wrapper with -C parameter support.
    .PARAMETER Command
        Specifies git command to execute.
    .PARAMETER Repository
        Specifies fullpath to git repository.
    .PARAMETER Proxy
        Specifies the command needs proxy or not.
    .PARAMETER Argument
        Specifies additional arguments, which should be used.
    #>
    # TODO: Add progress parameter/indication
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('Cmd', 'Action')]
        [String] $Command,
        [String] $Repository,
        [Switch] $Proxy,
        [String[]] $Argument
    )

    begin {
        # Global options
        $preAction = @()
        if ($Repository) {
            $Repository = $Repository.TrimEnd('\').TrimEnd('/')
            $preAction = @('-C', "$Repository")
        }
        $preAction += '--no-pager'

        if ($Proxy -and $SHOVEL_IS_PROXY_ENABLED) {
            $prox = get_config 'proxy'
            $preAction += @('-c', "http.proxy=$prox", '-c', "https.proxy=$prox")
        }
    }

    process {
        switch ($Command) {
            'CurrentCommit' {
                $action = 'rev-parse'
                $Argument = $Argument + @('HEAD')
            }
            'Update' {
                $action = 'pull'
                $Argument += '--rebase=false'
                $Proxy = $true
            }
            'UpdateLog' {
                $action = 'log'
                $para = @(
                    '--invert-grep'
                    '--extended-regexp'
                    '--regexp-ignore-case'
                    '--no-decorate'
                    '--grep="\[(scoop|shovel) skip\]"' # Ignore [scoop skip] [shovel skip]
                    '--grep="^Merge [pcb]"' # Ignore merge commits
                    '--format="tformat: * %C(yellow)%h%Creset %<|(72,trunc)%s %C(cyan)%cr%Creset"'
                )
                $Argument = $para + $Argument
            }
            'VersionLog' {
                $action = 'log'
                $Argument += '--oneline', '--max-count=1', 'HEAD'
            }
            default { $action = $Command }
        }

        $commandToRun = ('git', ($preAction -join ' '), $action, ($Argument -join ' ')) -join ' '
        debug $commandToRun

        git @preAction $action @Argument
        if ($LASTEXITCODE -ne 0) { throw [ScoopException]::new('Cannot process git command') }
    }
}

$__importedGit__ = $true

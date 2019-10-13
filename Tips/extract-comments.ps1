Function Get-Comment {
Param(
    [Parameter(Position=0)]
    [String] $FilePath,
    [Switch] $FromClipBoard
)
    If($FilePath) {
        $Content = Get-Content $FilePath
    }
    elseif($FromClipBoard) {
        $Content = [Windows.clipboard]::GetText()
    }
    else {
        Write-Host "Please provide a file/content to look for comments."
    }
    $CommentTokens =  [System.Management.Automation.PSParser]::Tokenize($Content, [ref]$null) |
        Where-Object{$_.type -like "*comment*"}
    Foreach($obj in $CommentTokens) {
        $IndentSpace = ""
        If($obj.StartColumn -gt 1) {
            1..($obj.startcolumn - 1)| %{[String]$IndentSpace += " "}
            #$IndentSpace+$obj.content
        }
        ''| select @{n='Line';e={$obj.StartLine}}, @{n="Comment";e={$IndentSpace+$obj.Content}}
    }
}
$(
    foreach (
        $DC in (
            (get-addomaincontroller -filter * | Sort-Object name).name)
             ){ $user = get-aduser m.cruz -properties lastlogon -server $dc |
                Select-Object name,lastlogon ;
                Write-Output "$DC - $(w32tm /ntte $user.lastlogon)"
            }
)
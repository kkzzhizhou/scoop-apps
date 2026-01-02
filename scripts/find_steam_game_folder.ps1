function find_steam_game_folder([string] $game_id) {
    $steam_path = Get-ItemProperty -Path "HKCU:/Software/Valve/Steam" -Name "SteamPath" -ErrorAction Stop
    $library_folders_vdf = "$($steam_path.SteamPath)/steamapps/libraryfolders.vdf"

    $regex = [regex]::new('"[^"]*"')

    $streamReader = [System.IO.StreamReader]::new($library_folders_vdf)

    # simple state machine
    # 0=initial, 1=found path, 2=found app, 3=found app id
    $state = 0
    while (-not $streamReader.EndOfStream) {
        $line = $streamReader.ReadLine()
        $line = $line.Trim()

        if ($line -eq "}" -and $state -eq 2) {
            $state = 0
            continue
        }

        $match0 = $regex.Match($line)
        $token0 = $match0.Value

        if (($state -eq 0) -and ($token0 -eq '"path"')) {
            $match1 = $regex.Match($line, $match0.Index + $match0.Length)
            $library_path = $match1.Value.Trim('"')
            $state = 1
            continue
        }

        if (($state -eq 1) -and ($token0 -eq '"apps"')) {
            $state = 2
            continue
        }

        if ($state -eq 2 -and $token0 -eq """$game_id""") {
            $state = 3
            break
        }
    }
    $streamReader.Close()

    if ($state -ne 3) { throw "Game not found" }

    $library_path = $library_path -replace "\\\\", '/'
    $game_manifest = "$library_path/steamapps/appmanifest_$game_id.acf"

    $streamReader = [System.IO.StreamReader]::new($game_manifest)
    while (-not $streamReader.EndOfStream) {
        $line = $streamReader.ReadLine()

        $match0 = $regex.Match($line)

        if ($match0.Value -eq '"installdir"') {
            $match1 = $regex.Match($line, $match0.Index + $match0.Length)
            $game_install_name = $match1.Value.Trim('"')
            break
        }
    }
    $streamReader.Close()

    if (-not $game_install_name) { throw "Game install name not found" }

    $game_install_path = "$library_path/steamapps/common/$game_install_name"

    return $game_install_path
}

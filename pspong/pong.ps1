### add the necessary assembly ###
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-Menu([string[]]$Items) {
    [int]$UserSelection = 1
    [int]$MenuSize = 0

    # Get the menu size depending of the biger item
    foreach ($Item in $Items) {
        if ($Item.Length -gt $MenuSize) {
            $MenuSize = $Item.Length
        }
    }
    $MenuSize += 4

    # Start the menu loop never end until user press enter
    do {
        Clear-Host

        # Check for key presses outside the item loop
        $up = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::Up)
        $down = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::Down)
        $enter = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::Enter)

        # Update UserSelection position based on key press
        if ($up -and $UserSelection -gt 1) {
            $UserSelection--
            Start-Sleep -Milliseconds 200
        }
        elseif ($down -and $UserSelection -lt $Items.Count) {
            $UserSelection++
            Start-Sleep -Milliseconds 200
        }

        $Selector = 0; # To compare current indec vs user select to display the good color in menu
        foreach ($Item in $Items) {
            $Selector++
            [ConsoleColor]$MenuColor = [ConsoleColor]::Gray
            if ($Selector -eq $UserSelection) {
                $MenuColor = [ConsoleColor]::DarkCyan # Put item in cyan if it curently selected by user
            }

            # Render menu character by character
            [int]$MenuRender = 0
            do {
                Write-Host "=" -NoNewline -ForegroundColor $MenuColor
                $MenuRender++
            } while ($MenuRender -lt $MenuSize + 2)

            Write-Host "`n=" -NoNewline -ForegroundColor $MenuColor
            $MenuRender = 0
            $SpaceCount = (($MenuSize - $Item.Length - 1) / 2)
            do {
                Write-Host " " -NoNewline -ForegroundColor $MenuColor
                $MenuRender++
            } while ($MenuRender -lt $SpaceCount)
            Write-Host $Item -NoNewline -ForegroundColor $MenuColor
            $MenuRender = 0
            do {
                Write-Host " " -NoNewline -ForegroundColor $MenuColor
                $MenuRender++
            } while ($MenuRender -lt $SpaceCount)
            Write-Host "=" -ForegroundColor $MenuColor
            $MenuRender = 0
            do {
                Write-Host "=" -NoNewline -ForegroundColor $MenuColor
                $MenuRender++
            } while ($MenuRender -lt $MenuSize + 2)
            Write-Host "`n" -ForegroundColor $MenuColor
        }
        
        # Check if user as press enter if yes exit menu and return user choice
        if ($enter) {
            [console]::Beep(600, 80)
            $select = $true
        }
        Start-Sleep -Milliseconds 60

    } while ($select -ne $true)
    return $UserSelection
}


function x($sx, $px) {
    #symbole,position
    $i = 0
    $cx = "▐"
    do {

        $cx += " "
        $i++
    }while ($i -lt $px)

    $cx += $sx

    if ($i -lt 17 -and $sx -ne "○") {
        do {

            $cx += " "
            $i++
        }while ($i -lt 17)
    }
    else {
        if ($i -lt 19) {
            do {

                $cx += " "
                $i++
            }while ($i -lt 19)
        }
    }
    $cx += "▐"

    return $cx
}

#PX 0-14
#BX 0-19
#BY 0-10
### Position de base, affichage (sybole text) et RESET du rendu pour P1, P2 et BALLE ###

$exit = 0

while ($exit -ne 2) {
    Write-Host "
,-.----.              ,-.----.                                     
\    /  \             \    /  \                                    
|   :    \            |   :    \                                   
|   |  .\ :           |   |  .\ :   ,---.        ,---,             
.   :  |: | .--.--.   .   :  |: |  '   ,'\   ,-+-. /  |  ,----._,. 
|   |   \ :/  /    '  |   |   \ : /   /   | ,--.'|'   | /   /  ' / 
|   : .   /  :  /`./  |   : .   /.   ; ,. :|   |  ,`"' ||   :     | 
;   | |`-'|  :  ;_    ;   | |`-' '   | |: :|   | /  | ||   | .\  . 
|   | ;    \  \    `. |   | ;    '   | .; :|   | |  | |.   ; ';  | 
:   ' |     `----.   \:   ' |    |   :    ||   | |  |/ '   .   . | 
:   : :    /  /`--'  /:   : :     \   \  / |   | |--'   `---`-'| | 
|   | :   '--'.     / |   | :      `----'  |   |/       .'__/\_: | 
`---'.|     `--'---'  `---'.|              '---'        |   :    : 
  `---`                 `---`                            \   \  /  
                                                          `--`-'   
         ___         ___         ___         ___         ___       
      .'  .`|     .'  .`|     .'  .`|     .'  .`|     .'  .`|      
   .'  .'   :  .'  .'   :  .'  .'   :  .'  .'   :  .'  .'   :      
,---, '   .',---, '   .',---, '   .',---, '   .',---, '   .'       
;   |  .'   ;   |  .'   ;   |  .'   ;   |  .'   ;   |  .'          
`---'       `---'       `---'       `---'       `---'            ";
Start-Sleep -Seconds 2

    $exit = Show-Menu -Items @("Play", "Exit")
    if ($exit -eq 1) {    
        $ai = (Show-Menu -Items @("Human VS Human", "Human VS Computer")) - 1

        if ($ai -eq 1) {
            $df = Show-Menu -Items @("Facile", "Normal", "Difficile")
        }

        $stop = 1
        while ($stop -ne 2) {

            ### Main variable ###
            $game = $false
            $mode = "p"
            $mode_x = 0
            $pt1 = 0
            $pt2 = 0

            $p1_x = 8
            $p1_i = "▄▄▄"
            $p1_g = ""

            $p2_x = 8
            $p2_i = "▄▄▄"
            $p2_g = ""

            $b_x = 9
            $b_y = 5
            $b_i = "○"
            $b_g = ""
            #####################################################################

            ##################### SCRIPT PRINCIPALE #############################
            do {
                if ($game -eq $false) {
                    ############### MAIN DISPLAY #########################
                    Clear-Host
                    $p1_g = x $p1_i $p1_x
                    $p2_g = x $p2_i $p2_x
                    $b_g = x $b_i $b_x

                    # Display header
                    if ($ai -eq 0) {
                        Write-Host "
   J1 $pt1  ▐   J2 $pt2   
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
                    }
                    else {
                        Write-Host "
   J1 $pt1  ▐   AI $pt2   
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
                    }
                    Write-Host "$p1_g" # display player 1

                    # Display ball and border
                    switch ($b_Y) {
                        0 {
                            Write-Host "$b_g
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐"
                        }
                        1 {
                            Write-Host "▐                    ▐
$b_g
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐"
                        }
                        2 {
                            Write-Host "▐                    ▐
▐                    ▐
$b_g
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐"
                        }
                        3 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
$b_g
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐"
                        }
                        4 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
$b_g
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐"
                        }

                        5 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
$b_g
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐"
                        }

                        6 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
$b_g
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐"
                        }
                        7 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
$b_g
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐"
                        }
                        8 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
$b_g
▐                    ▐
▐                    ▐
▐                    ▐"
                        }
                        9 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
$b_g
▐                    ▐
▐                    ▐"
                        }
                        10 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
$b_g
▐                    ▐"
                        }
                        11 {
                            Write-Host "▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
▐                    ▐
$b_g"
                        }
                    }
                    Write-Host "$p2_g
▐                    ▐
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
                    ##################################################################
                }

                # Game logic
                if ($b_y -lt 1) {
                    #d1
 
                    if ($d1 -gt -1 -and $d1 -lt 1) {
                        $mode_x = 0
                        [console]::Beep(600, 80)
                    }
                    else {
                        if ($d1 -lt 14 -and $d1 -gt 0) {
                            $mode_x = 1
                            [console]::Beep(600, 80)
                        }

                        if ($d1 -gt -14 -and $d1 -lt 0) {
                            [console]::Beep(600, 80)
                            $mode_x = 2
                        }

                        if ($d1 -lt -16) {
                            [console]::Beep(315, 800)
                            $pt2++
                            $b_y = 5
                            $b_x = 9
                            $mode = "p"
                            $mode_x = 0
                            $p1_x = 8
                            $p2_x = 8
                            Start-Sleep -Seconds 1
                        }

                        if ($d1 -gt 16) {
                            [console]::Beep(315, 800)
                            $pt2++
                            $b_y = 5
                            $b_x = 9
                            $mode = "p"
                            $mode_x = 0
                            $p1_x = 8
                            $p2_x = 8
                            Start-Sleep -Seconds 1
                        }

       
                    }
                }

                if ($b_y -gt 10) {
                    #d2
                    if ($d2 -gt -1 -and $d2 -lt 1) {
                        $mode_x = 0
                        [console]::Beep(600, 80)
                    }
                    else {
   
                        if ($d2 -lt 14 -and $d2 -gt 0) {
                            [console]::Beep(600, 80)
                            $mode_x = 1
                        }

       

                        if ($d2 -gt -14 -and $d2 -lt 0) {
                            [console]::Beep(600, 80)
                            $mode_x = 2
                        }

                        if ($d2 -lt -16) {
                            [console]::Beep(315, 800)
                            $pt1++
                            $b_y = 5
                            $b_x = 9
                            $mode = "m"
                            $mode_x = 0
                            $p1_x = 8
                            $p2_x = 8
                            Start-Sleep -Seconds 1
                        }

                        if ($d2 -gt 16) {
                            [console]::Beep(315, 800)
                            $pt1++
                            $b_y = 5
                            $b_x = 9
                            $mode = "m"
                            $mode_x = 0
                            $p1_x = 8
                            $p2_x = 8
                            Start-Sleep -Seconds 1
                        }
                    }
                }
                if ($pt1 -gt 5 -or $pt2 -gt 5) {
                    $game = $true
                }

                ###################### Mapping du clavier & AI ###########################
                $a = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::Left)
                $d = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::Right)
                if ($ai -eq 0) {
                    $l = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::A)
                    $r = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::D)
                }
                else {
                    #####################################################################################ai
                    switch ($df) {
                        1 { $ai_ru = Get-Random -Minimum -15 -Maximum 5 }
                        2 { $ai_ru = Get-Random -Minimum -5 -Maximum 15 }
                        3 { $ai_ru = Get-Random -Minimum -1 -Maximum 25 }
                    }

                    if ($ai_ru -ge 0) {
                        if ($p2_x -ne $b_x) {
                            if ($p2_x -lt $b_x -and $p2_x -lt 16) {
                                $p2_x++
            
                            }
                            else {
                                $p2_x--
            
                            }
                        }
                    }
                }
                #####################################################################

                ############### Gestion de la direction x de BALLE #################
                if ($mode_x -eq 1) {
                    if ($b_x -gt 1) {
                        $b_x--
                    }
                    else {
                        $mode_x = 2
                        [console]::Beep(650, 80)
                    }
                }

                if ($mode_x -eq 2) {
                    if ($b_x -lt 18) {
                        $b_x++
                    }
                    else {
                        $mode_x = 1
                        [console]::Beep(650, 80)
                    }
                }
                ####################################################

                ###### differance entre ball et player 1 & 2 #######

                $z1 = [math]::Round(($p1_x * 100) / 16)
                $z2 = [math]::Round(($p2_x * 100) / 16)
                $z3 = [math]::Round(($b_x * 100) / 18)

                $d1 = $z1 - $z3
                $d2 = $z2 - $z3

                #####################################################

                ############   ball mode and y +/-  #################
                if ($b_y -gt 10) {
                    $mode = "m"
                }

                if ($b_y -lt 1) {
                    $mode = "p"
                }

                if ($mode -eq "p") {
                    $b_y++
                }
                else {
                    $b_y--
                }
                ######################################################

                ############  player 1 & 2 input for x ###############
                if ($a -and $p1_x -gt 0) {
                    $p1_x--
                }
                if ($d -and $p1_x -lt 16) {
                    $p1_x++
                }

                if ($l -and $p2_x -gt 0) {
                    $p2_x--
                }
                if ($r -and $p2_x -lt 16) {
                    $p2_x++
                }
                ######################################################
                Start-Sleep -Milliseconds 70
            }
            while ($game -ne $true)
            #########################################################################

            Clear-Host

            if ($pt1 -gt $pt2) 
            {
                Write-Host "
    ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
   ▐ Player 1 won the game ▐
    ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
   "
   Pause | Out-Null
   $stop = Show-Menu -Items @("Replay","Exit");
            }
            else {
                if ($ai -eq 0) {
                    Write-Host "
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
▐ Player 2 won the game ▐
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
"
Pause | Out-Null
$stop = Show-Menu -Items @("Replay","Exit");
                }
                else {
                    Write-Host "
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
▐ Computer won the game ▐
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
"
Pause | Out-Null
$stop = Show-Menu -Items @("Replay","Exit");
                }

            }
        }
    }
}
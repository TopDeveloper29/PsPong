### add the necessary assembly ###

Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
cd $PSScriptRoot
if(Test-Path "temp.txt" -PathType Leaf)
{
Remove-Item("temp.txt") -Force
}
else
{
start powershell -ArgumentList ("-WindowStyle Maximized","$PSScriptRoot`\pong_demo.ps1")
Out-File -FilePath "$PSScriptRoot`\temp.txt"
exit
}

function x($sx,$px) #symbole,position
{

    $i = 0;
    $cx = "▐"
        do
        {

            $cx += " ";
            $i++;
        }while($i -lt $px)

    $cx += $sx;

    if($i -lt 17 -and $sx -ne "○")
    {
     do
        {

            $cx += " ";
            $i++;
        }while($i -lt 17)
    }
    else 
    {
        if($i -lt 19)
        {
            do
            {

                $cx += " ";
                $i++;
            }while($i -lt 19)
        }
    }
    $cx += "▐";

return $cx
}

#PX 0-14
#BX 0-19
#BY 0-10
### Position de base, affichage (sybole text) et RESET du rendu pour P1, P2 et BALLE ###

$ai = 1
$df = 3




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
#######################################################################################

##################### SCRIPT PRINCIPALE #############################
do{


if($game -eq $false)
{
############### MAIN DISPLAY #########################
clear
$p1_g = x $p1_i $p1_x
$p2_g = x $p2_i $p2_x
$b_g = x $b_i $b_x

#echo "1:$d1 2:$d2 Y:$b_y"                                         ################## debug variable (echo before game display) #####################
if($ai -eq 0)
{
write-host "
   AI1 $pt1  ▐   AI2 $pt2   
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
}
else
{
write-host "
   AI1 $pt1  ▐   AI2 $pt2   
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
}
write-host "$p1_g"
switch($b_Y)
{
0{write-host "$b_g
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
▐                    ▐"}
1{write-host "▐                    ▐
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
2{write-host "▐                    ▐
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
3{write-host "▐                    ▐
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
4{write-host "▐                    ▐
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

5{write-host "▐                    ▐
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

6{write-host "▐                    ▐
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
7{write-host "▐                    ▐
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
8{write-host "▐                    ▐
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
9{write-host "▐                    ▐
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
10{write-host "▐                    ▐
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
11{write-host "▐                    ▐
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
write-host "$p2_g
▐                    ▐
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
##################################################################
}
if($b_y -lt 1)
{
   #d1
 
   if($d1 -gt -1 -and $d1 -lt 1)
   {
    $mode_x = 0
    [console]::Beep(600,80)
   }
   else
   {
       if($d1 -lt 14 -and $d1 -gt 0)
       {
        $mode_x = 1
        [console]::Beep(600,80)
       }

       if($d1 -gt -14 -and $d1 -lt 0)
       {
       [console]::Beep(600,80)
        $mode_x = 2
       }

       if($d1 -lt -16)
       {
       [console]::Beep(315,800)
        $pt2++
        $b_y = 5
        $b_x = 9
        $mode = "p"
        $mode_x = 0
        $p1_x = 8
        $p2_x = 8
        Start-Sleep -Seconds 1
       }

        if($d1 -gt 16)
       {
       [console]::Beep(315,800)
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

if($b_y -gt 10)
{
   #d2
   if($d2 -gt -1 -and $d2 -lt 1)
   {
    $mode_x = 0
    [console]::Beep(600,80)
   }
   else
   {
   
       if($d2 -lt 14 -and $d2 -gt 0)
       {
       [console]::Beep(600,80)
        $mode_x = 1
       }

       

       if($d2 -gt -14 -and $d2 -lt 0)
       {
       [console]::Beep(600,80)
        $mode_x = 2
       }

       if($d2 -lt -16)
       {
       [console]::Beep(315,800)
        $pt1++
        $b_y = 5
        $b_x = 9
        $mode = "m"
        $mode_x = 0
        $p1_x = 8
        $p2_x = 8
        Start-Sleep -Seconds 1
       }

       if($d2 -gt 16)
       {
       [console]::Beep(315,800)
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

if($pt1 -gt 5)
{
    $game = $true
}
if($pt2 -gt 5)
{
    $game = $true
}
###################### Mapping du clavier & AI ###########################
$a = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::A)
$d = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::D)
if($ai -eq 0)
{
$l = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::Left)
$r = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::Right)
}
else
{
#####################################################################################ai
switch($df)
{
1{$ai_ru = Get-Random -Minimum -15 -Maximum 5
$ai_ru2 = Get-Random -Minimum -15 -Maximum 5
}
2{$ai_ru = Get-Random -Minimum -5 -Maximum 15
$ai_ru2 = Get-Random -Minimum -5 -Maximum 15
}
3{$ai_ru = Get-Random -Minimum -1 -Maximum 25
$ai_ru2 = Get-Random -Minimum -1 -Maximum 25
}
}

$rs = Get-Random -Minimum -1 -Maximum 1

if($ai_ru -ge 0)
{
    if($p2_x -ne $b_x)
    {
        if($p2_x -lt $b_x -and $p2_x -lt 16)
        {
            $p2_x++;
            
        }
        else
        {
            $p2_x--;
            
        }
    }
}

if($ai_ru2 -ge 0)
{
    if($p1_x -ne $b_x)
    {
        if($p1_x -lt $b_x -and $p1_x -lt 16)
        {
            $p1_x++;
            
        }
        else
        {
            $p1_x--;
            
        }
    }
}

}
#####################################################################

############### Gestion de la direction x de BALLE #################
if($mode_x -eq 1)
{
    if($b_x -gt 1)
    {
        $b_x--
    }
    else
    {
        $mode_x = 2
        [console]::Beep(650,80)
    }
}

if($mode_x -eq 2)
{
    if($b_x -lt 18)
    {
        $b_x++
    }
    else
    {
        $mode_x = 1
        [console]::Beep(650,80)
    }
}
####################################################

###### differance entre ball et player 1 & 2 #######

    $z1 = [math]::Round(($p1_x*100)/16)
    $z2 = [math]::Round(($p2_x*100)/16)
    $z3 = [math]::Round(($b_x*100)/18)

    $d1 = $z1-$z3
    $d2 = $z2-$z3

#####################################################

############   ball mode and y +/-  #################
if($b_y -gt 10)
{
    $mode = "m"
}

if($b_y -lt 1)
{
    $mode = "p"
}

if($mode -eq "p")
{
    $b_y++
}
else
{
    $b_y--
}
######################################################

############  player 1 & 2 input for x ###############
if($a -and $p1_x -gt 0)
{
    $p1_x--;
}
if($d -and $p1_x -lt 16)
{
    $p1_x++;
}

if($l -and $p2_x -gt 0)
{
    $p2_x--;
}
if($r -and $p2_x -lt 16)
{
    $p2_x++;
}
######################################################
Start-Sleep -Milliseconds 70
}
while($game -ne $true)
#########################################################################

clear

if($pt1 -gt $pt2)
{
Write-Host "
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
▐ L'Ordinateur 1 a Gagnée ▐
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
"
}
else
{
if($ai -eq 0)
{
Write-Host "
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
▐ Joueur 2 a Gagnée ▐
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
"
}
else
{
Write-Host "
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
▐ L'Ordinateur 2 a Gagnée ▐
 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
"
}

}
Start-Sleep -Seconds 5
start powershell -ArgumentList ("-WindowStyle Maximized","$PSScriptRoot`\pong_demo.ps1")
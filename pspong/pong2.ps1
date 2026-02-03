Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class Keyboard {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
}
"@

[Keyboard]::GetMethod("GetAsyncKeyState").Invoke($null, @($vKey))

enum BallDirection {
    Left
    Right
    Center
}
enum PlayerRequest {
    Left
    Right
    None
}
enum AiDifficulty {
    None
    Low
    Normal
    High
}
class ConsoleKeyboard {
    hidden [hashtable]$PreviousStates = @{}

    ConsoleKeyboard() {
        # Initialize the previous state table
        $this.PreviousStates = @{}
    }

    [bool] IsKeyDown([int]$vKey) {
        # Get current state
        $state = [Keyboard]::GetAsyncKeyState($vKey) -band 0x8000
        # Store for future use
        if (-not $this.PreviousStates.ContainsKey($vKey)) {
            $this.PreviousStates[$vKey] = $false
        }
        $this.PreviousStates[$vKey] = [bool]$state
        return [bool]$state
    }
}
class Game {
    # Game
    hidden [int] $GameWidth = 22;
    hidden [int] $GameHeight = 12;
    hidden [ConsoleKeyboard] $Keyboard = [ConsoleKeyboard]::new();
    [bool] $IsRunning = $true;
    [AiDifficulty]$AI = [AiDifficulty]::None

    # Ball
    hidden [int]$BallPosX = 11;
    hidden[int]$BallPosY = 6;
    hidden[bool]$BallFalling = $true;
    hidden[BallDirection]$BallDirection = [BallDirection]::Center;
    
    # Players
    hidden[int]$P1Pos = 6;
    hidden[int]$P2Pos = 6;
    hidden[PlayerRequest]$P1Request = [PlayerRequest]::None;
    hidden[PlayerRequest]$P2Request = [PlayerRequest]::None;

    # Control game speed and optimize
    hidden[int]$SkipPlayerUpdateTargetCount = 400;
    hidden[int]$SkipPlayerUpdateCount = 0;
    hidden[int]$SkipBallUpdateTargetCount = 1180;
    hidden[int]$SkipBallUpdateCount = 0;
    hidden[int]$SkipAiUpdateTargetCount = 150;
    hidden[int]$SkipAiUpdateCount = 0;
    hidden[bool]$PointRequiredUpdate = $true;

    # Score
    [int] $P1Score = 0;
    [int] $P2Score = 0;
    
    # Start the game
    [void] Start() {
        [System.Console]::Clear();
        if($this.SelectMenu(@("Play", "Exit")) -eq 1) { break; }

        Start-Sleep -Milliseconds 500;

        [System.Console]::WriteLine("=== Game Mode ===")
        switch ($this.SelectMenu(@("Player vs Player", "Ai Low","Ai Normal", "Ai High"))) {
            0 { $this.AI = [AiDifficulty]::None; }
            1 { $this.AI = [AiDifficulty]::Low; }
            2 { $this.AI = [AiDifficulty]::Normal; }
            3 { $this.AI = [AiDifficulty]::High; }
        }

        # Create game border
        $this.CreateBorder();

        while ($this.IsRunning) {             
            $this.ReadKeys();
            if ($this.IsRunning) {
                if ($this.AI -ne [AiDifficulty]::None) {
                    $this.UpdateAi();
                } 
                $this.UpdatePlayers();
                $this.UpdateBall();
                $this.UpdatePoint();

                if($this.P1Score -ge 10 -or $this.P2Score -ge 10)
                {
                    $this.Stop();
                }
            }
        }
    }

    [void] Stop() {
        $this.IsRunning = $false;
        [System.Console]::Clear();
        [System.Console]::ForegroundColor = [ConsoleColor]::White;
        [System.Console]::BackgroundColor = [ConsoleColor]::Black;
        [System.Console]::SetCursorPosition(0, $this.GameHeight + 1);
    }

    [int] SelectMenu([string[]]$Items) {
        [int]$LastSelection = 0;
        [int]$CurrentSelection = 0;
        
        $y = 0;
        foreach ($Item in $Items) {
            if($y -eq 0)
            {
                [System.Console]::ForegroundColor = [System.ConsoleColor]::Cyan;
            }
            else
            {
                [System.Console]::ForegroundColor = [System.ConsoleColor]::White;
            }
            [System.Console]::SetCursorPosition(0,$y);
            [System.Console]::Write("= $($Item) =");
            $y++;
        }
        while ($this.Keyboard.IsKeyDown(0x0D) -ne $true) {
            Start-Sleep -Milliseconds 80;
            if ($this.Keyboard.IsKeyDown(0x26)) {
                $CurrentSelection--;
                if ($CurrentSelection -le 0) {
                    $CurrentSelection = 0;
                }
            }
            elseif ($this.Keyboard.IsKeyDown(0x28)) {
                $CurrentSelection++;
                if ($CurrentSelection -gt $Items.Count - 1) {
                    $CurrentSelection = $Items.Count - 1;
                }
            }

            if ($CurrentSelection -ne $LastSelection)
            {
                [System.Console]::ForegroundColor = [System.ConsoleColor]::White;
                [System.Console]::SetCursorPosition(0,$LastSelection);
                [System.Console]::Write("= $($Items[$LastSelection]) =");
                $LastSelection = $CurrentSelection;
                [System.Console]::ForegroundColor = [System.ConsoleColor]::Cyan;
                [System.Console]::SetCursorPosition(0,$LastSelection);
                [System.Console]::Write("= $($Items[$LastSelection]) =");
            }
        }
        [System.Console]::Clear();
        return $CurrentSelection;
    }
    
    hidden [void] ReadKeys() {
        # Ensure keyboard helper exists
        if (-not $this.Keyboard) {
            $this.Keyboard = [ConsoleKeyboard]::new()
        }

        # P1 controls
        if ($this.Keyboard.IsKeyDown(0x27)) {
            # RightArrow
            $this.P1Request = [PlayerRequest]::Right
        }
        elseif ($this.Keyboard.IsKeyDown(0x25)) {
            # LeftArrow
            $this.P1Request = [PlayerRequest]::Left
        }
        else {
            $this.P1Request = [PlayerRequest]::None    # Neither pressed
        }

        # P2 controls
        if ($this.AI -eq [AiDifficulty]::None) {
            if ($this.Keyboard.IsKeyDown(0x44)) {
                # D
                $this.P2Request = [PlayerRequest]::Right
            }
            elseif ($this.Keyboard.IsKeyDown(0x41)) {
                # A
                $this.P2Request = [PlayerRequest]::Left
            }
            else {
                $this.P2Request = [PlayerRequest]::None
            }
        }

        # Escape to stop
        if ($this.Keyboard.IsKeyDown(0x1B)) {
            $this.Stop()
        }
    }

    hidden [void] CreateBorder() {
        $X = [System.Console]::CursorLeft;
        $Y = [System.Console]::CursorTop;
        $BorderChar = "█";
        $HeaderFooterChar = "▀";
        [System.Console]::ForegroundColor = [ConsoleColor]::Gray;

        for ($lx = 0; $lx -lt $this.GameWidth; $lx++) {
            [System.Console]::SetCursorPosition($X + $lx, $Y);
            [System.Console]::Write($HeaderFooterChar);
            [System.Console]::SetCursorPosition($X + $lx, $this.GameHeight);
            [System.Console]::Write($HeaderFooterChar);

        }

        for ($ly = 0; $ly -lt $this.GameHeight; $ly++) {
            [System.Console]::SetCursorPosition(0, $Y + $ly);
            [System.Console]::Write($BorderChar);
            [System.Console]::SetCursorPosition($this.GameWidth - 1, $Y + $ly);
            [System.Console]::Write($BorderChar);
        }
    }

    hidden [void] UpdatePoint() {
        if ($this.PointRequiredUpdate) {
            [System.Console]::ForegroundColor = [ConsoleColor]::Yellow;
            [System.Console]::SetCursorPosition(0, $this.GameHeight + 1);
            [System.Console]::Write("    P1: $($this.P1Score) | P2: $($this.P2Score)");
            $this.PointRequiredUpdate = $false;
        }
    }

    hidden [void]UpdatePlayers() {              
        [System.Console]::ForegroundColor = [ConsoleColor]::Cyan;
        
        if ($this.SkipPlayerUpdateCount -lt $this.SkipPlayerUpdateTargetCount) {
            $this.SkipPlayerUpdateCount++;
            return;
        }
        $this.SkipPlayerUpdateCount = 0;

        switch ($this.P1Request) {
            Left { 
                $CurrentPos = $this.P1Pos;
                $this.P1Pos--;
                if ($this.P1Pos -le 1) {
                    $this.P1Pos++;
                }
                $NewPos = $this.P1Pos;
                $this.UpdatePlayer(1, $CurrentPos, $NewPos);
            }
            Right {
                $CurrentPos = $this.P1Pos;
                $this.P1Pos++;
                if ($this.P1Pos -ge $this.GameWidth - 4) {
                    $this.P1Pos--;
                }
                $NewPos = $this.P1Pos;
                $this.UpdatePlayer(1, $CurrentPos, $NewPos);
            }
            None { $this.UpdatePlayer(1, $this.P1Pos, $this.P1Pos); }
        }

        switch ($this.P2Request) {
            Left { 
                $CurrentPos = $this.P2Pos;
                $this.P2Pos--;
                if ($this.P2Pos -le 1) {
                    $this.P2Pos++;
                }
                $NewPos = $this.P2Pos;
                $this.UpdatePlayer(2, $CurrentPos, $NewPos)
            }
            Right {
                $CurrentPos = $this.P2Pos;
                $this.P2Pos++;
                if ($this.P2Pos -ge $this.GameWidth - 4) {
                    $this.P2Pos--;
                }
                $NewPos = $this.P2Pos;
                $this.UpdatePlayer(2, $CurrentPos, $NewPos);

            }
            None { $this.UpdatePlayer(2, $this.P2Pos, $this.P2Pos); }
        }
    }

    hidden [void]UpdateAi() {

        if ($this.SkipAiUpdateCount -lt $this.SkipAiUpdateTargetCount) {
            $this.SkipAiUpdateCount++;
            return;
        }
        $this.SkipAiUpdateCount = 0;
        $SkipThisTime = 0
        switch ($this.AI) {
            Low { $SkipThisTime = Get-Random -Minimum -1 -Maximum 35; }
            Normal { $SkipThisTime = Get-Random -Minimum -1 -Maximum 25; }
            High { $SkipThisTime = Get-Random -Minimum -1 -Maximum 15; }
        }

        if ($SkipThisTime -eq 0) {
            $this.P2Pos = $this.BallPosX - 2;
        }

        if ($this.P2Pos -le 1) {
            $this.P2Pos = 2;
        }
        elseif ($this.P2Pos -ge ($this.GameWidth - 4)) {
            $this.P2Pos = ($this.GameWidth - 4);
        }
        $AiY = $this.GameHeight - 2;
        [System.Console]::SetCursorPosition(2, $AiY);
        $Chars = [string]::Empty;
        for ($i = 0; $i -ne ($this.GameWidth - 3); $i++) {
            $Chars += " ";
        }
        [System.Console]::Write($Chars);
        [System.Console]::SetCursorPosition($this.P2Pos, $AiY);
        [System.Console]::Write("▄▄▄");
    }

    hidden [void]UpdatePlayer([int]$PlayerNumber, [int]$CurrentPosition, [int]$NewPosition) {
        [int]$PlayerY = 0;
        switch ($PlayerNumber) {
            1 { $PlayerY = 1; }
            2 { $PlayerY = $this.GameHeight - 2; }
        }

        [System.Console]::SetCursorPosition($CurrentPosition, $PlayerY);
        [System.Console]::Write("   ");
        [System.Console]::SetCursorPosition($NewPosition, $PlayerY);
        [System.Console]::Write("▄▄▄");
    }

    hidden [void] ResetBall() {
        [console]::Beep(400, 180);
        [System.Console]::ForegroundColor = [ConsoleColor]::White;
        [System.Console]::SetCursorPosition($this.BallPosX, $this.BallPosY);
        [System.Console]::Write(" ");
        $this.SkipBallUpdateCount = 0;
        $this.BallFalling = Get-Random -InputObject @( $true, $false );
        $this.BallDirection = Get-Random -InputObject ([object[]][BallDirection].GetEnumValues());
        $this.BallPosX = 11;
        $this.BallPosY = 6;
        [System.Console]::SetCursorPosition($this.BallPosX, $this.BallPosY);
        [System.Console]::Write("●");
    }

    hidden [void] UpdateBall() {
        if ($this.SkipBallUpdateCount -lt $this.SkipBallUpdateTargetCount) {
            $this.SkipBallUpdateCount++;
            return;
        }
        $this.SkipBallUpdateCount = 0;
        [System.Console]::ForegroundColor = [ConsoleColor]::White;
        [System.Console]::SetCursorPosition($this.BallPosX, $this.BallPosY);
        [System.Console]::Write(" ");

        if ($this.BallFalling) {
            $this.BallPosY++
            if ($this.BallPosY -eq ($this.GameHeight - 2) -and $this.BallPosX -ge $this.P2Pos -and $this.BallPosX -le $this.P2Pos + 2) {
                $this.BallFalling = $false
                $this.BallDirection = Get-Random -InputObject ([object[]][BallDirection].GetEnumValues());
                [console]::Beep(600, 80);
            }
            elseif ($this.BallPosY -ge $this.GameHeight - 2) {
                # Player 1 scores
                $this.P1Score++
                $this.PointRequiredUpdate = $true
                $this.ResetBall();
                return;
            }
        }
        else {
            $this.BallPosY--
            if ($this.BallPosY -eq 2 -and $this.BallPosX -ge $this.P1Pos -and $this.BallPosX -le $this.P1Pos + 2) {
                $this.BallFalling = $true
                $this.BallDirection = Get-Random -InputObject ([object[]][BallDirection].GetEnumValues());
                [console]::Beep(600, 80)
            }
            elseif ($this.BallPosY -le 1) {
                # Player 2 scores
                $this.P2Score++
                $this.PointRequiredUpdate = $true
                $this.ResetBall();
                return;
            }
        }

        switch ($this.BallDirection) {
            Left { $this.BallPosX-- }
            Right { $this.BallPosX++ }
            Center { }
        }
        if ($this.BallPosX -ge $this.GameWidth - 2) {
            $this.BallPosX -= 2;
            $this.BallDirection = [BallDirection]::Left;
            [console]::Beep(600, 80)
        }
        elseif ($this.BallPosX -le 1) {
            $this.BallPosX += 2;
            $this.BallDirection = [BallDirection]::Right
            [console]::Beep(600, 80)
        }
        [System.Console]::SetCursorPosition($this.BallPosX, $this.BallPosY);
        [System.Console]::Write("●");
    }
}

# Hide the cursor
$host.UI.RawUI.CursorSize = 0

#Allow all special char
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Create the game object and start the game
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

# Create a new game
$Game = [Game]::new();
$Game.Start();
Write-Host "Score:`nPlayer 1: $($Game.P1Score)`nPlayer 2: $($Game.P2Score)"
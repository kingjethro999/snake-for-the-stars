'===============================================================================
'  SNAKE — For THE STARS
'  A dream from 2018. Finished in honour of the crew that started it.
'
'  Requires: FreeBASIC (fbc) or QB64
'  Build:    fbc -s console snake.bas
'  Run:      ./snake
'
'  Controls: W/A/S/D or Arrow Keys  |  P Pause  |  Q Quit
'===============================================================================

Const W As Integer = 40
Const H As Integer = 20
Const MAXLEN As Integer = W * H

Dim Shared snakeX(0 To MAXLEN - 1) As Integer
Dim Shared snakeY(0 To MAXLEN - 1) As Integer
Dim Shared snakeLen As Integer
Dim Shared dirX As Integer
Dim Shared dirY As Integer
Dim Shared foodX As Integer
Dim Shared foodY As Integer
Dim Shared score As Integer
Dim Shared gameOver As Integer
Dim Shared paused As Integer
Dim Shared tickMs As Integer
Dim Shared highScore As Integer
Dim Shared again As String

Declare Sub InitGame()
Declare Sub DrawFrame()
Declare Sub DrawBorder()
Declare Sub PlaceFood()
Declare Sub HandleInput()
Declare Sub UpdateSnake()
Declare Function CellOccupied(ByVal x As Integer, ByVal y As Integer) As Integer
Declare Sub ShowTitle()
Declare Sub ShowGameOver()
Declare Sub CenterPrint(ByVal row As Integer, ByVal text As String)
Declare Sub ClearPlayfield()

Randomize Timer

ShowTitle
Do
    InitGame
    Do
        HandleInput
        If gameOver <> 0 Then Exit Do
        If paused = 0 Then
            UpdateSnake
            DrawFrame
        End If
        Sleep tickMs, 1
    Loop
    ShowGameOver
    again = ""
    Do While again <> "Y" And again <> "N" And again <> "y" And again <> "n"
        again = Inkey$
        Sleep 50, 1
    Loop
    If again = "N" Or again = "n" Then Exit Do
Loop

Cls
Color 7, 0
Locate 10, 18
Print "For THE STARS — 2018 forever."
Locate 12, 22
Print "Press any key..."
Sleep
End

'-------------------------------------------------------------------------------
Sub ShowTitle()
    Cls
    Color 14, 0
    CenterPrint 4, "******************************"
    CenterPrint 5, "*     S N A K E              *"
    CenterPrint 6, "*     for THE STARS          *"
    CenterPrint 7, "******************************"
    Color 11, 0
    CenterPrint 10, "A project dreamed in 2018."
    CenterPrint 11, "Finished in honour of the crew."
    Color 7, 0
    CenterPrint 14, "W A S D  or  Arrows  —  move"
    CenterPrint 15, "P — pause     Q — quit"
    Color 10, 0
    CenterPrint 18, "Press any key to begin"
    Color 7, 0
    Sleep
    Do While Inkey$ <> ""
    Loop
End Sub

'-------------------------------------------------------------------------------
Sub InitGame()
    Dim As Integer i
    snakeLen = 3
    For i = 0 To snakeLen - 1
        snakeX(i) = 10 - i
        snakeY(i) = 10
    Next
    dirX = 1
    dirY = 0
    score = 0
    gameOver = 0
    paused = 0
    tickMs = 120
    PlaceFood
    Cls
    DrawBorder
    DrawFrame
End Sub

'-------------------------------------------------------------------------------
Sub DrawBorder()
    Dim As Integer x, y
    Color 8, 0
    For x = 1 To W + 2
        Locate 1, x : Print Chr$(219);
        Locate H + 2, x : Print Chr$(219);
    Next
    For y = 2 To H + 1
        Locate y, 1 : Print Chr$(219);
        Locate y, W + 2 : Print Chr$(219);
    Next
    Color 14, 0
    Locate 1, 3
    Print " THE STARS ";
    Color 7, 0
    Locate H + 3, 2
    Print "Score: 0   High: "; highScore; "   P=Pause  Q=Quit";
End Sub

'-------------------------------------------------------------------------------
Sub ClearPlayfield()
    Dim As Integer x, y
    Color 0, 0
    For y = 1 To H
        Locate y + 1, 2
        For x = 1 To W
            Print " ";
        Next
    Next
End Sub

'-------------------------------------------------------------------------------
Sub DrawFrame()
    Dim As Integer i
    ClearPlayfield

    Color 12, 0
    Locate foodY + 1, foodX + 1
    Print Chr$(254);

    Color 10, 0
    Locate snakeY(0) + 1, snakeX(0) + 1
    Print Chr$(219);
    Color 2, 0
    For i = 1 To snakeLen - 1
        Locate snakeY(i) + 1, snakeX(i) + 1
        Print Chr$(219);
    Next

    Color 7, 0
    Locate H + 3, 2
    Print "Score: "; score; "   High: "; highScore; "   ";
    If paused <> 0 Then
        Color 14, 0
        Print "[PAUSED] ";
        Color 7, 0
    Else
        Print "         ";
    End If
End Sub

'-------------------------------------------------------------------------------
Sub PlaceFood()
    Do
        foodX = Int(Rnd * W) + 1
        foodY = Int(Rnd * H) + 1
    Loop While CellOccupied(foodX, foodY) <> 0
End Sub

'-------------------------------------------------------------------------------
Function CellOccupied(ByVal x As Integer, ByVal y As Integer) As Integer
    Dim As Integer i
    For i = 0 To snakeLen - 1
        If snakeX(i) = x And snakeY(i) = y Then
            Return 1
        End If
    Next
    Return 0
End Function

'-------------------------------------------------------------------------------
Sub HandleInput()
    Dim As String k
    Dim As Integer nx, ny
    k = Inkey$
    If k = "" Then Exit Sub

    If Len(k) = 2 Then
        Select Case Asc(Right(k, 1))
            Case 72: nx = 0 : ny = -1
            Case 80: nx = 0 : ny = 1
            Case 75: nx = -1 : ny = 0
            Case 77: nx = 1 : ny = 0
            Case Else: nx = dirX : ny = dirY
        End Select
    Else
        Select Case UCase(k)
            Case "W": nx = 0 : ny = -1
            Case "S": nx = 0 : ny = 1
            Case "A": nx = -1 : ny = 0
            Case "D": nx = 1 : ny = 0
            Case "P"
                paused = 1 - paused
                DrawFrame
                Exit Sub
            Case "Q"
                gameOver = 1
                Exit Sub
            Case Else
                Exit Sub
        End Select
    End If

    If paused <> 0 Then Exit Sub
    If nx = -dirX And ny = -dirY And snakeLen > 1 Then Exit Sub
    dirX = nx
    dirY = ny
End Sub

'-------------------------------------------------------------------------------
Sub UpdateSnake()
    Dim As Integer i, nx, ny
    nx = snakeX(0) + dirX
    ny = snakeY(0) + dirY

    If nx < 1 Or nx > W Or ny < 1 Or ny > H Then
        gameOver = 1
        Exit Sub
    End If

    If CellOccupied(nx, ny) <> 0 Then
        If Not (nx = snakeX(snakeLen - 1) And ny = snakeY(snakeLen - 1)) Then
            gameOver = 1
            Exit Sub
        End If
    End If

    For i = snakeLen - 1 To 1 Step -1
        snakeX(i) = snakeX(i - 1)
        snakeY(i) = snakeY(i - 1)
    Next
    snakeX(0) = nx
    snakeY(0) = ny

    If nx = foodX And ny = foodY Then
        If snakeLen < MAXLEN Then
            snakeX(snakeLen) = snakeX(snakeLen - 1)
            snakeY(snakeLen) = snakeY(snakeLen - 1)
            snakeLen = snakeLen + 1
        End If
        score = score + 10
        If score > highScore Then highScore = score
        If tickMs > 50 Then tickMs = tickMs - 2
        PlaceFood
    End If
End Sub

'-------------------------------------------------------------------------------
Sub ShowGameOver()
    Color 12, 0
    CenterPrint H \ 2 + 1, "  GAME OVER  "
    Color 14, 0
    CenterPrint H \ 2 + 3, "Score: " & Str$(score)
    Color 7, 0
    CenterPrint H \ 2 + 5, "Play again? (Y/N)"
    Color 11, 0
    CenterPrint H \ 2 + 7, "— THE STARS —"
End Sub

'-------------------------------------------------------------------------------
Sub CenterPrint(ByVal row As Integer, ByVal text As String)
    Dim As Integer col
    col = (W + 2 - Len(text)) \ 2 + 1
    If col < 1 Then col = 1
    Locate row, col
    Print text;
End Sub

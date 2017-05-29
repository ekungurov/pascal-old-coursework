program BallsCollisions;

uses
  Crt, Graph, Unit1;

const
  N = 15;

var
  ActivePage: Integer;
  Ball: array [1..N] of PBall;

procedure InitScreen;
var
  Driver, Mode: Integer;
  AspectX, AspectY: Word;
begin
  Driver := EGA;
  Mode := EGAHi;
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then Halt(1);

  GetAspectRatio(AspectX, AspectY);
  AspectRatio := AspectX / AspectY;
end;

procedure CreateBalls;
var
  i: Integer;
  begin
  for i := 1 to N do begin
    New(Ball[i], Create);
  end;
end;

procedure CheckCollisions;
var
  i, j: Integer;
begin
  for i := 1 to N - 1 do begin
    for j := i + 1 to N do begin
      if (Ball[i]^.CheckCollisionWith(Ball[j]^)) then begin
        Ball[i]^.CollidedWith := j;
        if not(Ball[i]^.PreviouslyCollidedWith = j) then begin
          Ball[i]^.CalculateCollisionWith(Ball[j]^);
        end;
      end;
    end;
  end;
end;

procedure MoveBalls;
var
  i: Integer;
begin
  for i := 1 to N do begin
    Ball[i]^.Move;
  end;
end;

procedure DrawBalls;
var
  i: Integer;
begin
  for i := 1 to N do begin
    Ball[i]^.Draw;
  end;
end;

procedure DestroyBalls;
var
  i: Integer;
begin
  for i := 1 to N do begin
    Dispose(Ball[i]);
  end;
end;

procedure SwitchPages;
begin
  SetActivePage(ActivePage);
  ActivePage := ActivePage xor 1;
  SetVisualPage(ActivePage);
end;

procedure WaitVSync;
begin
  repeat until port[$3DA] and $08 <> 0;
end;

begin
  InitScreen;
  Randomize;
  CreateBalls;
  repeat
    CheckCollisions;
    MoveBalls;
    DrawBalls;
    SwitchPages;
    WaitVSync;
    ClearDevice;
  until KeyPressed;
  ReadKey;
  DestroyBalls;
  CloseGraph;
end.
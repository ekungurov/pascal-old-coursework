unit Unit1;
{$R-}

interface

uses
  Graph;

const
  Rmin = 15;
  ScreenX: LongInt = 640 shl 6;
  ScreenY: LongInt = 350 shl 6;
  MoveStep: LongInt = 80;

var
  AspectRatio: Real;

type
  PBall = ^TBall;
  TBall = object
    X: LongInt;
    Y: LongInt;
    Dx: LongInt;
    Dy: LongInt;
    Rx: LongInt;
    Ry: LongInt;
    Mass: LongInt;
    Color: Word;
    CollidedWith: Word;
    PreviouslyCollidedWith: Word;

    constructor Create;
    procedure Move;
    procedure Draw;
    function CheckCollisionWith(Other: TBall): Boolean;
    procedure CalculateCollisionWith(var Other: TBall);
  end;

implementation

  constructor TBall.Create;
  var
    R: Integer;
  begin
    R := Rmin + 4 * Trunc(10 * Sqr(Random));
    Mass := LongInt(R) * R * R;

    Rx := R shl 6;
    Ry := Round(Rx * AspectRatio);

    X := Rx + Trunc((ScreenX - 2 * Rx) * Random);
    Y := Ry + Trunc((ScreenY - 2 * Ry) * Random);

    Dx := Round(MoveStep * (2 * Random - 1));
    Dy := Round(MoveStep * (2 * Random - 1));

    Color := $0A or (1 shl Trunc(3 * Random));

    CollidedWith := 0;
    PreviouslyCollidedWith := 0;
  end;

  procedure TBall.Move;
  begin
    if X < Dx + Rx then Dx := Abs(Dx);
    if Y < Dy + Ry then Dy := Abs(Dy);
    if X > ScreenX + Dx - Rx - 1 then Dx := -Abs(Dx);
    if Y > ScreenY + Dy - Ry - 1 then Dy := -Abs(Dy);
    Inc(X, Dx);
    Inc(Y, Dy);

    PreviouslyCollidedWith := CollidedWith;
    CollidedWith := 0;
  end;

  procedure TBall.Draw;
  begin
    SetColor(Color);
    Circle(X shr 6, Y shr 6, Rx shr 6);
  end;

  function TBall.CheckCollisionWith(Other: TBall): Boolean;
  var
    DistanceX: LongInt;
    DistanceY: LongInt;
    SummOfRadiuses: LongInt;
  begin
    DistanceX := Self.X + Self.Dx - Other.X - Other.Dx;
    DistanceY := Self.Y + Self.Dy - Other.Y - Other.Dy;
    SummOfRadiuses := Self.Rx + Other.Rx;

    (* Firstly check roughly *)
    if (Abs(DistanceX) > SummOfRadiuses)
      or (Abs(DistanceY) > Self.Ry + Other.Ry) then
      CheckCollisionWith := False
    else
      (* Now check more precisely *)
      CheckCollisionWith :=
        (Sqr(DistanceX) + Sqr(Round(DistanceY / AspectRatio)) < Sqr(SummOfRadiuses));
  end;

  procedure TBall.CalculateCollisionWith(var Other: TBall);
  var
    DistanceX: LongInt;
    DistanceY: LongInt;
    Distance: LongInt;
    Sin_A, Cos_A: Real;
    Vn1, Vn2: Real;
    Vt1, Vt2: Real;
    Vexch: Real;
  begin
    DistanceX := Self.X - Other.X;
    DistanceY := Self.Y - Other.Y;
    Distance := Round(Sqrt(Sqr(DistanceX) + Sqr(Round(DistanceY / AspectRatio))));

    Sin_A := DistanceY / AspectRatio / Distance;
    Cos_A := DistanceX / Distance;

    Vn1 := Self.Dy * Sin_A / AspectRatio + Self.Dx * Cos_A;
    Vt1 := Self.Dy * Cos_A / AspectRatio - Self.Dx * Sin_A;

    Vn2 := Other.Dy * Sin_A / AspectRatio + Other.Dx * Cos_A;
    Vt2 := Other.Dy * Cos_A / AspectRatio - Other.Dx * Sin_A;

    Vexch := 2 * (Self.Mass * Vn1 + Other.Mass * Vn2) / (Self.Mass + Other.Mass);

    Vn1 := -Vn1 + Vexch;
    Vn2 := -Vn2 + Vexch;

    Self.Dx := Round(Vn1 * Cos_A - Vt1 * Sin_A);
    Self.Dy := Round((Vn1 * Sin_A + Vt1 * Cos_A) * AspectRatio);

    Other.Dx := Round(Vn2 * Cos_A - Vt2 * Sin_A);
    Other.Dy := Round((Vn2 * Sin_A + Vt2 * Cos_A) * AspectRatio);
  end;

end.
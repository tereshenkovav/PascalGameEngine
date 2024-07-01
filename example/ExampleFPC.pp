program ExampleFPC;

{$APPTYPE GUI}

uses
  {$ifdef unix}cthreads,{$endif}
  SysUtils, Math, 
  main ;

begin
  {$ifdef unix}
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  {$endif}

  Main.Run() ;
 
end.

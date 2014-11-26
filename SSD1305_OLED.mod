MODULE SSD1305_OLED;

IMPORT SYSTEM, MCU, SPI;

CONST

  Black*   = 0;
  White*   = 1;
  
  MaxX* = 127;
  MaxY* = 63;
  
  FontWidth = 6;
  FontHeight = 8;
  
  Cols* = (MaxX + 1) DIV FontWidth;
  Rows* = (MaxY + 1) DIV FontHeight;
  Pages* = (MaxY + 1) DIV 8;
  
  A0 = {6};    (* P0.6  = mbed P8 *)
  CS = {18};   (* P0.18 = mbed P11 *)
  DC = {19};
  SCLK = {20};
  Reset = {8}; (* P0.8  = mbed P6 *)
  
  OLED_MOSI = {9}; 
  OLED_CLK = {10}; (*Serial Clock. Used only in serial interface mode*)
  OLED_DC = {11}; (*This is Data/Command control pin. When it is pulled HIGH (i.e. connect to VDDIO), the data
                    at D[7:0] is treated as data. When it is pulled LOW, the data at D[7:0] will be transferred to
                    the command register.In I2C mode, this pin acts as SA0 for slave address selection.
                    For detail relationship to MCU interface signals, please refer to the Timing Characteristics 
                    Diagrams: Figure 13-1 to Figure 13-5.*)

  OLED_CS = {12}; (* chip select pin. active low*)
  OLED_RESET = {13}; 

  SSD1305_SETLOWCOLUMN = 000H;
  SSD1305_SETHIGHCOLUMN = 010H;
  SSD1305_SETSTARTCOLUMN = 021H;
  SSD1305_SETSTARTPAGE = 022H;
  SSD1305_MEMORYMODE = 020H;
  SSD1305_SETSTARTLINE = 040H;
  SSD1305_SETCONTRAST = 081H;
  SSD1305_SEGREMAP = 0A0H;
  SSD1305_SEGREMAP1 = 0A1H; 
  SSD1305_DISPLAYALLON_RESUME = 0A4H;
  SSD1305_DISPLAYALLON = 0A5H;
  SSD1305_NORMALDISPLAY = 0A6H;
  SSD1305_INVERTDISPLAY = 0A7H;
  SSD1305_SETMULTIPLEX = 0A8H;
  SSD1305_DISPLAYOFF = 0AEH;
  SSD1305_DISPLAYON = 0AFH;
  SSD1305_SET_PAGE = 0B0H;
  SSD1305_COMSCANDEC = 0C8H;
  SSD1305_SETDISPLAYOFFSET = 0D3H;
  SSD1305_SETDISPLAYCLOCKDIV = 0D5H;
  SSD1305_SETPRECHARGE = 0D9H;
  SSD1305_SETCOMPINS = 0DAH;
  SSD1305_SETVCOMDETECT = 0DBH;
  SSD1305_SET_MODIFY = 0E0H;
  SSD1305_CLR_MODIFY = 0EEH;
  SSD1305_NOP = 0E3H;
  
TYPE

VAR
 
PROCEDURE GLCD_WriteData(dataToWrite: INTEGER);
BEGIN
   SYSTEM.PUT(MCU.FIO0SET, A0);(* mBed P8*)
   SYSTEM.PUT(MCU.FIO0CLR, CS);(* mBed P11*)
   SPI.SendData(dataToWrite);
   SYSTEM.PUT(MCU.FIO0SET, CS);
END GLCD_WriteData;


PROCEDURE GLCD_WriteCommand(commandToWrite: INTEGER);
BEGIN
  SYSTEM.PUT(MCU.FIO0CLR, A0);
  SYSTEM.PUT(MCU.FIO0CLR, CS);
  SPI.SendData(commandToWrite);
  SYSTEM.PUT(MCU.FIO0SET, CS)
END GLCD_WriteCommand;

PROCEDURE GLCD_WriteComData(comm, data: INTEGER);
BEGIN
  SYSTEM.PUT(MCU.FIO0SET, A0);
  SYSTEM.PUT(MCU.FIO0CLR, CS);
  SPI.SendData(comm);
  SPI.SendData(data);
  SYSTEM.PUT(MCU.FIO0SET, CS)
END GLCD_WriteComData; 


PROCEDURE GLCD_ReadData();
BEGIN
END GLCD_ReadData;


PROCEDURE GLCD_InitializePorts();
BEGIN
END GLCD_InitializePorts;


PROCEDURE* ConfigurePinsProc();
BEGIN
END ConfigurePinsProc;


(*PROCEDURE GLCD_ReadByteFromROMMemory(rbyte :CHAR):ptr;
BEGIN

END GLCD_ReadByteFromROMMemory;*)


PROCEDURE GLCD_Initialize();
BEGIN
GLCD_InitializePorts();
GLCD_WriteCommand(SSD1305_DISPLAYOFF);  

GLCD_WriteCommand(SSD1305_SETDISPLAYCLOCKDIV);  
GLCD_WriteCommand(080H); (* // the suggested ratio 0x80*)

GLCD_WriteCommand(SSD1305_SETMULTIPLEX); 
GLCD_WriteCommand(03FH); (* // 0x3F 1/64 duty*)

GLCD_WriteCommand(SSD1305_SETDISPLAYOFFSET); 
GLCD_WriteCommand(000H); (* no offset*)

GLCD_WriteCommand(SSD1305_SETSTARTLINE); 
GLCD_WriteCommand(SSD1305_SEGREMAP1); 
GLCD_WriteCommand(SSD1305_COMSCANDEC); 

GLCD_WriteCommand(SSD1305_SETCOMPINS); 
GLCD_WriteCommand(012H); (* disable COM left/right remap*)

GLCD_WriteCommand(SSD1305_SETCONTRAST);
GLCD_WriteCommand(0FFH);

GLCD_WriteCommand(SSD1305_SETPRECHARGE); 
GLCD_WriteCommand(0F1H);

GLCD_WriteCommand(SSD1305_SETVCOMDETECT); 
GLCD_WriteCommand(040H);

GLCD_WriteCommand(SSD1305_DISPLAYALLON_RESUME); 

GLCD_WriteCommand(SSD1305_NORMALDISPLAY); 

GLCD_WriteCommand(SSD1305_MEMORYMODE); 
GLCD_WriteCommand(000H);

GLCD_WriteComData(SSD1305_SETLOWCOLUMN, 000H);  (*low col = 0*) 

GLCD_WriteComData(SSD1305_SETHIGHCOLUMN, 000H);  (* hi col = 0*) 

GLCD_WriteCommand(SSD1305_SETSTARTCOLUMN);
GLCD_WriteCommand(0);

(*GLCD_WriteCommand(SCREEN_WIDTH-1  ; FIX THIS!!! ???*******?????*)

GLCD_WriteComData(SSD1305_SEGREMAP, 001H);

GLCD_WriteCommand(SSD1305_DISPLAYON);(*//--turn on oled panel*)

END GLCD_Initialize;


END SSD1305_OLED.

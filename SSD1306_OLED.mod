MODULE SSD1306_OLED;
(* =========================================================================  
   Example Cortex-M3 Oberon Module  
 
   Description:
     Sitronix ST756R LCD Controller Driver

   Target:
     mbed systems
     
   Tested on: 
     ARM mbed Application Board with a Newhaven C12832A1Z 128 x 32 LCD display 
   
   Reference:
     Sitronix ST756R DataSheet Ver 1.5 (10 Mar 2006).
     
   (c) 2013-2014 CFB Software
   http://www.astrobe.com
   
   ========================================================================= *)

IMPORT Timer, MCU, ResData, SPI, SYSTEM;

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
  Reset = {8}; (* P0.8  = mbed P6 *)
  
 (* OLED_MOSI = {9}; 
  OLED_CLK = {10}; 
  OLED_DC = {11}; 
  OLED_CS = {12}; 
  OLED_RESET = {13}; *)
  
  SSD1306_I2C_ADDRESS =              03DH;
  
  SSD1306_LCDWIDTH =                 128;
  SSD1306_LCDHEIGHT =                64;
  SSD1306_SETCONTRAST =              081H;
  SSD1306_DISPLAYALLON_RESUME =      0A4H;
  SSD1306_DISPLAYALLON =             0A5H;
  SSD1306_NORMALDISPLAY =            0A6H;
  SSD1306_INVERTDISPLAY =            0A7H;
  SSD1306_DISPLAYOFF =               0AEH;
  SSD1306_DISPLAYON =                0AFH;
  SSD1306_SETDISPLAYOFFSET =         0D3H;
  SSD1306_SETCOMPINS =               0DAH;
  
  SSD1306_SETVCOMDETECT =            0DBH;

  SSD1306_SETDISPLAYCLOCKDIV =       0D5H;
  SSD1306_SETPRECHARGE =             0D9H; 

  SSD1306_SETMULTIPLEX =             0A8H;

  SSD1306_SETLOWCOLUMN =             000H;
  SSD1306_SETHIGHCOLUMN =            010H;

  SSD1306_SETSTARTLINE =             040H;

  SSD1306_MEMORYMODE =               020H;
  SSD1306_COLUMNADDR =               021H;
  SSD1306_PAGEADDR   =               022H;

  SSD1306_COMSCANINC =               0C0H;
  SSD1306_COMSCANDEC =               0C8H;

  SSD1306_SEGREMAP =                 0A0H;

  SSD1306_CHARGEPUMP =               08DH;

  SSD1306_EXTERNALVCC =              01H;(* 0x1; *)
  SSD1306_SWITCHCAPVCC =             02H;(* 0x2; *)


  SSD1306_ACTIVATE_SCROLL =          02FH;
  SSD1306_DEACTIVATE_SCROLL =        02EH;
  SSD1306_SET_VERTICAL_SCROLL_AREA = 0A3H;
  SSD1306_RIGHT_HORIZONTAL_SCROLL =  026H;
  SSD1306_LEFT_HORIZONTAL_SCROLL =   027H;
  SSD1306_VERTICAL_AND_RIGHT_HORIZONTAL_SCROLL = 029H;
  SSD1306_VERTICAL_AND_LEFT_HORIZONTAL_SCROLL  = 02AH;        
  

TYPE
  (* Each bit represents a pixel on the screen *)
  (* Each page can be refreshed invidually *)
  BitMap = ARRAY MaxX + 1 OF SET;  
  
VAR  
  (* In-memory representation of the screen *)
  bitMap0, bitMap: BitMap;
    
   
  PROCEDURE SendData(data: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.FIO0SET, A0);(* mBed P8*)
    SYSTEM.PUT(MCU.FIO0CLR, CS);(* mBed P11*)
    SPI.SendData(data);
    SYSTEM.PUT(MCU.FIO0SET, CS);
  END SendData;
  
   
  PROCEDURE SendCommand(data: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.FIO0CLR, A0);(* mBed P8*)
    SYSTEM.PUT(MCU.FIO0CLR, CS);(* mBed P11*)
    SPI.SendData(data);
    SYSTEM.PUT(MCU.FIO0SET, CS)
  END SendCommand;
  
  PROCEDURE SendComData(comm, data: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.FIO0CLR, A0);
    SYSTEM.PUT(MCU.FIO0SET, CS);
    SPI.SendData(comm);
    SPI.SendData(data);
    SYSTEM.PUT(MCU.FIO0SET, CS)
  END SendComData; 
  
  
  PROCEDURE* ConfigureSPI1Pins;
  VAR
    s: SET;
  BEGIN 
    (* SPI1 *)
    (* Setup    SCK1, SSEL1, MISO1, MOSI1, no SSEL *)
    (* PS0 bits 15:14 12:13  17:16, 19:18 := 10B *) 
    SYSTEM.GET(MCU.PINSEL0, s);
    s := s + {15, 17, 19} - {14, 16, 18};
    SYSTEM.PUT(MCU.PINSEL0, s)
  END ConfigureSPI1Pins;
   

  PROCEDURE* ConfigureGPIOPins;
  VAR
    s: SET;
  BEGIN
    (* P0.6, P0.8 are GPIO ports *)
    SYSTEM.GET(MCU.PINSEL0, s);
    s := s - {12, 13, 16, 17};
    SYSTEM.PUT(MCU.PINSEL0, s);

    (* P0.18 is GPIO port *)
    SYSTEM.GET(MCU.PINSEL1, s);
    s := s - {4, 5};
    SYSTEM.PUT(MCU.PINSEL1, s);

    (* P0.6, 0.8 and 0.18 are outputs *)
    SYSTEM.GET(MCU.FIO0DIR, s);
    SYSTEM.PUT(MCU.FIO0DIR, s + A0 + CS + Reset)
  END ConfigureGPIOPins;

   
  PROCEDURE Init*;
  CONST
    nBits = 8;
  BEGIN
    SPI.Init(SPI.SPI1, nBits, ConfigureSPI1Pins);
    ConfigureGPIOPins();
    SYSTEM.PUT(MCU.FIO0CLR, A0); 
    SYSTEM.PUT(MCU.FIO0SET, CS); 
    SYSTEM.PUT(MCU.FIO0CLR, Reset); 
    Timer.uSecDelay(100);
    SYSTEM.PUT(MCU.FIO0SET, Reset); 
    Timer.uSecDelay(100);

    SendCommand(0AEH); (* Display off  ??? 0xAE*)
    
    SendCommand(0A2H); (* Bias voltage *) 
    SendCommand(00AH); (* ADC Normal *)
    
    SendComData(05DH, 080H); (* COM Scan normal *)
    (*SendCommand(080H);  suggested ratio 0x80 *)
 
    SendComData(0A8H, 03FH); (* Set Multiplex *)
    (*SendCommand(03FH);*)
    
    SendComData(3D0H, 000H); (* Set display offset *)
    (*SendCommand(000H);  (* no offset *)*)
 
    SendComData(040H, 000H); (* Set start line *)
    (*SendCommand(000H);*)
    
    SendComData(08DH, 014H);  (* Set charge pump*)
    (*SendCommand(140H);  (* set for internal vcc. 0x10 for external vcc*)*)
    
    SendComData(020H, 000H); (* Set memory mode *)
    (*SendCommand(000H);*)
    
    SendComData(0A0H, 001H); (* Set segremap *)
    (*SendCommand(1H);*)
    
    SendCommand(08CH); (* ComScanDecr *)
    
    SendComData(0ADH, 012H); (* Set com pins*) 
    (*SendCommand(012H);*)
    
    SendComData(081H, 0FCH); (* Set contrast *)
    (*SendCommand(0FCH); (* external vcc=0FCH, internal=09FH*)*)
    
    SendComData(0DH, 01FH);  (*Set precharge *)
    (*SendCommand(1F0H);*)
    
    SendComData(0DBH, 040H); (* Set V com detect *)
    (*SendCommand(040H);*)
    
    SendCommand(0A4H); (* Display all on resume *)
    
    SendCommand(0A6H); (* Normal display *) 
   
    (*ClearScreen(Black);*)
    bitMap0 := bitMap;
    (*ClearScreen(White);*)
    (*Refresh();*)
    SendCommand(0A4H);  (*DisplayOn *)
    
(*  Init sequence
  #if defined SSD1306_128_64
    // Init sequence for 128x64 OLED module
    ssd1306_command(SSD1306_DISPLAYOFF);                    // 0xAE
    ssd1306_command(SSD1306_SETDISPLAYCLOCKDIV);            // 0xD5
    ssd1306_command(0x80);                                  // the suggested ratio 0x80
    ssd1306_command(SSD1306_SETMULTIPLEX);                  // 0xA8
    ssd1306_command(0x3F);
    ssd1306_command(SSD1306_SETDISPLAYOFFSET);              // 0xD3
    ssd1306_command(0x0);                                   // no offset
    ssd1306_command(SSD1306_SETSTARTLINE | 0x0);            // line #0
    ssd1306_command(SSD1306_CHARGEPUMP);                    // 0x8D
    if (vccstate == SSD1306_EXTERNALVCC) 
      { ssd1306_command(0x10); }
    else 
      { ssd1306_command(0x14); }
    ssd1306_command(SSD1306_MEMORYMODE);                    // 0x20
    ssd1306_command(0x00);                                  // 0x0 act like ks0108
    ssd1306_command(SSD1306_SEGREMAP | 0x1);
    ssd1306_command(SSD1306_COMSCANDEC);
    ssd1306_command(SSD1306_SETCOMPINS);                    // 0xDA
    ssd1306_command(0x12);
    ssd1306_command(SSD1306_SETCONTRAST);                   // 0x81
    if (vccstate == SSD1306_EXTERNALVCC) 
      { ssd1306_command(0x9F); }
    else 
      { ssd1306_command(0xCF); }
    ssd1306_command(SSD1306_SETPRECHARGE);                  // 0xd9
    if (vccstate == SSD1306_EXTERNALVCC) 
      { ssd1306_command(0x22); }
    else 
      { ssd1306_command(0xF1); }
    ssd1306_command(SSD1306_SETVCOMDETECT);                 // 0xDB
    ssd1306_command(0x40);
    ssd1306_command(SSD1306_DISPLAYALLON_RESUME);           // 0xA4
    ssd1306_command(SSD1306_NORMALDISPLAY);                 // 0xA6
  #endif*)


  END Init;

END SSD1306_OLED.

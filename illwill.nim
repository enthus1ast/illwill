## :Authors: John Novak
##
## This is a ``curses`` inspired simple terminal library that aims to make
## writing cross-platform text mode applications easier. The main features are:
##
## * Non-blocking keyboard input
## * Support for key combinations and special keys available both in the
##   standard Windows Console (``cmd.exe``) and most common POSIX terminals
## * Virtual terminal buffers with double-buffering support (only
##   display changes from the previous frame and minimise the number of
##   attribute changes to reduce CPU usage)
## * Simple graphics using UTF-8 box drawing symbols
## * Full-screen support with restoring the contents of the terminal after
##   exit
##
## The module depends only on the standard `terminal` module. However, you
## should not use any `terminal` functions directly, neither should you use
## ``echo``, ``write`` or other similar functions for output. You should only
## use the interface provided by the module to interact with the terminal.
##
## The following symbols are exported from the `terminal` module (these are
## safe to use):
##
## ``terminalWidth()``, ``terminalHeight()``, ``terminalSize()``,
## ``hideCursor()``, ``showCursor()``, ``Style``
##

import os, strformat, terminal, unicode

export terminal.terminalWidth
export terminal.terminalHeight
export terminal.terminalSize
export terminal.hideCursor
export terminal.showCursor
export terminal.Style

type
  ForegroundColor* = enum   ## Foreground colors
    fgNone = 0,             ## default
    fgBlack = 30,           ## black
    fgRed,                  ## red
    fgGreen,                ## green
    fgYellow,               ## yellow
    fgBlue,                 ## blue
    fgMagenta,              ## magenta
    fgCyan,                 ## cyan
    fgWhite                 ## white

  BackgroundColor* = enum   ## Background colors
    bgNone = 0,             ## default (transparent)
    bgBlack = 40,           ## black
    bgRed,                  ## red
    bgGreen,                ## green
    bgYellow,               ## yellow
    bgBlue,                 ## blue
    bgMagenta,              ## magenta
    bgCyan,                 ## cyan
    bgWhite                 ## white

  Key* {.pure.} = enum      ## Supported single key presses and key combinations
    None = (-1, "None"),

    # Special ASCII characters
    CtrlA  = (1, "CtrlA"),
    CtrlB  = (2, "CtrlB"),
    CtrlC  = (3, "CtrlC"),
    CtrlD  = (4, "CtrlD"),
    CtrlE  = (5, "CtrlE"),
    CtrlF  = (6, "CtrlF"),
    CtrlG  = (7, "CtrlG"),
    CtrlH  = (8, "CtrlH"),
    Tab    = (9, "Tab"),     # Ctrl-I
    CtrlJ  = (10, "CtrlJ"),
    CtrlK  = (11, "CtrlK"),
    CtrlL  = (12, "CtrlL"),
    Enter  = (13, "Enter"),  # Ctrl-M
    CtrlN  = (14, "CtrlN"),
    CtrlO  = (15, "CtrlO"),
    CtrlP  = (16, "CtrlP"),
    CtrlQ  = (17, "CtrlQ"),
    CtrlR  = (18, "CtrlR"),
    CtrlS  = (19, "CtrlS"),
    CtrlT  = (20, "CtrlT"),
    CtrlU  = (21, "CtrlU"),
    CtrlV  = (22, "CtrlV"),
    CtrlW  = (23, "CtrlW"),
    CtrlX  = (24, "CtrlX"),
    CtrlY  = (25, "CtrlY"),
    CtrlZ  = (26, "CtrlZ"),
    Escape = (27, "Escape"),

    CtrlBackslash    = (28, "CtrlBackslash"),
    CtrlRightBracket = (29, "CtrlRightBracket"),

    # Printable ASCII characters
    Space           = (32, "Space"),
    ExclamationMark = (33, "ExclamationMark"),
    DoubleQuote     = (34, "DoubleQuote"),
    Hash            = (35, "Hash"),
    Dollar          = (36, "Dollar"),
    Percent         = (37, "Percent"),
    Ampersand       = (38, "Ampersand"),
    SingleQuote     = (39, "SingleQuote"),
    LeftParen       = (40, "LeftParen"),
    RightParen      = (41, "RightParen"),
    Asterisk        = (42, "Asterisk"),
    Plus            = (43, "Plus"),
    Comma           = (44, "Comma"),
    Minus           = (45, "Minus"),
    Dot             = (46, "Dot"),
    Slash           = (47, "Slash"),

    Zero  = (48, "Zero"),
    One   = (49, "One"),
    Two   = (50, "Two"),
    Three = (51, "Three"),
    Four  = (52, "Four"),
    Five  = (53, "Five"),
    Six   = (54, "Six"),
    Seven = (55, "Seven"),
    Eight = (56, "Eight"),
    Nine  = (57, "Nine"),

    Colon        = (58, "Colon"),
    Semicolon    = (59, "Semicolon"),
    LessThan     = (60, "LessThan"),
    Equals       = (61, "Equals"),
    GreaterThan  = (62, "GreaterThan"),
    QuestionMark = (63, "QuestionMark"),
    At           = (64, "At"),

    ShiftA  = (65, "ShiftA"),
    ShiftB  = (66, "ShiftB"),
    ShiftC  = (67, "ShiftC"),
    ShiftD  = (68, "ShiftD"),
    ShiftE  = (69, "ShiftE"),
    ShiftF  = (70, "ShiftF"),
    ShiftG  = (71, "ShiftG"),
    ShiftH  = (72, "ShiftH"),
    ShiftI  = (73, "ShiftI"),
    ShiftJ  = (74, "ShiftJ"),
    ShiftK  = (75, "ShiftK"),
    ShiftL  = (76, "ShiftL"),
    ShiftM  = (77, "ShiftM"),
    ShiftN  = (78, "ShiftN"),
    ShiftO  = (79, "ShiftO"),
    ShiftP  = (80, "ShiftP"),
    ShiftQ  = (81, "ShiftQ"),
    ShiftR  = (82, "ShiftR"),
    ShiftS  = (83, "ShiftS"),
    ShiftT  = (84, "ShiftT"),
    ShiftU  = (85, "ShiftU"),
    ShiftV  = (86, "ShiftV"),
    ShiftW  = (87, "ShiftW"),
    ShiftX  = (88, "ShiftX"),
    ShiftY  = (89, "ShiftY"),
    ShiftZ  = (90, "ShiftZ"),

    LeftBracket  = (91, "LeftBracket"),
    Backslash    = (92, "Backslash"),
    RightBracket = (93, "RightBracket"),
    Caret        = (94, "Caret"),
    Underscore   = (95, "Underscore"),
    GraveAccent  = (96, "GraveAccent"),

    A = (97, "A"),
    B = (98, "B"),
    C = (99, "C"),
    D = (100, "D"),
    E = (101, "E"),
    F = (102, "F"),
    G = (103, "G"),
    H = (104, "H"),
    I = (105, "I"),
    J = (106, "J"),
    K = (107, "K"),
    L = (108, "L"),
    M = (109, "M"),
    N = (110, "N"),
    O = (111, "O"),
    P = (112, "P"),
    Q = (113, "Q"),
    R = (114, "R"),
    S = (115, "S"),
    T = (116, "T"),
    U = (117, "U"),
    V = (118, "V"),
    W = (119, "W"),
    X = (120, "X"),
    Y = (121, "Y"),
    Z = (122, "Z"),

    LeftBrace  = (123, "LeftBrace"),
    Pipe       = (124, "Pipe"),
    RightBrace = (125, "RightBrace"),
    Tilde      = (126, "Tilde"),
    Backspace  = (127, "Backspace"),

    # Special characters with virtual keycodes
    Up       = (1001, "Up"),
    Down     = (1002, "Down"),
    Right    = (1003, "Right"),
    Left     = (1004, "Left"),
    Home     = (1005, "Home"),
    Insert   = (1006, "Insert"),
    Delete   = (1007, "Delete"),
    End      = (1008, "End"),
    PageUp   = (1009, "PageUp"),
    PageDown = (1010, "PageDown"),

    F1  = (1011, "F1"),
    F2  = (1012, "F2"),
    F3  = (1013, "F3"),
    F4  = (1014, "F4"),
    F5  = (1015, "F5"),
    F6  = (1016, "F6"),
    F7  = (1017, "F7"),
    F8  = (1018, "F8"),
    F9  = (1019, "F9"),
    F10 = (1020, "F10"),
    F11 = (1021, "F11"),
    F12 = (1022, "F12")


func toKey(c: int): Key =
  try:
    result = Key(c)
  except RangeError:  # ignore unknown keycodes
    result = Key.None


var gFullscreen = false

when defined(windows):
  import encodings, unicode, winlean

  proc kbhit(): cint {.importc: "_kbhit", header: "<conio.h>".}
  proc getch(): cint {.importc: "_getch", header: "<conio.h>".}

  proc consoleInit() = discard
  proc consoleDeinit() = discard

  func getKeyAsync(): Key =
    var key = Key.None

    if kbhit() > 0:
      let c = getch()
      case c:
      of   0:
        case getch():
        of 59: key = Key.F1
        of 60: key = Key.F2
        of 61: key = Key.F3
        of 62: key = Key.F4
        of 63: key = Key.F5
        of 64: key = Key.F6
        of 65: key = Key.F7
        of 66: key = Key.F8
        of 67: key = Key.F9
        of 68: key = Key.F10
        else: discard getch()  # ignore unknown 2-key keycodes

      of   8: key = Key.Backspace
      of   9: key = Key.Tab
      of  13: key = Key.Enter
      of  32: key = Key.Space

      of 224:
        case getch():
        of  72: key = Key.Up
        of  75: key = Key.Left
        of  77: key = Key.Right
        of  80: key = Key.Down

        of  71: key = Key.Home
        of  82: key = Key.Insert
        of  83: key = Key.Delete
        of  79: key = Key.End
        of  73: key = Key.PageUp
        of  81: key = Key.PageDown

        of 133: key = Key.F11
        of 134: key = Key.F12
        else: discard  # ignore unknown 2-key keycodes

      else:
        key = toKey(c)

    result = key


  proc writeConsole(hConsoleOutput: HANDLE, lpBuffer: pointer,
                    nNumberOfCharsToWrite: DWORD,
                    lpNumberOfCharsWritten: ptr DWORD,
                    lpReserved: pointer): WINBOOL {.
    stdcall, dynlib: "kernel32", importc: "WriteConsoleW".}

  var hStdout = getStdHandle(STD_OUTPUT_HANDLE)
  var utf16LEConverter = open(destEncoding = "utf-16", srcEncoding = "UTF-8")

  proc put(s: string) =
    var us = utf16LEConverter.convert(s)
    var numWritten: DWORD
    discard writeConsole(hStdout, pointer(us[0].addr), DWORD(s.runeLen),
                         numWritten.addr, nil)


else:  # OS X & Linux
  import posix, tables, termios

  proc nonblock(enabled: bool) =
    var ttyState: Termios

    # get the terminal state
    discard tcGetAttr(STDIN_FILENO, ttyState.addr)

    if enabled:
      # turn off canonical mode & echo
      ttyState.c_lflag = ttyState.c_lflag and not Cflag(ICANON or ECHO)

      # minimum of number input read
      ttyState.c_cc[VMIN] = 0.cuchar

    else:
      # turn on canonical mode & echo
      ttyState.c_lflag = ttyState.c_lflag or ICANON or ECHO

    # set the terminal attributes.
    discard tcSetAttr(STDIN_FILENO, TCSANOW, ttyState.addr)


  proc kbhit(): cint =
    var tv: Timeval
    tv.tv_sec = Time(0)
    tv.tv_usec = 0

    var fds: TFdSet
    FD_ZERO(fds)
    FD_SET(STDIN_FILENO, fds)
    discard select(STDIN_FILENO+1, fds.addr, nil, nil, tv.addr)
    return FD_ISSET(STDIN_FILENO, fds)


  proc consoleInit() = nonblock(true)
  proc consoleDeinit() = nonblock(false)

  # surely a 100 char buffer is more than enough; the longest
  # keycode sequence I've seen was 6 chars
  const KeySequenceMaxLen = 100

  # global keycode buffer
  var keyBuf: array[KeySequenceMaxLen, int]

  let
    keySequences = {
      ord(Key.Up):        @["\eOA", "\e[A"],
      ord(Key.Down):      @["\eOB", "\e[B"],
      ord(Key.Right):     @["\eOC", "\e[C"],
      ord(Key.Left):      @["\eOD", "\e[D"],

      ord(Key.Home):      @["\e[1~", "\e[7~", "\eOH", "\e[H"],
      ord(Key.Insert):    @["\e[2~"],
      ord(Key.Delete):    @["\e[3~"],
      ord(Key.End):       @["\e[4~", "\e[8~", "\eOF", "\e[F"],
      ord(Key.PageUp):    @["\e[5~"],
      ord(Key.PageDown):  @["\e[6~"],

      ord(Key.F1):        @["\e[11~", "\eOP"],
      ord(Key.F2):        @["\e[12~", "\eOQ"],
      ord(Key.F3):        @["\e[13~", "\eOR"],
      ord(Key.F4):        @["\e[14~", "\eOS"],
      ord(Key.F5):        @["\e[15~"],
      ord(Key.F6):        @["\e[17~"],
      ord(Key.F7):        @["\e[18~"],
      ord(Key.F8):        @["\e[19~"],
      ord(Key.F9):        @["\e[20~"],
      ord(Key.F10):       @["\e[21~"],
      ord(Key.F11):       @["\e[23~"],
      ord(Key.F12):       @["\e[24~"]
    }.toTable

  proc parseKey(charsRead: int): Key =
    # Inspired by
    # https://github.com/mcandre/charm/blob/master/lib/charm.c
    var key = Key.None
    if charsRead == 1:
      let ch = keyBuf[0]
      case ch:
      of   9: key = Key.Tab
      of  10: key = Key.Enter
      of  27: key = Key.Escape
      of  32: key = Key.Space
      of 127: key = Key.Backspace
      of 0, 29, 30, 31: discard   # these have no Windows equivalents so
                                  # we'll ignore them
      else:
        key = toKey(ch)
    else:
      var inputSeq = ""
      for i in 0..<charsRead:
        inputSeq &= char(keyBuf[i])
      for keyCode, sequences in keySequences.pairs:
        for s in sequences:
          if s == inputSeq:
            key = toKey(keyCode)
    result = key

  proc getKeyAsync(): Key =
    var i = 0
    while kbhit() > 0 and i < KeySequenceMaxLen:
      var ret = read(0, keyBuf[i].addr, 1)
      if ret > 0:
        i += 1
      else:
        break
    if i == 0:  # nothing read
      result = Key.None
    else:
      result = parseKey(i)

  template put(s: string) = stdout.write s


const
  XtermColor    = "xterm-color"
  Xterm256Color = "xterm-256color"

proc enterFullscreen() =
  ## Enters full screen mode (clears the terminal).
  when defined(posix):
    case getEnv("TERM"):
    of XtermColor:
      stdout.write "\e7\e[?47h"
    of Xterm256Color:
      stdout.write "\e[?1049h"
    else:
      eraseScreen()
  else:
    eraseScreen()

proc exitFullscreen() =
  ## Exits full screen mode (restores the previous contents of the terminal).
  when defined(posix):
    case getEnv("TERM"):
    of XtermColor:
      stdout.write "\e[2J\e[?47l\e8"
    of Xterm256Color:
      stdout.write "\e[?1049l"
    else:
      eraseScreen()
  else:
    eraseScreen()

proc illwillInit*(fullscreen: bool = true) =
  ## Initializes the terminal and enabled non-blocking keyboard input. Needs
  ## to be called before doing anything with the library.
  gFullscreen = fullscreen
  if gFullscreen: enterFullscreen()
  consoleInit()
  resetAttributes()

proc illwillDeinit*() =
  ## Resets the terminal to its previous state. Needs to be called before
  ## exiting the application.
  if gFullscreen: exitFullscreen()
  consoleDeinit()
  resetAttributes()
  showCursor()

proc getKey*(): Key =
  ## Reads the next keystroke in a non-blocking manner. If there are no
  ## keypress events in the buffer, ``Key.None`` is returned.
  getKeyAsync()


type
  TerminalChar* = object
    ## Represents a character in the terminal buffer, including color and
    ## style information.
    ##
    ## If `forceWrite` is set to true, the character is always output even
    ## when double buffering is enabled (this is a hack to achieve better
    ## continuity of horizontal lines when using box drawing UTF-8 symbols in
    ## the Windows Console).
    ch*: Rune
    fg*: ForegroundColor
    bg*: BackgroundColor
    style*: set[Style]
    forceWrite*: bool

  TerminalBuffer* = ref object
    ## A virtual terminal buffer of a fixed width and height. It remembers the
    ## current color and style settings and the current cursor position.
    ##
    ## Write to the terminal buffer with ``TerminalBuffer.write()`` or you can
    ## access the character buffer directly with the index operators:
    ##
    ## .. code-block::
    ##   # Create a new terminal buffer
    ##   var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
    ##
    ##   # Write the character "X" to the top left of the terminal then read it back
    ##   tb[0,0] = TerminalChar("X".runeAt(0), fgWhite, bgNone, style = {})
    ##   let ch = tb[0,0]
    ##
    ##   # Write "foo" at position (10,10) in bright red
    ##   tb.setForegroundColor(fgRed, bright=true)
    ##   tb.setCursorPos(10, 10)
    ##   tb.write("foo")
    ##
    ##   # Write "bar" at position (15,12) in bright red, without changing
    ##   # the current cursor position
    ##   tb.write(15, 12, "bar")
    ##
    ##   # Output the contents of the buffer to the screen
    ##   tb.display()
    ##
    width: int
    height: int
    buf: seq[TerminalChar]
    currBg: BackgroundColor
    currFg: ForegroundColor
    currStyle: set[Style]
    currX: Natural
    currY: Natural

proc `[]=`*(tb: var TerminalBuffer, x, y: Natural, ch: TerminalChar) =
  ## Index operator to write a character into the terminal buffer at the
  ## specified location.
  if x < tb.width and y < tb.height:
    tb.buf[tb.width * y + x] = ch

proc `[]`*(tb: TerminalBuffer, x, y: Natural): TerminalChar =
  ## Index operator to read a character from the terminal buffer at the
  ## specified location.
  if x < tb.width and y < tb.height:
    result = tb.buf[tb.width * y + x]


proc fill*(tb: var TerminalBuffer, x1, y1, x2, y2: Natural, ch: string = " ") =
  ## Fills a rectangular areas with the `ch` character, using the current text
  ## attributes.
  if x1 < tb.width and y1 < tb.height:
    let
      c = TerminalChar(ch: ch.runeAt(0), fg: tb.currFg, bg: tb.currBg,
                       style: tb.currStyle)

      xe = min(x2, tb.width-1)
      ye = min(y2, tb.height-1)

    for y in y1..ye:
      for x in x1..xe:
        tb[x, y] = c


proc clear*(tb: var TerminalBuffer, ch: string = " ") =
  ## Clears the contents of the terminal buffer with the `ch` character, using
  ## the ``fgNone`` and ``bgNone`` attributes.
  let c = TerminalChar(ch: ch.runeAt(0), fg: fgNone, bg: bgNone, style: {})
  tb.fill(0, 0, tb.width-1, tb.height-1, ch)

proc initTerminalBuffer(tb: var TerminalBuffer, width, height: Natural) =
  ## Initializes a new terminal buffer object of a fixed width and height.
  tb.width = width
  tb.height = height
  newSeq(tb.buf, width * height)
  tb.currBg = bgNone
  tb.currFg = fgNone
  tb.currStyle = {}

proc newTerminalBuffer*(width, height: Natural): TerminalBuffer =
  ## Creates a new terminal buffer of a fixed width and height.
  var tb = new TerminalBuffer
  tb.initTerminalBuffer(width, height)
  tb.clear()
  result = tb

func width*(tb: TerminalBuffer): Natural =
  ## Returns the width of the terminal buffer.
  result = tb.width

func height*(tb: TerminalBuffer): Natural =
  ## Returns the height of the terminal buffer.
  result = tb.height

proc copyFrom*(tb: var TerminalBuffer,
               src: TerminalBuffer, srcX, srcY, width, height: Natural,
               destX, destY: Natural) =
  ## Copies the contents of the `src` terminal buffer into this one.
  ## A rectangular area of dimension `width` and `height` is copied from
  ## the position `srcX` and `srcY` in the source buffer to the position
  ## `destX` and `destY` in this buffer.
  ##
  ## If the extents of the area to be copied lie outside the extents of the
  ## buffers, the copied area will be clipped to the available area (in other
  ## words, the call can never fail; in the worst case it just copies
  ## nothing).
  let
    srcWidth = max(src.width - srcX, 0)
    srcHeight = max(src.height - srcY, 0)
    destWidth = max(tb.width - destX, 0)
    destHeight = max(tb.height - destY, 0)
    w = min(min(srcWidth, destWidth), width)
    h = min(min(srcHeight, destHeight), height)

  for yOffs in 0..<h:
    for xOffs in 0..<w:
      tb[xOffs + destX, yOffs + destY] = src[xOffs + srcX, yOffs + srcY]


proc copyFrom*(tb: var TerminalBuffer, src: TerminalBuffer) =
  ## Copies the full contents of the `src` terminal buffer into this one.
  ##
  ## If the extents of the source buffer is greater than the extents of the
  ## destination buffer, the copied area is clipped to the destination area.
  tb.copyFrom(src, 0, 0, src.width, src.height, 0, 0)

proc newTerminalBufferFrom*(src: TerminalBuffer): TerminalBuffer =
  ## Creates a new terminal buffer with the dimensions of the `src` buffer and
  ## copies its contents into the new buffer.
  var tb = new TerminalBuffer
  tb.initTerminalBuffer(src.width, src.height)
  tb.copyFrom(src)
  result = tb

proc setCursorPos*(tb: var TerminalBuffer, x, y: Natural) =
  ## Sets the current cursor position.
  tb.currX = x
  tb.currY = y

proc setCursorXPos*(tb: var TerminalBuffer, x: Natural) =
  ## Sets the current x cursor position.
  tb.currX = x

proc setCursorYPos*(tb: var TerminalBuffer, y: Natural) =
  ## Sets the current y cursor position.
  tb.currY = y

proc setBackgroundColor*(tb: var TerminalBuffer, bg: BackgroundColor) =
  ## Sets the current background color.
  tb.currBg = bg

proc setForegroundColor*(tb: var TerminalBuffer, fg: ForegroundColor,
                         bright: bool = false) =
  ## Sets the current foreground color and the bright style flag.
  if bright:
    incl(tb.currStyle, styleBright)
  else:
    excl(tb.currStyle, styleBright)
  tb.currFg = fg

proc setStyle*(tb: var TerminalBuffer, style: set[Style]) =
  ## Sets the current style flags.
  tb.currStyle = style

func getCursorPos*(tb: TerminalBuffer): tuple[x: Natural, y: Natural] =
  ## Returns the current cursor position.
  result = (tb.currX, tb.currY)

func getCursorXPos*(tb: TerminalBuffer): Natural =
  ## Returns the current x cursor position.
  result = tb.currX

func getCursorYPos*(tb: TerminalBuffer): Natural =
  ## Returns the current y cursor position.
  result = tb.currY

func getBackgroundColor*(tb: var TerminalBuffer): BackgroundColor =
  ## Returns the current background color.
  result = tb.currBg

func getForegroundColor*(tb: var TerminalBuffer): ForegroundColor =
  ## Returns the current foreground color.
  result = tb.currFg

func getStyle*(tb: var TerminalBuffer): set[Style] =
  ## Returns the current style flags.
  result = tb.currStyle

proc resetAttributes*(tb: var TerminalBuffer) =
  ## Resets the current text attributes to ``bgNone``, ``fgWhite`` and clears
  ## all the style flags.
  tb.setBackgroundColor(bgNone)
  tb.setForegroundColor(fgWhite)
  tb.setStyle({})

proc write*(tb: var TerminalBuffer, x, y: Natural, s: string) =
  ## Writes a string into the terminal buffer at the specified position using
  ## the current text attributes. Lines do not wrap and attempting to write
  ## outside the extents of the buffer will not raise an error; the output
  ## will be cropped to the visible area.

  var currX = x
  for ch in runes(s):
    var c = TerminalChar(ch: ch, fg: tb.currFg, bg: tb.currBg,
                         style: tb.currStyle)
    tb[currX, y] = c
    inc(currX)
  tb.currX = currX
  tb.currY = y

proc write*(tb: var TerminalBuffer, s: string) =
  write(tb, tb.currX, tb.currY, s)


var
  gPrevTerminalBuffer: TerminalBuffer
  gCurrBg: BackgroundColor
  gCurrFg: ForegroundColor
  gCurrStyle: set[Style]

proc setAttribs(c: TerminalChar) =
  if c.bg == bgNone or c.fg == fgNone or c.style == {}:
    resetAttributes()
    gCurrBg = c.bg
    gCurrFg = c.fg
    gCurrStyle = c.style
    if gCurrBg != bgNone:
      setBackgroundColor(cast[terminal.BackgroundColor](gCurrBg))
    if gCurrFg != fgNone:
      setForegroundColor(cast[terminal.ForegroundColor](gCurrFg))
    if gCurrStyle != {}:
      setStyle(gCurrStyle)
  else:
    if c.bg != gCurrBg:
      gCurrBg = c.bg
      setBackgroundColor(cast[terminal.BackgroundColor](gCurrBg))
    if c.fg != gCurrFg:
      gCurrFg = c.fg
      setForegroundColor(cast[terminal.ForegroundColor](gCurrFg))
    if c.style != gCurrStyle:
      gCurrStyle = c.style
      setStyle(gCurrStyle)

proc setPos(x, y: Natural) =
  terminal.setCursorPos(x, y)

proc setXPos(x: Natural) =
  terminal.setCursorXPos(x)


proc displayFull(tb: TerminalBuffer) =
  var buf = ""

  proc flushBuf() =
    if buf.len > 0:
      put buf
      buf = ""

  for y in 0..<tb.height:
    setPos(0, y)
    for x in 0..<tb.width:
      let c = tb[x,y]
      if c.bg != gCurrBg or c.fg != gCurrFg or c.style != gCurrStyle:
        flushBuf()
        setAttribs(c)
      buf &= $c.ch
    flushBuf()


proc displayDiff(tb: TerminalBuffer) =
  var
    buf = ""
    bufXPos, bufYPos: Natural
    currXPos = -1
    currYPos = -1

  proc flushBuf() =
    if buf.len > 0:
      if currYPos != bufYPos:
        currXPos = bufXPos
        currYPos = bufYPos
        setPos(currXPos, currYPos)
      elif currXPos != bufXPos:
        currXPos = bufXPos
        setXPos(currXPos)
      put buf
      inc(currXPos, buf.runeLen)
      buf = ""

  for y in 0..<tb.height:
    bufXPos = 0
    bufYPos = y
    for x in 0..<tb.width:
      let c = tb[x,y]
      if c != gPrevTerminalBuffer[x,y] or c.forceWrite:
        if c.bg != gCurrBg or c.fg != gCurrFg or c.style != gCurrStyle:
          flushBuf()
          bufXPos = x
          setAttribs(c)
        buf &= $c.ch
      else:
        flushBuf()
        bufXPos = x+1
    flushBuf()


var gDoubleBufferingEnabled = true

proc setDoubleBuffering*(enabled: bool) =
  ## Enables or disables double buffering (enabled by default).
  gDoubleBufferingEnabled = enabled
  gPrevTerminalBuffer = nil

proc display*(tb: TerminalBuffer) =
  ## Outputs the contents of the terminal buffer to the screen.
  if gDoubleBufferingEnabled:
    if gPrevTerminalBuffer == nil:
      displayFull(tb)
      gPrevTerminalBuffer = newTerminalBufferFrom(tb)
    else:
      if tb.width == gPrevTerminalBuffer.width and
         tb.height == gPrevTerminalBuffer.height:
        displayDiff(tb)
        gPrevTerminalBuffer.copyFrom(tb)
      else:
        displayFull(tb)
        gPrevTerminalBuffer = newTerminalBufferFrom(tb)
    flushFile(stdout)
  else:
    displayFull(tb)
    flushFile(stdout)


type
  BoxChar = int

const
  LEFT   = 0x01
  RIGHT  = 0x02
  UP     = 0x04
  DOWN   = 0x08
  H_DBL  = 0x10
  V_DBL  = 0x20

  HORIZ = LEFT or RIGHT
  VERT  = UP or DOWN

var gBoxCharsUnicode: array[64, string]

gBoxCharsUnicode[0] = " "

gBoxCharsUnicode[   0 or  0 or     0 or    0] = " "
gBoxCharsUnicode[   0 or  0 or     0 or LEFT] = "─"
gBoxCharsUnicode[   0 or  0 or RIGHT or    0] = "─"
gBoxCharsUnicode[   0 or  0 or RIGHT or LEFT] = "─"
gBoxCharsUnicode[   0 or UP or     0 or    0] = "│"
gBoxCharsUnicode[   0 or UP or     0 or LEFT] = "┘"
gBoxCharsUnicode[   0 or UP or RIGHT or    0] = "└"
gBoxCharsUnicode[   0 or UP or RIGHT or LEFT] = "┴"
gBoxCharsUnicode[DOWN or  0 or     0 or    0] = "│"
gBoxCharsUnicode[DOWN or  0 or     0 or LEFT] = "┐"
gBoxCharsUnicode[DOWN or  0 or RIGHT or    0] = "┌"
gBoxCharsUnicode[DOWN or  0 or RIGHT or LEFT] = "┬"
gBoxCharsUnicode[DOWN or UP or     0 or    0] = "│"
gBoxCharsUnicode[DOWN or UP or     0 or LEFT] = "┤"
gBoxCharsUnicode[DOWN or UP or RIGHT or    0] = "├"
gBoxCharsUnicode[DOWN or UP or RIGHT or LEFT] = "┼"

gBoxCharsUnicode[H_DBL or    0 or  0 or     0 or    0] = " "
gBoxCharsUnicode[H_DBL or    0 or  0 or     0 or LEFT] = "═"
gBoxCharsUnicode[H_DBL or    0 or  0 or RIGHT or    0] = "═"
gBoxCharsUnicode[H_DBL or    0 or  0 or RIGHT or LEFT] = "═"
gBoxCharsUnicode[H_DBL or    0 or UP or     0 or    0] = "│"
gBoxCharsUnicode[H_DBL or    0 or UP or     0 or LEFT] = "╛"
gBoxCharsUnicode[H_DBL or    0 or UP or RIGHT or    0] = "╘"
gBoxCharsUnicode[H_DBL or    0 or UP or RIGHT or LEFT] = "╧"
gBoxCharsUnicode[H_DBL or DOWN or  0 or     0 or    0] = "│"
gBoxCharsUnicode[H_DBL or DOWN or  0 or     0 or LEFT] = "╕"
gBoxCharsUnicode[H_DBL or DOWN or  0 or RIGHT or    0] = "╒"
gBoxCharsUnicode[H_DBL or DOWN or  0 or RIGHT or LEFT] = "╤"
gBoxCharsUnicode[H_DBL or DOWN or UP or     0 or    0] = "│"
gBoxCharsUnicode[H_DBL or DOWN or UP or     0 or LEFT] = "╡"
gBoxCharsUnicode[H_DBL or DOWN or UP or RIGHT or    0] = "╞"
gBoxCharsUnicode[H_DBL or DOWN or UP or RIGHT or LEFT] = "╪"

gBoxCharsUnicode[V_DBL or    0 or  0 or     0 or    0] = " "
gBoxCharsUnicode[V_DBL or    0 or  0 or     0 or LEFT] = "─"
gBoxCharsUnicode[V_DBL or    0 or  0 or RIGHT or    0] = "─"
gBoxCharsUnicode[V_DBL or    0 or  0 or RIGHT or LEFT] = "─"
gBoxCharsUnicode[V_DBL or    0 or UP or     0 or    0] = "║"
gBoxCharsUnicode[V_DBL or    0 or UP or     0 or LEFT] = "╜"
gBoxCharsUnicode[V_DBL or    0 or UP or RIGHT or    0] = "╙"
gBoxCharsUnicode[V_DBL or    0 or UP or RIGHT or LEFT] = "╨"
gBoxCharsUnicode[V_DBL or DOWN or  0 or     0 or    0] = "║"
gBoxCharsUnicode[V_DBL or DOWN or  0 or     0 or LEFT] = "╖"
gBoxCharsUnicode[V_DBL or DOWN or  0 or RIGHT or    0] = "╓"
gBoxCharsUnicode[V_DBL or DOWN or  0 or RIGHT or LEFT] = "╥"
gBoxCharsUnicode[V_DBL or DOWN or UP or     0 or    0] = "║"
gBoxCharsUnicode[V_DBL or DOWN or UP or     0 or LEFT] = "╢"
gBoxCharsUnicode[V_DBL or DOWN or UP or RIGHT or    0] = "╟"
gBoxCharsUnicode[V_DBL or DOWN or UP or RIGHT or LEFT] = "╫"

gBoxCharsUnicode[H_DBL or V_DBL or    0 or  0 or     0 or    0] = " "
gBoxCharsUnicode[H_DBL or V_DBL or    0 or  0 or     0 or LEFT] = "═"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or  0 or RIGHT or    0] = "═"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or  0 or RIGHT or LEFT] = "═"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or UP or     0 or    0] = "║"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or UP or     0 or LEFT] = "╝"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or UP or RIGHT or    0] = "╚"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or UP or RIGHT or LEFT] = "╩"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or  0 or     0 or    0] = "║"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or  0 or     0 or LEFT] = "╗"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or  0 or RIGHT or    0] = "╔"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or  0 or RIGHT or LEFT] = "╦"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or UP or     0 or    0] = "║"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or UP or     0 or LEFT] = "╣"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or UP or RIGHT or    0] = "╠"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or UP or RIGHT or LEFT] = "╬"


proc toUTF8String(c: BoxChar): string = gBoxCharsUnicode[c]

type BoxBuffer* = ref object
  ## Box buffers are used to store the results of multiple consecutive box
  ## drawing calls. The idea is that when you draw a series of lines and
  ## rectangles into the buffer, the overlapping lines will get automatically
  ## connected by placing the appropriate UTF-8 symbols at the corner and
  ## junction points. The results can then be written to a terminal buffer.
  width: Natural
  height: Natural
  buf: seq[BoxChar]

proc newBoxBuffer*(width, height: Natural): BoxBuffer =
  ## Creates a new box buffer of a fixed width and height.
  result = new BoxBuffer
  result.width = width
  result.height = height
  newSeq(result.buf, width * height)

func width*(bb: BoxBuffer): Natural =
  ## Returns the width of the box buffer.
  result = bb.width

func height*(bb: BoxBuffer): Natural =
  ## Returns the height of the box buffer.
  result = bb.height

proc `[]=`(b: var BoxBuffer, x, y: Natural, c: BoxChar) =
  if x < b.width and y < b.height:
    b.buf[b.width * y + x] = c

func `[]`(b: BoxBuffer, x, y: Natural): BoxChar =
  if x < b.width and y < b.height:
    result = b.buf[b.width * y + x]


proc copyFrom*(bb: var BoxBuffer,
               src: BoxBuffer, srcX, srcY, width, height: Natural,
               destX, destY: Natural) =
  ## Copies the contents of the `src` box buffer into this one.
  ## A rectangular area of dimension `width` and `height` is copied from
  ## the position `srcX` and `srcY` in the source buffer to the position
  ## `destX` and `destY` in this buffer.
  ##
  ## If the extents of the area to be copied lie outside the extents of the
  ## buffers, the copied area will be clipped to the available area (in other
  ## words, the call can never fail; in the worst case it just copies
  ## nothing).
  let
    srcWidth = max(src.width - srcX, 0)
    srcHeight = max(src.height - srcY, 0)
    destWidth = max(bb.width - destX, 0)
    destHeight = max(bb.height - destY, 0)
    w = min(min(srcWidth, destWidth), width)
    h = min(min(srcHeight, destHeight), height)

  for yOffs in 0..<h:
    for xOffs in 0..<w:
      bb[xOffs + destX, yOffs + destY] = src[xOffs + srcX, yOffs + srcY]


proc copyFrom*(bb: var BoxBuffer, src: BoxBuffer) =
  ## Copies the full contents of the `src` box buffer into this one.
  ##
  ## If the extents of the source buffer is greater than the extents of the
  ## destination buffer, the copied area is clipped to the destination area.
  bb.copyFrom(src, 0, 0, src.width, src.height, 0, 0)

proc newBoxBufferFrom*(src: BoxBuffer): BoxBuffer =
  ## Creates a new box buffer with the dimensions of the `src` buffer and
  ## copies its contents into the new buffer.
  var bb = new BoxBuffer
  bb.copyFrom(src)
  result = bb

proc drawHorizLine*(b: var BoxBuffer, x1, x2, y: Natural,
                    doubleStyle: bool = false) =
  ## Draws a horizontal line into the box buffer. Set `doubleStyle` to true
  ## to draw double lines.
  if y < b.height:
    var xStart = x1
    var xEnd = x2
    if xStart > xEnd: swap(xStart, xEnd)
    if xStart < b.width:
      xEnd = min(xEnd, b.width-1)
      for x in xStart..xEnd:
        let pos = y * b.width + x
        var c = b.buf[pos]
        var h: int
        if x == xStart:
          h = if (c and LEFT) > 0: HORIZ else: RIGHT
        elif x == xEnd:
          h = if (c and RIGHT) > 0: HORIZ else: LEFT
        else:
          h = HORIZ
        if doubleStyle:
          h = h or H_DBL
        b.buf[pos] = c or h

proc drawVertLine*(b: var BoxBuffer, x, y1, y2: Natural,
                   doubleStyle: bool = false) =
  ## Draws a vertical line into the box buffer. Set `doubleStyle` to true
  ## to draw double lines.
  if x < b.width:
    var yStart = y1
    var yEnd = y2
    if yStart > yEnd: swap(yStart, yEnd)
    if yStart < b.height:
      yEnd = min(yEnd, b.height-1)
      for y in yStart..yEnd:
        let pos = y * b.width + x
        var c = b.buf[pos]
        var v: int
        if y == yStart:
          v = if (c and UP) > 0: VERT else: DOWN
        elif y == yEnd:
          v = if (c and DOWN) > 0: VERT else: UP
        else:
          v = VERT
        if doubleStyle:
          v = v or V_DBL
        b.buf[pos] = c or v

proc drawRect*(b: var BoxBuffer, x1, y1, x2, y2: Natural,
               doubleStyle: bool = false) =
  ## Draws a rectangle into the box buffer. Set `doubleStyle` to true to draw
  ## double lines.
  b.drawHorizLine(x1, x2, y1, doubleStyle)
  b.drawHorizLine(x1, x2, y2, doubleStyle)
  b.drawVertLine(x1, y1, y2, doubleStyle)
  b.drawVertLine(x2, y1, y2, doubleStyle)


proc write*(tb: var TerminalBuffer, b: var BoxBuffer) =
  ## Writes the contents of the box buffer into this terminal buffer with
  ## the current text attributes.
  let width = min(tb.width, b.width)
  let height = min(tb.height, b.height)
  var horizBoxCharCount: int
  var forceWrite: bool

  for y in 0..<height:
    horizBoxCharCount = 0
    forceWrite = false
    for x in 0..<width:
      let boxChar = b[x,y]
      if boxChar > 0:
        if ((boxChar and LEFT) or (boxChar and RIGHT)) > 0:
          if horizBoxCharCount == 1:
            var prev = tb[x-1,y]
            prev.forceWrite = true
            tb[x-1,y] = prev
          if horizBoxCharCount >= 1:
            forceWrite = true
          inc(horizBoxCharCount)
        else:
          horizBoxCharCount = 0
          forceWrite = false

        var c = TerminalChar(ch: toUTF8String(boxChar).runeAt(0),
                             fg: tb.currFg, bg: tb.currBg,
                             style: tb.currStyle, forceWrite: forceWrite)
        tb[x,y] = c


proc drawHorizLine*(tb: var TerminalBuffer, x1, x2, y: Natural,
                    doubleStyle: bool = false) =
  ## Convenience method to draw a single horizontal line into a terminal
  ## buffer directly.
  var bb = newBoxBuffer(tb.width, tb.height)
  bb.drawHorizLine(x1, x2, y, doubleStyle)
  tb.write(bb)

proc drawVertLine*(tb: var TerminalBuffer, x, y1, y2: Natural,
                   doubleStyle: bool = false) =
  ## Convenience method to draw a single vertical line into a terminal buffer
  ## directly.
  var bb = newBoxBuffer(tb.width, tb.height)
  bb.drawVertLine(x, y1, y2, doubleStyle)
  tb.write(bb)

proc drawRect*(tb: var TerminalBuffer, x1, y1, x2, y2: Natural,
               doubleStyle: bool = false) =
  ## Convenience method to draw a rectangle into a terminal buffer directly.
  var bb = newBoxBuffer(tb.width, tb.height)
  bb.drawRect(x1, y1, x2, y2, doubleStyle)
  tb.write(bb)


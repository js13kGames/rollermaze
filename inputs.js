// Input processing

// Clear input state
function clearinputstate()
{
  gs.keystate=KEYNONE;
}

// Check if an input is set in keyboard input state
function ispressed(keybit)
{
  return ((gs.keystate&keybit)!=0);
}

///////////
// Keyboard
///////////

// Update the player key state
function updatekeystate(e, dir)
{
    switch (e.code)
    {
      case "ArrowLeft": // cursor left
      case "KeyA": // A
      case "KeyZ": // Z
        if (dir==1)
          gs.keystate|=KEYLEFT;
        else
          gs.keystate&=~KEYLEFT;
  
        e.preventDefault();
        break;
  
      case "ArrowUp": // cursor up
      case "KeyW": // W
      case "Semicolon": // semicolon
        if (dir==1)
          gs.keystate|=KEYUP;
        else
          gs.keystate&=~KEYUP;
  
        e.preventDefault();
        break;
  
      case "ArrowRight": // cursor right
      case "KeyD": // D
      case "KeyX": // X
        if (dir==1)
          gs.keystate|=KEYRIGHT;
        else
          gs.keystate&=~KEYRIGHT;
  
        e.preventDefault();
        break;
  
      case "ArrowDown": // cursor down
      case "KeyS": // S
      case "Period": // dot
        if (dir==1)
          gs.keystate|=KEYDOWN;
        else
          gs.keystate&=~KEYDOWN;
  
        e.preventDefault();
        break;
  
      case "Enter": // enter
      case "ShiftLeft": // L shift
      case "ShiftRight": // R shift
      case "Space": // space
        if (dir==1)
          gs.keystate|=KEYACTION;
        else
          gs.keystate&=~KEYACTION;
  
        e.preventDefault();
        break;
  
      case "KeyI": // I (for info/debug)
        if (dir==1)
          gs.debug=(!gs.debug);
  
        e.preventDefault();
        break;
  
      default:
        break;
    }
  }

///////////
// Mouse
///////////

// Move the pointer position
function pointerpos(e, dir)
{
  if (dir==1)
  {
    if (!gs.touch)
    {
      // Press - record positions
      gs.keystate=KEYNONE;

      gs.cursorx=e.clientX;
      gs.cursory=e.clientY;

      gs.touch=true;
    }
  }
  else
  {
    // Release - calculate deltas
    var deltax=e.clientX-gs.cursorx;
    var deltay=e.clientY-gs.cursory;

    gs.keystate=KEYNONE;

    if (Math.abs(deltax)>Math.abs(deltay))
    {
      // Horizontal
      if (deltax>0)
        gs.keystate|=KEYRIGHT;
      else
        gs.keystate|=KEYLEFT;
    }
    else
    {
      // Vertical
      if (deltay>0)
        gs.keystate|=KEYDOWN;
      else
        gs.keystate|=KEYUP;
    }
  }
}

function touchpos(e, dir)
{
  try
  {
    pointerpos(e.touches[0] || e.changedTouches[0], dir);
  }
  catch(err){}
}
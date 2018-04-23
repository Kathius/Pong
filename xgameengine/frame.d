module gameengine.frame;

public import gameengine.model;
public import gameengine.view;
public import gameengine.controller;
public import gameengine.glcanvas;

import derelict.util.exception;
import std.string;

bool myMissingProcCallback(char[] libName, char[] procName)
{
	// there are 8 functions in SDL's CPU interface - test for them all.
	// If the procName matches any one of them, return true to ignore the missing
	// function.
	if( procName.cmp("Mix_SetReverb") == 0)
			return true;		// ignore the error and throw no exception

	// a function other than one of those above failed to load - return false
	// to indicate that an exception should be thrown.
	return false;
}


class Frame
{
protected:
	GlCanvas canvas;
	bool am_running;
	
	struct Resolution {uint x; uint y;};
	Resolution my_resolution;
	
	float frames_per_second, ticks_per_second;
	Controller current_screen;
	
	bool show_fps;
	
public:
	this(Resolution res)
	{
		my_resolution = res;
		show_fps=false;
		
		InitLibs();
		
		canvas = new GlCanvas(my_resolution.x, my_resolution.y);
		canvas.SetupGl();
	}
	
	~this()
	{
		CleanupLibs();
	}
	
	void InitLibs()
	{
		// initialize the SDL Derelict module
		Derelict_SetMissingProcCallback(&myMissingProcCallback);
		
		DerelictSDL.load();
		DerelictGL.load();
		DerelictGLU.load();

		// initialize SDL's VIDEO module
		SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);
		
		// enable double-buffering
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		
		// create our OpenGL window
		SDL_SetVideoMode(my_resolution.x, my_resolution.y, 24, SDL_OPENGL);
		SDL_WM_SetCaption(toStringz("My SDL Window"), null);
		
	}
	void CleanupLibs()
	{
		// tell SDL to quit
		SDL_Quit();

		// release SDL's shared lib
		DerelictGLU.unload();
		DerelictGL.unload();
		DerelictSDL.unload();
	}
	void onInit()
	{
		
	}


	int Run()
	{
		onInit();
		
		uint NextTick, NextFrame;
		uint CurrentTick;
		
		uint last_calculation_tick;
		
		CurrentTick = NextTick = NextFrame = last_calculation_tick = SDL_GetTicks();
		
		uint FrameTickInterval = 1000 / 60;
		uint TickInterval = 1000 / 100;
		
		uint frames_this_second;
		uint ticks_this_second;
		
		am_running = true;
		
		mainLoop:
		while(am_running)
		{
			do
			{
				SDL_Delay(1);
				ProcessEvents();
				ComputerTurns();
				CurrentTick = SDL_GetTicks();
			} while (NextTick > CurrentTick && NextFrame > CurrentTick);
			
			uint delay_tick = NextTick + 10*TickInterval;
			while (CurrentTick >= NextTick)
			{
				onTick();
				NextTick += TickInterval;
				ticks_this_second++;
				if (NextTick > delay_tick) break;
			}
			
			if (CurrentTick >= NextFrame)
			{
				drawGLFrame();
				frames_this_second++;
				while (CurrentTick >= NextFrame) NextFrame += FrameTickInterval;
			}
			
			/* calculate the actual tick and frame rate */
			if (CurrentTick >= last_calculation_tick + 1000)
			{
				ticks_per_second = cast(float)ticks_this_second * (1000.0/(CurrentTick-last_calculation_tick));
				frames_per_second = cast(float)frames_this_second * (1000.0/(CurrentTick-last_calculation_tick));
				last_calculation_tick = CurrentTick;
				frames_this_second = ticks_this_second = 0;
			}
		}

		return 0;
	}
	
	void onTick()
	{
		current_screen.onTick();
	}
	
	void onEvent(SDL_Event event)
	{
		switch(event.type)
		{
		case SDL_QUIT:
			am_running = false;
			break;
		case SDL_KEYDOWN:
			switch (event.key.keysym.sym)
			{
			case SDLK_f:
				show_fps = !show_fps;
				break;
			default:
				current_screen.onKeyDown(event.key.keysym.sym);
			}
			break;
		case SDL_KEYUP:
			current_screen.onKeyUp(event.key.keysym.sym);
			break;
		default:
			break;
		}
		
	}
	
	void ComputerTurns()
	{
		current_screen.onThink();
	}
	
	void ProcessEvents()
	{
		SDL_Event event;

		while(SDL_PollEvent(&event))
		{
			onEvent(event);
		}
	}
	
	
	void onDraw()
	{
		current_screen.onDraw();
		
		if (show_fps)
		{
			GlCanvas.DrawText(Point(1.9, 1.95), format("fps: %2.2f", frames_per_second), .02);
			GlCanvas.DrawText(Point(1.9, 1.75), format("tps: %2.2f", ticks_per_second), .02);
		}
	}
	
	void drawGLFrame()
	{
		canvas.Clear();
		
		onDraw();

		canvas.Swap();
	}
	
	
}
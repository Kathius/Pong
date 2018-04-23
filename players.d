module players;

import playfield;
public import gameengine.controller;

class ComputerPlayer : Controller
{
protected:
	PongBar my_bar;
	Playfield my_field;

public:
	this(PongBar bar, Playfield field)
	{
		my_bar = bar;
		my_field = field;
	}
	
	void onThink()
	{
		if (my_bar.Position < my_field.BallPosition.y) my_bar.Direction = 1;
		else if (my_bar.Position > my_field.BallPosition.y) my_bar.Direction = -1;
		else my_bar.Direction = 0;
	}
	
}

class HumanPlayer : Controller
{
protected:
	PongBar my_bar;

public:
	this(PongBar bar)
	{
		my_bar = bar;
	}
	
	void onKeyDown(SDLKey key)
	{
		switch (key)
		{
		case SDLK_UP:
			my_bar.Direction = 1;
			break;
		case SDLK_DOWN:
			my_bar.Direction = -1;
			break;
		default: break;
		}
	}
	void onJoystickMove(uint stick, uint axis, int value)
	{
		if (stick != 0) return;
		if (axis != 1) return;
		if (value > -1000 && value < 1000) my_bar.Direction = 0;
		else my_bar.Direction = -value / 30000.0;
	}
	void onKeyUp(SDLKey key)
	{
		switch (key)
		{
		case SDLK_DOWN:
		case SDLK_UP:
			my_bar.Direction = 0;
			break;
		default: break;
		}		
	}
}

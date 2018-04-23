module mainmenu;

import gameengine.glcanvas;
import gameengine.controller;

import std.string;

class MainMenu : Model
{
protected:
	static enum MENUITEMS
	{
		NEWGAME,
		QUIT
	}
	
	MENUITEMS current_item=MENUITEMS.NEWGAME;
	
public:
	
	
public:
	enum Event
	{
		NEWGAME,
		QUIT
	};
	
	this()
	{
	}
	
	void NextItem()
	{
		current_item++;
		if (current_item > MENUITEMS.max) current_item = MENUITEMS.min;
	}
	void PrevItem()
	{
		current_item--;
		if (current_item < MENUITEMS.min) current_item = MENUITEMS.max;
	}
	void Choose()
	{
		switch (current_item)
		{
		case MENUITEMS.NEWGAME:
			SendEvent(Event.NEWGAME);
			break;
		case MENUITEMS.QUIT:
			SendEvent(Event.QUIT);
			break;
		default: break;
		}
	}
	/*
	void onKeyDown(SDLKey key)
	{
		switch (key)
		{
		case SDLK_DOWN:
			current_item++;
			if (current_item > MENUITEMS.max) current_item = MENUITEMS.min;
			break;		
		case SDLK_UP:
			current_item--;
			if (current_item < MENUITEMS.min) current_item = MENUITEMS.max;
			break;
		case SDLK_RETURN:
			switch (current_item)
			{
			case MENUITEMS.NEWGAME:
				SendEvent(Event.NEWGAME);
				break;
			case MENUITEMS.QUIT:
				SendEvent(Event.QUIT);
				//SDL_PushEvent(&SDL_Event(SDL_QUIT));
				break;
			default: break;
			}
			break;
		case SDLK_ESCAPE:
			SendEvent(Event.QUIT);
			//SDL_PushEvent(&SDL_Event(SDL_QUIT));
			break;
		default: break;
		}
		
	}
	void onKeyUp(SDLKey key)
	{
		
	}
	*/
}

class MainMenuView : View
{
protected:
	MainMenu m;
	alias MainMenu.MENUITEMS MI;
	char[][MI] menu_items;	
public:
	this(MainMenu mm)
	{
		m = mm;
	}
	void Draw()
	{
		menu_items[MI.NEWGAME] = "new game";
		menu_items[MI.QUIT] = "quit";
		foreach (item, text; menu_items)
		{
			GlCanvas.DrawText(Point(-1, 1-0.5*item), menu_items[item], .05, item == m.current_item ? 2 : 4);
		}
	}
};
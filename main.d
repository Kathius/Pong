module pong.main;

import gameengine.frame;
import playfield;
import mainmenu;

void main()
{
	auto game = new Pong();
	game.Run();
	delete game;
}

class Pong : Frame
{
protected:
	MainMenu menu;
	PongGame game;
protected:

	this()
	{
		super(Resolution(800, 600));
		game = new PongGame();
		menu = new MainMenu();
		
		menu.RegisterEventHandler(MainMenu.Event.NEWGAME, &NewGame);
		menu.RegisterEventHandler(MainMenu.Event.QUIT, &onQuit);
	}
	
	void onInit()
	{
		current_screen = menu;
	}
	
	void NewGame()
	{
		game.onNewGame();
		current_screen = game;
	}
	void onQuit()
	{
		SDL_PushEvent(&SDL_Event(SDL_QUIT));
	}
	void LoseGame()
	{
		current_screen = menu;
	}
};

class PongGame : Controller
{
protected:
	Controller my_players[2];
	Playfield field;
	PlayfieldView field_view;
	bool am_paused = false;
	
public:
	this()
	{
		field = new Playfield();
		field_view = new PlayfieldView(field);
	}
	void onNewGame()
	{
		my_players[0] = new HumanPlayer(field.Bar1);
		my_players[1] = new ComputerPlayer(field.Bar2, field);
	}
	
	bool Paused()
	{
		return am_paused;
	}
	void onKeyDown(SDLKey key)
	{
		switch(key)
		{
		case SDLK_p:
			am_paused = !am_paused;
			break;
		default:
			foreach (p; my_players) p.onKeyDown(key);
		}
		
	}
	void onKeyUp(SDLKey key)
	{
		foreach (p; my_players) p.onKeyUp(key);
	}
	void onJoystickMove(uint stick, uint axis, int value)
	{
		foreach (p; my_players) p.onJoystickMove(stick, axis, value);
	}
	void onThink()
	{
		foreach (p; my_players) p.onThink();
	}
	void onTick()
	{
		if (!am_paused)
		{
			field.onTick();
		}
		field_view.onTick();
	}
	void onDraw()
	{
		field_view.Draw();
		if (am_paused) GlCanvas.DrawText(Point(-1.4, .4), "pause", .15, 2);
	}
}

class MainMenu : Controller
{
protected:
	mainmenu.MainMenu menu;
	mainmenu.MainMenuView menu_view;
	
public:
	alias mainmenu.MainMenu.Event Event;
	
	this()
	{
		menu = new mainmenu.MainMenu();
		menu_view = new MainMenuView(menu);
	}
	
	void onKeyDown(SDLKey key)
	{
		switch (key)
		{
		case SDLK_DOWN:
			menu.NextItem();
			break;		
		case SDLK_UP:
			menu.PrevItem();
			break;
		case SDLK_RETURN:
			menu.Choose();
			break;
		default: break;
		}
	}
	void onDraw()
	{
		menu_view.Draw();
	}
	
	void RegisterEventHandler(uint event, Model.EventHandler handler)
	{
		menu.RegisterEventHandler(event, handler);
	}
}

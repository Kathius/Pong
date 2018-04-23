module playfield;

public import players;

import gameengine.view;

import std.random;
import std.stdio;

class PlayfieldView : View
{
protected:
	Playfield m;
	
public:
	this(Playfield pf)
	{
		m = pf;
	}
	
	void Draw()
	{
		GlCanvas.DrawLine(Point(-2, 1.5),  Point(2, 1.5));
		GlCanvas.DrawLine(Point(-2, -1.5), Point(2, -1.5));
		
		GlCanvas.DrawRect(
			Point(-2.1, m.bar1.UpperPosition),
			Point(-2.0, m.bar1.LowerPosition), 2);
		GlCanvas.DrawRect(
			Point(2.1, m.bar2.UpperPosition),
			Point(2.0, m.bar2.LowerPosition), 2);
		
		GlCanvas.DrawCircle(m.my_ball_pos, m.my_ball_size, 2);
		
		GlCanvas.DrawText(Point(-2.3, 1.6), std.string.toString(m.bar1.Score), .05, 2);
		GlCanvas.DrawText(Point(2.3, 1.6), std.string.toString(m.bar2.Score), .05, 2);
	}
	
	void onTick()
	{
	}
}

class PongBar : Model
{
protected:
	float my_position;
	float my_direction;
	float my_size;
	uint my_score;
	
public:
	this(float size)
	{
		my_size = size;
		my_position = 0;
		my_direction = 0;
		my_score = 0;
	}
	
	float Position()
	{
		return my_position;
	}
	float UpperPosition()
	{
		return my_position + my_size;
	}
	float LowerPosition()
	{
		return my_position - my_size;
	}
	
	float Direction(float d)
	{
		my_direction = d < -1 ? -1 : d > 1 ? 1 : d;
		return my_direction;
	}
	float Direction()
	{
		return my_direction;
	}
	
	uint Score()
	{
		return my_score;
	}
	
	void onTick()
	{
		my_position += my_direction * .015;
		
		if (my_position < -1.6 + my_size) my_position = -1.6 + my_size;
		if (my_position > 1.6 - my_size) my_position = 1.6 - my_size;
	}
}

class Playfield : Model
{
protected:
	PongBar bar1, bar2;
	
	float my_player_size = .3;
	
	Point my_ball_pos;
	Point my_ball_dir;
	float my_ball_speed = .02;
	float my_ball_size = .1;

public:

	static this()
	{
	}
	
	float min(float a, float b)
	{
		if (a < b) return a;
		return b;
	}
	float max(float a, float b)
	{
		if (a > b) return a;
		return b;
	}
	this()
	{
		bar1 = new PongBar(my_player_size);
		bar2 = new PongBar(my_player_size);
		my_ball_pos = Point(0,0);
		my_ball_dir = Point(1,1);
	}
	
	PongBar Bar1()
	{
		return bar1;
	}
	PongBar Bar2()
	{
		return bar2;
	}
	Point BallPosition()
	{
		return my_ball_pos;
	}
	void Reset()
	{
		bar1.my_position = bar2.my_position = 0;
		bar1.Direction = bar2.Direction = 0;
	}
	
	void onTick()
	{
		static uint iTick = 0;
		
		my_ball_pos = my_ball_pos + my_ball_dir * my_ball_speed;
		
		bar1.onTick();
		bar2.onTick();
		
		DetectCollision();

		iTick++;
	}
	
	void DetectCollision()
	{
		/* check for upper or lower collision */
		if (my_ball_pos.y-my_ball_size <= -1.5)
		{
			my_ball_pos.y = -1.49+my_ball_size;
			my_ball_dir.y *= -1;
		}else if (my_ball_pos.y+my_ball_size >= 1.5)
		{
			my_ball_pos.y = 1.49-my_ball_size;
			my_ball_dir.y *= -1;
		}
		
		/* check if we hit a bar */
		if (my_ball_dir.x < 0 && my_ball_pos.x-my_ball_size <= -2
			&& my_ball_pos.y-my_ball_size <= bar1.UpperPosition
			&& my_ball_pos.y+my_ball_size >= bar1.LowerPosition)
		{
			my_ball_dir.x = 1;
			my_ball_dir.y += bar1.Direction/4;
			my_ball_dir.y += (bar1.Position-my_ball_pos.y)/4;
		}else if (my_ball_dir.x > 0 && my_ball_pos.x+my_ball_size >= 2
			&& my_ball_pos.y-my_ball_size <= bar2.UpperPosition
			&& my_ball_pos.y+my_ball_size >= bar2.LowerPosition)
		{
			my_ball_dir.x = -1;
			my_ball_dir.y += bar2.Direction/4;
			my_ball_dir.y += (bar2.Position-my_ball_pos.y)/4;
		}
		
		/* check if the ball went through */
		if (my_ball_dir.x < 0 && my_ball_pos.x-my_ball_size < -2.05)
		{
			my_ball_pos.x = -2.5;
			my_ball_dir = Point(1, .3);
			bar2.my_score++;
		}else if (my_ball_dir.x > 0 && my_ball_pos.x-my_ball_size > 2.05)
		{
			my_ball_pos.x = 2.5;
			my_ball_dir = Point(-1, .3);
			bar1.my_score++;
		}
		
	}
}


package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import utils.Delegate;
	import utils.MovieClipListener;
	

	public class HorizontalLevel extends Sprite
	{
		public function HorizontalLevel(char:Character, lifeScore:LifeScore, gameParams:GameParams)
		{
			mCharacter = char;
			mLifeScore = lifeScore;
			mGameParams = gameParams;
						
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false, 0, true);
		}
		
		private function OnAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false);

			mLava = new (getDefinitionByName("mcLavaClass") as Class) as MovieClip;
			addChild(mLava);

			var lavaHeight : Number = mGameParams.EvaluateAtCurrentTime("LavaHeight") as Number;

			// Nuestro padre tiene necesariamente que marcar el área de juego
			mLava.y = parent.height - lavaHeight;

			// Comenzamos a crear obstaculos
			mObstacles = new Array();
			
			// Setup del timer
			mObstaclesTimer = new Timer(0);
			mObstaclesTimer.addEventListener(TimerEvent.TIMER, OnObstaclesTimer);

			SetupObstaclesTimerNextCycle();
			
			mObstaclesTimer.start();
		}
	
		public function Update(elapsedTime : Number) : void
		{
			mLava.x -= elapsedTime* (mGameParams.EvaluateAtCurrentTime("LavaSpeed") as Number);
			
			if (mLava.x + mLava.width <= parent.width)
				mLava.x = 0;
			
			for (var c:int=0; c < mObstacles.length; c++)
			{
				// Movemos
				mObstacles[c].TheMovieClip.x -= elapsedTime * mObstacles[c].TheSpeed;
				
				// Vemos colisiones con el personaje
				if (mObstacles[c].TheMovieClip.hitTestObject(mCharacter))
				{
					// Bye bye
					KillObstacle(c);
					c--;
					
					// El personaje rebota
					mCharacter.ObstacleRebound();
				}
			}
		}
		
		private function KillObstacle(index:int):void
		{
			mObstacles[index].TheMovieClip.gotoAndPlay("kill");
			MovieClipListener.AddFrameScript(mObstacles[index].TheMovieClip, "killEnd", 
											 Delegate.create(OnObstacleKillEnd, mObstacles[index].TheMovieClip));
					
			// Lo quitamos ya de nuestra lista de update, y al acabar la animación de muerte lo quitaremos de entre nuestros hijos
			mObstacles.splice(index, 1);	
		}
		
		private function GetIndexOfObstacleByMovieClip(mc:MovieClip):int
		{
			var ret : int = -1;
			for (var c:int=0; c < mObstacles.length; c++)
			{
				if (mObstacles[c].TheMovieClip == mc)
				{
					ret = c;
					break;
				}
			}
			
			return ret;
		}
		
		private function OnObstacleKillEnd(mc:MovieClip):void
		{
			MovieClipListener.AddFrameScript(mc, "killEnd", null);
			removeChild(mc);
		}
		
		private function OnObstaclesTimer(event:TimerEvent):void
		{
			var newObs : MovieClip = new (getDefinitionByName("mcGloboAzulClass") as Class) as MovieClip;

			newObs.x = parent.width + newObs.width;
			newObs.y = (mGameParams.EvaluateAtCurrentTime("ObstacleY") as Number) * parent.height;
			
			var obsSpeed : Number = mGameParams.EvaluateAtCurrentTime("ObstacleSpeed") as Number;
			
			mObstacles.push({TheMovieClip:newObs, TheSpeed:obsSpeed});
			addChild(newObs);
			
			SetupObstaclesTimerNextCycle();
			
			// Nos subscribimos a su click
			newObs.addEventListener(MouseEvent.MOUSE_DOWN, OnObstacleMouseDown, false, 0, true);
		}
		
		private function SetupObstaclesTimerNextCycle() : void
		{
			// Randomizamos el siguiente timer según la curva de temporización en función del tiempo que llevamos jugando
			mObstaclesTimer.delay = (mGameParams.EvaluateAtCurrentTime("ObstaclesTiming") as Number) * 1000;
		}
		
		private function OnObstacleMouseDown(event:MouseEvent):void
		{
			event.target.removeEventListener(MouseEvent.MOUSE_DOWN, OnObstacleMouseDown, false);
			event.stopPropagation();
			
			var idxObs : int = GetIndexOfObstacleByMovieClip(event.target as MovieClip);
			
			// Es posible que justo en este frame haya habido una colisión con el player y que
			// el obstaculo ya no exista en el click
			if (idxObs != -1)
			{
				KillObstacle(idxObs);
			
				mLifeScore.OnObstacleKilled(new Point(event.stageX, event.stageY));
			}
		}
			
		private var mCharacter : Character;
		private var mLifeScore : LifeScore;
		private var mLava : MovieClip;
		
		private var mObstacles : Array;				// {TheMovieClip:MovieClip, TheSpeed:Number} 
		private var mObstaclesTimer : Timer;
		
		private var mGameParams : GameParams;
	}
}
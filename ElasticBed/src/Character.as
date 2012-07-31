package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	import utils.MovieClipListener;

	public final class Character extends Sprite
	{
		public function Character(lifeScore : LifeScore, gameParams:GameParams)
		{
			mGameParams = gameParams;
			mLifeScore = lifeScore;
						
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false, 0, true);
			
			mCharMovieClip = new (getDefinitionByName("mcBenitoClass") as Class) as MovieClip;
			addChild(mCharMovieClip);

			this.width = mCharMovieClip.width;
			this.height = mCharMovieClip.height;
		}
		
		private function OnAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false);
			
			Reset();
		}
		
		public function Reset() : void
		{
			mState = "AIRBORNE";

			// Nos ponemos en el centro de la stage
			mVel = new Point(0, 0);
			mPos = new Point(stage.stageWidth * 0.5, 0);
		}
		
		private function DoKillAnim() : void
		{
			mCharMovieClip.gotoAndPlay("killAnim");
			MovieClipListener.AddFrameScript(mCharMovieClip, "killAnimEnd", OnKillAnimEnd);
		}
		
		private function OnKillAnimEnd() : void
		{
			MovieClipListener.AddFrameScript(mCharMovieClip, "killAnimEnd", null);
			Reset();	
		}
	
		public function Update(elapsedTime:Number) : void
		{
			if (mState == "AIRBORNE")
			{
				// Actualizamos la física sólo en caso de estar volando
				mPos = GetNextPos(elapsedTime);
				mVel = GetNextVel(elapsedTime);
			
				var lavaHeight : Number = mGameParams.EvaluateAtCurrentTime("LavaHeight") as Number;
			
				// Caemos a la lava?
				if (mPos.y >= stage.stageHeight - lavaHeight)
				{
					mState = "DYING";
					DoKillAnim();
					mLifeScore.OnCharacterKilled();
				}
				else
				{			
					// Comprobamos colisiones con las paredes
					if (mPos.x - (width*0.5) < 0)
					{			
						mPos.x = width*0.5;
						mVel.x = -mVel.x;
					}
					else if (mPos.x + (width*0.5) > stage.stageWidth)
					{
						mPos.x = stage.stageWidth - (width*0.5);
						mVel.x = -mVel.x;
					}
				}
			}
			
			x = mPos.x;
			y = mPos.y;
		}
		
		public function GetNextVel(elapsedTime:Number) : Point
		{
			// Cogemos la gravedad actual, suponemos que la variación entre frame y frame no es muy grande
			var test : Number = (mGameParams.EvaluateAtCurrentTime("ScreenGravity") as Number) * elapsedTime;
			var accel : Point = new Point(0, test);		
			return mVel.add(accel);
		}
		
		public function GetNextPos(elapsedTime:Number) : Point
		{
			var nextVel : Point = GetNextVel(elapsedTime);
			nextVel.x *= elapsedTime;
			nextVel.y *= elapsedTime;
			return mPos.add(nextVel);
		}
		
		public function GetVel() : Point
		{
			return mVel;
		}
		
		public function ApplyForce(dir:Point) : void
		{
			mVel =	dir;
			mVel.normalize(mGameParams.EvaluateAtCurrentTime("ReboundExitVel") as Number);
			mVel.x *= mGameParams.EvaluateAtCurrentTime("ReboundHorizontalFactor") as Number;
		}
		
		public function get Pos() : Point
		{
			return mPos;
		}
		
		public function get Radius():Number 
		{
			var biggest:Number = width > height? width*0.5 : height*0.5;
			return biggest;
		}
		
		public function ObstacleRebound():void
		{
			mVel.y  = mGameParams.EvaluateAtCurrentTime("ObstacleReboundY") as Number;
			mVel.x += mGameParams.EvaluateAtCurrentTime("ObstacleReboundX") as Number;
		}
		
		private var mGameParams : GameParams;
		private var mCharMovieClip : MovieClip;
		private var mLifeScore : LifeScore;		
		private var mState : String = "NULL";

		private var mVel : Point = new Point(0, 0);
		private var mPos : Point = new Point(0, 0);
	}
}
package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	import utils.Delegate;
	import utils.MovieClipListener;

	public class LifeScore extends Sprite
	{
		public function LifeScore(gameParams:GameParams)
		{
			mGameParams = gameParams;
			this.mouseEnabled = false;
			
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false, 0, true);			
		}
		
		private function OnAddedToStage(e:Event):void
		{
			mScore = new (getDefinitionByName("mcScoreClass") as Class) as MovieClip;
			mLifes = new (getDefinitionByName("mcLifesClass") as Class) as MovieClip;
			
			addChild(mScore);
			addChild(mLifes);
			
			mScore.x = parent.width - mScore.width - 10;
			mScore.y = 10;
			
			mLifes.y = 10;
			mLifes.x = 10;
			
			mScore.ctScore.text = GetPaddedString(mCurrentScore, 9);			
			mCurrentLifes = mGameParams.GetParam("MaxLifes") as Number;
		}
		
		public function OnObstacleKilled(stageCoord:Point) : void
		{
			var pointsPerObstacleKill : Number = mGameParams.EvaluateAtCurrentTime("PointsPerObstacleKill") as Number; 
			mCurrentScore += pointsPerObstacleKill;
			mScore.ctScore.text = GetPaddedString(mCurrentScore, 9);

			ShowPointsMovieClip(stageCoord, pointsPerObstacleKill);
		}
		
		public function OnCharacterRebound(stageCoord:Point) : void
		{
			var pointsPerRebound : Number = mGameParams.EvaluateAtCurrentTime("PointsPerRebound") as Number;
			mCurrentScore += pointsPerRebound;
			mScore.ctScore.text = GetPaddedString(mCurrentScore, 9);
			
			ShowPointsMovieClip(stageCoord, pointsPerRebound);
		}
		
		public function OnCharacterKilled() : void
		{
			mCurrentLifes--;
			
			if (mCurrentLifes < 0)
				mCurrentLifes = 0;

			var asString : String = "life"+mCurrentLifes.toString();
			mLifes.gotoAndPlay(asString);
		}
		
		
		private function ShowPointsMovieClip(stageCoord:Point, numPoints:int):void
		{
			// TODO: Caso "substract", de momento pillamos siempre el Add
			var animPoints : MovieClip = new (getDefinitionByName("mcPointsAddClass") as Class) as MovieClip;
			addChild(animPoints);
			var localPoint : Point = this.globalToLocal(stageCoord);
			animPoints.x = localPoint.x;
			animPoints.y = localPoint.y;
			animPoints.mcPointsAdd.ctPoints.text = "+" + numPoints;
			MovieClipListener.AddFrameScript(animPoints, "animEnd", Delegate.create(OnPointsAddAnimEnd, animPoints));	
		}
		
		private function OnPointsAddAnimEnd(mc:MovieClip):void
		{
			MovieClipListener.AddFrameScript(mc, "animEnd", null);
			removeChild(mc);
		} 
		
		
		public function Update(elapsedTime:Number):void
		{
		}
		
		private function GetPaddedString(num:int, digits:int) : String
		{
			var ret:String = num.toString();
			while (ret.length < digits)
				ret = "0" + ret;
			return ret;
		}

		private var mGameParams : GameParams;
		
		private var mScore : MovieClip;
		private var mLifes : MovieClip;
		
		private var mCurrentScore : int = 0;
		private var mCurrentLifes : int = -1;
	}
}
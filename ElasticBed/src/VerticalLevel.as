package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import utils.UIComponentWrapper;

	public final class VerticalLevel extends UIComponent
	{
		public function VerticalLevel(char:Character)
		{
			mCharacter = char;
			
			mBackElementClasses = [ Resources.Star01Class, Resources.Star02Class, Resources.Star03Class,
							  		Resources.Star04Class ];

			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false, 0, true);
		}
		
		protected function OnAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false);
			
			this.width = parent.width;
			this.height = parent.height;
			
			mBackSprites = new Array();

			for (var c:int=0; c < 2; c++)
			{
				// Generamos uno nuevo al final del array
				var newSprite : Sprite = AddAndGenerateNewSprite();
				
				// El 0 es el de más abajo en la pila
				newSprite.y = -this.height*c;
			}
		}

		public function ScrollUp() : void
		{
			mState = "SCROLLING";
		}
		
		public function Update(elapsedTime:Number):void
		{
			if (mState == "SCROLLING")
				DoScrolling(elapsedTime);
		}
		
		private function DoScrolling(elapsedTime:Number) : void
		{
			var charVel : Point = mCharacter.GetVel();
			
			if (charVel.y >= 0)
			{
				mState = "STATIC";
				return;
			}
			
			var distToTravel : Number = elapsedTime*charVel.length*GameConstants.BACKGROUND_SPEED_FACTOR;
			
			for (var c : int = 0; c < mBackSprites.length; c++)
			{
				mBackSprites[c].y += distToTravel;
			}
			
			// Si el primero en la pila se sale por debajo nuestra
			if (mBackSprites[0].y >= this.height)
			{
				mBackSprites.shift();
				
				var newSpr : Sprite = AddAndGenerateNewSprite();
				newSpr.y = -this.height*(mBackSprites.length-1); 
			}
		}
		
		private function AddAndGenerateNewSprite() : Sprite
		{
			var newSpr : UIComponent = new UIComponent();
			mBackSprites.push(newSpr);
			addChild(newSpr);
			GenerateSpriteBackground(mBackSprites.length-1);
			
			return newSpr;
		}
		
		private function GenerateSpriteBackground(which:int) : void
		{
			var backSprite : UIComponent = mBackSprites[which];
			
			var numCellsWidth : int = 3;
			var numCellsHeight : int = 3;
			
			var slotWidth : Number = this.width / numCellsWidth;
			var slotHeight : Number = this.height / numCellsHeight;
			
			for (var c:int = 0; c < numCellsHeight; c++)
			{
				for (var d:int=0; d < numCellsWidth; d++)
				{
					var widthRand : Number  = (Math.random()*0.6) + 0.20;
					var heightRand : Number = (Math.random()*0.7) + 0.15;
					
					var whichElement : int = Math.random()*mBackElementClasses.length;
					
					var newBackElement : Sprite = new mBackElementClasses[whichElement];
					newBackElement.mouseEnabled = false;
					backSprite.addChild(new UIComponentWrapper(newBackElement));
					
					newBackElement.x = (widthRand*slotWidth) + (d*slotWidth);
					newBackElement.y = (heightRand*slotHeight) + (c*slotHeight);
				}
			}
		}
		
		private function GenerateNewObstacles() : void
		{
			var numLinesHeight : int = 3;
						
			for (var c:int = 0; c < numLinesHeight; c++)
			{
				var newObstacle : Sprite = new Resources.Obstacle01Class(); 
			}
		}
		
		private var mState : String = "STATIC";
		
		private var mBackSprites : Array;			// Usaremos al menos 2 sprites para hacer el scroll
		private var mBackElementClasses : Array;
		
		private var mCharacter : Character;
	}
}
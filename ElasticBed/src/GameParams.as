package
{
	import utils.Curve;
	import utils.RandUtils;
	import utils.XmlParams;
	
	public class GameParams
	{
		public function GameParams(xmlParams:XmlParams)
		{
			mXmlParams = xmlParams;
		}
		
		public function EvaluateAtCurrentTime(paramName:String):Object
		{
			var ret : Object = mXmlParams.TheParams[paramName];
			
			if (ret is Curve)
			{
				ret = (ret as Curve).Evaluate(mCurrentTime);
			}
			
			// Proceso de la variabilidad, fully recursive (sólo para Numbers!)
			if (ret is Number)
			{
				var variab : Object = EvaluateAtCurrentTime(paramName+"Variability"); 
				
				if (variab != null && (variab is Number))
				{
					ret = (ret as Number) + RandUtils.RandMinusPlus()*(variab as Number);
				}
			}
		
			return ret;
		}
		
		public function GetParam(paramName:String):Object
		{
			return mXmlParams.TheParams[paramName];
		}
		
		public function Update(elapsedTime:Number):void
		{
			mCurrentTime += elapsedTime;	
		}
		
		private var mXmlParams : XmlParams;
		private var mCurrentTime : Number = 0;
	}
}
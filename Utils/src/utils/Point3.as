package utils
{
	import flash.geom.Point;
	
	public final class Point3
	{
		public var x : Number = 0;
		public var y : Number = 0;
		public var z : Number = 0;
		
		public function Point3(_x : Number, _y : Number, _z : Number)
		{
			x = _x; y = _y; z = _z;
		}
		
		public function toString() : String { return "x " + x + " y " + y + " z " + z; }
		
		public function Clone() : Point3
		{
			return new Point3(x, y, z);
		}
		
		public function IsEqual(other : Point3) : Boolean
		{
			return x == other.x && y == other.y && z == other.z;
		}
		
		public function Normalize() : void
		{
			var invLength : Number = 1/Math.sqrt(x*x + y*y + z*z);
			
			x *= invLength;
			y *= invLength;
			z *= invLength;
		}
		
		public function Distance(other : Point3) : Number
		{
			return Math.sqrt( (other.x - x)*(other.x - x) + (other.y - y)*(other.y - y) + (other.z - z)*(other.z - z) );  
		}
		
		public function AddToThis(other : Point3) : Point3
		{
			x += other.x;
			y += other.y;
			z += other.z;
			return this;
		}
		
		public function Add(other : Point3) : Point3
		{
			return new Point3(x + other.x, y + other.y, z + other.z);
		}

		public function Substract(other : Point3) : Point3
		{
			return new Point3(x - other.x, y - other.y, z - other.z);
		}
		
		public function GetScaledDirection(secondPoint : Point3, scale : Number) : Point3
		{
			var temp : Point3 = new Point3(secondPoint.x - x, secondPoint.y - y, secondPoint.z - z);
			temp.Normalize();
			temp.x *= scale;
			temp.y *= scale;
			temp.z *= scale;
			return temp;
		}
	}
}
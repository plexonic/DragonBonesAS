package dragonBones.utils
{
	import flash.geom.Matrix;
	
	import dragonBones.objects.DBTransform;
	
	/** @private */
	final public class TransformUtil
	{
		private static const HALF_PI:Number = Math.PI * 0.5;
		private static const DOUBLE_PI:Number = Math.PI * 2;
		
		//private static const _helpMatrix:Matrix = new Matrix();
		
		private static const _helpTransformMatrix:Matrix = new Matrix();
		private static const _helpParentTransformMatrix:Matrix = new Matrix();
		
		/*
		public static function transformPointWithParent(transform:DBTransform, parent:DBTransform):void
		{
			transformToMatrix(parent, _helpMatrix, true);
			_helpMatrix.invert();
			
			var x:Number = transform.x;
			var y:Number = transform.y;
			
			transform.x = _helpMatrix.a * x + _helpMatrix.c * y + _helpMatrix.tx;
			transform.y = _helpMatrix.d * y + _helpMatrix.b * x + _helpMatrix.ty;
			
			transform.skewX = formatRadian(transform.skewX - parent.skewX);
			transform.skewY = formatRadian(transform.skewY - parent.skewY);
		}
		*/
		public static function transformToMatrix(transform:DBTransform, matrix:Matrix, keepScale:Boolean = false):void
		{
			if(keepScale)
			{
				matrix.a = transform.scaleX * Math.cos(transform.skewY)
				matrix.b = transform.scaleX * Math.sin(transform.skewY)
				matrix.c = -transform.scaleY * Math.sin(transform.skewX);
				matrix.d = transform.scaleY * Math.cos(transform.skewX);
				matrix.tx = transform.x;
				matrix.ty = transform.y;
			}
			else
			{
				matrix.a = Math.cos(transform.skewY)
				matrix.b = Math.sin(transform.skewY)
				matrix.c = -Math.sin(transform.skewX);
				matrix.d = Math.cos(transform.skewX);
				matrix.tx = transform.x;
				matrix.ty = transform.y;
			}
		}
		
		public static function formatRadian(radian:Number):Number
		{
			//radian %= DOUBLE_PI;
			if (radian > Math.PI)
			{
				radian -= DOUBLE_PI;
			}
			if (radian < -Math.PI)
			{
				radian += DOUBLE_PI;
			}
			return radian;
		}
		
		public static function globalToLocal(transform:DBTransform, parent:DBTransform):void
		{
			transformToMatrix(transform, _helpTransformMatrix, true);
			transformToMatrix(parent, _helpParentTransformMatrix, true);
			
			_helpParentTransformMatrix.invert();
			_helpTransformMatrix.concat(_helpParentTransformMatrix);
			
			matrixToTransform(_helpTransformMatrix, transform, transform.scaleX * parent.scaleX >= 0, transform.scaleY * parent.scaleY >= 0);
		}

		//@daal was here :) some optimiziation done
		public static function matrixToTransform(matrix:Matrix, transform:DBTransform, scaleXF:Boolean, scaleYF:Boolean):void
		{
			transform.x = matrix.tx;
			transform.y = matrix.ty;
			transform.scaleX = Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b) * (scaleXF ? 1 : -1);
			transform.scaleY = Math.sqrt(matrix.d * matrix.d + matrix.c * matrix.c) * (scaleYF ? 1 : -1);
			
			var skew:Array = new Array(4);
			skew[0] = Math.acos(matrix.d / transform.scaleY);
			skew[1] = -skew[0];
			skew[2] = Math.asin(-matrix.c / transform.scaleY);
			skew[3] = skew[2] >= 0 ? Math.PI - skew[2] : skew[2] - Math.PI;
			var skewXArray0Fixed : Number = skew[0].toFixed(4);

			if(skewXArray0Fixed == skew[2].toFixed(4) || skewXArray0Fixed == skew[3].toFixed(4))
			{
				transform.skewX = skew[0];
			}
			else
			{
				transform.skewX = skew[1];
			}

			skew[0] = Math.acos(matrix.a / transform.scaleX);
			skew[1] = -skew[0];
			skew[2] = Math.asin(matrix.b / transform.scaleX);
			skew[3] = skew[2] >= 0 ? Math.PI - skew[2] : skew[2] - Math.PI;
			var skewYArray0Fixed : Number = skew[0].toFixed(4);
			
			if(skewYArray0Fixed == skew[2].toFixed(4) || skewYArray0Fixed == skew[3].toFixed(4))
			{
				transform.skewY = skew[0];
			}
			else 
			{
				transform.skewY = skew[1];
			}
			
		}
	}
	
}
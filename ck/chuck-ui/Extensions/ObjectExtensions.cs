using System;
public static class ObjectExtensions {
	public static bool IsType<T>(this object obj) where T : IConvertible {
		return obj != null && obj.GetType().GetGenericTypeDefinition() == typeof(T);
	}

	public static T ConvertTo<T>(this object obj) where T : IConvertible {
		return obj != null && obj.IsType<T>() 
			? (T)Convert.ChangeType(obj, typeof(T)) 
			: default(T);
	}
}

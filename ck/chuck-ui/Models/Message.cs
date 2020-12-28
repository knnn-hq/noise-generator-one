using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;

public class Message {
	public IPEndPoint Sender { get; set; }
	public string Path { get; set; }
	public object[] Args { get; set; }
	public int NumArgs => Args?.Length ?? 0;

	/**
	 *
	 */
	public IEnumerable<T> GetAllArgsOfType<T>() where T : IConvertible {
		return NumArgs > 0 
			? Args.Where(a => a.IsType<T>()).Select(a => a.ConvertTo<T>()) 
			: new T[] {};
	}
	public T GetFirstArgOfType<T>() where T : IConvertible {
		return GetAllArgsOfType<T>().FirstOrDefault();
	}
}

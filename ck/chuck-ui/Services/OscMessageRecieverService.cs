using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Haukcode.Osc;
using Microsoft.Extensions.Configuration;

public class OscMessageRecieverService : IMessageRecieverService {
	private readonly OscReceiver _receiver;
	private readonly Thread _thread;
	private readonly IConfiguration _config;
	private readonly IConfigurationSection _configSection;
	private readonly int _port;

	private readonly ConcurrentQueue<OscMessage> _messages = new ConcurrentQueue<OscMessage>();
	private readonly ConcurrentQueue<Exception> _exceptions = new ConcurrentQueue<Exception>();
	private void ListenLoop() {
		try {
			while (_receiver.State != OscSocketState.Closed) {
				// if we are in a state to recieve
				if (_receiver.State == OscSocketState.Connected) {
					// get the next message 
					// this will block until one arrives or the socket is closed
					OscPacket packet = _receiver.Receive();

					if (packet is OscMessage msg) {
						_messages.Enqueue(msg);
					} else if (packet is OscBundle bnd) {
						foreach (OscMessage m in bnd) {
							_messages.Enqueue(m);
						}
					}
				}
			}
		}
		catch (Exception ex) {
			if (_receiver.State == OscSocketState.Connected) {
				_exceptions.Enqueue(ex);
			}
		}
	}

	public IEnumerable<Exception> GetExceptions() => _exceptions;
	public IEnumerable<Message> GetQueuedMessages() {
		var msgs = new List<Message>();
		while (!_messages.IsEmpty && _messages.TryDequeue(out OscMessage oscMessage)) {
			msgs.Add(new Message {
				Sender = oscMessage.Origin,
				Path = oscMessage.Address,
				Args = oscMessage.ToArray()
			});
		}

		return msgs;
	}

	public OscMessageRecieverService(IConfiguration config) {
		_config = config;
		_configSection = _config.GetSection("OscServer");
		_port = int.TryParse(_configSection.GetSection("Port").Value, out int port) ? port : 1234;

		try {
			_receiver = new OscReceiver(_port);
			_thread = new Thread(ListenLoop);
			_receiver.Connect();
			_thread.Start();
		} catch (Exception ex) {
			_exceptions.Enqueue(ex);
		}
	}
}

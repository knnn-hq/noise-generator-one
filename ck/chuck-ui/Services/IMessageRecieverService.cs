using System;
using System.Collections.Generic;

public interface IMessageRecieverService {
	IEnumerable<Message> GetQueuedMessages();
	IEnumerable<Exception> GetExceptions();
}

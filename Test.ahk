class bollib {
	Something[]
	{
		get {
			msgbox, Getting %value%
			return this.a
		}
		set {
			msgbox, Setting %value%
			this.a := value
			return this.a
		}
	}
}

b := new bollib
b.something := "awesome"
msgbox, % b.something
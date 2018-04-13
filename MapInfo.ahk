raise(err){
	msgbox, %err%
}

class miEnums {
	static COL_INFO_NAME      := 1
	static COL_INFO_NUM       := 2
	static COL_INFO_TYPE      := 3
	static COL_INFO_WIDTH     := 4
	static COL_INFO_DECPLACES := 5
	static COL_INFO_INDEXED   := 6
	static COL_INFO_EDIT ABLE := 7
	static COL_TYPE := {"CHAR":1, "DECIMAL":2, "INTEGER":3, "SMALLINT":4, "DATE":5, "LOGICAL":6, "GRAPHICAL":7, "FLOAT":8, "TIME": 37, "DATETIME":38}

	
}

class MapInfo {
	new(){
		if !(this.mi := ComObjCreate("MapInfo.Application.x64")) ;64 bit
			this.mi  := ComObjCreate("MapInfo.Application")      ;32 bit
	}
	MIConnect(){
		if !(this.mi := ComObjActive("MapInfo.Application.x64")) ;64 bit
			this.mi  := ComObjActive("MapInfo.Application")      ;32 bit
	}
	
	Windows
	{
		get {
			this._windows = []
			loop, % this.NumWindows()
			{
				this._windows.push(new Window(this.mi,A_Index))
			}
			return this._windows
		}
	}
	
	Tables
	{
		get {
			this._tables = []
			loop, % this.NumTables()
			{
				this._tables.push(new Table(this.mi,this,A_Index))
			}
			return this._tables
		}
	}
	
	class Window {
		new(mi,index){
			this.mi          := mi
			this.application := this.mi ;Alias
			this.index       := index
			this.name        := this.windowinfo(index,1)
		}
	}
	
	class Table {
		new(mi,parent,index){
			this.mi          := mi
			this.index       := index
			this.name        := MapInfo.TableInfo(index,1)
		}
		Columns
		{
			get {
				if this._columns
					return this._columns
				
				this._columns := []
				Loop, % MapInfo.TableInfo(this.name, 8)
				{
					this._columns.push(new Column(this.mi,this,A_Index)
				}
				return this._columns
			}
		}
		class Column {
			new(mi,parent,index){
				this.mi := mi
				this.parent := this
				this.index := index
				this._name := MapInfo.ColumnInfo(this.parent.name,"Col" . index, miEnums.COL_INFO_NAME)
				this._type := this.name := MapInfo.ColumnInfo(this.parent.name,"Col" . index, miEnums.COL_INFO_TYPE)
			}
			_getType(){
				
			}
			name[] {
				get {
					return this._name
				}
				set {
					try {
						cmd := Statement("Alter Table",this.parent.name,"(","Rename",this.name,value,")")
						this.mi.do(cmd)
						this.name := value
					} catch (e) {
						raise(e)
					}
				}
			}
			type[] {
				get {
					return this._type
				}
				set {
					try {
						cmd := Statement("Alter Table",this.parent.name,"(","Modify",this.name,value,")")
						this.mi.do(cmd)
						this._type := value
					} catch (e) {
						raise(e)
					}
				}
			}
		}
		name[] {
			get {
				this._name
			}
			set {
				try {
					this.mi.do("Commit Table " . this.name . " as """ . value . """")
					this._name := value
					return this._name
				} catch (e) {
					raise("Error in Column.SetName()" . e)
				}
			}
		}
		
		Save(asFile:="", interactive:=false){
			cmd := "Commit Table " . this.name . (asFile ? " as " . asFile : "") . (interactive ? " interactive":"")
		}
	}
	
	TableInfo(arg1,arg2){
		cmd = TableInfo(%arg1%,%arg2%)
		this.mi.eval(cmd)
	}
	WindowInfo(arg1,arg2){
		cmd = TableInfo(%arg1%,%arg2%)
		this.mi.eval(cmd)
	}
	NumWindows(){
		cmd = NumWindows()
		this.mi.eval(cmd)
	}
	NumTables(){
		cmd = NumTables()
		this.mi.eval(cmd)
	}
	
}

Statement(params*){
    string:=params[1]
	Loop % params.MaxIndex()-1
		string .= delimiter Trim(params[A_Index+1])
	return string
}

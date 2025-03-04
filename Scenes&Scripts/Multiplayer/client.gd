extends Control
class_name NakamaMultiplayer

var session :NakamaSession = null #This is the Session
var client: NakamaClient  = null #This is the client inside of the session
var socket: NakamaSocket = null #This is the socket, or connection
var createdMatch
var multiplayerBridge

static var Players = {}

signal onStartGame()

#@onready var UsernameText = $Panel/UserAccountText
#@onready var DisplaynameText = $Panel/DisplayNameText
#@onready var LobbynameText = $Panel4/LobbyNameEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	client = Nakama.create_client("defaultkey", "1a72-41-10-6-137.ngrok-free.app", 443, "https")
	##client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http") #httpd ehrn when change to ngrok
	#session = await client.authenticate_email_async("test@gmail.com", "password")
	#socket = Nakama.create_socket_from(client)
	#await socket.connect_async(session)
	#
	#socket.connected.connect(onSocketConnected)
	#socket.closed.connect(onSocketClosed)
	#socket.received_error.connect(onSocketRecievedError)
	#
	#socket.received_match_presence.connect(onMatchPresence)
	#socket.received_match_state.connect(onMatchState)	
#
	#updateUserInfo("test", "testDisplay")
	#var account = await client.get_account_async(session)
	#UsernameText.text = account.user.username
	#DisplaynameText.text = account.user.displayname
	#print(account) 
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func updateUserInfo(username, displayname, avatarurl = "", language = "en", location="eu", timezone="est"):
	await client.update_account_async(session, username, displayname, avatarurl, language, timezone)

func onSocketConnected():
	print("Socket Connected")

func onSocketClosed():
	print("Socket onSocketClosed")

func onSocketRecievedError(err):
	print("Socket onSocketRecievedError" ,  str(err))
	
func onMatchPresence(presence: NakamaRTAPI.MatchPresenceEvent):
	print(presence)
	print("onMatchPresence")
	
func onMatchState(state : NakamaRTAPI.MatchData):
	#print(state)
	#print(state.data)
	print("onMatchState")
	#MultiplayerActionInterpreter.interpretAction(state)
	MultiplayerActionInterpreter.interpretAction()
	
	#$GameManager.add_child(battlegroundScene.instantiate())

func LoginButtonPressed() -> void:
	$TextureRect/UserAccountText.text = "Logging in..."
	$TextureRect/LoginButton.disabled = true
	#client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http") #httpd ehrn when change to ngrok
	session = await client.authenticate_email_async("test@gmail.com", "password")
	
	#session = await client.authenticate_email_async($Panel2/EmailInput.text,$Panel2/PasswordInput.text)
#	
	socket = Nakama.create_socket_from(client)
	await socket.connect_async(session)
	
	socket.connected.connect(onSocketConnected)
	socket.closed.connect(onSocketClosed)
	socket.received_error.connect(onSocketRecievedError)
	
	socket.received_match_presence.connect(onMatchPresence)
	socket.received_match_state.connect(onMatchState)	

	updateUserInfo("test", "testDisplay")
	var account = await client.get_account_async(session)
	#$UserAccountText.text = account.user.username
	$TextureRect/UserAccountText.text = "Logged in, welcome:"
	$TextureRect/DisplayNameText.text = account.user.display_name
	
	setupMultiplayerBridge()
	
	#MatchStats.myName = $Panel/UserAccountText.text
	print(account) 

func setupMultiplayerBridge():
	multiplayerBridge = NakamaMultiplayerBridge.new(socket)
	multiplayerBridge.match_join_error.connect(onMatchJoinedError)
	var multiplayer = get_tree().get_multiplayer()
	multiplayer.set_multiplayer_peer(multiplayerBridge.multiplayer_peer)
	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)
	
func onPeerDisconnected(id):
	print("Peer disconnected id is: ", str(id))

func onPeerConnected(id):
	print("Peer connected id is: ", str(id))
	if !Players.has(id):
		Players[id] = {
			"name": id,
			"ready": 0
		}
	if Players.has(multiplayer.get_unique_id()):
		Players[multiplayer.get_unique_id()] = {
			"name": multiplayer.get_unique_id(),
			"ready": 0
		}

func onMatchJoinedError(err):
	print("Unable to join match", str(err.message))

func onMatchJoin():
	print("Joined Match with id: ", multiplayerBridge.match_id)
	
func StoreData() -> void:
	var saveData = {
		"name": "username",
		"decks" : [{
			"id": 1,
			"name": "GreenStarterDeck",
			"cards": ["default_card_001","default_card_001","default_card_001","default_card_001","default_card_001","default_card_001","default_card_001","default_card_001"]
		},{
			"id": 2,
			"name": "BlueStarterDeck",
			"cards": ["default_card_001","default_card_001","default_card_001","default_card_001","default_card_001","default_card_001","default_card_001"]
		}],
		"level":10,
		"coins":10,
		"gems":5
	}
	
	var data = JSON.stringify(saveData)
	var result = await client.write_storage_objects_async(session, [NakamaWriteStorageObject.new("saves", "savegame", 1, 1 , data, "")] )
	#Saves is the "Collection" of data. and "savegame" is the name of the object or name of the saved data in Collection.
	
	if result.is_exception():
		print("error", str(result))
		return
	
	print("Stored data successfully!")

func GetData() -> void:
	var result = await client.read_storage_objects_async(session, [
		NakamaStorageObjectId.new("saves", "savegame", session.user_id)
	])
	
	if result.is_exception():
		print("error", str(result))
		return
	
	for i in result.objects:
		print("Value in result is :", "\n", (i.value))
		
	pass # Replace with function body.


func ListData() -> void:
	
	var dataList = await client.list_storage_objects_async(session, "saves", session.user_id, 5) #limits to 5 records
	
	for i in dataList.objects:
		print("listing game object" , i)
	pass

func CreateLobby() -> void:
	multiplayerBridge.join_named_match($Panel4/LobbyNameEdit.text)
	#createdMatch = await socket.create_match_async(LobbynameText.text)
	#if createdMatch.is_exception():
		#print("Failed to create/join match: ", str(createdMatch))
		#return
	#
	#print("Created match: ", str(createdMatch.match_id))


#func PingLobby(data: Dictionary = {}) -> void:
	## If no data is provided, send default "hello world" message
	#if data.is_empty():
		#data = {"hello": "world"}
	#
	## Send the match state with a code (1)
	#socket.send_match_state_async(createdMatch.match_id, 1, JSON.stringify(data))
	
	
		#sendData.rpc("Hello World!")
	#print("Created Match ID :" , MatchStats.matchID)
	#var data = {"hello" : "world"}
	#var gameID = MatchStats.getMatchID()
	#printEverything()
	##print("My socket is: ", socket)
	#socket.send_match_state_async(gameID, 1, JSON.stringify(data))
	#pass # Replace with function body.

func PingLobby(data: Dictionary = {}, op_code: int = 2) -> void:
	
	# Ensure we always send some data
	if data.is_empty():
		data = {"message": "default_ping"}
	
	# Send the match state with the provided or default op_code
	socket.send_match_state_async(createdMatch.match_id, op_code, JSON.stringify(data))

@rpc("any_peer")
func sendData(message):
	print(message)

func StartMatchmaking() -> void:
	var query = "+properties.region:US +properties.rank:>=4 +properties.rank:<=10"
	#var query = "*"
	var stringP = {"region":"US"}
	var numberP = {"rank": 6}
	
	var ticket = await socket.add_matchmaker_async(query, 2, 2, stringP, numberP)
	#var ticket = await socket.add_matchmaker_async(query, 2, 4)
	
	
	if ticket.is_exception():
		print("Failed to matchmake, error: ", str(ticket))
		return
	
	print("Match ticket number : ", str(ticket))
	
	socket.received_matchmaker_matched.connect(onMatchMakerMatched)
	
	pass # Replace with function body.

func onMatchMakerMatched(matched: NakamaRTAPI.MatchmakerMatched):
	var joinedMatch = await socket.join_matched_async(matched)
	createdMatch = joinedMatch
	print("createdMatch assigned in THIS script:", createdMatch)
	#MatchStats.setMatchID(joinedMatch.match_id)
	#var myname = MatchStats.myName
	
	
	print("Match Found! : ", (joinedMatch))
	print("Created Match :" , createdMatch)
	$Panel.visible = false
	$Panel2.visible = false
	$Panel3.visible = false
	$Panel4.visible = false
	
	
	#print("Here: ", myname, " & ", joinedMatch.presences , " & " , joinedMatch.presences == [])
	#if !joinedMatch.presences == []:
		#typeof(joinedMatch.presences)
		#MatchStats.addPlayer(joinedMatch.presences[0]["username"])
		
	GetUserAccount()
	
	#MultiplayerActionInterpreter
	
	StartGameLogic()
	pass

func StartGame() -> void: #Button
	Ready.rpc(multiplayer.get_unique_id())
	pass # Replace with function body.

@rpc("any_peer","call_local")
func Ready(id):
	Players[id].ready = 1
	
	if multiplayer.is_server():
		var readyPlayers = 0
		for i in Players:
			if Players[i].ready == 1:
				readyPlayers += 1
		
		if readyPlayers == Players.size():
			StartGameLogic.rpc()

@rpc("any_peer","call_local")
func StartGameLogic() -> void:
	onStartGame.emit()
	
	#$GameManager.add_child(battlegroundScene.instantiate())
	#hide()
	pass # Re

func GetUserAccount():
	var account = await client.get_account_async(session)
	var username = account.user.username
	var avatar_url = account.user.avatar_url
	var user_id = account.user.id
	
	return account
	print("My username is: ", username)

func printEverything():
	print("print everuythng")
	print(socket)
	print(createdMatch)
	print("createdMatch value:", createdMatch)
	print("Instance ID:", self.get_instance_id())

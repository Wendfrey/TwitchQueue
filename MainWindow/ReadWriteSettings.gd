extends Node

var current_settings: Dictionary;

func _ready():
	current_settings = read_settings_file()

func read_settings_file() -> Dictionary:
	var settings_file: File = File.new()
	assert(settings_file.open(ProjectSettings.get_setting("global/conf_filename"), File.READ) == OK)
	
	var jsonResult: JSONParseResult = JSON.parse(settings_file.get_as_text())
	settings_file.close()
	assert(jsonResult.error == OK, "Error {eCode}: {msg} en la linea {ln}".format({code=jsonResult.error, msg = jsonResult.error_string, ln = jsonResult.error_line}))
	
	return jsonResult.result

func write_settings_file():
	var settings_file: File = File.new()
	assert(settings_file.open(ProjectSettings.get_setting("global/conf_filename"), File.WRITE) == OK)
	settings_file.store_string(JSON.print(current_settings, "\t"))
	settings_file.flush()
	settings_file.close()
